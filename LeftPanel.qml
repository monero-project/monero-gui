import QtQuick 2.2
import "components"

Rectangle {
    id: panel
    signal dashboardClicked()
    signal historyClicked()
    signal transferClicked()
    signal settingsClicked()
    signal addressBookClicked()
    signal miningClicked()

    width: 260
    color: "#FFFFFF"

    Image {
        id: logo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 31
        source: "images/moneroLogo.png"
    }

    Column {
        id: column1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: logo.bottom
        anchors.topMargin: 40
        spacing: 6

        Label {
            text: qsTr("Locked balance")
            anchors.left: parent.left
            anchors.leftMargin: 50
            tipText: qsTr("Test tip 1<br/><br/>line 2")
        }

        Row {
            Item {
                anchors.verticalCenter: parent.verticalCenter
                height: 26
                width: 50

                Image {
                    anchors.centerIn: parent
                    source: "images/lockIcon.png"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Arial"
                font.pixelSize: 26
                color: "#000000"
                text: "78.9239845"
            }
        }

        Item { //separator
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
        }

        Label {
            text: qsTr("Unlocked")
            anchors.left: parent.left
            anchors.leftMargin: 50
            tipText: qsTr("Test tip 2<br/><br/>line 2")
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 50
            font.family: "Arial"
            font.pixelSize: 18
            color: "#000000"
            text: "2324.9239845"
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: menuRect.top
        width: 1
        color: "#DBDBDB"
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: "#DBDBDB"
    }

    Rectangle {
        id: menuRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: column1.bottom
        anchors.topMargin: 50
        color: "#1C1C1C"

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            property var previousButton: dashboardButton
            MenuButton {
                id: dashboardButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Dashboard")
                symbol: qsTr("D")
                dotColor: "#FFE00A"
                checked: true
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = dashboardButton
                    panel.dashboardClicked()
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: dashboardButton.checked || transferButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }

            MenuButton {
                id: transferButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Transfer")
                symbol: qsTr("T")
                dotColor: "#FF6C3C"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = transferButton
                    panel.transferClicked()
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: transferButton.checked || historyButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }

            MenuButton {
                id: historyButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("History")
                symbol: qsTr("H")
                dotColor: "#6B0072"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = historyButton
                    panel.historyClicked()
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: historyButton.checked || addressBookButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }

            MenuButton {
                id: addressBookButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Address book")
                symbol: qsTr("B")
                dotColor: "#FF4F41"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = addressBookButton
                    panel.addressBookClicked()
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: addressBookButton.checked || miningButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }

            MenuButton {
                id: miningButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Mining")
                symbol: qsTr("M")
                dotColor: "#FFD781"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = miningButton
                    panel.miningClicked()
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: miningButton.checked || settingsButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }

            MenuButton {
                id: settingsButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Settings")
                symbol: qsTr("S")
                dotColor: "#36B25C"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = settingsButton
                    panel.settingsClicked()
                }
            }
        }

        NetworkStatusItem {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            connected: true
        }
    }
}
