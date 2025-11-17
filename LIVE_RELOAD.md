# QML Live Reload Setup

This document describes the live reload setup for QML development in the Monero GUI project.

## Quick Start

### Local Development

1. **Build the application:**
   ```bash
   cmake -G Ninja -B build -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt6;/opt/homebrew/opt/icu4c;/opt/homebrew/opt/abseil" -DCMAKE_CXX_FLAGS="-std=gnu++23"
   cmake --build build
   ```

2. **Run with live reload:**
   ```bash
   export QML_LIVE_RELOAD=1
   ./build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui
   ```

3. **Edit QML files** - changes will automatically reload after 500ms

### Docker Development

1. **Start development container:**
   ```bash
   ./scripts/docker-dev.sh
   ```

2. **Inside container, build and run:**
   ```bash
   cd /workspace
   cmake -B build -DCMAKE_PREFIX_PATH="/usr"
   cmake --build build
   export QML_LIVE_RELOAD=1
   ./build/bin/monero-wallet-gui
   ```

## How It Works

The application uses Qt's `QFileSystemWatcher` to monitor QML files for changes:

- **Watched directories:** `components/`, `pages/`, `wizard/`
- **Watched files:** `main.qml`, `LeftPanel.qml`, `MiddlePanel.qml`
- **Debounce:** 500ms delay to avoid multiple reloads
- **Auto-reload:** Clears QML cache and reloads when files change

## Environment Variables

- `QML_LIVE_RELOAD=1` - Enables live reload mode
- `QML_DISABLE_DISK_CACHE=1` - Disables QML disk cache (already set)

## Docker Volume Mounts

The `docker-compose.dev.yml` mounts:
- `components/` (read-only)
- `pages/` (read-only)
- `wizard/` (read-only)
- `src/` (read-write)
- `build/` (read-write)

Changes made on the host are immediately visible in the container.

## Limitations

- C++ changes still require recompilation
- Resource file (`qml.qrc`) changes require rebuild
- Context property changes require restart
- New QML type registrations require restart

## See Also

- `scripts/README-LIVE-RELOAD.md` - Detailed documentation
- `scripts/dev-live-reload.sh` - Development script
- `scripts/docker-dev.sh` - Docker development script

