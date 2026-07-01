# macOS:

Use macOS 12 for better backwards compability.

1. `HOMEBREW_OPTFLAGS="-march=core2" HOMEBREW_OPTIMIZATION_LEVEL="O0" brew install boost zmq libpgm libsodium expat protobuf@21 libgcrypt hidapi libusb cmake pkg-config && brew link protobuf@21`

2. Get the latest LTS from here: https://www.qt.io/offline-installers and install

3. `git clone --recursive -b v0.X.Y.Z --depth 1 https://github.com/monero-project/monero-gui` 

4. Compile `monero-wallet-gui.app`

```bash
mkdir build && cd build
cmake -S . -B build -G Ninja -D ARCH=default -D CMAKE_PREFIX_PATH=/path/to/Qt6.8.3/
cmake --build build
cmake --build build --target deploy
```

5. Replace the `monerod` binary inside `monero-wallet-gui.app/Contents/MacOS/` with one built using deterministic builds / gitian.

## Codesigning and notarizing

1. Save the following text as `entitlements.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>com.apple.security.cs.disable-executable-page-protection</key>
        <true/>
</dict>
</plist>
```

2. `codesign --deep --force --verify --verbose --options runtime --timestamp --entitlements entitlements.plist --sign 'XXXXXXXXXX' monero-wallet-gui.app`

You can check if this step worked by using `codesign -dvvv monero-wallet-gui.app`

3. `hdiutil create -fs HFS+ -srcfolder monero-gui-v0.X.Y.Z -volname monero-wallet-gui monero-gui-mac-x64-v0.X.Y.Z.dmg`

4. `xcrun notarytool submit monero-gui-mac-x64-v0.X.Y.Z.dmg --apple-id email@address.org --team-id XXXXXXXXXX`

5. `xcrun notarytool info aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee --apple-id email@address.org --team-id XXXXXXXXXX`

6. `xcrun stapler staple -v monero-gui-mac-x64-v0.X.Y.Z.dmg`
