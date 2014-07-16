import QtQuick 2.0
import "../components"
import moneroComponents 1.0

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds
    
    property var previousItem
    delegate: Rectangle {
        id: delegate
        height: 90
        width: listView.width
        z: 0
        color: index % 2 ? "#F8F8F8" : "#FFFFFF"
        function collapseDropdown() { dropdown.expanded = false }
        
        Row {
            id: row1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 14
            
            Rectangle {
                id: dot
                width: 14
                height: width
                radius: width / 2
                color: out ? "#FF4F41" : "#36B05B"
            }
            
            Item { //separator
                width: 12
                height: 14
            }
            
            Text {
                id: descriptionText
                width: text.length ? (descriptionArea.containsMouse ? parent.width - x - 12 : 120) : 0
                anchors.verticalCenter: dot.verticalCenter
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
            
            Item { //separator
                width: descriptionText.width ? 12 : 0
                height: 14
                visible: !descriptionArea.containsMouse
            }
            
            Text {
                id: addressText
                anchors.verticalCenter: dot.verticalCenter
                width: parent.width - x - 12
                elide: Text.ElideRight
                font.family: "Arial"
                font.pixelSize: 14
                color: "#545454"
                text: address
                visible: !descriptionArea.containsMouse
            }
        }
        
        Row {
            anchors.left: parent.left
            anchors.top: row1.bottom
            anchors.topMargin: 8
            spacing: 12
            
            Item { //separator
                width: 14
                height: 14
            }
            
            Column {
                anchors.top: parent.top
                width: 215
                
                Text {
                    anchors.left: parent.left
                    font.family: "Arial"
                    font.pixelSize: 12
                    color: "#545454"
                    text: qsTr("Date")
                }
                
                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 33

                    Text {
                        font.family: "Arial"
                        font.pixelSize: 18
                        font.letterSpacing: -1
                        color: "#000000"
                        text: date
                    }

                    Text {
                        font.family: "Arial"
                        font.pixelSize: 18
                        font.letterSpacing: -1
                        color: "#000000"
                        text: time
                    }
                }
            }
            
            Column {
                anchors.top: parent.top
                width: 148
                
                Text {
                    anchors.left: parent.left
                    font.family: "Arial"
                    font.pixelSize: 12
                    color: "#545454"
                    text: qsTr("Amount")
                }
                
                Text {
                    font.family: "Arial"
                    font.pixelSize: 18
                    font.letterSpacing: -1
                    color: "#000000"
                    text: amount
                }
            }
            
            Column {
                anchors.top: parent.top
                width: 148
                
                Text {
                    anchors.left: parent.left
                    font.family: "Arial"
                    font.pixelSize: 12
                    color: "#545454"
                    text: qsTr("Balance")
                }
                
                Row {
                    spacing: 2
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3
                        font.family: "Arial"
                        font.pixelSize: 16
                        color: out ? "#FF4F41" : "#36B05B"
                        text: out ? "↓" : "↑"
                    }
                    
                    Text {
                        anchors.bottom: parent.bottom
                        font.family: "Arial"
                        font.pixelSize: 18
                        font.letterSpacing: -1
                        color: out ? "#FF4F41" : "#36B05B"
                        text: balance
                    }
                }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: "#DBDBDB"
        }

        ListModel {
            id: dropModel
            ListElement { name: "<b>Copy address to clipboard</b>"; icon: "../images/dropdownCopy.png" }
            ListElement { name: "<b>Add to address book</b>"; icon: "../images/dropdownAdd.png" }
            ListElement { name: "<b>Send to same destination</b>"; icon: "../images/dropdownSend.png" }
            ListElement { name: "<b>Find similar transactions</b>"; icon: "../images/dropdownSearch.png" }
        }

        Clipboard { id: clipboard }
        TableDropdown {
            id: dropdown
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 11
            anchors.rightMargin: 5
            dataModel: dropModel
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
    }
}
