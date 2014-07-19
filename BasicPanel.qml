import QtQuick 2.0
import "components"

Rectangle {
    width: 470
    height: paymentId.y + paymentId.height + 12
    color: "#F0EEEE"
    border.width: 1
    border.color: "#DBDBDB"

    Rectangle {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        anchors.topMargin: 30
        height: 64
        color: "#FFFFFF"

        Image {
            id: logo
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -5
            anchors.left: parent.left
            anchors.leftMargin: 20
            source: "images/moneroLogo2.png"
        }

        Grid {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            columns: 3

            Text {
                width: 116
                height: 20
                font.family: "Arial"
                font.pixelSize: 12
                font.letterSpacing: -1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                color: "#535353"
                text: qsTr("Locked Balance:")
            }

            Text {
                id: balanceText
                width: 100
                height: 20
                font.family: "Arial"
                font.pixelSize: 18
                font.letterSpacing: -1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                color: "#000000"
                text: qsTr("78.9239845")
            }

            Item {
                height: 20
                width: 20

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    source: "images/lockIcon.png"
                }
            }

            Text {
                width: 116
                height: 20
                font.family: "Arial"
                font.pixelSize: 12
                font.letterSpacing: -1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                color: "#535353"
                text: qsTr("Availible Balance:")
            }

            Text {
                id: availableBalanceText
                width: 100
                height: 20
                font.family: "Arial"
                font.pixelSize: 14
                font.letterSpacing: -1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignBottom
                color: "#000000"
                text: qsTr("2324.9239845")
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#DBDBDB"
        }
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.margins: 12
        spacing: 12

        LineEdit {
            height: 32
            fontSize: 15
            width: parent.width - sendButton.width - row.spacing
            placeholderText: qsTr("amount...")
        }

        StandardButton {
            id: sendButton
            width: 60
            height: 32
            fontSize: 11
            text: qsTr("SEND")
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
        }
    }

    LineEdit {
        id: destinationLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: row.bottom
        anchors.margins: 12
        fontSize: 15
        height: 32
        placeholderText: qsTr("destination...")
    }

    Text {
        id: privacyLevelText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: destinationLine.bottom
        anchors.topMargin: 12

        font.family: "Arial"
        font.pixelSize: 12
        color: "#535353"
        text: qsTr("Privacy level")
    }

    PrivacyLevelSmall {
        id: privacyLevel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: privacyLevelText.bottom
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 12
    }

    LineEdit {
        id: paymentId
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: privacyLevel.bottom
        anchors.margins: 12
        fontSize: 15
        height: 32
        placeholderText: qsTr("payment ID (optional)...")
    }
}
