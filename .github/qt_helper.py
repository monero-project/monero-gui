#!/usr/bin/env python3
import argparse
import fnmatch
import hashlib
import pathlib
import subprocess
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

MAX_TRIES = 32
MAX_XML_SIZE = 1024 * 1024 * 1024
MIRROR = 'download.qt.io'


def fetch_links_to_archives(host_os, target, major, minor, patch, toolchain, packages):
  qt_dir = f'qt{major}_{major}{minor}{patch}'
  base_url = f'https://{MIRROR}/online/qtsdkrepository/{host_os}/{target}/{qt_dir}/{qt_dir}'
  url = f'{base_url}/Updates.xml'
  print('fetching', url, flush=True)

  for _ in range(MAX_TRIES):
    try:
      with urllib.request.urlopen(url, timeout=30) as response:
        resp = response.read(MAX_XML_SIZE + 1)
      if len(resp) > MAX_XML_SIZE:
        raise RuntimeError(f'{url} exceeds the {MAX_XML_SIZE}-byte size limit')
      update_xml = ET.fromstring(resp)
      break
    except KeyboardInterrupt:
      raise
    except Exception as e:
      print('error', e, flush=True)
  else:
    raise RuntimeError(f'Failed to fetch {url} after {MAX_TRIES} attempts')

  package_prefix = f'qt.qt{major}.{major}{minor}{patch}'
  package_names = {
    f'{package_prefix}.{package}.{toolchain}' if package else f'{package_prefix}.{toolchain}'
    for package in packages
  }

  found_packages = set()
  for pkg in update_xml.findall('./PackageUpdate'):
    name = pkg.find('.//Name')
    if name is None:
      continue
    if name.text not in package_names:
      continue
    found_packages.add(name.text)
    version = pkg.find('.//Version')
    if version is None:
      continue
    archives = pkg.find('.//DownloadableArchives')
    if archives is None or archives.text is None:
      continue
    for archive in archives.text.split(', '):
      archive = archive.strip()
      if not archive:
        continue
      url = f'{base_url}/{name.text}/{version.text}{archive}'
      file_name = pathlib.Path(urllib.parse.urlparse(url).path).name
      yield {'name': file_name, 'url': url, 'archive': archive}

  missing_packages = package_names - found_packages
  if missing_packages:
    raise RuntimeError(f'Qt packages not found: {", ".join(sorted(missing_packages))}')


def download(links):
  metalink = ET.Element('metalink', xmlns='urn:ietf:params:xml:ns:metalink')
  for link in links:
    file = ET.SubElement(metalink, 'file', name=link['name'])
    ET.SubElement(file, 'url').text = link['url']

  data = ET.tostring(metalink, encoding='UTF-8', xml_declaration=True)

  for _ in range(MAX_TRIES):
    result = subprocess.run([
      'aria2c',
      '--connect-timeout=8',
      '--console-log-level=warn',
      '--continue',
      '--follow-metalink=mem',
      '--max-concurrent-downloads=100',
      '--max-connection-per-server=16',
      '--max-file-not-found=100',
      '--max-tries=100',
      '--min-split-size=1MB',
      '--retry-wait=1',
      '--split=100',
      '--summary-interval=0',
      '--timeout=8',
      '--user-agent=',
      '--metalink-file=-',
    ], input=data, check=False)
    if result.returncode == 0:
      return True

  return False


def file_hash(path):
  digest = hashlib.sha256()
  with open(path, 'rb') as file:
    for chunk in iter(lambda: file.read(1024 * 1024), b''):
      digest.update(chunk)
  return digest.digest()


def calc_hash_sum(files):
  digest = hashlib.sha256()
  for path in files:
    digest.update(file_hash(path))
  return digest.hexdigest()


def extract_archives(files, out='.', targets=()):
  for path in files:
    print('extracting', path, flush=True)
    result = subprocess.run(
      ['bsdtar', '-xf', path, '-C', out, *targets],
      stdout=subprocess.DEVNULL,
      check=False,
    )
    if result.returncode != 0:
      return False
  return True


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument('os')
  parser.add_argument('target')
  parser.add_argument('version')
  parser.add_argument('toolchain')
  parser.add_argument('expect')
  parser.add_argument('--add-package', action='append', default=[],
                      help='additional package below qt.qt<major>.<version>, such as addons.qtshadertools')
  parser.add_argument('--archive', action='append', default=[],
                      help='fnmatch pattern selecting archives from the requested packages')
  args = parser.parse_args()

  host_os, target, version, toolchain, expect = (
    args.os, args.target, args.version, args.toolchain, args.expect
  )
  major, minor, patch = version.split('.')

  packages = [''] + args.add_package
  links = list(fetch_links_to_archives(
    host_os, target, major, minor, patch, toolchain, packages
  ))
  if args.archive:
    links = [
      link for link in links
      if any(fnmatch.fnmatch(link['archive'], pattern) for pattern in args.archive)
    ]
  if not links:
    raise RuntimeError('No Qt archives matched')
  print(*(link['url'] for link in links), sep='\n', flush=True)

  if not download(links):
    raise RuntimeError('Failed to download Qt archives')

  archive_names = [link['name'] for link in links]
  result = calc_hash_sum(archive_names)
  print('result', result, 'expect', expect, flush=True)
  if expect != '-' and result != expect:
    raise RuntimeError(f'Qt archive hash mismatch: expected {expect}, got {result}')

  if not extract_archives(archive_names):
    raise RuntimeError('Failed to extract Qt archives')

  for archive_name in archive_names:
    pathlib.Path(archive_name).unlink()


if __name__ == '__main__':
  main()
