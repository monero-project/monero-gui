// Copyright (c) 2014-2015, The Monero Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0
import moneroComponents.Clipboard 1.0

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds
    
    footer: Rectangle {
        height: 127
        width: listView.width
        color: "#FFFFFF"

        Text {
            anchors.centerIn: parent
            font.family: "Arial"
            font.pixelSize: 14
            color: "#545454"
            text: qsTr("No more results") + translationManager.emptyString
        }
    }

    property var previousItem
    delegate: Rectangle {
        id: delegate
        height: 90
        width: listView.width
        color: index % 2 ? "#F8F8F8" : "#FFFFFF"
        z: listView.count - index
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
                    text: qsTr("Date")  + translationManager.emptyString
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
                    text: qsTr("Balance") + translationManager.emptyString
                }
                
                Text {
                    font.family: "Arial"
                    font.pixelSize: 18
                    font.letterSpacing: -1
                    color: "#000000"
                    text: balance
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
                    text: qsTr("Amount") + translationManager.emptyString
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
                        text: amount
                    }
                }
            }
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
            z: 1
            onExpandedChanged: {
                if(expanded) {
                    listView.previousItem = delegate
                    listView.currentIndex = index
                }
            }
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
