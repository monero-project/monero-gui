import QtQuick 2.0

Row {
    id: item
    property bool connected: false

    Item {
        id: iconItem
        anchors.bottom: parent.bottom
        width: 50
        height: 50

        Image {
            anchors.centerIn: parent
            source: item.connected ? "../images/statusConnected.png" :
                                     "../images/statusDisconnected.png"
        }
    }

    Column {
        anchors.bottom: parent.bottom
        height: 53
        spacing: 3

        Text {
            anchors.left: parent.left
            font.family: "Arial"
            font.pixelSize: 12
            color: "#545454"
            text: qsTr("Network status")
        }

        Text {
            anchors.left: parent.left
            font.family: "Arial"
            font.pixelSize: 18
            color: item.connected ? "#FF6C3B" : "#AAAAAA"
            text: item.connected ? qsTr("Connected") : qsTr("Disconnected")
        }
    }
}
