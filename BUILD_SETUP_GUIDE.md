# Monero GUI Build Environment Setup - Windows

**Goal**: Set up a complete build environment to compile Monero GUI with I2P integration

**Platform**: Windows 10/11
**Build System**: MSYS2 (MinGW-w64)
**Estimated Time**: 30-60 minutes (mostly downloads)

---

## Step 1: Install MSYS2

### Download MSYS2

1. Go to: **https://www.msys2.org/**
2. Download the installer: `msys2-x86_64-latest.exe`
3. Run the installer
4. Install to: `C:\msys64` (default location - recommended)
5. Check "Run MSYS2 now" at the end

### Initial Update

After installation opens, run these commands in the MSYS2 terminal:

```bash
# Update package database and core packages
pacman -Syu
```

**IMPORTANT**: This will close the terminal. That's normal!

Reopen MSYS2 (Start Menu → MSYS2 MSYS) and run:

```bash
# Update remaining packages
pacman -Su
```

---

## Step 2: Install Build Dependencies

**Open "MSYS2 MinGW 64-bit"** from Start Menu (NOT "MSYS2 MSYS"!)

Run these commands to install all required packages:

```bash
# Install toolchain (compiler, linker, etc.)
pacman -S --needed mingw-w64-x86_64-toolchain

# Install build tools
pacman -S --needed mingw-w64-x86_64-cmake
pacman -S --needed mingw-w64-x86_64-ninja
pacman -S --needed make
pacman -S --needed git

# Install Qt5 (GUI framework)
pacman -S --needed mingw-w64-x86_64-qt5-base
pacman -S --needed mingw-w64-x86_64-qt5-declarative
pacman -S --needed mingw-w64-x86_64-qt5-graphicaleffects
pacman -S --needed mingw-w64-x86_64-qt5-quickcontrols
pacman -S --needed mingw-w64-x86_64-qt5-quickcontrols2
pacman -S --needed mingw-w64-x86_64-qt5-svg
pacman -S --needed mingw-w64-x86_64-qt5-xmlpatterns
pacman -S --needed mingw-w64-x86_64-qt5-tools

# Install Boost libraries
pacman -S --needed mingw-w64-x86_64-boost

# Install cryptography libraries
pacman -S --needed mingw-w64-x86_64-libsodium
pacman -S --needed mingw-w64-x86_64-hidapi
pacman -S --needed mingw-w64-x86_64-unbound

# Install compression libraries
pacman -S --needed mingw-w64-x86_64-zlib
pacman -S --needed mingw-w64-x86_64-libzip

# Install protobuf (for Ledger support)
pacman -S --needed mingw-w64-x86_64-protobuf
pacman -S --needed mingw-w64-x86_64-protobuf-c

# Install pkg-config
pacman -S --needed mingw-w64-x86_64-pkg-config
```

**This will download ~2-3 GB of packages. Go grab a coffee! ☕**

---

## Step 3: Verify Installation

After installation completes, verify everything is installed:

```bash
# Check GCC compiler
gcc --version

# Check CMake
cmake --version

# Check Qt
qmake --version

# Check Git
git --version
```

Expected output should show versions (e.g., gcc 13.x, cmake 3.x, Qt 5.15.x)

---

## Step 4: Navigate to Monero GUI

In the same MSYS2 MinGW 64-bit terminal:

```bash
# Navigate to your monero-gui directory
cd /c/Users/goldie/Downloads/mr\ krabs/monero-gui

# Verify you're on the right branch
git branch

# Should show: * feature/i2p-binary-manager

# Check submodule status
git submodule status
```

---

## Step 5: Initialize Submodules (If Needed)

If submodules aren't initialized yet:

```bash
# Initialize all submodules (monero core + dependencies)
git submodule update --init --recursive
```

**This downloads monero core (~200 MB). This may take 5-10 minutes.**

---

## Step 6: Build Monero GUI

### Option A: Full Release Build (Recommended)

```bash
# Clean any previous builds
make clean

# Build release version
make release-win64
```

**Expected time**: 30-90 minutes depending on your CPU
- Uses all CPU cores for parallel compilation
- Creates optimized release binary
- Binary location: `build/release/bin/monero-wallet-gui.exe`

### Option B: Quick Debug Build (Faster for testing)

```bash
# Create build directory
mkdir -p build/debug
cd build/debug

# Configure with CMake
cmake -G "MinGW Makefiles" \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_PREFIX_PATH=/mingw64 \
  ../..

# Build (using all CPU cores)
cmake --build . -j$(nproc)

# Binary location: build/debug/bin/monero-wallet-gui.exe
```

