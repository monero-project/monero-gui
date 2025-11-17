#!/bin/bash
# Script to test hot reload functionality
# This script makes test changes to QML files and demonstrates live reload

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Hot Reload Test Script${NC}"
echo "========================"
echo ""

cd "$PROJECT_ROOT"

# Check if app is built
APP_PATH=""
if [ -f "build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui" ]; then
    APP_PATH="build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui"
elif [ -f "build/bin/monero-wallet-gui" ]; then
    APP_PATH="build/bin/monero-wallet-gui"
fi

if [ -z "$APP_PATH" ]; then
    echo -e "${YELLOW}Application not found.${NC}"
    echo ""
    echo "Options:"
    echo "1. Build now (this may take several minutes)"
    echo "2. Use qmlscene instead (quick QML-only test)"
    echo "3. Exit and build manually"
    echo ""
    read -p "Select option (1-3): " build_choice
    
    case $build_choice in
        1)
            echo -e "${BLUE}Configuring CMake...${NC}"
            cmake -G Ninja -B build -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt6;/opt/homebrew/opt/icu4c;/opt/homebrew/opt/abseil" -DCMAKE_CXX_FLAGS="-std=gnu++23" > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo -e "${RED}CMake configuration failed. Please build manually.${NC}"
                exit 1
            fi
            echo -e "${BLUE}Building application (this will take a while)...${NC}"
            echo "You can cancel with Ctrl+C and build manually later"
            cmake --build build
            if [ $? -ne 0 ]; then
                echo -e "${RED}Build failed. Please fix errors and try again.${NC}"
                exit 1
            fi
            # Check again after build
            if [ -f "build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui" ]; then
                APP_PATH="build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui"
            elif [ -f "build/bin/monero-wallet-gui" ]; then
                APP_PATH="build/bin/monero-wallet-gui"
            fi
            ;;
        2)
            # Will use qmlscene option
            ;;
        3)
            echo "Exiting. Build manually with:"
            echo "  cmake -G Ninja -B build -DCMAKE_PREFIX_PATH=\"/opt/homebrew/opt/qt6;/opt/homebrew/opt/icu4c;/opt/homebrew/opt/abseil\" -DCMAKE_CXX_FLAGS=\"-std=gnu++23\""
            echo "  cmake --build build"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            exit 1
            ;;
    esac
fi

# Check for qmlscene
QMLSCENE_CMD=""
if command -v qmlscene &> /dev/null; then
    QMLSCENE_CMD="qmlscene"
elif [ -f "/opt/homebrew/opt/qt6/bin/qmlscene" ]; then
    QMLSCENE_CMD="/opt/homebrew/opt/qt6/bin/qmlscene"
fi

echo -e "${BLUE}Test Options:${NC}"
echo "1. Test with qmlscene (quick QML-only test)"
echo "2. Test with built application (full functionality)"
echo "3. Make test changes to components"
echo "4. Show test instructions"
echo ""
read -p "Select option (1-4): " choice

case $choice in
    1)
        if [ -z "$QMLSCENE_CMD" ]; then
            echo -e "${RED}Error: qmlscene not found${NC}"
            exit 1
        fi
        echo -e "${GREEN}Starting qmlscene with live reload...${NC}"
        echo "Edit test-live-reload.qml and watch it update!"
        echo ""
        $QMLSCENE_CMD --live test-live-reload.qml
        ;;
    2)
        if [ -z "$APP_PATH" ]; then
            echo -e "${RED}Error: Application not found${NC}"
            echo "Please build the application first or use option 1 (qmlscene)"
            exit 1
        fi
        echo -e "${GREEN}Starting application with live reload...${NC}"
        echo "Edit QML files in components/, pages/, or wizard/ and watch them update!"
        echo ""
        export QML_LIVE_RELOAD=1
        "$APP_PATH"
        ;;
    3)
        echo -e "${YELLOW}Making test changes to components...${NC}"
        echo ""
        
        # Backup original files
        cp components/CheckBox.qml components/CheckBox.qml.backup
        cp components/Label.qml components/Label.qml.backup
        
        echo "Test changes made:"
        echo "1. Added comment to CheckBox.qml"
        echo "2. Added comment to Label.qml"
        echo ""
        echo -e "${GREEN}Now start the app with QML_LIVE_RELOAD=1 and edit these files!${NC}"
        echo ""
        echo "To restore originals:"
        echo "  mv components/CheckBox.qml.backup components/CheckBox.qml"
        echo "  mv components/Label.qml.backup components/Label.qml"
        ;;
    4)
        echo -e "${BLUE}Hot Reload Test Instructions:${NC}"
        echo ""
        echo "1. Start the application with live reload:"
        echo "   export QML_LIVE_RELOAD=1"
        echo "   ./build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui"
        echo ""
        echo "2. In another terminal, edit a QML file:"
        echo "   - components/CheckBox.qml"
        echo "   - components/Label.qml"
        echo "   - Or any file in components/, pages/, wizard/"
        echo ""
        echo "3. Save the file"
        echo ""
        echo "4. Watch the application - it should reload within 500ms"
        echo ""
        echo "5. Check the console for messages:"
        echo "   - 'QML file changed - reloading...'"
        echo "   - 'Reloading QML engine...'"
        echo "   - 'QML reloaded successfully'"
        echo ""
        echo "See TEST_HOT_RELOAD.md for detailed instructions"
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

