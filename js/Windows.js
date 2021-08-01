var flagsCustomDecorations = (Qt.FramelessWindowHint | Qt.CustomizeWindowHint | Qt.WindowMinimizeButtonHint | Qt.WindowSystemMenuHint | Qt.Window);
var flags = (Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint | Qt.WindowCloseButtonHint | Qt.WindowTitleHint | Qt.WindowMaximizeButtonHint | Qt.WindowFullscreenButtonHint);

/**
 * Toggles window decorations
 * @param {bool} custom - toggle decorations
 */
function setCustomWindowDecorations(custom) {
    // save x,y positions, because we need to hide/show the window
    var x = appWindow.x
    var y = appWindow.y
    if (x < 0) x = 0
    if (y < 0) y = 0

    // Update persistentSettings
    persistentSettings.customDecorations = custom;

    titleBar.visible = custom;

    if (custom) {
        appWindow.flags = flagsCustomDecorations;
    } else {
        appWindow.flags = flags;
    }

    // Reset window
    appWindow.hide()
    appWindow.x = x
    appWindow.y = y
    appWindow.show()
}