**Expected time**: 15-30 minutes
- Faster compilation
- Includes debug symbols
- Good for development/testing

---

## Step 7: Monitor Build Progress

During build, you'll see:

```
[ 12%] Building CXX object src/CMakeFiles/monero-wallet-gui.dir/i2p/I2PManager.cpp.obj
[ 15%] Building CXX object src/CMakeFiles/monero-wallet-gui.dir/main/main.cpp.obj
...
[ 98%] Linking CXX executable bin/monero-wallet-gui.exe
[100%] Built target monero-wallet-gui
```

### Common Build Output

- **Yellow warnings**: Usually safe to ignore
- **Red errors**: Need to fix (see troubleshooting below)
- **Build time**: Progress percentage and estimated time

---

## Step 8: Run Your Build

After successful build:

```bash
# If you used Option A (release build):
cd build/release/bin
./monero-wallet-gui.exe

# If you used Option B (debug build):
cd build/debug/bin
./monero-wallet-gui.exe
```

The GUI should launch! 🎉

---

## Troubleshooting Common Issues

### Issue 1: "pacman: command not found"

**Problem**: Not using MinGW 64-bit terminal

**Solution**: 
- Close current terminal
- Open "MSYS2 MinGW 64-bit" from Start Menu
- Look for the purple/magenta icon (NOT the blue MSYS icon)

---

### Issue 2: "Could not find Qt5..."

**Problem**: Qt5 not properly installed or wrong terminal

**Solution**:
```bash
# Reinstall Qt5
pacman -S mingw-w64-x86_64-qt5-base

# Verify Qt path
qmake --version

# Make sure you're in MinGW 64-bit terminal
echo $MSYSTEM
# Should output: MINGW64
```

---

### Issue 3: "Submodule 'monero' not initialized"

**Problem**: Monero core submodule not downloaded

**Solution**:
```bash
cd /c/Users/goldie/Downloads/mr\ krabs/monero-gui
git submodule update --init --recursive
```

---

### Issue 4: Build fails with "undefined reference to..."

**Problem**: Missing library or linking issue

**Solution**:
```bash
# Clean build and try again
make clean
make release-win64

# Or if using CMake directly:
rm -rf build/
mkdir build && cd build
cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release ..
cmake --build . -j$(nproc)
```

---

### Issue 5: "fatal error: boost/xxx.hpp: No such file or directory"

**Problem**: Boost libraries missing

**Solution**:
```bash
pacman -S mingw-w64-x86_64-boost
```

---

### Issue 6: Out of disk space

**Problem**: Build requires ~10-15 GB free space

**Solution**:
- Free up disk space
- Build on a different drive with more space:
```bash
cd /d/builds  # Use D: drive
git clone your-fork
cd monero-gui
```

---

## Verification Checklist

After setup, verify everything works:

- [ ] MSYS2 MinGW 64-bit terminal opens
- [ ] `gcc --version` shows version 13.x or newer
- [ ] `cmake --version` shows version 3.x
- [ ] `qmake --version` shows Qt 5.15.x
- [ ] `git submodule status` shows initialized submodules
- [ ] Build completes without errors
- [ ] `monero-wallet-gui.exe` launches

---

## Test Your I2P Integration

Once the GUI launches:

### 1. Navigate to I2P Settings
- Open Monero GUI
- Go to: **Settings → I2P**

### 2. Verify UI Elements
- [ ] "Enable I2P" toggle visible
- [ ] "Download i2pd" button visible
- [ ] Status shows "Not installed"
- [ ] No errors in console

### 3. Test Download
- [ ] Click "Download i2pd"
- [ ] Progress bar appears
- [ ] Watch console for: "Hash verification passed"
- [ ] Status changes to "Installed, not running"

### 4. Test Start/Stop
- [ ] Click "Start i2pd"
- [ ] Status changes to "Running"
- [ ] In PowerShell: `netstat -ano | findstr 7656` shows listening
- [ ] Click "Stop i2pd"
- [ ] Process terminates

### 5. Test Daemon Integration
- [ ] Start i2pd
- [ ] Enable I2P toggle
- [ ] Start local daemon (Settings → Node)
- [ ] Check console for: "I2P proxy enabled for monerod: 127.0.0.1:7656"
- [ ] In task manager, verify monerod.exe is running
- [ ] Stop i2pd → daemon should auto-restart

