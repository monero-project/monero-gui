import QtQuick 2.2

Rectangle {
    color: "#F0EEEE"

    states: [
        State {
            name: "Dashboard"
//            PropertyChanges { target: loader; source: "pages/Dashboard.qml" }
        }, State {
            name: "History"
            PropertyChanges { target: loader; source: "pages/History.qml" }
        }, State {
            name: "Transfer"
            PropertyChanges { target: loader; source: "pages/Transfer.qml" }
        }, State {
            name: "AddressBook"
            PropertyChanges { target: loader; source: "pages/AddressBook.qml" }
        }, State {
            name: "Settings"
            PropertyChanges { target: loader; source: "pages/Settings.qml" }
        }, State {
            name: "Mining"
            PropertyChanges { target: loader; source: "pages/Mining.qml" }
        }
    ]

    Row {
        id: styledRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Rectangle { height: 4; width: parent.width / 5; color: "#FFE00A" }
        Rectangle { height: 4; width: parent.width / 5; color: "#6B0072" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF6C3C" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FFD781" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF4F41" }
    }

    Loader {
        id: loader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: styledRow.bottom
        anchors.bottom: parent.bottom
    }

    Rectangle {
        anchors.top: styledRow.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 1
        color: "#DBDBDB"
    }

    Rectangle {
        anchors.top: styledRow.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 1
        color: "#DBDBDB"
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#DBDBDB"
    }
}
