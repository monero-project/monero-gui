# macOS:

Use macOS 10.12 - 10.13 for better backwards compability.

1. `HOMEBREW_OPTFLAGS="-march=core2" HOMEBREW_OPTIMIZATION_LEVEL="O0" brew install boost zmq libpgm miniupnpc libsodium expat libunwind-headers protobuf libgcrypt hidapi`

2. Get the latest LTS from here: https://www.qt.io/offline-installers and install

3. `git clone --recursive -b v0.X.Y.Z --depth 1 https://github.com/monero-project/monero-gui` 

4. `CMAKE_PREFIX_PATH=~/Qt5.12.8/5.12.8/clang_64 make release`

5. `cd build/release && make deploy`

6. Replace the `monerod` binary inside `monero-wallet-gui.app/Contents/MacOS/` with one built using deterministic builds / gitian.

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

4. `xcrun altool -t osx --file monero-gui-mac-x64-v0.X.Y.Z.dmg --primary-bundle-id org.monero-project.monero-wallet-gui.dmg --notarize-app --username email@address.org`

5. `xcrun altool --notarization-info aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeee -u email@address.org`

6. `xcrun stapler staple -v monero-gui-mac-x64-v0.X.Y.Z.dmg`
