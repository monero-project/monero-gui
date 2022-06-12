import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import FontAwesome 1.0
import "../components" as MoneroComponents

MenuItem {
    id: menuItem

    property bool glyphIconSolid: true
    property alias glyphIcon: glyphIcon.text

    background: Rectangle {
        color: MoneroComponents.Style.buttonBackgroundColorDisabledHover
        opacity: 0

        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                parent.opacity = 1;
            }
            onExited: {
                parent.opacity = 0;
            }
            onClicked: {
                if (menuItem.enabled) {
                    menuItem.triggered();
                    parent.opacity = 0;
                }
            }
        }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 10
        opacity: menuItem.enabled ? 1 : 0.4
        spacing: 8

        Text {
            id: glyphIcon

            color: MoneroComponents.Style.buttonTextColor
            font.family: glyphIconSolid ? FontAwesome.fontFamilySolid : FontAwesome.fontFamily
            font.pixelSize: 14
            font.styleName: glyphIconSolid ? "Solid" : "Regular"
        }

        Text {
            color: MoneroComponents.Style.blackTheme ? MoneroComponents.Style.buttonTextColor : MoneroComponents.Style.defaultFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            Layout.fillWidth: true
            text: menuItem.text
        }
    }
}
