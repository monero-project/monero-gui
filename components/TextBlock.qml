import QtQuick 2.9

import "../components" as NejCoinComponents

TextEdit {
    color: NejCoinComponents.Style.defaultFontColor
    font.family: NejCoinComponents.Style.fontRegular.name
    selectionColor: NejCoinComponents.Style.textSelectionColor
    wrapMode: Text.Wrap
    readOnly: true
    selectByMouse: true
    // Workaround for https://bugreports.qt.io/browse/QTBUG-50587
    onFocusChanged: {
        if(focus === false)
            deselect()
    }
}
