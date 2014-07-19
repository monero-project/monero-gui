import QtQuick 2.0

Item {
    property alias placeholderText: input.placeholderText
    property alias text: input.text
    property int fontSize: 18
    height: 37

    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: 1
        color: "#DBDBDB"
        //radius: 4
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 1
        color: "#FFFFFF"
        //radius: 4
    }

    Input {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        font.pixelSize: parent.fontSize
    }
}
