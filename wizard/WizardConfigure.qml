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
            ListElement { dotColor: "#36B05B" }
            ListElement { dotColor: "#FFE00A" }
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

    Text {
        id: headerText
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 74
        anchors.leftMargin: 16
        width: parent.width - dotsRow.width - 16

        font.family: "Arial"
        font.pixelSize: 28
        wrapMode: Text.Wrap
        //renderType: Text.NativeRendering
        color: "#3F3F3F"
        text: qsTr("We’re almost there - let’s just configure some Monero preferences")
    }

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerText.bottom
        anchors.topMargin: 34
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 24

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            CheckBox {
                text: qsTr("Kickstart the Monero blockchain?")
                anchors.left: parent.left
                anchors.right: parent.right
                background: "#F0EEEE"
                fontColor: "#4A4646"
                fontSize: 18
                checkedIcon: "../images/checkedVioletIcon.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
                checked: true
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                font.family: "Arial"
                font.pixelSize: 15
                color: "#4A4646"
                wrapMode: Text.Wrap
                text: qsTr("It is very important to write it down as this is the only backup you will need for your wallet. " +
                           "You will be asked to confirm the seed in the next screen to ensure it has copied down correctly.")
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            CheckBox {
                text: qsTr("Enable disk conservation mode?")
                anchors.left: parent.left
                anchors.right: parent.right
                background: "#F0EEEE"
                fontColor: "#4A4646"
                fontSize: 18
                checkedIcon: "../images/checkedVioletIcon.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
                checked: true
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                font.family: "Arial"
                font.pixelSize: 15
                color: "#4A4646"
                wrapMode: Text.Wrap
                text: qsTr("Disk conservation mode uses substantially less disk-space, but the same amount of bandwidth as " +
                           "a regular Monero instance. However, storing the full blockchain is beneficial to the security " +
                           "of the Monero network. If you are on a device with limited disk space, then this option is appropriate for you.")
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 12

            CheckBox {
                text: qsTr("Allow background mining?")
                anchors.left: parent.left
                anchors.right: parent.right
                background: "#F0EEEE"
                fontColor: "#4A4646"
                fontSize: 18
                checkedIcon: "../images/checkedVioletIcon.png"
                uncheckedIcon: "../images/uncheckedIcon.png"
                checked: true
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                font.family: "Arial"
                font.pixelSize: 15
                color: "#4A4646"
                wrapMode: Text.Wrap
                text: qsTr("Mining secures the Monero network, and also pays a small reward for the work done. This option " +
                           "will let Monero mine when your computer is on mains power and is idle. It will stop mining when you continue working.")
            }
        }
    }
}
