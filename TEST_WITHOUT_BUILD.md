# Test Hot Reload Without Building

Since `qmlscene` may not have Qt modules installed, here's how to test hot reload with the actual application components:

## Option 1: Build and Test (Recommended)

```bash
# Build the application
cmake -G Ninja -B build -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt6;/opt/homebrew/opt/icu4c;/opt/homebrew/opt/abseil" -DCMAKE_CXX_FLAGS="-std=gnu++23"
cmake --build build

# Run with live reload
export QML_LIVE_RELOAD=1
./build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui
```

Then edit any QML file in `components/`, `pages/`, or `wizard/` and watch it update!

## Option 2: Test with Simple Components

Even without building, you can prepare test changes:

1. **Edit `components/CheckBox.qml`:**
   - Find line ~88: `color: (checkBox.enabled && checkBox.checked) ? "red" :`
   - Change `"red"` to `"blue"`
   - Save

2. **Edit `components/Label.qml`:**
   - Find line ~71: `font.pixelSize: fontSize`
   - Change to: `font.pixelSize: fontSize + 4`
   - Save

3. **When you build and run**, these changes will be visible immediately!

## Option 3: Use Qt Creator

If you have Qt Creator installed:

1. Open the project in Qt Creator
2. Open any QML file
3. Make changes
4. Qt Creator's QML Live Preview will show updates

## What Hot Reload Watches

The live reload system watches:
- `components/` directory
- `pages/` directory  
- `wizard/` directory
- `main.qml`
- `LeftPanel.qml`
- `MiddlePanel.qml`

Any changes to files in these locations will trigger automatic reload when `QML_LIVE_RELOAD=1` is set.

