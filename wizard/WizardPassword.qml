import QtQuick 2.2
import "../components"

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
        anchors.topMargin: 85
        spacing: 6

        ListModel {
            id: dotsModel
            ListElement { dotColor: "#36B05B" }
            ListElement { dotColor: "#FFE00A" }
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
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.top: parent.top
        anchors.topMargin: 74
        spacing: 24

        Text {
            anchors.left: parent.left
            width: headerColumn.width - dotsRow.width - 16
            font.family: "Arial"
            font.pixelSize: 28
            wrapMode: Text.Wrap
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
            text: qsTr("Now that your wallet has been created, please set a password for the wallet")
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 18
            wrapMode: Text.Wrap
            //renderType: Text.NativeRendering
            color: "#4A4646"
            text: qsTr("Note that this password cannot be recovered, and if forgotten you will need to restore your wallet from the mnemonic seed you were just given<br/><br/>
                        Your password will be used to protect your wallet and to confirm actions, so make sure that your password is sufficiently secure.")
        }
    }

    Item {
        id: passwordItem
        anchors.top: headerColumn.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        width: 300
        height: 62

        TextInput {
            anchors.fill: parent
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            font.family: "Arial"
            font.pixelSize: 32
            renderType: Text.NativeRendering
            color: "#35B05A"
            passwordCharacter: "•"
            echoMode: TextInput.Password
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

    PrivacyLevelSmall {
        id: privacyLevel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: passwordItem.bottom
        anchors.topMargin: 24
        background: "#F0EEEE"
        interactive: false
    }

    Item {
        id: retypePasswordItem
        anchors.top: privacyLevel.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        width: 300
        height: 62

        TextInput {
            anchors.fill: parent
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            font.family: "Arial"
            font.pixelSize: 32
            renderType: Text.NativeRendering
            color: "#35B05A"
            passwordCharacter: "•"
            echoMode: TextInput.Password
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
