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
import "../components"
import moneroComponents.AddressBook 1.0
import moneroComponents.AddressBookModel 1.0

Rectangle {
    id: root
    color: "transparent"
    property var model

    ColumnLayout {
        id: columnLayout
        anchors.margins: (isMobile)? 17 : 40
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 26 * scaleRatio

        RowLayout {
            StandardButton {
                id: qrfinderButton
                text: qsTr("Qr Code") + translationManager.emptyString
                visible : appWindow.qrScannerEnabled
                enabled : visible
                width: visible ? 60 * scaleRatio : 0
                onClicked: {
                    cameraUi.state = "Capture"
                    cameraUi.qrcode_decoded.connect(updateFromQrCode)
                }
            }

            LineEdit {
                Layout.fillWidth: true;
                id: addressLine
                labelText: qsTr("Address") + translationManager.emptyString
                error: true;
                placeholderText: qsTr("4...") + translationManager.emptyString
            }
        }

        LineEdit {
            id: paymentIdLine
            Layout.fillWidth: true;
            labelText: qsTr("Payment ID <font size='2'>(Optional)</font>") + translationManager.emptyString
            placeholderText: qsTr("Paste 64 hexadecimal characters") + translationManager.emptyString
//            tipText: qsTr("<b>Payment ID</b><br/><br/>A unique user name used in<br/>the address book. It is not a<br/>transfer of information sent<br/>during the transfer")
//                    + translationManager.emptyString
        }

        LineEdit {
            id: descriptionLine
            Layout.fillWidth: true;
            labelText: qsTr("Description <font size='2'>(Optional)</font>") + translationManager.emptyString
            placeholderText: qsTr("Give this entry a name or description") + translationManager.emptyString
        }


        RowLayout {
            id: addButton
            Layout.bottomMargin: 17 * scaleRatio
            StandardButton {
                text: qsTr("Add") + translationManager.emptyString
                enabled: checkInformation(addressLine.text, paymentIdLine.text, appWindow.persistentSettings.nettype)

                onClicked: {
                    if (!currentWallet.addressBook.addRow(addressLine.text.trim(), paymentIdLine.text.trim(), descriptionLine.text)) {
                        informationPopup.title = qsTr("Error") + translationManager.emptyString;
                        // TODO: check currentWallet.addressBook.errorString() instead.
                        if(currentWallet.addressBook.errorCode() === AddressBook.Invalid_Address)
                             informationPopup.text  = qsTr("Invalid address") + translationManager.emptyString
                        else if(currentWallet.addressBook.errorCode() === AddressBook.Invalid_Payment_Id)
                             informationPopup.text  = currentWallet.addressBook.errorString()
                        else
                             informationPopup.text  = qsTr("Can't create entry") + translationManager.emptyString

                        informationPopup.onCloseCallback = null
                        informationPopup.open();
                    } else {
                        addressLine.text = "";
                        paymentIdLine.text = "";
                        descriptionLine.text = "";
                    }
                }
            }
        }
    }

    Rectangle {
        id: tableRect
        anchors.top: columnLayout.bottom
        anchors.leftMargin: (isMobile)? 17 : 40
        anchors.rightMargin: (isMobile)? 17 : 40
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height - addButton.y - addButton.height - 36 * scaleRatio
        color: "transparent"

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.InQuad }
        }

        Scroll {
            id: flickableScroll
            anchors.right: table.right
            anchors.rightMargin: -14
            anchors.top: table.top
            anchors.bottom: table.bottom
            flickable: table
        }

        AddressBookTable {
            id: table
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onContentYChanged: flickableScroll.flickableContentYChanged()
            model: root.model
        }
    }

    function checkInformation(address, payment_id, nettype) {
      address = address.trim()
      payment_id = payment_id.trim()

      var address_ok = walletManager.addressValid(address, nettype)
      var payment_id_ok = payment_id.length == 0 || walletManager.paymentIdValid(payment_id)
      var ipid = walletManager.paymentIdFromAddress(address, nettype)
      if (ipid.length > 0 && payment_id.length > 0)
         payment_id_ok = false

      addressLine.error = !address_ok
      paymentIdLine.error = !payment_id_ok

      return address_ok && payment_id_ok
    }

    function onPageCompleted() {
        console.log("adress book");
        root.model = currentWallet.addressBookModel;
    }

    function updateFromQrCode(address, payment_id, amount, tx_description, recipient_name) {
        console.log("updateFromQrCode")
        addressLine.text = address
        paymentIdLine.text = payment_id
        //amountLine.text = amount
        descriptionLine.text = recipient_name + " " + tx_description
        cameraUi.qrcode_decoded.disconnect(updateFromQrCode)
    }

}
