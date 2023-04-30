import requests
import subprocess
from urllib.request import urlretrieve
import difflib

sech_key = "https://p2pool.io/SChernykh.asc"
sech_key_backup = "https://raw.githubusercontent.com/monero-project/gitian.sigs/master/gitian-pubkeys/SChernykh.asc"
sech_key_fp = "1FCA AB4D 3DC3 310D 16CB  D508 C47F 82B5 4DA8 7ADF"

p2pool_files = [{
                    "os": "WIN",
                    "filename": "windows-x64.zip",
                },
                {
                    "os": "LINUX",
                    "filename": "linux-x64.tar.gz"
                },
                {
                    "os": "MACOS_AARCH64",
                    "filename": "macos-aarch64.tar.gz",
                },
                {
                    "os": "MACOS",
                    "filename": "macos-x64.tar.gz",
                }]

def get_hash(fname):
    fhash = subprocess.check_output(["sha256sum", fname]).decode("utf-8")
    print(fhash.strip())
    return fhash.split()[0]

def main():
    global p2pool_files, sech_key, sech_key_backup, sech_key_fp
    p2pool_tag_api = "https://api.github.com/repos/SChernykh/p2pool/releases/latest"
    data = requests.get(p2pool_tag_api).json()
    tag = data["tag_name"]
    head = f"p2pool-{tag}-"
    url = f"https://github.com/SChernykh/p2pool/releases/download/{tag}/"

    try:
        urlretrieve(sech_key,"SChernykh.asc")
    except:
        urlretrieve(sech_key_backup,"SChernykh.asc")

    urlretrieve(f"{url}sha256sums.txt.asc","sha256sums.txt.asc")

    subprocess.check_call(["gpg", "--import", "SChernykh.asc"])
    subprocess.check_call(["gpg", "--verify", "sha256sums.txt.asc"])    
    fingerprint = subprocess.check_output(["gpg","--fingerprint", "SChernykh"]).decode("utf-8").splitlines()[1].strip()
    
    assert fingerprint == sech_key_fp
    
    with open("sha256sums.txt.asc","r") as f:
        lines = f.readlines()

    signed_hashes = {}
    for line in lines:
        if "Name:" in line:
            signed_fname = line.split()[1]
        if "SHA256:" in line:
            signed_hashes[signed_fname] = line.split()[1].lower()

    expected = ""
    for i in range(len(p2pool_files)):
        fname = p2pool_files[i]["filename"]
        str_os =p2pool_files[i]["os"]
        dl = f"{url}{head}{fname}"
        urlretrieve(dl,f"{head}{fname}")
        fhash = get_hash(f"{head}{fname}")
        assert signed_hashes[f"{head}{fname}"] == fhash
        if i == 0:
            expected += f"        #ifdef Q_OS_{str_os}\n"
        else:
            expected += f"        #elif defined(Q_OS_{str_os})\n"
        expected += f"            url = \"https://github.com/SChernykh/p2pool/releases/download/{tag}/{head}{fname}\";\n"
        expected += f"            fileName = m_p2poolPath + \"/{head}{fname}\";\n"
        expected += f"            validHash = \"{fhash}\";\n"
    expected += "        #endif\n"

    print(f"Expected:\n{expected}")

    with open("src/p2pool/P2PoolManager.cpp","r") as f:
        p2pool_lines = f.readlines()

    unexpected = ""
    ignore = 1
    for line in p2pool_lines:
        if ignore == 0:
            unexpected += line
        if "QString validHash;" in line:
            ignore = 0
        if "#endif" in line and ignore == 0:
            break

    d = difflib.Differ()
    diff = d.compare(str(unexpected).splitlines(True),str(expected).splitlines(True))

    print("Unexpected:")
    for i in diff:
        if i.startswith("?"):
            continue
        print(i.replace("\n",""))

    assert unexpected == expected

if __name__ == "__main__":
    main()
