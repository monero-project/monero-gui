import QtQuick 2.9

import "../components" as MoneroComponents

TextEdit {
    color: MoneroComponents.Style.defaultFontColor
    font.family: MoneroComponents.Style.fontRegular.name
    selectionColor: MoneroComponents.Style.textSelectionColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
