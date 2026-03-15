#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: scripts/fetch-i2pd.sh --url <archive-url> [--output <path>] [--version <tag>]

Downloads an official i2pd release archive, extracts the router binary and
copies it into external/i2p/bin so the GUI build can bundle it. The script does
not guess URLs – pass the exact link from https://github.com/PurpleI2P/i2pd/releases.

Examples:
  scripts/fetch-i2pd.sh --url https://github.com/PurpleI2P/i2pd/releases/download/2.49.0/i2pd-2.49.0-macos.tar.xz
  scripts/fetch-i2pd.sh --url https://github.com/PurpleI2P/i2pd/releases/download/2.49.0/i2pd-win64-2.49.0.zip --version win64
  scripts/fetch-i2pd.sh --url https://github.com/PurpleI2P/i2pd/releases/download/2.59.0/i2pd_2.59.0-1bookworm1_amd64.deb --output external/i2p/bin/linux-x86_64

After running, point CMake at the extracted binary with:
  cmake -DI2P_ROUTER_SOURCE="$(pwd)/external/i2p/bin/<platform>/i2pd"
EOF
}

URL=""
OUTPUT=""
PLATFORM_SUFFIX=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --url)
            URL="$2"
            shift 2
            ;;
        --output)
            OUTPUT="$2"
            shift 2
            ;;
        --version)
            PLATFORM_SUFFIX="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ -z "$URL" ]]; then
    echo "Error: --url is required" >&2
    usage >&2
    exit 1
fi

if [[ -z "$OUTPUT" ]]; then
    OS_NAME="$(uname -s | tr 'A-Z' 'a-z')"
    OUTPUT="external/i2p/bin/${OS_NAME}${PLATFORM_SUFFIX:+-$PLATFORM_SUFFIX}"
fi

ARCHIVE=$(mktemp)
trap 'rm -f "$ARCHIVE"' EXIT

echo "Downloading $URL ..."
curl -L "$URL" -o "$ARCHIVE"

EXTRACT_DIR=$(mktemp -d)
trap 'rm -rf "$EXTRACT_DIR"; rm -f "$ARCHIVE"' EXIT

case "$URL" in
    *.tar.gz|*.tgz|*.tar.xz|*.tar.zst|*.tar.bz2)
        if command -v cmake >/dev/null 2>&1; then
            cmake -E tar xzf "$ARCHIVE" --directory "$EXTRACT_DIR"
        else
            tar -xf "$ARCHIVE" -C "$EXTRACT_DIR"
        fi
        ;;
    *.zip)
        unzip -q "$ARCHIVE" -d "$EXTRACT_DIR"
        ;;
    *.deb)
        (cd "$EXTRACT_DIR" && ar -x "$ARCHIVE")
        DATA_ARCHIVE=$(find "$EXTRACT_DIR" -maxdepth 1 -name 'data.tar.*' | head -n 1 || true)
        if [[ -z "$DATA_ARCHIVE" ]]; then
            echo "Unable to locate data.tar.* inside deb archive" >&2
            exit 1
        fi
        if [[ "$DATA_ARCHIVE" == *.xz ]]; then
            tar -xJf "$DATA_ARCHIVE" -C "$EXTRACT_DIR"
        elif [[ "$DATA_ARCHIVE" == *.zst ]]; then
            tar --zstd -xf "$DATA_ARCHIVE" -C "$EXTRACT_DIR"
        else
            tar -xf "$DATA_ARCHIVE" -C "$EXTRACT_DIR"
        fi
        ;;
    *)
        echo "Unknown archive format. Please supply a .tar.*, .zip or .deb release." >&2
        exit 1
        ;;
esac

mapfile -t CANDIDATES < <(find "$EXTRACT_DIR" -maxdepth 5 -type f -name 'i2pd*' | sort)

choose_binary() {
    local file
    for file in "${CANDIDATES[@]}"; do
        [[ -z "$file" ]] && continue
        local info
        info=$(file "$file" 2>/dev/null || true)
        if echo "$info" | grep -Eq '(Mach-O|PE32|ELF)'; then
            printf '%s' "$file"
            return 0
        fi
    done
    for file in "${CANDIDATES[@]}"; do
        [[ -z "$file" ]] && continue
        if [[ "$file" == *i2pd.exe ]]; then
            printf '%s' "$file"
            return 0
        fi
    done
    for file in "${CANDIDATES[@]}"; do
        [[ -z "$file" ]] && continue
        if [[ $(basename "$file") == "i2pd" ]]; then
            printf '%s' "$file"
            return 0
        fi
    done
    return 1
}

BIN_PATH=$(choose_binary || true)
if [[ -z "$BIN_PATH" ]]; then
    echo "Could not locate i2pd binary inside archive." >&2
    exit 1
fi

DEST_DIR="$OUTPUT"
mkdir -p "$DEST_DIR"
DEST_NAME="i2pd"
if [[ "$BIN_PATH" == *.exe ]]; then
    DEST_NAME="i2pd.exe"
fi

cp "$BIN_PATH" "$DEST_DIR/$DEST_NAME"
chmod +x "$DEST_DIR/$DEST_NAME" 2>/dev/null || true

echo "Copied router to $DEST_DIR/$DEST_NAME"
echo "CMake will auto-detect it under external/i2p/bin, or explicitly set:"
echo "  cmake -DI2P_ROUTER_SOURCE=$PWD/$DEST_DIR/$DEST_NAME ..."
