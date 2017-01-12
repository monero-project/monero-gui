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
import moneroComponents.AddressBookModel 1.0


ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds
    property var previousItem
    property int rowSpacing: 12
    property var addressBookModel: null

    function buildTxDetailsString(tx_id, paymentId, tx_key,tx_note, destinations) {
        var trStart = '<tr><td width="85" style="padding-top:5px"><b>',
            trMiddle = '</b></td><td style="padding-left:10px;padding-top:5px;">',
            trEnd = "</td></tr>";

        return '<table border="0">'
            + (tx_id ? trStart + qsTr("Tx ID:") + trMiddle + tx_id + trEnd : "")
            + (paymentId ? trStart + qsTr("Payment ID:") + trMiddle + paymentId  + trEnd : "")
            + (tx_key ? trStart + qsTr("Tx key:") + trMiddle + tx_key + trEnd : "")
            + (tx_note ? trStart + qsTr("Tx note:") + trMiddle + tx_note  + trEnd : "")
            + (destinations ? trStart + qsTr("Destinations:") + trMiddle + destinations + trEnd : "")
            + "</table>"
            + translationManager.emptyString;
    }

    function lookupPaymentID(paymentId) {
        if (!addressBookModel)
            return ""
        var idx = addressBookModel.lookupPaymentID(paymentId)
        if (idx < 0)
            return ""
        idx = addressBookModel.index(idx, 0)
        return addressBookModel.data(idx, AddressBookModel.AddressBookDescriptionRole)
    }


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

    StandardDialog {
        id: detailsPopup
        cancelVisible: false
        okVisible: true
        width:850
    }


    delegate: Rectangle {
        id: delegate
        height: 144
        width: listView.width
        color: index % 2 ? "#F8F8F8" : "#FFFFFF"
        z: listView.count - index
        function collapseDropdown() { dropdown.expanded = false }

        StandardButton {
            id: detailsButton
            anchors.right:parent.right
            anchors.rightMargin: 15
            anchors.top: parent.top
            anchors.topMargin: parent.height/2 - this.height/2
            width: 80
            fontSize: 14
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            text: qsTr("Details")
            onClicked: {
                var tx_key = currentWallet.getTxKey(hash)
                var tx_note = currentWallet.getUserNote(hash)
                detailsPopup.title = "Transaction details";
                detailsPopup.content = buildTxDetailsString(hash,paymentId,tx_key,tx_note,destinations);
                detailsPopup.open();

            }
        }



        Row {
            id: row1
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 14
            // -- direction indicator
            Rectangle {
                id: dot
                width: 14
                height: width
                radius: width / 2
                color: isOut ? "#FF4F41" : "#36B05B"
            }

            Item { //separator
                width: 12
                height: 14
            }

            // -- description aka recepient name from address book (TODO)
            /*
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
            */
            /*
            Item { //separator
                width: descriptionText.width ? 12 : 0
                height: 14
                visible: !descriptionArea.containsMouse
            }
            */
            // -- address (in case outgoing transaction) - N/A in case of incoming
            TextEdit {
                id: addressText
                readOnly: true
                selectByMouse: true
                anchors.verticalCenter: dot.verticalCenter
                width: parent.width - x - 12
                //elide: Text.ElideRight
                font.family: "Arial"
                font.pixelSize: 14
                color: "#545454"
                text: hash
                // visible: !descriptionArea.containsMouse
            }
        }

        Row {
            // - Payment ID
            id: row2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.leftMargin: 26

            // -- "PaymentID" title
            Text {
                id: paymentLabel
                width: 86
                anchors.bottom: parent.bottom
                font.family: "Arial"
                font.pixelSize: 12
                font.letterSpacing: -1
                color: "#535353"
                text: paymentId !== "" ? qsTr("Payment ID:")  + translationManager.emptyString : ""
            }
            // -- "PaymentID" value
            TextEdit {
                readOnly: true
                selectByMouse: true
                id: paymentIdValue
                width: 136
                anchors.bottom: parent.bottom
                //elide: Text.ElideRight
                font.family: "Arial"
                font.pixelSize:13
                font.letterSpacing: -1
                color: "#545454"
                text: paymentId

            }
            // Address book lookup
            TextEdit {
                readOnly: true
                selectByMouse: true
                id: addressBookLookupValue
                width: 136
                anchors.bottom: parent.bottom
                //elide: Text.ElideRight
                font.family: "Arial"
                font.pixelSize:13
                font.letterSpacing: -1
                color: "#545454"
                text: "(" + lookupPaymentID(paymentId) + ")"
                visible: text !== "()"
            }
        }
        Row {
            // block height row
            id: row3
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: row2.bottom
            anchors.topMargin: rowSpacing
            anchors.leftMargin: 26

            // -- "BlockHeight" title
            Text {
                id: blockHeghtTitle
                anchors.bottom: parent.bottom
                width: 86
                font.family: "Arial"
                font.pixelSize: 12
                font.letterSpacing: -1
                color: "#535353"
                text:  qsTr("BlockHeight:")  + translationManager.emptyString
            }
            // -- "BlockHeight" value
            TextEdit {
                readOnly: true
                selectByMouse: true
                width: 85
                anchors.bottom: parent.bottom
                //elide: Text.ElideRight
                font.family: "Arial"
                font.pixelSize: 13
                color:  (confirmations < 10)? "#FF6C3C" : "#545454"
                text: {
                    if (!isPending)
                        if(confirmations < 10)
                            return blockHeight + " " + qsTr("(%1/10 confirmations)").arg(confirmations)
                        else
                            return blockHeight
                    if (!isOut)
                        return qsTr("UNCONFIRMED") + translationManager.emptyString
                    return qsTr("PENDING") + translationManager.emptyString

                }
            }
        }

        // -- "Date", "Balance" and "Amound" section
        Row {
            id: row4
            anchors.top: row3.bottom
            anchors.left: parent.left
            spacing: 12
            anchors.topMargin: rowSpacing

            Item { //separator
                width: 14
                height: 14
            }

            // -- "Date" column
            Column {
                anchors.top: parent.top
                width: 215

                Text {
                    anchors.left: parent.left
                    font.family: "Arial"
                    font.pixelSize: 12
                    color: "#545454"
                    text: qsTr("Date") + translationManager.emptyString
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
            // -- "Balance" column
            // XXX: we don't have a balance
            /*
            Column {
                anchors.top: parent.top
                width: 148
                visible: false

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
            */

            // -- "Amount column
            Column {
                anchors.top: parent.top

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
                        color: isOut ? "#FF4F41" : "#36B05B"
                        text: isOut ? "↓" : "↑"
                    }

                    Text {
                        id: amountText
                        anchors.bottom: parent.bottom
                        font.family: "Arial"
                        font.pixelSize: 18
                        font.letterSpacing: -1
                        color: isOut ? "#FF4F41" : "#36B05B"
                        text:  displayAmount
                    }
                }
            }

            // -- "Fee column
            Column {
                anchors.top: parent.top
                width: 148
                visible: isOut
                Text {
                    anchors.left: parent.left
                    font.family: "Arial"
                    font.pixelSize: 12
                    color: "#545454"
                    text: qsTr("Fee") + translationManager.emptyString
                }

                Row {
                    spacing: 2
                    Text {
                        anchors.bottom: parent.bottom
                        font.family: "Arial"
                        font.pixelSize: 18
                        font.letterSpacing: -1
                        color: "#FF4F41"
                        text:  fee
                    }
                }
            }
        }


        /*
        // Transaction dropdown menu.
        // Disable for now until AddressBook implemented
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
        */
    }

    ListModel {
        id: dropModel
        ListElement { name: "<b>Copy address to clipboard</b>"; icon: "../images/dropdownCopy.png" }
        ListElement { name: "<b>Add to address book</b>"; icon: "../images/dropdownAdd.png" }
        ListElement { name: "<b>Send to same destination</b>"; icon: "../images/dropdownSend.png" }
        ListElement { name: "<b>Find similar transactions</b>"; icon: "../images/dropdownSearch.png" }
    }

    Clipboard { id: clipboard }
}
