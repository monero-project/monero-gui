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
        height: 64
        width: listView.width
        color: index % 2 ? "#F8F8F8" : "#FFFFFF"
        z: listView.count - index
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

        TextEdit {
            id: addressText
            selectByMouse: true
            anchors.bottom: descriptionText.bottom
            anchors.left: descriptionText.right
            anchors.right: dropdown.left
            anchors.leftMargin: description.length > 0 ? 12 : 0
            anchors.rightMargin: 40
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
            text: qsTr("Payment ID:") + translationManager.emptyString
        }

        TextEdit {
            selectByMouse: true;
            anchors.bottom: paymentLabel.bottom
            anchors.left: paymentLabel.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.right: dropdown.left


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
//            ListElement { name: "<b>Find similar transactions</b>"; icon: "../images/dropdownSearch.png" }
            ListElement { name: "<b>Remove from address book</b>"; icon: "../images/dropdownDel.png" }
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
                if(expanded) {
                    listView.previousItem = delegate
                    listView.currentIndex = index
                }
            }
            onOptionClicked: {
                // Ensure tooltip is closed
                appWindow.toolTip.visible = false;
                if(option === 0)
                    clipboard.setText(address)
                else if(option === 1){
                   console.log("Sending to: ", address +" "+ paymentId);
                   middlePanel.sendTo(address, paymentId, description);
                   leftPanel.selectItem(middlePanel.state)
                } else if(option === 2){
                    console.log("Delete: ", rowId);
                    currentWallet.addressBookModel.deleteRow(rowId);
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
    }
}
