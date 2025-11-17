# Hot Reload Test Guide

This document provides step-by-step instructions to test the hot reload functionality.

## Prerequisites

1. **Build the application** (if using built app):
   ```bash
   cmake -G Ninja -B build -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt6;/opt/homebrew/opt/icu4c;/opt/homebrew/opt/abseil" -DCMAKE_CXX_FLAGS="-std=gnu++23"
   cmake --build build
   ```

2. **Or use qmlscene** (for quick QML-only testing):
   ```bash
   # macOS
   /opt/homebrew/opt/qt6/bin/qmlscene --live test-live-reload.qml
   
   # Linux (if installed)
   qmlscene --live test-live-reload.qml
   ```

## Test 1: Simple Label Text Change

### Using Test File

1. **Start the test file:**
   ```bash
   export QML_LIVE_RELOAD=1
   /opt/homebrew/opt/qt6/bin/qmlscene --live test-live-reload.qml
   ```

2. **Edit `test-live-reload.qml`:**
   - Find line with `text: "TEST 1: Simple Label - Edit this text in the file!"`
   - Change to: `text: "TEST 1: ✅ HOT RELOAD WORKS! Changed at " + new Date().toLocaleTimeString()`
   - Save the file

3. **Observe:** The label should update within 500ms without restarting

### Using Real Component (CheckBox)

1. **Start the application:**
   ```bash
   export QML_LIVE_RELOAD=1
   ./build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui
   ```

2. **Edit `components/CheckBox.qml`:**
   - Find the `TextPlain` component (around line 124)
   - Add a test property or modify existing text
   - For example, add a comment: `// HOT RELOAD TEST - " + new Date().toLocaleTimeString()`
   - Or modify the `visible` property temporarily

3. **Observe:** Any CheckBox in the UI should update automatically

## Test 2: Color/Property Changes

### Using Test File

1. **Edit `test-live-reload.qml`:**
   - Find `color: "blue"` (around line 30)
   - Change to: `color: "red"` or `color: "#ff00ff"`
   - Save

2. **Observe:** The rectangle color changes instantly

### Using Real Component

1. **Edit `components/CheckBox.qml`:**
   - Find `backgroundRect` (around line 90)
   - Modify the `color` property
   - Save

2. **Observe:** CheckBox backgrounds update in real-time

## Test 3: Nested Components

### Using Test File

1. **Edit `test-live-reload.qml`:**
   - Find `nestedRect` (around line 40)
   - Change `color: "lightgreen"` to `color: "orange"`
   - Modify nested Label text
   - Save

2. **Observe:** Both the rectangle and nested labels update

### Using Real Component (Label.qml)

1. **Edit `components/Label.qml`:**
   - Modify the `TextPlain` component properties
   - Change font size or color
   - Save

2. **Observe:** All Labels using this component update throughout the app

## Test 4: Multiple File Changes

1. **Make changes to multiple files simultaneously:**
   - Edit `components/CheckBox.qml`
   - Edit `components/Label.qml`
   - Edit `main.qml`
   - Save all files

2. **Observe:** All changes should reload together (debounced to 500ms)

## Expected Behavior

✅ **Success Indicators:**
- Console shows: "QML file changed - reloading..."
- Console shows: "Reloading QML engine..."
- Console shows: "QML reloaded successfully"
- UI updates without application restart
- No errors in console

❌ **Failure Indicators:**
- No console messages about reloading
- UI doesn't update
- Application crashes
- Errors in console

## Troubleshooting

### Changes Not Appearing

1. **Check environment variable:**
   ```bash
   echo $QML_LIVE_RELOAD
   # Should output: 1
   ```

2. **Check console output:**
   - Look for "QML Live Reload enabled" message
   - Look for "Watching X paths for changes" message

3. **Verify file paths:**
   - Ensure files are in `components/`, `pages/`, or `wizard/` directories
   - Check that files are saved (not just modified in editor)

4. **Check file permissions:**
   - Ensure files are readable
   - In Docker, check volume mount permissions

### Application Crashes on Reload

1. **Check for syntax errors:**
   - QML syntax errors will cause reload to fail
   - Check console for error messages

2. **Check for missing imports:**
   - Ensure all imports are available
   - Check that component dependencies exist

3. **Restart application:**
   - If reload fails, restart the application
   - Fix syntax errors before trying again

## Test Checklist

- [ ] Simple text change works
- [ ] Color change works
- [ ] Nested component changes work
- [ ] Multiple file changes work
- [ ] Changes appear within 500ms
- [ ] No application crashes
- [ ] Console shows reload messages
- [ ] Works in Docker (if using Docker)
- [ ] Works with qmlscene
- [ ] Works with built application

## Next Steps

After confirming hot reload works:

1. **Use for development:**
   - Keep application running
   - Make QML changes
   - See updates instantly

2. **Optimize workflow:**
   - Use for UI tweaks
   - Test styling changes quickly
   - Iterate on layouts rapidly

3. **Remember limitations:**
   - C++ changes still require rebuild
   - Resource file changes require rebuild
   - Context property changes require restart

