#!/usr/bin/env python3
import defusedxml.ElementTree
import hashlib
import mmap
import pathlib
import subprocess
import sys
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET

MAX_TRIES = 32

def fetch_links_to_archives(os, target, major, minor, patch, toolchain):
  MAX_XML_SIZE = 1024 * 1024 * 1024
  MIRROR = 'download.qt.io'
  base_url = f'https://{MIRROR}/online/qtsdkrepository/{os}/{target}/qt{major}_{major}{minor}{patch}'
  url = f'{base_url}/Updates.xml'
  for _ in range(MAX_TRIES):
    try:
      resp = urllib.request.urlopen(url).read(MAX_XML_SIZE)
      update_xml = defusedxml.ElementTree.fromstring(resp)
      break
    except KeyboardInterrupt:
      raise
    except BaseException as e:
      print('error', e, flush=True)
  else:
    return
  for pkg in update_xml.findall('./PackageUpdate'):
    name = pkg.find('.//Name')
    if name == None:
      continue
    if name.text != f'qt.qt{major}.{major}{minor}{patch}.{toolchain}':
      continue
    version = pkg.find('.//Version')
    if version == None:
      continue
    archives = pkg.find('.//DownloadableArchives')
    if archives == None or archives.text == None:
      continue
    for archive in archives.text.split(', '):
      url = f'{base_url}/{name.text}/{version.text}{archive}'
      file_name = pathlib.Path(urllib.parse.urlparse(url).path).name
      yield {'name': file_name, 'url': url}

def download(links):
  metalink = ET.Element('metalink', xmlns = "urn:ietf:params:xml:ns:metalink")
  for link in links:
    file = ET.SubElement(metalink, 'file', name = link['name'])
    ET.SubElement(file, 'url').text = link['url']
  data = ET.tostring(metalink, encoding='UTF-8', xml_declaration=True)
  for _ in range(MAX_TRIES):
    with subprocess.Popen([
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
    ], stdin=subprocess.PIPE) as aria:
      aria.communicate(data)
      if aria.wait() == 0:
        return True
  return False

def calc_hash_sum(files):
  obj = hashlib.new('sha256')
  for path in files:
    with open(path, 'rb') as f:
      with mmap.mmap(f.fileno(), 0, mmap.MAP_SHARED, mmap.PROT_READ) as m:
        file_hash = hashlib.new('sha256', m).digest()
        obj.update(file_hash)
  return obj.digest().hex()

def extract_archives(files, out='.', targets=[]):
  for path in files:
    if subprocess.Popen(['7z', 'x', '-bd', '-y', '-aoa', f'-o{out}', path] + targets,
      stdout=subprocess.DEVNULL,
    ).wait() != 0:
      return False
  return True

def main():
  os, target, version, toolchain, expect = sys.argv[1:]
  major, minor, patch = version.split('.')
  links = [*fetch_links_to_archives(os, target, major, minor, patch, toolchain)]
  print(*[l['url'].encode() for l in links], sep='\n', flush=True)
  assert download(links)
  result = calc_hash_sum([l['name'] for l in links])
  print('result', result, 'expect', expect, flush=True)
  assert result == expect
  assert extract_archives([l['name'] for l in links], '.', ['{}.{}.{}'.format(major, minor, patch)])
  [pathlib.Path(l['name']).unlink() for l in links]

if __name__ == '__main__':
  main()
