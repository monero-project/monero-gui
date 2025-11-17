# Hot Reload Demonstration

This guide shows you how to test the hot reload functionality with visible changes.

## Quick Start Test

### Option 1: Using qmlscene (Fastest - QML Only)

```bash
# Start the test file
/opt/homebrew/opt/qt6/bin/qmlscene --live test-live-reload.qml
```

**Then:**
1. Open `test-live-reload.qml` in your editor
2. Change line 30: `color: "blue"` → `color: "red"`
3. Save the file
4. **Watch the rectangle turn red instantly!** ⚡

### Option 2: Using Built Application (Full Functionality)

```bash
# Build first (if not already built)
cmake --build build

# Start with live reload
export QML_LIVE_RELOAD=1
./build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui
```

**Then test these changes:**

#### Test 1: CheckBox Background Color
1. Edit `components/CheckBox.qml`
2. Find line ~92: `color: (checkBox.enabled && checkBox.checked) ? "red" :`
3. Change `"red"` to `"blue"` or `"#00ff00"`
4. Save
5. **Check any checkbox in the UI - background changes instantly!**

#### Test 2: Label Font Size
1. Edit `components/Label.qml`
2. Find line ~70: `font.pixelSize: fontSize`
3. Change to: `font.pixelSize: fontSize + 2` (makes all labels slightly larger)
4. Save
5. **All labels in the app update immediately!**

#### Test 3: TextPlain Color
1. Edit `components/TextPlain.qml`
2. Find any color property
3. Modify it (e.g., add a tint)
4. Save
5. **All text using TextPlain updates!**

## Expected Console Output

When you save a file, you should see:

```
QML file changed - reloading...
Reloading QML engine...
QML reloaded successfully
```

## Visual Test Checklist

- [ ] **Simple property change** - Change a color, see it update
- [ ] **Text change** - Modify label text, see it change
- [ ] **Nested component** - Change Label.qml, all labels update
- [ ] **Multiple files** - Change multiple files, all reload together
- [ ] **No restart needed** - App keeps running throughout

## Troubleshooting

**Not seeing updates?**
1. Check console for "QML Live Reload enabled" message
2. Verify `QML_LIVE_RELOAD=1` is set
3. Ensure files are in watched directories (`components/`, `pages/`, `wizard/`)
4. Check that files are actually saved (not just modified in editor)

**App crashes on reload?**
1. Check for QML syntax errors
2. Verify all imports are available
3. Restart app and fix errors

## Test Files Created

- `test-live-reload.qml` - Standalone test file for qmlscene
- `components/CheckBox.qml` - Modified with test comments
- `components/Label.qml` - Modified with test comments
- `TEST_HOT_RELOAD.md` - Detailed test guide
- `scripts/test-hot-reload.sh` - Interactive test script

## Next Steps

Once you confirm hot reload works:

1. **Use it for development:**
   - Keep app running
   - Make QML changes
   - See updates instantly

2. **Iterate quickly:**
   - UI tweaks
   - Styling changes
   - Layout adjustments

3. **Remember:**
   - C++ changes still need rebuild
   - Resource changes need rebuild
   - Context properties need restart

