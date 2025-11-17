#!/bin/bash
# Docker development script for live QML reload
# This script builds and runs the development container with volume mounts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Monero GUI - Docker Development Environment${NC}"
echo "=========================================="

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "Error: docker-compose is not installed or not in PATH"
    exit 1
fi

cd "$PROJECT_ROOT"

# Check for X11 display (Linux/macOS with XQuartz)
if [ -z "$DISPLAY" ]; then
    if [ "$(uname)" = "Darwin" ]; then
        echo -e "${YELLOW}macOS detected. Make sure XQuartz is running.${NC}"
        echo "You can start XQuartz with: open -a XQuartz"
        echo "Then set DISPLAY: export DISPLAY=:0"
        DISPLAY=:0
    else
        DISPLAY=:0
    fi
fi

export DISPLAY

# Build the image if it doesn't exist or if --build is specified
if [[ "$*" == *"--build"* ]] || ! docker images | grep -q "monero-gui-project-monero-gui-dev"; then
    echo -e "${BLUE}Building Docker image...${NC}"
    $COMPOSE_CMD -f docker-compose.dev.yml build
fi

# Start the container
echo -e "${GREEN}Starting development container...${NC}"
echo "Mounted directories:"
echo "  - components/ (read-only)"
echo "  - pages/ (read-only)"
echo "  - wizard/ (read-only)"
echo "  - src/ (read-write)"
echo "  - build/ (read-write)"
echo ""

# Run the container interactively
$COMPOSE_CMD -f docker-compose.dev.yml run --rm \
    -e DISPLAY="$DISPLAY" \
    monero-gui-dev \
    /bin/bash -c "
        echo 'Development container started!'
        echo 'To run with live reload:'
        echo '  ./scripts/dev-live-reload.sh --built'
        echo ''
        echo 'To use qmlscene (QML only):'
        echo '  ./scripts/dev-live-reload.sh --qmlscene'
        echo ''
        echo 'To build the project:'
        echo '  cd /workspace && cmake -B build -DCMAKE_PREFIX_PATH=\"/usr\" && cmake --build build'
        echo ''
        /bin/bash
    "

