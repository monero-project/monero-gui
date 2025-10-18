# Quick Start Build Script for Monero GUI
# Run this in MSYS2 MinGW 64-bit terminal

echo "=================================================="
echo "  Monero GUI I2P Integration - Build Script"
echo "=================================================="
echo ""

# Check if we're in the right terminal
if [ "$MSYSTEM" != "MINGW64" ]; then
    echo "❌ ERROR: Wrong terminal!"
    echo "Please open 'MSYS2 MinGW 64-bit' from Start Menu"
    echo "Look for the purple/magenta icon, NOT the blue MSYS icon"
    exit 1
fi

echo "✅ Running in MinGW64 environment"
echo ""

# Verify we're in the right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo "❌ ERROR: Not in monero-gui directory!"
    echo "Please navigate to: cd /c/Users/goldie/Downloads/mr\\ krabs/monero-gui"
    exit 1
fi

echo "✅ In monero-gui directory"
echo ""

# Check for required tools
echo "Checking build dependencies..."
echo ""

check_command() {
    if command -v $1 &> /dev/null; then
        version=$($1 --version 2>&1 | head -n 1)
        echo "✅ $1: $version"
        return 0
    else
        echo "❌ $1: NOT FOUND"
        return 1
    fi
}

missing=0

check_command gcc || missing=1
check_command cmake || missing=1
check_command qmake || missing=1
check_command git || missing=1
check_command make || missing=1

echo ""

if [ $missing -eq 1 ]; then
    echo "❌ Missing dependencies!"
    echo ""
    echo "Please install missing packages:"
    echo "  pacman -S mingw-w64-x86_64-toolchain"
    echo "  pacman -S mingw-w64-x86_64-cmake"
    echo "  pacman -S mingw-w64-x86_64-qt5-base"
    echo ""
    exit 1
fi

echo "✅ All required tools found!"
echo ""

# Check git branch
current_branch=$(git branch --show-current)
echo "Current branch: $current_branch"

if [ "$current_branch" != "feature/i2p-binary-manager" ]; then
    echo "⚠️  WARNING: Not on feature/i2p-binary-manager branch!"
    echo "Switch with: git checkout feature/i2p-binary-manager"
    echo ""
fi

# Check submodules
echo ""
echo "Checking submodules..."
if git submodule status | grep -q '^-'; then
    echo "⚠️  Submodules not initialized!"
    echo ""
    read -p "Initialize submodules now? This will download ~200 MB (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Initializing submodules..."
        git submodule update --init --recursive
    else
        echo "Skipping submodule initialization"
        echo "You can initialize later with: git submodule update --init --recursive"
    fi
else
    echo "✅ Submodules initialized"
fi

echo ""
echo "=================================================="
echo "  Ready to Build!"
echo "=================================================="
echo ""
echo "Choose build type:"
echo ""
echo "1. RELEASE BUILD (Recommended)"
echo "   - Optimized, fast performance"
echo "   - Takes 30-90 minutes"
echo "   - Command: make release-win64"
echo ""
echo "2. DEBUG BUILD (Faster compilation)"
echo "   - Debug symbols included"
echo "   - Takes 15-30 minutes"
echo "   - Good for development"
echo ""
echo "3. SKIP BUILD (Just verify environment)"
echo ""
read -p "Enter choice (1/2/3): " choice

case $choice in
    1)
        echo ""
        echo "Starting RELEASE build..."
        echo "This will take 30-90 minutes depending on your CPU"
        echo ""
        read -p "Continue? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            make clean
            make release-win64
            
            if [ $? -eq 0 ]; then
                echo ""
                echo "=================================================="
                echo "  ✅ BUILD SUCCESSFUL!"
                echo "=================================================="
                echo ""
                echo "Binary location:"
                echo "  build/release/bin/monero-wallet-gui.exe"
                echo ""
                echo "To run:"
                echo "  cd build/release/bin"
                echo "  ./monero-wallet-gui.exe"
                echo ""
                echo "Next steps:"
                echo "  1. Test the GUI launches"
                echo "  2. Check Settings → I2P tab"
                echo "  3. Follow TESTING_GUIDE.md"
                echo ""
            else
                echo ""
                echo "❌ BUILD FAILED"
                echo "Check error messages above"
                echo "See BUILD_SETUP_GUIDE.md troubleshooting section"
            fi
        fi
        ;;
    2)
        echo ""
        echo "Starting DEBUG build..."
        echo "This will take 15-30 minutes"
        echo ""
        mkdir -p build/debug
        cd build/debug
        cmake -G "MinGW Makefiles" \
              -DCMAKE_BUILD_TYPE=Debug \
              -DCMAKE_PREFIX_PATH=/mingw64 \
              ../..
        cmake --build . -j$(nproc)
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "=================================================="
            echo "  ✅ BUILD SUCCESSFUL!"
            echo "=================================================="
            echo ""
            echo "Binary location:"
            echo "  build/debug/bin/monero-wallet-gui.exe"
            echo ""
            echo "To run:"
            echo "  cd build/debug/bin"
            echo "  ./monero-wallet-gui.exe"
            echo ""
        else
            echo ""
            echo "❌ BUILD FAILED"
            echo "Check error messages above"
        fi
        ;;
    3)
        echo ""
        echo "Skipping build. Environment verified!"
        echo ""
        echo "To build manually:"
        echo "  make release-win64    (Release build)"
        echo "  make debug-win64      (Debug build)"
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac

echo ""
echo "Done!"
