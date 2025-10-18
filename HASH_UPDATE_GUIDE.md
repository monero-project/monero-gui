# How to Update i2pd SHA256 Hashes

## Current Status

The `I2PManager.cpp` file currently contains **placeholder hashes** that need to be replaced with real SHA256 checksums before the implementation can be safely used in production.

## Why This Matters

Hash verification ensures that downloaded i2pd binaries haven't been tampered with. Without correct hashes:
- ❌ Downloads could be compromised
- ❌ Users could receive malicious binaries
- ❌ Security vulnerability in the implementation

## Files to Download

You need to download these exact files from i2pd releases:

1. **Windows (MinGW)**
   - URL: `https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_win64_mingw.zip`
   - Platform: Windows x64
   - Size: ~2-3 MB

2. **Linux (x86_64)**
   - URL: `https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_linux_amd64.tar.gz`
   - Platform: Linux x86_64
   - Size: ~2-3 MB

3. **macOS (Intel)**
   - URL: `https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_macos.tar.gz`
   - Platform: macOS x86_64
   - Size: ~2-3 MB

4. **macOS (Apple Silicon)**
   - URL: `https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_macos_arm64.tar.gz`
   - Platform: macOS ARM64
   - Size: ~2-3 MB

## How to Calculate SHA256 Hashes

### On Windows (PowerShell):
```powershell
# Download the files first
cd Downloads

# Calculate SHA256 for each file
Get-FileHash i2pd_2.54.0_win64_mingw.zip -Algorithm SHA256
Get-FileHash i2pd_2.54.0_linux_amd64.tar.gz -Algorithm SHA256
Get-FileHash i2pd_2.54.0_macos.tar.gz -Algorithm SHA256
Get-FileHash i2pd_2.54.0_macos_arm64.tar.gz -Algorithm SHA256
```

### On Linux/macOS (Terminal):
```bash
# Download the files first
cd ~/Downloads

# Calculate SHA256 for each file
sha256sum i2pd_2.54.0_win64_mingw.zip
sha256sum i2pd_2.54.0_linux_amd64.tar.gz
sha256sum i2pd_2.54.0_macos.tar.gz
sha256sum i2pd_2.54.0_macos_arm64.tar.gz
```

## Where to Update in Code

**File:** `src/i2p/I2PManager.cpp`  
**Function:** `QString I2PManager::getExpectedHash() const`  
**Lines:** ~155-170

### Current Code (PLACEHOLDERS):
```cpp
QString I2PManager::getExpectedHash() const
{
    // SHA256 hashes for i2pd v2.54.0
    // TODO: Update these with real hashes from i2pd releases
    
#ifdef Q_OS_WIN
    return "e3f8a7c2b9d1f6e5a4c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9f8e7d6c5b4a3b2a1"; // TODO: Update with real hash
#elif defined(Q_OS_MACOS)
    return "a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2"; // TODO: Update with real hash
#elif defined(Q_OS_LINUX)
    return "b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3"; // TODO: Update with real hash
#else
    return "c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4"; // TODO: Update with real hash
#endif
}
```

### Expected Code (EXAMPLE - Replace with real hashes):
```cpp
QString I2PManager::getExpectedHash() const
{
    // SHA256 hashes for i2pd v2.54.0
    // Verified from official i2pd GitHub releases
    
#ifdef Q_OS_WIN
    return "ACTUAL_WINDOWS_SHA256_HERE"; // Windows MinGW x64
#elif defined(Q_OS_MACOS)
    #ifdef __aarch64__
    return "ACTUAL_MACOS_ARM64_SHA256_HERE"; // macOS Apple Silicon
    #else
    return "ACTUAL_MACOS_X64_SHA256_HERE"; // macOS Intel
    #endif
#elif defined(Q_OS_LINUX)
    return "ACTUAL_LINUX_SHA256_HERE"; // Linux x86_64
#else
    return ""; // Unsupported platform
#endif
}
```

## Step-by-Step Process

