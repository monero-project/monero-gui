import QtQuick 2.0
import moneroComponents 1.0

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds

    property var previousItem
    delegate: Rectangle {
        id: delegate
        height: 64
        width: listView.width
        color: index % 2 ? "#F8F8F8" : "#FFFFFF"
        function collapseDropdown() { dropdown.expanded = false }

        Text {
            id: descriptionText
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 12
            width: text.length ? (descriptionArea.containsMouse ? dropdown.x - x - 12 : 139) : 0
            font.family: "Arial"
            font.bold: true
            font.pixelSize: 19
            color: "#444444"
            elide: Text.ElideRight
            text: description

            MouseArea {
                id: descriptionArea
                anchors.fill: parent
                hoverEnabled: true
            }
        }

        Text {
            id: addressText
            anchors.bottom: descriptionText.bottom
            anchors.left: descriptionText.right
            anchors.right: dropdown.left
            anchors.leftMargin: description.length > 0 ? 12 : 0
            anchors.rightMargin: 12
            elide: Text.ElideRight
            font.family: "Arial"
            font.pixelSize: 16
            font.letterSpacing: -1
            color: "#545454"
            text: address
        }

        Text {
            id: paymentLabel
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 12

            width: 139
            font.family: "Arial"
            font.pixelSize: 12
            font.letterSpacing: -1
            color: "#535353"
            text: qsTr("Payment ID:")
        }

        Text {
            anchors.bottom: paymentLabel.bottom
            anchors.left: paymentLabel.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.right: dropdown.left

            elide: Text.ElideRight
            font.family: "Arial"
            font.pixelSize: 13
            font.letterSpacing: -1
            color: "#545454"
            text: paymentId
        }

        ListModel {
            id: dropModel
            ListElement { name: "<b>Copy address to clipboard</b>"; icon: "../images/dropdownCopy.png" }
            ListElement { name: "<b>Send to same destination</b>"; icon: "../images/dropdownSend.png" }
            ListElement { name: "<b>Find similar transactions</b>"; icon: "../images/dropdownSearch.png" }
            ListElement { name: "<b>Remove from history</b>"; icon: "../images/dropdownDel.png" }
        }

        Clipboard { id: clipboard }
        TableDropdown {
            id: dropdown
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 5
            dataModel: dropModel
            z: 1
            onExpandedChanged: {
                if(listView.previousItem !== undefined && listView.previousItem !== delegate)
                    listView.previousItem.collapseDropdown()
                if(expanded) {
                    listView.previousItem = delegate
                    listView.currentIndex = index
                    listView.currentItem.z = 2
                }
            }
            onCollapsed: delegate.z = 0
            onOptionClicked: {
                if(option === 0)
                    clipboard.setText(address)
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
}