---

## Build Environment Tips

### Speed Up Future Builds

After first successful build, subsequent builds are much faster (5-10 minutes):

```bash
# Only rebuild changed files
make release-win64

# Or with CMake:
cd build/release
cmake --build . -j$(nproc)
```

### Clean Build (When Needed)

If you encounter weird errors:

```bash
# Full clean
make clean
rm -rf build/

# Then rebuild
make release-win64
```

### Parallel Compilation

By default, builds use all CPU cores. To limit:

```bash
# Use only 4 cores (reduce CPU usage)
make release-win64 -j4

# Or with CMake:
cmake --build . -j4
```

---

## Next Steps After Successful Build

1. **Follow TESTING_GUIDE.md** - Complete testing checklist
2. **Test on Windows thoroughly** - Your primary platform
3. **Document any issues** - Screenshot errors, save logs
4. **Test transactions** - Use testnet first!
5. **Prepare for cross-platform** - Linux VM or Docker

---

## Useful Commands Reference

### MSYS2 Package Management

```bash
# Search for package
pacman -Ss <package-name>

# Install package
pacman -S <package-name>

# Update all packages
pacman -Syu

# Remove package
pacman -R <package-name>

# List installed packages
pacman -Q | grep mingw
```

### Git Commands

```bash
# Check current branch
git branch

# View commit history
git log --oneline --graph -15

# Check file changes
git status

# View specific commit
git show <commit-hash>
```

### Build Commands

```bash
# Full release build
make release-win64

# Debug build
make debug-win64

# Clean build files
make clean

# Test build (no GUI)
make release-test
```

---

## Expected Build Output

### Successful Build

```
...
[ 95%] Building CXX object src/CMakeFiles/monero-wallet-gui.dir/i2p/I2PManager.cpp.obj
[ 96%] Building CXX object src/CMakeFiles/monero-wallet-gui.dir/main/main.cpp.obj
[ 97%] Building CXX object src/CMakeFiles/monero-wallet-gui.dir/qml.qrc.cpp.obj
[ 98%] Linking CXX executable bin/monero-wallet-gui.exe
[100%] Built target monero-wallet-gui

Build succeeded!
```

### Files Created

```
build/release/
├── bin/
│   ├── monero-wallet-gui.exe    (Main GUI application)
│   ├── monerod.exe               (Daemon)
│   ├── monero-wallet-cli.exe    (CLI wallet)
│   └── monero-wallet-rpc.exe    (RPC wallet)
└── lib/
    └── (various .dll files)
```

---

## System Requirements

### Minimum
- **OS**: Windows 10 64-bit
- **RAM**: 4 GB (8 GB recommended)
- **Disk**: 15 GB free space
- **CPU**: 2 cores (4+ cores recommended)

### Recommended
- **OS**: Windows 10/11 64-bit
- **RAM**: 16 GB
- **Disk**: 30 GB free space (for blockchain + build)
- **CPU**: 4+ cores (for faster compilation)
- **SSD**: For faster builds

---

## Time Estimates

| Task | Time |
|------|------|
| Download MSYS2 | 2-5 min |
| Install MSYS2 | 5 min |
| Install dependencies | 10-20 min |
| Initialize submodules | 5-10 min |
| **First build** | **30-90 min** |
| Subsequent builds | 5-10 min |
| **Total setup** | **~2 hours** |

---

## Getting Help

If you encounter issues:

1. **Check this guide's troubleshooting section**
2. **Search MSYS2 docs**: https://www.msys2.org/docs/
3. **Monero build docs**: https://github.com/monero-project/monero-gui/blob/master/README.md
4. **Ask in chat**: Provide exact error message and build log

---

## Success Indicators

You're ready to test when:

✅ Build completes with `[100%] Built target monero-wallet-gui`
✅ `monero-wallet-gui.exe` exists in `build/release/bin/`
✅ GUI launches without immediate crashes
✅ Settings → I2P tab is visible
✅ No missing DLL errors

---

## What's Next?

After successful build:

1. ✅ **Build environment setup** ← YOU ARE HERE
2. ⏳ **Functional testing** (TESTING_GUIDE.md)
3. ⏳ **Cross-platform testing** (Linux, macOS)
4. ⏳ **PR preparation**
5. 💰 **Claim 140.167 XMR bounty!**

---

**Ready to build?** Open "MSYS2 MinGW 64-bit" and start with Step 4! 🚀

Good luck, and let's get this bounty! 💪
