#!/bin/bash
# Development script for live QML reload
# This script sets up the environment and runs the app with live reload capabilities

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Monero GUI - Live Reload Development Setup${NC}"
echo "=========================================="

# Check if running in Docker
if [ -f /.dockerenv ]; then
    echo -e "${YELLOW}Running inside Docker container${NC}"
    DOCKER_MODE=true
else
    echo -e "${YELLOW}Running on host system${NC}"
    DOCKER_MODE=false
fi

# Check for Qt6
if command -v qmlscene &> /dev/null; then
    QMLSCENE_CMD="qmlscene"
elif [ -f "/opt/homebrew/opt/qt6/bin/qmlscene" ]; then
    QMLSCENE_CMD="/opt/homebrew/opt/qt6/bin/qmlscene"
elif [ -f "/usr/bin/qmlscene" ]; then
    QMLSCENE_CMD="/usr/bin/qmlscene"
else
    echo "Warning: qmlscene not found. Will use built application instead."
    QMLSCENE_CMD=""
fi

# Check if build exists
if [ ! -d "$PROJECT_ROOT/build" ]; then
    echo "Build directory not found. Please run cmake and build first."
    exit 1
fi

# Determine which method to use
USE_QMLSCENE=false
USE_BUILT_APP=true

# Check for --qmlscene flag
if [[ "$*" == *"--qmlscene"* ]]; then
    USE_QMLSCENE=true
    USE_BUILT_APP=false
fi

# Check for --built flag
if [[ "$*" == *"--built"* ]]; then
    USE_QMLSCENE=false
    USE_BUILT_APP=true
fi

cd "$PROJECT_ROOT"

if [ "$USE_QMLSCENE" = true ] && [ -n "$QMLSCENE_CMD" ]; then
    echo -e "${GREEN}Using qmlscene for live reload (limited functionality)${NC}"
    echo "Note: This mode only works for pure QML. C++ backend features will not be available."
    echo ""
    
    # Set up QML import paths
    export QML2_IMPORT_PATH="$PROJECT_ROOT/components:$PROJECT_ROOT/pages:$PROJECT_ROOT/wizard"
    
    # Run qmlscene with live reload
    if [ "$QMLSCENE_CMD" = "qmlscene" ]; then
        $QMLSCENE_CMD --live main.qml
    else
        $QMLSCENE_CMD --live main.qml
    fi
elif [ "$USE_BUILT_APP" = true ]; then
    echo -e "${GREEN}Using built application with file watcher${NC}"
    echo ""
    
    # Check if app exists
    if [ -f "$PROJECT_ROOT/build/bin/monero-wallet-gui" ]; then
        APP_PATH="$PROJECT_ROOT/build/bin/monero-wallet-gui"
    elif [ -f "$PROJECT_ROOT/build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui" ]; then
        APP_PATH="$PROJECT_ROOT/build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui"
    else
        echo "Error: Built application not found. Please build the project first."
        exit 1
    fi
    
    # Set environment for live reload
    export QML_DISABLE_DISK_CACHE=1
    export QML_LIVE_RELOAD=1
    
    # Run the application
    echo "Starting application: $APP_PATH"
    echo "QML files will be watched for changes..."
    echo ""
    "$APP_PATH" "$@"
else
    echo "Error: No suitable method found to run the application."
    exit 1
fi

