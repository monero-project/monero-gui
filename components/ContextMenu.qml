import QtQuick.Controls 2.2
import QtQuick 2.9

import "../components" as MoneroComponents

MouseArea {
    signal paste()

    id: root
    acceptedButtons: Qt.RightButton
    anchors.fill: parent
    onClicked: {
        if (mouse.button === Qt.RightButton)
            contextMenu.open()
    }

    Menu {
        id: contextMenu

        background: Rectangle {
            radius: 2
            color: MoneroComponents.Style.buttonInlineBackgroundColor
        }

        font.family: MoneroComponents.Style.fontRegular.name
        font.pixelSize: 14
        width: 50
        x: root.mouseX
        y: root.mouseY

        MenuItem {
            id: pasteItem
            background: Rectangle {
                radius: 2
                color: MoneroComponents.Style.buttonBackgroundColorDisabledHover
                opacity: pasteItem.down ? 1 : 0
            }
            enabled: root.parent.canPaste
            onTriggered: root.paste()
            text: qsTr("Paste") + translationManager.emptyString
        }
    }
}
