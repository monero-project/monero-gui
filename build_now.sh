#!/bin/bash
# Monero GUI I2P Integration - Automated Build Script
# This script automates the entire build process

set -e  # Exit on any error

clear
echo "=========================================================="
echo "  🚀 MONERO GUI I2P INTEGRATION - BUILD AUTOMATION"
echo "=========================================================="
echo ""
echo "Building your path to $28,000+ 💰"
echo ""

# Verify environment
if [ "$MSYSTEM" != "MINGW64" ]; then
    echo "❌ ERROR: Wrong terminal!"
    echo "Please run this in: MSYS2 MinGW 64-bit (purple icon)"
    exit 1
fi

echo "✅ MinGW64 environment verified"
echo ""

# Check we're in the right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo "❌ ERROR: Not in monero-gui directory!"
    echo "Run: cd /c/Users/goldie/Downloads/mr\\ krabs/monero-gui"
    exit 1
fi

echo "✅ In monero-gui directory"
echo ""

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf build/ 2>/dev/null || true
echo "✅ Clean complete"
echo ""

# Start build
echo "=========================================================="
echo "  🔨 STARTING RELEASE BUILD"
echo "=========================================================="
echo ""
echo "⏱️  Estimated time: 30-90 minutes"
echo "💻 Your CPU will be at 100% - this is normal!"
echo "☕ Grab a coffee and relax!"
echo ""
echo "Real-time progress below:"
echo "=========================================================="
echo ""

# Run make with verbose output
make release-win64

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================================="
    echo "  ✅ BUILD SUCCESSFUL! 🎉"
    echo "=========================================================="
    echo ""
    echo "📦 Binary location:"
    echo "   build/release/bin/monero-wallet-gui.exe"
    echo ""
    echo "🚀 NEXT STEPS:"
    echo ""
    echo "1. Launch the GUI:"
    echo "   cd build/release/bin"
    echo "   ./monero-wallet-gui.exe"
    echo ""
    echo "2. Test I2P integration:"
    echo "   - Go to: Settings → I2P"
    echo "   - Click: Download i2pd"
    echo "   - Verify: 'Hash verification passed' in console"
    echo "   - Test: Start/stop i2pd"
    echo ""
    echo "3. Follow TESTING_GUIDE.md for complete tests"
    echo ""
    echo "4. After testing, submit PR and CLAIM YOUR BOUNTY! 💰"
    echo ""
    echo "=========================================================="
    echo "🎉 $28,000+ is within reach! Let's go! 🚀"
    echo "=========================================================="
else
    echo ""
    echo "=========================================================="
    echo "  ❌ BUILD FAILED"
    echo "=========================================================="
    echo ""
    echo "Check the error messages above."
    echo ""
    echo "Common fixes:"
    echo "  - Missing Qt: pacman -S mingw-w64-x86_64-qt5-base"
    echo "  - Missing Boost: pacman -S mingw-w64-x86_64-boost"
    echo "  - Submodule issue: git submodule update --init --recursive"
    echo ""
    echo "See BUILD_SETUP_GUIDE.md for more troubleshooting"
    exit 1
fi
