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
import QtQuick.Dialogs 1.2
import "../components" as MoneroComponents
import "../js/TxUtils.js" as TxUtils
import moneroComponents.AddressBook 1.0
import moneroComponents.AddressBookModel 1.0
import moneroComponents.Clipboard 1.0
import moneroComponents.NetworkType 1.0

ColumnLayout {
    id: root
    property var model
    property bool selectAndSend: false
    Clipboard { id: clipboard }

    ColumnLayout {
        Layout.margins: (isMobile ? 17 : 20) * scaleRatio
        Layout.topMargin: 40 * scaleRatio
        Layout.fillWidth: true
        spacing: 26 * scaleRatio
        visible: !root.selectAndSend

        MoneroComponents.LineEditMulti {
            id: addressLine
            Layout.fillWidth: true
            fontBold: true
            labelText: qsTr("Address") + translationManager.emptyString
            placeholderText: {
                switch (persistentSettings.nettype) {
                    case NetworkType.MAINNET:
                        return "4.. / 8.. / OpenAlias";
                    case NetworkType.STAGENET:
                        return "5.. / 7..";
                    case NetworkType.TESTNET:
                        return "9.. / B..";
                    default:
                        break;
                }
            }
            wrapMode: Text.WrapAnywhere
            addressValidation: true
            pasteButton: true
            onPaste: function(clipboardText) {
                const parsed = walletManager.parse_uri_to_object(clipboardText);
                if (!parsed.error) {
                    addressLine.text = parsed.address;
                    setPaymentId(parsed.payment_id);
                    setDescription(parsed.tx_description);
                } else {
                    addressLine.text = clipboardText;
                }
            }
            inlineButton.icon: "../images/qr.png"
            inlineButton.buttonColor: MoneroComponents.Style.orange
            inlineButton.onClicked: {
                cameraUi.state = "Capture"
                cameraUi.qrcode_decoded.connect(updateFromQrCode)
            }
            inlineButtonVisible : appWindow.qrScannerEnabled && !addressLine.text
        }

        MoneroComponents.StandardButton {
            id: resolveButton
            text: qsTr("Resolve") + translationManager.emptyString
            visible: TxUtils.isValidOpenAliasAddress(addressLine.text)
            enabled : visible
            onClicked: {
                var result = walletManager.resolveOpenAlias(addressLine.text)
                if (result) {
                    var parts = result.split("|")
                    if (parts.length === 2) {
                        var address_ok = walletManager.addressValid(parts[1], appWindow.persistentSettings.nettype)
                        if (parts[0] === "true") {
                            if (address_ok) {
                                // prepend openalias to description
                                descriptionLine.text = descriptionLine.text ? addressLine.text + " " + descriptionLine.text : addressLine.text
                                addressLine.text = parts[1]
                            }
                            else
                                oa_message(qsTr("No valid address found at this OpenAlias address"))
                        }
                        else if (parts[0] === "false") {
                              if (address_ok) {
                                  addressLine.text = parts[1]
                                  oa_message(qsTr("Address found, but the DNSSEC signatures could not be verified, so this address may be spoofed"))
                              }
                              else
                              {
                                  oa_message(qsTr("No valid address found at this OpenAlias address, but the DNSSEC signatures could not be verified, so this may be spoofed"))
                              }
                        }
                        else {
                            oa_message(qsTr("Internal error"))
                        }
                    }
                    else {
                        oa_message(qsTr("Internal error"))
                    }
                }
                else {
                    oa_message(qsTr("No address found"))
                }
            }
        }

        MoneroComponents.LineEditMulti {
            id: paymentIdLine
            visible: appWindow.persistentSettings.showPid
            Layout.fillWidth: true
            labelText: qsTr("Payment ID <font size='2'>(Optional)</font>") + translationManager.emptyString
            placeholderText: qsTr("Paste 64 hexadecimal characters") + translationManager.emptyString
            wrapMode: Text.WrapAnywhere
//            tipText: qsTr("<b>Payment ID</b><br/><br/>A unique user name used in<br/>the address book. It is not a<br/>transfer of information sent<br/>during the transfer")
//                    + translationManager.emptyString
        }

        MoneroComponents.LineEditMulti {
            id: descriptionLine
            Layout.fillWidth: true
            labelText: qsTr("Description <font size='2'>(Optional)</font>") + translationManager.emptyString
            placeholderText: qsTr("Give this entry a name or description") + translationManager.emptyString
            wrapMode: Text.WrapAnywhere
        }

        RowLayout {
            id: addButton
            Layout.bottomMargin: 17 * scaleRatio
            MoneroComponents.StandardButton {
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
                        clearFields();
                    }
                }
            }
        }
    }

    Rectangle {
        id: tableRect
        Layout.leftMargin: (isMobile ? 17 : 40) * scaleRatio
        Layout.rightMargin: (isMobile ? 17 : 40) * scaleRatio
        Layout.topMargin: (root.selectAndSend ? 40 : 0) * scaleRatio
        Layout.fillHeight: true
        Layout.fillWidth: true
        color: "transparent"

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.InQuad }
        }

        MoneroComponents.Scroll {
            id: flickableScroll
            anchors.right: table.right
            anchors.rightMargin: -14 * scaleRatio
            anchors.top: table.top
            anchors.bottom: table.bottom
            flickable: table
        }

        MoneroComponents.AddressBookTable {
            id: table
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            onContentYChanged: flickableScroll.flickableContentYChanged()
            model: root.model
            selectAndSend: root.selectAndSend
        }
    }

    function checkInformation(address, payment_id, nettype) {
      address = address.trim()
      payment_id = payment_id.trim()

      var address_ok = walletManager.addressValid(address, nettype)
      var payment_id_ok = payment_id.length === 0 || walletManager.paymentIdValid(payment_id)
      var ipid = walletManager.paymentIdFromAddress(address, nettype)
      if (ipid.length > 0 && payment_id.length > 0)
         payment_id_ok = false

      addressLine.error = !address_ok
      paymentIdLine.error = !payment_id_ok

      return address_ok && payment_id_ok
    }

    function onPageClosed() {
        root.selectAndSend = false;
    }

    function onPageCompleted() {
        console.log("adress book");
        root.model = currentWallet.addressBookModel;
    }

    function updateFromQrCode(address, payment_id, amount, tx_description, recipient_name) {
        console.log("updateFromQrCode")
        addressLine.text = address
        paymentIdLine.text = payment_id
        descriptionLine.text = recipient_name + " " + tx_description
        cameraUi.qrcode_decoded.disconnect(updateFromQrCode)
    }

    function setDescription(value) {
        descriptionLine.text = value;
    }

    function setPaymentId(value) {
        paymentIdLine.text = value;
    }

    function clearFields() {
        addressLine.text = "";
        paymentIdLine.text = "";
        descriptionLine.text = "";
    }

    function oa_message(text) {
      oaPopup.title = qsTr("OpenAlias error") + translationManager.emptyString
      oaPopup.text = text
      oaPopup.icon = StandardIcon.Information
      oaPopup.onCloseCallback = null
      oaPopup.open()
    }

    MoneroComponents.StandardDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: oaPopup
        cancelVisible: false
        onAccepted:  {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }
}