### 1. Download All Binaries
```powershell
# Create temporary directory
mkdir i2pd_hashes
cd i2pd_hashes

# Download all 4 files
Invoke-WebRequest -Uri "https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_win64_mingw.zip" -OutFile "i2pd_win.zip"
Invoke-WebRequest -Uri "https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_linux_amd64.tar.gz" -OutFile "i2pd_linux.tar.gz"
Invoke-WebRequest -Uri "https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_macos.tar.gz" -OutFile "i2pd_macos_x64.tar.gz"
Invoke-WebRequest -Uri "https://github.com/PurpleI2P/i2pd/releases/download/2.54.0/i2pd_2.54.0_macos_arm64.tar.gz" -OutFile "i2pd_macos_arm64.tar.gz"
```

### 2. Calculate All Hashes
```powershell
# Calculate hashes
Write-Host "Windows SHA256:"
(Get-FileHash i2pd_win.zip -Algorithm SHA256).Hash.ToLower()

Write-Host "`nLinux SHA256:"
(Get-FileHash i2pd_linux.tar.gz -Algorithm SHA256).Hash.ToLower()

Write-Host "`nmacOS x64 SHA256:"
(Get-FileHash i2pd_macos_x64.tar.gz -Algorithm SHA256).Hash.ToLower()

Write-Host "`nmacOS ARM64 SHA256:"
(Get-FileHash i2pd_macos_arm64.tar.gz -Algorithm SHA256).Hash.ToLower()
```

### 3. Update I2PManager.cpp

Replace the placeholder hashes in `getExpectedHash()` function with the real ones you calculated.

### 4. Update macOS Architecture Detection

You may also need to improve the macOS architecture detection:

```cpp
#elif defined(Q_OS_MACOS)
    #if defined(__aarch64__) || defined(__arm64__)
    return "MACOS_ARM64_HASH_HERE"; // Apple Silicon
    #else
    return "MACOS_X64_HASH_HERE"; // Intel Mac
    #endif
```

### 5. Commit Changes
```bash
git add src/i2p/I2PManager.cpp
git commit -m "feat: Add real SHA256 hashes for i2pd 2.54.0 binaries"
```

## Verification

After updating, test the hash verification:

1. Try downloading i2pd through the GUI
2. Check that it verifies successfully
3. Try with a corrupted file (should fail)

## Alternative: Official Checksums

Check if i2pd releases provide an official checksums file:
- Look in release assets for `checksums.txt` or `SHA256SUMS`
- If available, use those official hashes
- Cross-verify with your own calculations

## Security Notes

⚠️ **IMPORTANT:**
- Always download from official i2pd GitHub releases
- Never trust hashes from third-party sources
- Verify hashes match across multiple sources if possible
- Consider GPG signature verification if available

## Current Implementation Status

- ✅ Hash verification code implemented
- ✅ Error handling for mismatches
- ⏳ **Real hashes NOT YET ADDED (placeholders only)**
- ⏳ Hash verification currently DISABLED in code (line ~247-254)

**Lines ~247-254 in I2PManager.cpp:**
```cpp
// TODO: Re-enable hash verification once we have correct hashes
/*
if (hash != expectedHash) {
    emit errorOccurred("Hash verification failed");
    emit downloadFinished(false);
    return;
}
*/
```

## Next Steps

1. ✅ Download all 4 i2pd binaries
2. ✅ Calculate SHA256 hashes
3. ✅ Update `I2PManager.cpp` with real hashes
4. ✅ Remove the TODO comments
5. ✅ Re-enable hash verification (uncomment lines ~250-254)
6. ✅ Test download functionality
7. ✅ Commit changes

## Estimated Time

⏱️ **15-30 minutes** (depending on download speeds)

---

**Status:** ⏳ **REQUIRED BEFORE PRODUCTION USE**  
**Priority:** 🔴 **HIGH** (Security critical)  
**Assigned:** Shadeeeloveer  
**Tracking:** Week 2 tasks

---

*Last Updated: October 17, 2025*
