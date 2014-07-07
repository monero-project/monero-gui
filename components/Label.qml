import QtQuick 2.0

Item {
    property alias text: label.text
    property alias color: label.color
    property int fontSize: 12
    width: icon.x + icon.width
    height: icon.height

    Text {
        id: label
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.left: parent.left
        font.family: "Arial"
        font.pixelSize: parent.fontSize
        color: "#555555"
    }

    Image {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: label.right
        anchors.leftMargin: 5
        source: "../images/whatIsIcon.png"
        visible: appWindow.whatIsEnable
    }
}
