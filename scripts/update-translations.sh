#!/bin/bash
# Script to update all translation files with new strings from source code
# This should be run after adding new translatable strings to the codebase

set -e

# Find lupdate
LUPDATE=$(which lupdate 2>/dev/null || which lupdate-qt5 2>/dev/null || which lupdate-qt6 2>/dev/null)

if [ -z "$LUPDATE" ]; then
    echo "Error: lupdate not found. Please install Qt Linguist Tools."
    echo "On macOS with Homebrew: brew install qt@5"
    exit 1
fi

echo "Using: $LUPDATE"
echo ""

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Update base template file
echo "Updating base translation template (monero-core.ts)..."
$LUPDATE -extensions cpp,h,qml -no-obsolete -locations relative -recursive . \
    -ts translations/monero-core.ts

# Update all language-specific files
echo ""
echo "Updating language-specific translation files..."
for TS_FILE in translations/monero-core_*.ts; do
    if [ -f "$TS_FILE" ]; then
        LANG=$(basename "$TS_FILE" .ts | sed 's/monero-core_//')
        echo "  Updating $LANG..."
        $LUPDATE -extensions cpp,h,qml -no-obsolete -locations relative -recursive . \
            -ts "$TS_FILE"
    fi
done

echo ""
echo "Translation files updated successfully!"
echo ""
echo "Next steps:"
echo "1. Open translation files in Qt Linguist to translate new strings"
echo "2. Or edit .ts files directly in a text editor"
echo "3. Build the project - translations will be compiled automatically"
echo ""
echo "To build translations manually:"
echo "  lrelease translations/monero-core_<lang>.ts"

