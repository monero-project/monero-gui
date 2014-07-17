import QtQuick 2.0

Rectangle {
    property alias text: content.text
    width: content.width + 12
    height: content.height + 17
    color: "#FF6C3C"
    //radius: 3

    Image {
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
