import QtQuick 2.2
import QtQuick.Window 2.1

Window {
    property alias text: content.text
    property alias containsMouse: tipArea.containsMouse
    flags: Qt.ToolTip
    color: "transparent"
    height: rect.height + tip.height
    width: rect.width

    MouseArea {
        id: tipArea
        hoverEnabled: true
        anchors.fill: parent
    }

    Rectangle {
        id: rect
        width: content.width + 12
        height: content.height + 17
        color: "#FF6C3C"
        //radius: 3

        Image {
            id: tip
            anchors.top: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 5
            source: "../images/tip.png"
        }

        Text {
            id: content
            anchors.horizontalCenter: parent.horizontalCenter
            y: 6
            lineHeight: 0.7
            font.family: "Arial"
            font.pixelSize: 12
            font.letterSpacing: -1
            color: "#FFFFFF"
        }
    }
}
