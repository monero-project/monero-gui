import QtQuick 2.0
import "../components"

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
                id: paymentIdText
                width: text.length ? 122 : 0
                anchors.verticalCenter: dot.verticalCenter
                font.family: "Arial"
                font.bold: true
                font.pixelSize: 19
                color: "#444444"
                elide: Text.ElideRight
                text: paymentId
            }
            
            Item { //separator
                width: paymentIdText.width ? 12 : 0
                height: 14
            }
            
            Text {
                anchors.verticalCenter: dot.verticalCenter
                width: parent.width - x - 12
                elide: Text.ElideRight
                font.family: "Arial"
                font.pixelSize: 14
                color: "#545454"
                text: description.length > 0 ? description : address
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
                width: 202
                
                Text {
                    anchors.left: parent.left
                    font.family: "Arial"
                    font.pixelSize: 12
                    color: "#545454"
                    text: qsTr("Date")
                }
                
                Text {
                    font.family: "Arial"
                    font.pixelSize: 18
                    color: "#000000"
                    text: date
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

        TableDropdown {
            id: dropdown
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 11
            anchors.rightMargin: 5
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
        }
    }
}
