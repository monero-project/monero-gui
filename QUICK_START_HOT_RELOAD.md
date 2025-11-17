# Quick Start: Test Hot Reload (No Build Required!)

## Fastest Way to Test Hot Reload

**Use qmlscene - no build needed:**

```bash
./scripts/quick-test-reload.sh
```

This will:
1. Open a test window
2. Let you edit `test-live-reload.qml`
3. Show changes instantly when you save

## What to Do

1. **Run the script:**
   ```bash
   ./scripts/quick-test-reload.sh
   ```

2. **A window will open** showing test components

3. **Edit `test-live-reload.qml`** in your editor:
   - Change line 30: `color: "blue"` → `color: "red"`
   - Save the file
   - **Watch the rectangle turn red instantly!** ⚡

4. **Try other changes:**
   - Change text on line 18
   - Change nestedRect color on line 47
   - Modify any property
   - Save and see it update!

## If You Want to Test with Full App

The full app needs to be built first. The script will now ask you:

1. **Build now** (takes time)
2. **Use qmlscene instead** (quick test - recommended!)
3. **Exit and build manually**

Just choose option 2 for the quick test!

## Manual Build (If Needed)

If you want to test with the full application:

```bash
# Configure
cmake -G Ninja -B build -DCMAKE_PREFIX_PATH="/opt/homebrew/opt/qt6;/opt/homebrew/opt/icu4c;/opt/homebrew/opt/abseil" -DCMAKE_CXX_FLAGS="-std=gnu++23"

# Build (this takes time)
cmake --build build

# Run with hot reload
export QML_LIVE_RELOAD=1
./build/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui
```

But for quick testing, just use `./scripts/quick-test-reload.sh` - it's instant!

