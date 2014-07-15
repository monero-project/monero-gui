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
        fontSize: 14
    }

    Label {
        id: transactionPriority
        anchors.top: parent.top
        anchors.topMargin: 17
        fontSize: 14
        x: (parent.width - 17) / 2 + 17
        text: qsTr("Transaction prority")
    }

    Row {
        anchors.top: amountLabel.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 7
        width: (parent.width - 17) / 2 + 10
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
        id: priorityDropdown
        anchors.top: transactionPriority.bottom
        anchors.right: parent.right
        anchors.rightMargin: 17
        anchors.topMargin: 5
        anchors.left: transactionPriority.left
        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        z: 1
    }

    Label {
        id: privacyLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: priorityDropdown.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 30
        fontSize: 14
        text: qsTr("Privacy Level")
    }

    PrivacyLevel {
        id: privacyLevelItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: privacyLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
    }

    Label {
        id: addressLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: privacyLevelItem.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 30
        fontSize: 14

        textFormat: Text.RichText
        text: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>\
                    Address <font size='2'>  ( Type in  or select from </font> <a href='#'>Address</a><font size='2'> book )</font>")

        onLinkActivated: appWindow.showPageRequest("AddressBook")
    }

    LineEdit {
        id: addressLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: addressLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
    }

    Label {
        id: paymentLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: addressLine.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 17
        fontSize: 14
        text: qsTr("Payment ID <font size='2'>( Optional )</font>")
    }

    LineEdit {
        id: paymentLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: paymentLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
    }

    Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: paymentLine.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 17
        spacing: 17

        StandardButton {
            id: sendButton
            width: 60
            text: qsTr("SEND")
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
        }

        CheckBox {
            id: checkBox
            text: qsTr("Add to Address book")
            anchors.bottom: sendButton.bottom
        }
    }
}
