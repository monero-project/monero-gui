# Rules for deploying the application. For macos, windows and android use qt tools
# to add required qt libraries and qml modules to the application bundle.

# This isn't needed for linux where we're using system libraries on $PATH or
# qt is statically linked.

macx {
    QMAKE_POST_LINK = macdeployqt $$sprintf("%1/%2/%3.app", $$OUT_PWD, $$DESTDIR, $$TARGET) \
        -qmldir=$$PWD
}

win32 {
    QMAKE_POST_LINK = windeployqt $$sprintf("%1/%2/%3.exe", $$OUT_PWD, $$DESTDIR, $$TARGET) \
        -release -no-translations -qmldir=$$PWD

    # Win64 msys2 deploy settings
    contains(QMAKE_HOST.arch, x86_64) {
        QMAKE_POST_LINK = $$PWD/windeploy_helper.sh $$DESTDIR
    }
}

linux:!android {
    TARGET = monero-wallet-gui
    QMAKE_POST_LINK = $$PWD/linuxdeploy_helper.sh $$sprintf("%1/%2 %3", $$OUT_PWD, $$DESTDIR, $$TARGET)
}

android {
    QMAKE_POST_LINK = make install INSTALL_ROOT=$$DESTDIR && androiddeployqt \
        --input android-libmonero-wallet-gui.so-deployment-settings.json --output $$DESTDIR \
        --deployment bundled --android-platform android-21 --jdk /usr/lib/jvm/java-8-openjdk-amd64 \
        -qmldir=$$PWD
}
