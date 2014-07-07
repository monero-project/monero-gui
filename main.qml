import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import "components"

ApplicationWindow {
    id: appWindow
    property bool whatIsEnable: false
    property bool ctrlPressed: false
    function ctrlKeyPressed() { ctrlPressed = true; }
    function ctrlKeyReleased() { ctrlPressed = false; }

    visible: true
    width: 1269
    height: 932
    color: "#FFFFFF"
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    flags: Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint

    Item {
        id: rootItem
        anchors.fill: parent

        MouseArea {
            property var previousPosition
            anchors.fill: parent

            onPressed: previousPosition = Qt.point(mouseX, mouseY)
            onPositionChanged: {
                if (pressedButtons == Qt.LeftButton) {
                    var dx = mouseX - previousPosition.x
                    var dy = mouseY - previousPosition.y
                    appWindow.x += dx
                    appWindow.y += dy
                }
            }
        }

        LeftPanel {
            id: leftPanel
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onDashboardClicked: middlePanel.state = "Dashboard"
            onHistoryClicked: middlePanel.state = "History"
            onTransferClicked: middlePanel.state = "Transfer"
            onAddressBookClicked: middlePanel.state = "AddressBook"
            onMiningClicked: middlePanel.state = "Minning"
            onSettingsClicked: middlePanel.state = "Settings"
        }

        RightPanel {
            id: rightPanel
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }

        MiddlePanel {
            id: middlePanel
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: leftPanel.right
            anchors.right: rightPanel.left
            state: "Dashboard"
        }

        TipItem {
            id: tipItem
            text: "send to the same destination"
            visible: false
            z: 100
        }
    }
}
