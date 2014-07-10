import QtQuick 2.0
import "../components"

Rectangle {
    color: "#F0EEEE"

    Label {
        id: amountLabel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 17
        text: qsTr("Amount")
    }

    Label {
        id: transactionPriority
        anchors.top: parent.top
        anchors.topMargin: 17
        x: (parent.width - 17) / 2 + 17
        text: qsTr("Transaction prority")
    }

    Row {
        anchors.top: amountLabel.bottom
        anchors.topMargin: 17
        width: (parent.width - 17) / 2
        Item {
            width: 37
            height: 37

            Image {
                anchors.centerIn: parent
                source: "../images/moneroIcon.png"
            }
        }

        LineEdit {
            placeholderText: qsTr("Amount...")
            width: parent.width - 37 - 17
        }
    }

    StandardDropdown {
        anchors.top: transactionPriority.bottom
        anchors.right: parent.right
        anchors.rightMargin: 17
        anchors.topMargin: 17
        anchors.left: transactionPriority.left
        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        z: 1
    }
}
