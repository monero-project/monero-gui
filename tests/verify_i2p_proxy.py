import socket
import socks # Requires: pip install PySocks
import requests

def test_i2p_connection():
    print("[-] Testing I2P Proxy Connection...")
    
    # Configure requests to use the local I2P proxy
    proxies = {
        'http': 'socks5h://127.0.0.1:4447',
        'https': 'socks5h://127.0.0.1:4447'
    }
    
    # Target: A known stable I2P site (e.g., i2pproject.i2p or a monero node)
    target_url = "http://i2p-projekt.i2p" 
    
    try:
        print(f"[-] Attempting to reach {target_url} via proxy...")
        response = requests.get(target_url, proxies=proxies, timeout=30)
        
        if response.status_code == 200:
            print("[+] SUCCESS: Connected to I2P network!")
            print(f"[+] Response size: {len(response.content)} bytes")
            return True
        else:
            print(f"[!] FAILED: HTTP {response.status_code}")
            return False
            
    except Exception as e:
        print(f"[!] ERROR: Connection failed. Is the I2P router running?")
        print(f"[!] Details: {e}")
        return False

if __name__ == "__main__":
    test_i2p_connection()
