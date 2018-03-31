// Copyright (c) 2014-2018, The Monero Project
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
import QtQuick.Layouts 1.1
import moneroComponents.Clipboard 1.0
import moneroComponents.AddressBookModel 1.0

import "../components" as MoneroComponents

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds
    property var previousItem
    property var addressBookModel: null

    function buildTxDetailsString(tx_id, paymentId, tx_key,tx_note, destinations, rings) {
        var trStart = '<tr><td width="85" style="padding-top:5px"><b>',
            trMiddle = '</b></td><td style="padding-left:10px;padding-top:5px;">',
            trEnd = "</td></tr>";

        return '<table border="0">'
            + (tx_id ? trStart + qsTr("Tx ID:") + trMiddle + tx_id + trEnd : "")
            + (paymentId ? trStart + qsTr("Payment ID:") + trMiddle + paymentId  + trEnd : "")
            + (tx_key ? trStart + qsTr("Tx key:") + trMiddle + tx_key + trEnd : "")
            + (tx_note ? trStart + qsTr("Tx note:") + trMiddle + tx_note  + trEnd : "")
            + (destinations ? trStart + qsTr("Destinations:") + trMiddle + destinations + trEnd : "")
            + (rings ? trStart + qsTr("Rings:") + trMiddle + rings + trEnd : "")
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
        height: 127 * scaleRatio
        width: listView.width
        color: "transparent"

        Text {
            anchors.centerIn: parent
            font.family: "Arial"
            font.pixelSize: 14 * scaleRatio
            color: "#545454"
            text: qsTr("No more results") + translationManager.emptyString
        }
    }

    delegate: Rectangle {
        id: delegate
        height: tableContent.height + 20 * scaleRatio
        width: listView.width
        color: "transparent"
        Layout.leftMargin: 10 * scaleRatio
        z: listView.count - index
        function collapseDropdown() { dropdown.expanded = false }

        Rectangle{
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: "#404040"
        }

        Rectangle{
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            width: 1
            color: "#404040"
        }

        Rectangle{
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: 1
            color: "#404040"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                var tx_key = currentWallet.getTxKey(hash)
                var tx_note = currentWallet.getUserNote(hash)
                var rings = currentWallet.getRings(hash)
                if (rings)
                    rings = rings.replace(/\|/g, '\n')
                informationPopup.title = "Transaction details";
                informationPopup.text = buildTxDetailsString(hash,paymentId,tx_key,tx_note,destinations, rings);
                informationPopup.open();
                informationPopup.onCloseCallback = null
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: 15 * scaleRatio
            anchors.top: parent.top
            anchors.topMargin: parent.height/2 - this.height/2
            width: 30 * scaleRatio; height: 30 * scaleRatio
            radius: 25
            color: "#404040"

            Image {
                width: 20 * scaleRatio
                height: 20 * scaleRatio
                fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent
                source: "qrc:///images/nextPage.png"
            }
        }

        ColumnLayout {
            id: tableContent
            // Date
            RowLayout {
                Layout.topMargin: 20 * scaleRatio
                Layout.leftMargin: 10 * scaleRatio
                Text {
                    font.family: MoneroComponents.Style.fontMedium.name
                    font.pixelSize: 14 * scaleRatio
                    color: MoneroComponents.Style.defaultFontColor
                    text: date
                }

                Text {
                    font.family: Style.fontRegular.name
                    font.pixelSize: 14 * scaleRatio
                    color: MoneroComponents.Style.dimmedFontColor
                    text: time
                }

                // Show confirmations
                Text {
                    visible: confirmations < confirmationsRequired || isPending
                    Layout.leftMargin: 5 * scaleRatio
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 14 * scaleRatio
                    color:  (confirmations < confirmationsRequired)? "#FF6C3C" : "#545454"
                    text: {
                        if (!isPending)
                            if(confirmations < confirmationsRequired)
                                return qsTr("(%1/%2 confirmations)").arg(confirmations).arg(confirmationsRequired)
                        if (!isOut)
                            return qsTr("UNCONFIRMED") + translationManager.emptyString
                        if (isFailed)
                            return qsTr("FAILED") + translationManager.emptyString
                        return qsTr("PENDING") + translationManager.emptyString

                    }
                }
            }

            // Amount & confirmations
            RowLayout {
                Layout.leftMargin: 10 * scaleRatio
                spacing: 2
                Text {
                    font.family: "Arial"
                    font.pixelSize: 14 * scaleRatio
                    color: isOut ? MoneroComponents.Style.defaultFontColor : "#2eb358"
                    text: isOut ? "↓" : "↑"
                }

                Text {
                    id: amountText
                    font.family: "Arial"
                    font.pixelSize: 18 * scaleRatio
                    color: isOut ? MoneroComponents.Style.defaultFontColor : "#2eb358"
                    text:  displayAmount
                }
            }
        }
    }

    ListModel {
        id: dropModel
        ListElement { name: "<b>Copy address to clipboard</b>"; icon: "../images/dropdownCopy.png" }
        ListElement { name: "<b>Add to address book</b>"; icon: "../images/dropdownAdd.png" }
        ListElement { name: "<b>Send to this address</b>"; icon: "../images/dropdownSend.png" }
        ListElement { name: "<b>Find similar transactions</b>"; icon: "../images/dropdownSearch.png" }
    }

    Clipboard { id: clipboard }
}
