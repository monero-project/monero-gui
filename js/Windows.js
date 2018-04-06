function setCustomWindowDecorations(custom) {
    var x = appWindow.x
    var y = appWindow.y
    if (x < 0)
    x = 0
    if (y < 0)
    y = 0
    persistentSettings.customDecorations = custom;
    
    // hides custom titlebar based on customDecorations
    titleBar.visible = custom;
    daemonConsolePopup.titleBar.visible = custom;

    if (custom) {
        appWindow.flags = Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint;
        daemonConsolePopup.flags = Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint;
    } else {
        appWindow.flags = Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint | Qt.WindowTitleHint | Qt.WindowMaximizeButtonHint;
        daemonConsolePopup.flags = Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint | Qt.WindowTitleHint | Qt.WindowMaximizeButtonHint;
    }

    appWindow.hide()
    appWindow.x = x
    appWindow.y = y
    appWindow.show()
}