# Building Monero GUI with I2P Support

This document provides detailed instructions for building the Monero GUI wallet with I2P support on various platforms.

## Prerequisites

### Common Prerequisites
- Git
- CMake (version 3.10 or higher)
- Boost (version 1.58 or higher)
- Qt (version 5.9.7 or higher, Qt 6 is not supported yet)
- OpenSSL

### Platform-Specific Prerequisites

#### Windows
- MSYS2 with MinGW-w64 toolchain
- NSIS (for installer creation)

#### macOS
- Xcode
- Homebrew (recommended for installing dependencies)

#### Linux
- GCC or Clang
- Development packages for Qt and Boost

## Getting the Source Code

```bash
git clone --recursive https://github.com/monero-project/monero-gui.git
cd monero-gui
```

## Building with I2P Support

### Option 1: Using the Build Script

#### Windows (PowerShell)
```powershell
./build.windows.ps1 -withI2P
```

#### macOS and Linux
```bash
./build.sh --with-i2p
```

### Option 2: Manual Build

#### Windows (MSYS2)
```bash
mkdir build && cd build
cmake -G "MSYS Makefiles" -DWITH_I2P=ON ..
make
```

#### macOS
```bash
mkdir build && cd build
cmake -DWITH_I2P=ON ..
make
```

#### Linux
```bash
mkdir build && cd build
cmake -DWITH_I2P=ON ..
make
```

## Verifying I2P Support

To verify that I2P support is properly built:

1. Run the compiled Monero GUI
2. Go to Settings > Node
3. You should see I2P options in the interface
4. Check the "Enable I2P" option and configure the settings

## Troubleshooting

### Common Issues

#### Missing I2P Options
If you don't see I2P options in the settings:
- Ensure you built with `-DWITH_I2P=ON`
- Check the build logs for any I2P-related errors

#### Build Failures
- Make sure all dependencies are properly installed
- On Windows, ensure you're using the correct MSYS2 environment
- On macOS, try `brew install boost qt openssl`
- On Linux, install required packages with your package manager

#### I2P Daemon Download Failures
If the automatic download of the I2P daemon binary fails during the build process:

1. Download the appropriate I2P binary manually:
   - Windows: [I2P Installer for Windows](https://geti2p.net/en/download/2.8.2/clearnet/https/files.i2p-projekt.de/i2pinstall_2.8.2_windows.exe/download)
   - macOS: [I2P Installer JAR file](https://geti2p.net/en/download/2.8.2/clearnet/https/files.i2p-projekt.de/i2pinstall_2.8.2.jar/download)
   - Linux: [I2P Installer JAR file](https://geti2p.net/en/download/2.8.2/clearnet/https/files.i2p-projekt.de/i2pinstall_2.8.2.jar/download)

2. Place the downloaded file in the expected location:
   - For Windows: Copy to `<build-dir>/bin/i2pd.exe`
   - For macOS/Linux: Copy to `<build-dir>/bin/i2pd` and make it executable

3. Continue with the build process

## Additional Notes

- I2P support requires additional resources and may increase application startup time
- For development and testing, you may want to use a local I2P router
- Production builds should use the embedded I2P router for user convenience

## Support

If you encounter issues with the I2P integration, please file an issue on the GitHub repository with detailed information about your build environment and the problem you're experiencing. 