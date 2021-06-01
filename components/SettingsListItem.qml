import QtQuick 2.9
import QtQuick.Layouts 1.1
import FontAwesome 1.0

import "../components" as MoneroComponents

ColumnLayout {
    id: settingsListItem
    property alias iconText: iconLabel.text
    property alias tooltip: label.tooltip
    property alias title: label.text
    signal clicked()

    Layout.fillWidth: true
    spacing: 0

    Rectangle {
        id: root
        Layout.fillWidth: true
        Layout.minimumWidth: 150
        Layout.fillHeight: true
        Layout.minimumHeight: 90
        color: "transparent"

        Rectangle {
            id: rect
            height: root.height
            width: root.width
            color: "transparent";

            Rectangle {
                id: icon
                color: "transparent"
                height: 32
                width: 32
                anchors.centerIn: rect

                MoneroComponents.Label {
                    id: iconLabel
                    anchors.centerIn: icon
                    fontSize: 32
                    fontFamily: FontAwesome.fontFamilySolid
                    fontColor: MoneroComponents.Style.defaultFontColor
                    styleName: "Solid"
                    opacity: 0.65
                }
            }

            MoneroComponents.TextPlain {
                id: label
                anchors.top: icon.bottom
                anchors.topMargin: 5
                anchors.horizontalCenter: icon.horizontalCenter
                color: MoneroComponents.Style.defaultFontColor
                opacity: 0.65
                font.bold: true
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 16
                wrapMode: Text.WordWrap
            }
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                label.tooltip ? label.tooltipPopup.open() : ""
                iconLabel.fontSize = 36
                iconLabel.opacity = 1
                label.opacity = 1
            }
            onExited: {
                label.tooltip ? label.tooltipPopup.close() : ""
                iconLabel.fontSize = 32
                iconLabel.opacity = 0.65
                label.opacity = 0.65
            }
            onClicked: {
                settingsListItem.clicked()
            }
        }
    }
}
