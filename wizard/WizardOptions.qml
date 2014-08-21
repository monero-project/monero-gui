import QtQuick 2.2

Item {
    id: page
    signal createWalletClicked()
    opacity: 0
    visible: false
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    Column {
        id: headerColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 74
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 24

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 28
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
            wrapMode: Text.Wrap
            text: qsTr("I want")
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 18
            //renderType: Text.NativeRendering
            color: "#4A4646"
            wrapMode: Text.Wrap
            text: qsTr("Please select one of the following options:")
        }
    }

    Row {
        anchors.verticalCenterOffset: 35
        anchors.centerIn: parent
        spacing: 40

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30

            Rectangle {
                width: 202; height: 202
                radius: 101
                color: createWalletArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

                Image {
                    anchors.centerIn: parent
                    source: "qrc:///images/createWallet.png"
                }

                MouseArea {
                    id: createWalletArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: page.createWalletClicked()
                }
            }

            Text {
                font.family: "Arial"
                font.pixelSize: 16
                color: "#4A4949"
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("This is my first time, I want to<br/>create a new account")
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30

            Rectangle {
                width: 202; height: 202
                radius: 101
                color: recoverWalletArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

                Image {
                    anchors.centerIn: parent
                    source: "qrc:///images/recoverWallet.png"
                }

                MouseArea {
                    id: recoverWalletArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            Text {
                font.family: "Arial"
                font.pixelSize: 16
                color: "#4A4949"
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("I want to recover my account<br/>from my 24 work seed")
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30

            Rectangle {
                width: 202; height: 202
                radius: 101
                color: openAccountArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

                Image {
                    anchors.centerIn: parent
                    source: "qrc:///images/openAccount.png"
                }

                MouseArea {
                    id: openAccountArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            Text {
                font.family: "Arial"
                font.pixelSize: 16
                color: "#4A4949"
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("I want to open account file")
            }
        }
    }
}
