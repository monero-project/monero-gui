#!/bin/bash
# Quick hot reload test using qmlscene (no build required)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Find qmlscene - prefer Qt6
QMLSCENE_CMD=""
if [ -f "/opt/homebrew/opt/qt6/bin/qmlscene" ]; then
    QMLSCENE_CMD="/opt/homebrew/opt/qt6/bin/qmlscene"
elif command -v qmlscene &> /dev/null; then
    # Check if it's Qt6
    QML_VERSION=$(qmlscene --version 2>&1 | grep -o "Qt [0-9]" | head -1)
    if [[ "$QML_VERSION" == *"Qt 6"* ]]; then
        QMLSCENE_CMD="qmlscene"
    else
        echo "⚠️  Found Qt5 qmlscene, but need Qt6"
        QMLSCENE_CMD=""
    fi
fi

if [ -z "$QMLSCENE_CMD" ]; then
    echo "❌ Qt6 qmlscene not found"
    echo ""
    echo "Options:"
    echo "1. Install Qt6: brew install qt6"
    echo "2. Test with built application (recommended):"
    echo "   - Build: cmake --build build"
    echo "   - Run: export QML_LIVE_RELOAD=1 && ./build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui"
    echo "   - Edit components/CheckBox.qml and save to see live reload!"
    exit 1
fi

echo "=== Quick Hot Reload Test (qmlscene) ==="
echo ""
echo "Trying simple test file first (QtQuick 2.0)..."
echo ""

# Try simple version first (QtQuick 2.0 - more compatible)
if [ -f "test-live-reload-simple.qml" ]; then
    echo "Starting test-live-reload-simple.qml..."
    echo ""
    echo "INSTRUCTIONS:"
    echo "1. The test window will open"
    echo "2. Edit test-live-reload-simple.qml in your editor"
    echo "3. Change line 25: color: \"blue\" to color: \"red\""
    echo "4. Save the file"
    echo "5. Watch the rectangle turn red instantly! ⚡"
    echo ""
    echo "Press Ctrl+C to stop"
    echo ""
    
    if $QMLSCENE_CMD --live test-live-reload-simple.qml 2>&1 | grep -q "not installed\|not found"; then
        echo ""
        echo "⚠️  qmlscene doesn't have Qt modules installed."
        echo ""
        echo "Alternative: Use the built application instead:"
        echo "  1. Build the app: cmake --build build"
        echo "  2. Run: export QML_LIVE_RELOAD=1 && ./build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui"
        echo ""
        echo "Or test with the actual app components:"
        echo "  - Edit components/CheckBox.qml"
        echo "  - Edit components/Label.qml"
        echo "  - Changes will reload automatically"
        exit 1
    fi
else
    echo "Error: test-live-reload-simple.qml not found"
    exit 1
fi

