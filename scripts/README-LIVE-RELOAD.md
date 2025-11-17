# QML Live Reload Development Setup

This directory contains scripts and configuration for live reloading QML files during development.

## Overview

Live reload allows you to see QML UI changes immediately without restarting the application. There are two methods available:

1. **Built Application with File Watcher** (Recommended)
   - Full application functionality with C++ backend
   - Automatically reloads QML when files change
   - Best for full-stack development

2. **qmlscene with --live flag** (Limited)
   - Pure QML preview (no C++ backend)
   - Faster for UI-only changes
   - Limited functionality

## Quick Start

### Option 1: Local Development (macOS/Linux)

1. **Build the application:**
   ```bash
   cmake -G Ninja -B build -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt6;/opt/homebrew/opt/icu4c;/opt/homebrew/opt/abseil" -DCMAKE_CXX_FLAGS="-std=gnu++23"
   cmake --build build
   ```

2. **Run with live reload:**
   ```bash
   ./scripts/dev-live-reload.sh --built
   ```

3. **Edit QML files** in `components/`, `pages/`, or `wizard/` directories
   - Changes will automatically reload after 500ms

### Option 2: Docker Development

1. **Start Docker development environment:**
   ```bash
   ./scripts/docker-dev.sh
   ```

2. **Inside the container, build and run:**
   ```bash
   cd /workspace
   cmake -B build -DCMAKE_PREFIX_PATH="/usr"
   cmake --build build
   ./scripts/dev-live-reload.sh --built
   ```

3. **Edit QML files** on your host machine - changes will be reflected in the container

### Option 3: qmlscene (QML Only)

For quick UI prototyping without the full application:

```bash
./scripts/dev-live-reload.sh --qmlscene
```

**Note:** This mode only works for pure QML. C++ backend features (wallet, daemon, etc.) will not be available.

## How It Works

### File Watcher Implementation

The application uses Qt's `QFileSystemWatcher` to monitor QML files:

- **Watched directories:**
  - `components/`
  - `pages/`
  - `wizard/`

- **Watched files:**
  - `main.qml`
  - `LeftPanel.qml`
  - `MiddlePanel.qml`

- **Debounce:** Changes are debounced by 500ms to avoid multiple reloads

- **Auto-reload:** When a file changes, the QML engine clears its cache and reloads `main.qml`

### Environment Variables

- `QML_LIVE_RELOAD=1` - Enables live reload mode
- `QML_DISABLE_DISK_CACHE=1` - Disables QML disk cache (already set in main.cpp)

## Docker Configuration

The `docker-compose.dev.yml` file sets up:

- **Volume mounts:**
  - `components/` (read-only)
  - `pages/` (read-only)
  - `wizard/` (read-only)
  - `src/` (read-write)
  - `build/` (read-write)

- **X11 Display:** Configured for GUI applications in Docker

- **Environment:** Pre-configured with live reload enabled

## Troubleshooting

### Changes Not Reloading

1. **Check that live reload is enabled:**
   ```bash
   echo $QML_LIVE_RELOAD
   # Should output: 1
   ```

2. **Verify file paths are correct:**
   - Ensure QML files are in the watched directories
   - Check that paths are relative to project root

3. **Check file permissions:**
   - Ensure files are readable
   - In Docker, check volume mount permissions

### Docker Display Issues (macOS)

1. **Install and start XQuartz:**
   ```bash
   brew install --cask xquartz
   open -a XQuartz
   ```

2. **Set DISPLAY:**
   ```bash
   export DISPLAY=:0
   xhost +localhost
   ```

3. **Restart Docker container:**
   ```bash
   ./scripts/docker-dev.sh
   ```

### qmlscene Not Found

If `qmlscene` is not found:

1. **Install Qt6:**
   ```bash
   brew install qt6
   ```

2. **Or use the built application:**
   ```bash
   ./scripts/dev-live-reload.sh --built
   ```

## Limitations

1. **C++ Changes:** C++ code changes still require recompilation and restart
2. **Resource Files:** Changes to `qml.qrc` require rebuild
3. **Context Properties:** Changes to context properties in `main.cpp` require restart
4. **QML Imports:** New QML imports may require restart

## Best Practices

1. **Use live reload for:**
   - UI layout changes
   - Styling adjustments
   - Component property changes
   - QML logic modifications

2. **Restart application for:**
   - C++ backend changes
   - New QML type registrations
   - Resource file changes
   - Major architectural changes

3. **Development workflow:**
   - Keep the application running with live reload
   - Make QML changes in your editor
   - See changes automatically after 500ms
   - Test functionality immediately
   - Rebuild only when C++ changes are needed

## Advanced Usage

### Custom Watch Paths

To add additional paths to watch, modify `src/main/main.cpp`:

```cpp
watchPaths << projectRoot + "/custom/path";
```

### Adjust Debounce Time

Change the reload timer interval in `src/main/main.cpp`:

```cpp
reloadTimer->setInterval(1000); // 1 second debounce
```

### Disable Live Reload

Unset the environment variable:

```bash
unset QML_LIVE_RELOAD
./build/bin/monero-wallet-gui
```

Or comment out the live reload code in `main.cpp`.

