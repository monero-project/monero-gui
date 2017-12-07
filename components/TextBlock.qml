import QtQuick 2.0

import "." 1.0

TextEdit {
    color: Style.defaultFontColor
    font.family: Style.fontRegular.name
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
