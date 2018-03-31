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
import moneroComponents.Clipboard 1.0
import moneroComponents.AddressBookModel 1.0

import "../components" as MoneroComponents
import "../js/TxUtils.js" as TxUtils

ListView {
    id: listView
    clip: true
    boundsBehavior: ListView.StopAtBounds
    property var previousItem
    property int rowSpacing: 12
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
            font.pixelSize: 14
            color: "#545454"
            text: qsTr("No more results") + translationManager.emptyString
        }
    }

    delegate: Rectangle {
        id: delegate
        property bool collapsed: index ? false : true
        height: collapsed ? 180 * scaleRatio : 70 * scaleRatio
        width: listView.width
        color: "transparent"

        function collapse(){
            delegate.height = 180 * scaleRatio;
        }

        // borders
        Rectangle{
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: 1
            color: "#404040"
        }

        Rectangle{
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: collapsed ? 2 : 1
            color: collapsed ? "#BBBBBB" : "#404040"
        }

        Rectangle{
            anchors.right: parent.right
            anchors.bottom: parent.top
            anchors.left: parent.left
            height: 1
            color: "#404040"
        }

        Rectangle{
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: 1
            color: "#404040"
        }

        Rectangle {
            id: row1
            anchors.left: parent.left
            anchors.leftMargin: 20 * scaleRatio
            anchors.right: parent.right
            anchors.rightMargin: 20 * scaleRatio
            anchors.top: parent.top
            anchors.topMargin: 15 * scaleRatio
            height: 40 * scaleRatio
            color: "transparent"

            Image {
                id: arrowImage
                source: isOut ? "../images/downArrow.png" : "../images/upArrow-green.png"
                height: 18 * scaleRatio
                width: 12 * scaleRatio
                anchors.top: parent.top
                anchors.topMargin: 12 * scaleRatio
            }

            Text {
                id: txrxLabel
                anchors.left: arrowImage.right
                anchors.leftMargin: 18 * scaleRatio
                font.family: MoneroComponents.Style.fontLight.name
                font.pixelSize: 14 * scaleRatio
                text: isOut ? "Sent" : "Received"
                color: "#808080"
            }

            Text {
                id: amountLabel
                anchors.left: arrowImage.right
                anchors.leftMargin: 18 * scaleRatio
                anchors.top: txrxLabel.bottom
                anchors.topMargin: 0 * scaleRatio
                font.family: MoneroComponents.Style.fontBold.name
                font.pixelSize: 18 * scaleRatio
                font.bold: true
                text: {
                    var _amount = amount;
                    if(_amount === 0){
                        // *sometimes* amount is 0, while the 'destinations string' 
                        // has the correct amount, so we try to fetch it from that instead.
                        _amount = TxUtils.destinationsToAmount(destinations);
                        _amount = (_amount *1);
                    }

                    return _amount + " XMR";
                }
                color: isOut ? "white" : "#2eb358"
            }

            Rectangle {
                anchors.right: parent.right
                width: 300 * scaleRatio
                height: parent.height
                color: "transparent"

                Text {
                    id: dateLabel
                    anchors.left: parent.left
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 14 * scaleRatio
                    text: date
                    color: "#808080"
                }

                Text {
                    id: timeLabel
                    anchors.left: dateLabel.right
                    anchors.leftMargin: 7 * scaleRatio
                    anchors.top: parent.top
                    anchors.topMargin: 3 * scaleRatio
                    font.pixelSize: 12 * scaleRatio
                    text: time
                    color: "#808080"
                }

                Text {
                    id: toLabel
                    property string address: ""
                    color: "#BBBBBB"
                    anchors.left: parent.left
                    anchors.top: dateLabel.bottom
                    anchors.topMargin: 0
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16 * scaleRatio
                    text: {
                        if(isOut){
                            address = TxUtils.destinationsToAddress(destinations);
                            if(address){
                                var truncated = TxUtils.addressTruncate(address);
                                return "To " + truncated;
                            } else {
                                return "Unknown recipient";
                            }
                        }
                        return "";
                    }

                    MouseArea{
                        visible: parent.address !== undefined
                        hoverEnabled: true
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            toLabel.color = "white";
                        }
                        onExited: {
                            toLabel.color = "#BBBBBB";
                        }
                        onClicked: {
                            if(parent.address){
                                console.log("Address copied to clipboard");
                                clipboard.setText(parent.address);
                                appWindow.showStatusMessage(qsTr("Address copied to clipboard"),3)
                            }
                        }
                    }
                }

                Rectangle {
                    height: 24 * scaleRatio
                    width: 24 * scaleRatio
                    color: "transparent"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: dropdownImage
                        height: 8 * scaleRatio
                        width: 12 * scaleRatio
                        source: "../images/whiteDropIndicator.png"
                        rotation: delegate.collapsed ? 180 : 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            delegate.collapsed = !delegate.collapsed;
                        }
                    }
                }
            }
        }

        Rectangle {
            id: row2
            anchors.left: parent.left
            anchors.leftMargin: 20 * scaleRatio
            anchors.right: parent.right
            anchors.rightMargin: 20 * scaleRatio
            anchors.top: row1.bottom
            anchors.topMargin: 15 * scaleRatio
            height: 40 * scaleRatio
            color: "transparent"
            visible: delegate.collapsed

            // left column
            MoneroComponents.HistoryTableInnerColumn{
                anchors.left: parent.left
                anchors.leftMargin: 30 * scaleRatio

                labelHeader: "Transaction ID"
                labelValue: hash.substring(0, 18) + "..."
                copyValue: hash
            }

            // right column
            MoneroComponents.HistoryTableInnerColumn{
                anchors.right: parent.right
                anchors.rightMargin: 100 * scaleRatio
                width: 200 * scaleRatio
                height: parent.height
                color: "transparent"

                labelHeader: qsTr("Fee")
                labelValue: {
                    if(!isOut && !fee){
                        return "-";
                    } else if(isOut && fee){
                        return fee + " XMR";
                    } else {
                        return "Unknown"
                    }
                }
                copyValue: {
                    if(isOut && fee){ return fee }
                    else { return "" }
                }
            }

        }

        Rectangle {
            id: row3
            anchors.left: parent.left
            anchors.leftMargin: 20 * scaleRatio
            anchors.right: parent.right
            anchors.rightMargin: 20 * scaleRatio
            anchors.top: row2.bottom
            anchors.topMargin: 15 * scaleRatio
            height: 40 * scaleRatio
            color: "transparent"
            visible: delegate.collapsed

            // left column
            MoneroComponents.HistoryTableInnerColumn{
                anchors.left: parent.left
                anchors.leftMargin: 30 * scaleRatio
                labelHeader: qsTr("Blockheight")
                labelValue: {
                    if (!isPending)
                        if(confirmations < confirmationsRequired)
                            return blockHeight + " " + qsTr("(%1/%2 confirmations)").arg(confirmations).arg(confirmationsRequired);
                        else
                            return blockHeight;
                    if (!isOut)
                        return qsTr("UNCONFIRMED") + translationManager.emptyString
                    if (isFailed)
                        return qsTr("FAILED") + translationManager.emptyString
                    return qsTr("PENDING") + translationManager.emptyString
                }
                copyValue: labelValue
            }

            // right column
            MoneroComponents.HistoryTableInnerColumn {
                visible: currentWallet.getUserNote(hash)
                anchors.right: parent.right
                anchors.rightMargin: 80 * scaleRatio
                width: 220 * scaleRatio
                height: parent.height
                color: "transparent"

                labelHeader: qsTr("Description")
                labelValue: {
                    var note = currentWallet.getUserNote(hash);
                    if(note){
                        if(note.length > 28) {
                            return note.substring(0, 28) + "...";
                        } else {
                            return note;
                        }
                    } else {
                        return "";
                    }
                }
                copyValue: {
                    return currentWallet.getUserNote(hash);
                }
            }

            Rectangle {
                id: proofButton
                visible: isOut
                color: "#404040"
                height: 24 * scaleRatio
                width: 24 * scaleRatio
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 36
                radius: 20 * scaleRatio

                MouseArea {
                    id: proofButtonMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var address = TxUtils.destinationsToAddress(destinations);
                        if(address === undefined){
                            console.log('getProof: Error fetching address')
                            return;
                        }

                        var checked = (TxUtils.checkTxID(hash) && TxUtils.checkAddress(address, appWindow.persistentSettings.nettype));
                        if(!checked){
                            console.log('getProof: Error checking TxId and/or address');
                        }

                        console.log("getProof: Generate clicked: txid " + hash + ", address " + address);
                        root.getProofClicked(hash, address, '');
                    }

                    onEntered: {
                        proofButton.color = "#656565";
                    }

                    onExited: {
                        proofButton.color = "#404040";
                    }
                }

                Text {
                    color: MoneroComponents.Style.defaultFontColor
                    text: "P"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14 * scaleRatio
                }
            }

            Rectangle {
                id: detailsButton
                color: "#404040"
                height: 24 * scaleRatio
                width: 24 * scaleRatio
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                radius: 20 * scaleRatio

                MouseArea {
                    id: detailsButtonMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var tx_key = currentWallet.getTxKey(hash)
                        var tx_note = currentWallet.getUserNote(hash)
                        var rings = currentWallet.getRings(hash)
                        if (rings)
                            rings = rings.replace(/\|/g, '\n')
                        informationPopup.title = "Transaction details";
                        informationPopup.content = buildTxDetailsString(hash,paymentId,tx_key,tx_note,destinations, rings);
                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    }

                    onEntered: {
                        detailsButton.color = "#656565";
                    }

                    onExited: {
                        detailsButton.color = "#404040";
                    }
                }

                Text {
                    color: MoneroComponents.Style.defaultFontColor
                    text: "?"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 14 * scaleRatio
                }
            }
        }
    }

    Clipboard { id: clipboard }
}
