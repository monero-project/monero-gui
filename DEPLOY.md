# macOS:

Use macOS 10.12 - 10.13 for better backwards compability.

1. `HOMEBREW_OPTFLAGS="-march=core2" HOMEBREW_OPTIMIZATION_LEVEL="O0" brew install boost zmq libpgm miniupnpc libsodium expat libunwind-headers protobuf libgcrypt`

2. `HOMEBREW_OPTFLAGS="-march=core2" HOMEBREW_OPTIMIZATION_LEVEL="O0" brew install --HEAD hidapi`

3. Get the latest LTS from here: https://www.qt.io/offline-installers and install

4. `export PATH=$PATH:$HOME/Qt5.12.8/5.12.8/clang_64/bin`

5. `git clone https://github.com/monero-project/monero-gui` 

6. `git checkout v0.X.Y.Z`

7. `sed -i '' s/ARCH=\"native\"/ARCH=\"x86-64\"/g get_libwallet_api.sh`

8. `sed -i '' s/-O2/-O0/g monero-wallet-gui.pro`

9. `./build.sh`

10. `cd build && make deploy`

11. `cd release/bin/monero-wallet-gui.app/Contents/PlugIns/imageformats/`

12. `cp ~/Qt5.12.8/5.12.8/clang_64/plugins/imageformats/libqsvg.dylib .`

13. `install_name_tool -change ~/Qt5.12.8/5.12.8/clang_64/clang_64/lib/QtGui.framework/Versions/5/QtGui @executable_path/../Frameworks/QtGui.framework/Versions/5/QtGui libqsvg.dylib`

14. `install_name_tool -change ~/Qt5.12.8/5.12.8/clang_64/clang_64/lib/QtWidgets.framework/Versions/5/QtWidgets @executable_path/../Frameworks/QtGui.framework/Versions/5/QtGui libqsvg.dylib`

15. `install_name_tool -change ~/Qt5.12.8/5.12.8/clang_64/lib/QtSvg.framework/Versions/5/QtSvg @executable_path/../Frameworks/QtGui.framework/Versions/5/QtGui libqsvg.dylib`
 
16. `install_name_tool -change ~/Qt5.12.8/5.12.8/clang_64/clang_64/lib/QtCore.framework/Versions/5/QtCore @executable_path/../Frameworks/QtGui.framework/Versions/5/QtGui libqsvg.dylib`

17. Replace the `monerod` binary inside `monero-wallet-gui.app/Contents/MacOS/` with one built using deterministic builds / gitian.

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
