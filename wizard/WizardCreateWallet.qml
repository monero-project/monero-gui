import QtQuick 2.2

Item {
    opacity: 0
    visible: false
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    Row {
        id: dotsRow
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 74
        spacing: 6

        ListModel {
            id: dotsModel
            ListElement { dotColor: "#FFE00A" }
            ListElement { dotColor: "#DBDBDB" }
            ListElement { dotColor: "#DBDBDB" }
            ListElement { dotColor: "#DBDBDB" }
        }

        Repeater {
            model: dotsModel
            delegate: Rectangle {
                width: 12; height: 12
                radius: 6
                color: dotColor
            }
        }
    }

    Column {
        id: headerColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 74
        spacing: 24

        Text {
            width: headerColumn.width - dotsRow.width - 50
            font.family: "Arial"
            font.pixelSize: 28
            wrapMode: Text.Wrap
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
            text: qsTr("A new wallet has been created for you")
        }

        Text {
            font.family: "Arial"
            font.pixelSize: 18
            //renderType: Text.NativeRendering
            color: "#4A4646"
            text: qsTr("This is the name of your wallet. You can change it to a different name if you’d like:")
        }
    }

    Item {
        anchors.top: headerColumn.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50
        width: 300
        height: 62

        TextInput {
            anchors.fill: parent
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            font.family: "Arial"
            font.pixelSize: 32
            renderType: Text.NativeRendering
            color: "#FF6C3C"
            text: qsTr("My account name")
            focus: true
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#DBDBDB"
        }
    }
}
