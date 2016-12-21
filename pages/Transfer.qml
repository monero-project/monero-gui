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
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import moneroComponents.PendingTransaction 1.0
import "../components"
import moneroComponents.Wallet 1.0


Rectangle {
    id: root
    signal paymentClicked(string address, string paymentId, string amount, int mixinCount,
                          int priority, string description)
    signal sweepUnmixableClicked()

    color: "#F0EEEE"
    property string startLinkText: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style><font size='2'> (</font><a href='#'>Start daemon</a><font size='2'>)</font>"

    function scaleValueToMixinCount(scaleValue) {
        var scaleToMixinCount = [4,5,6,7,8,9,10,11,12,13,14,15,20,25];
        if (scaleValue < scaleToMixinCount.length) {
            return scaleToMixinCount[scaleValue];
        } else {
            return 0;
        }
    }

    function isValidOpenAliasAddress(address) {
      address = address.trim()
      var dot = address.indexOf('.')
      if (dot < 0)
        return false
      // we can get an awful lot of valid domains, including non ASCII chars... accept anything
      return true
    }

    function oa_message(text) {
      oaPopup.title = qsTr("OpenAlias error") + translationManager.emptyString
      oaPopup.text = text
      oaPopup.icon = StandardIcon.Information
      oaPopup.onCloseCallback = null
      oaPopup.open()
    }

    // Information dialog
    StandardDialog {
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

    Item {
      id: pageRoot
      anchors.fill: parent
    Label {
        id: amountLabel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 17
        text: qsTr("Amount") + translationManager.emptyString
        fontSize: 14
    }

    Label {
        id: transactionPriority
        anchors.top: parent.top
        anchors.topMargin: 17
        fontSize: 14
        x: (parent.width - 17) / 2 + 17
        text: qsTr("Transaction priority") + translationManager.emptyString
    }

    Row {
        id: amountRow
        anchors.top: amountLabel.bottom
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 7
        width: (parent.width - 17) / 2 + 10
        Item {
            width: 37
            height: 37

            Image {
                anchors.centerIn: parent
                source: "../images/moneroIcon.png"
            }
        }
        // Amount input
        LineEdit {
            id: amountLine
            placeholderText: qsTr("") + translationManager.emptyString
            width: parent.width - 37 - 17 - 60
            validator: DoubleValidator {
                bottom: 0.0
                top: 18446744.073709551615
                decimals: 12
                notation: DoubleValidator.StandardNotation
                locale: "C"
            }
        }

        StandardButton {
            id: amountAllButton
            //anchors.left: amountLine.right
            //anchors.top: amountLine.top
            //anchors.bottom: amountLine.bottom
            width: 60
            text: qsTr("or ALL") + translationManager.emptyString
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            enabled : true
            onClicked: amountLine.text = "(all)"
        }
    }

    ListModel {
        id: priorityModel
        // ListElement: cannot use script for property value, so
        // code like this wont work:
        // ListElement { column1: qsTr("LOW") + translationManager.emptyString ; column2: ""; priority: PendingTransaction.Priority_Low }

        ListElement { column1: qsTr("LOW (x1 fee)") ; column2: ""; priority: PendingTransaction.Priority_Low }
        ListElement { column1: qsTr("MEDIUM (x20 fee)") ; column2: ""; priority: PendingTransaction.Priority_Medium }
        ListElement { column1: qsTr("HIGH (x166 fee)")  ; column2: "";  priority: PendingTransaction.Priority_High }
    }

    StandardDropdown {
        id: priorityDropdown
        anchors.top: transactionPriority.bottom
        anchors.right: parent.right
        anchors.rightMargin: 17
        anchors.topMargin: 5
        anchors.left: transactionPriority.left
        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        dataModel: priorityModel
        z: 1
    }



    Label {
        id: privacyLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: amountRow.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 30
        fontSize: 14
        text: qsTr("Privacy level") + translationManager.emptyString
    }

    PrivacyLevel {
        id: privacyLevelItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: privacyLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
        onFillLevelChanged: {
            print ("PrivacyLevel changed:"  + fillLevel)
            print ("mixin count:"  + scaleValueToMixinCount(fillLevel))
        }
    }


    Label {
        id: costLabel
        anchors.right: parent.right
        anchors.top: amountRow.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 30
        fontSize: 14
        text: qsTr("Transaction cost")
    }


    Label {
        id: addressLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: privacyLevelItem.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 30
        fontSize: 14
        textFormat: Text.RichText
        text: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style>\
                    Address <font size='2'>  ( Paste in or select from </font> <a href='#'>Address book</a><font size='2'> )</font>")
              + translationManager.emptyString

        onLinkActivated: appWindow.showPageRequest("AddressBook")
    }
    // recipient address input
    RowLayout {
        id: addressLineRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: addressLabel.bottom

        LineEdit {
            id: addressLine
            anchors.left: parent.left
            anchors.right: resolveButton.left
            anchors.leftMargin: 17
            anchors.topMargin: 5
            placeholderText: "4..."
            // validator: RegExpValidator { regExp: /[0-9A-Fa-f]{95}/g }
        }

        StandardButton {
            id: resolveButton
            anchors.right: parent.right
            anchors.leftMargin: 17
            anchors.topMargin: 17
            anchors.rightMargin: 17
            width: 60
            text: qsTr("RESOLVE") + translationManager.emptyString
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            enabled : isValidOpenAliasAddress(addressLine.text)
            onClicked: {
                var result = walletManager.resolveOpenAlias(addressLine.text)
                if (result) {
                  var parts = result.split("|")
                  if (parts.length == 2) {
                    var address_ok = walletManager.addressValid(parts[1], appWindow.persistentSettings.testnet)
                    if (parts[0] === "true") {
                      if (address_ok) {
                        addressLine.text = parts[1]
                        addressLine.cursorPosition = 0
                      }
                      else
                        oa_message(qsTr("No valid address found at this OpenAlias address"))
                    } else if (parts[0] === "false") {
                      if (address_ok) {
                        addressLine.text = parts[1]
                        addressLine.cursorPosition = 0
                        oa_message(qsTr("Address found, but the DNSSEC signatures could not be verified, so this address may be spoofed"))
                      } else {
                        oa_message(qsTr("No valid address found at this OpenAlias address, but the DNSSEC signatures could not be verified, so this may be spoofed"))
                      }
                    } else {
                      oa_message(qsTr("Internal error"))
                    }
                  } else {
                    oa_message(qsTr("Internal error"))
                  }
                } else {
                  oa_message(qsTr("No address found"))
                }
            }
        }
    }

    Label {
        id: paymentIdLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: addressLineRow.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 17
        fontSize: 14
        text: qsTr("Payment ID <font size='2'>( Optional )</font>") + translationManager.emptyString
    }

    // payment id input
    LineEdit {
        id: paymentIdLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: paymentIdLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
        placeholderText: qsTr("16 or 64 hexadecimal characters") + translationManager.emptyString
        // validator: DoubleValidator { top: 0.0 }
    }

    Label {
        id: descriptionLabel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: paymentIdLine.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 17
        fontSize: 14
        text: qsTr("Description <font size='2'>( Optional - saved to local wallet history )</font>")
              + translationManager.emptyString
    }

    LineEdit {
        id: descriptionLine
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: descriptionLabel.bottom
        anchors.leftMargin: 17
        anchors.rightMargin: 17
        anchors.topMargin: 5
    }

    function checkInformation(amount, address, payment_id, testnet) {
      address = address.trim()
      payment_id = payment_id.trim()

      var amount_ok = amount.length > 0
      var address_ok = walletManager.addressValid(address, testnet)
      var payment_id_ok = payment_id.length == 0 || walletManager.paymentIdValid(payment_id)
      var ipid = walletManager.paymentIdFromAddress(address, testnet)
      if (ipid.length > 0 && payment_id.length > 0)
         payment_id_ok = false

      addressLine.error = !address_ok
      amountLine.error = !amount_ok
      paymentIdLine.error = !payment_id_ok

      return amount_ok && address_ok && payment_id_ok
    }

    StandardButton {
        id: sendButton
        anchors.left: parent.left
        anchors.top: descriptionLine.bottom
        anchors.leftMargin: 17
        anchors.topMargin: 17
        width: 60
        text: qsTr("SEND") + translationManager.emptyString
        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        enabled : pageRoot.checkInformation(amountLine.text, addressLine.text, paymentIdLine.text, appWindow.persistentSettings.testnet)
        onClicked: {
            console.log("Transfer: paymentClicked")
            var priority = priorityModel.get(priorityDropdown.currentIndex).priority
            console.log("priority: " + priority)
            console.log("amount: " + amountLine.text)
            addressLine.text = addressLine.text.trim()
            paymentIdLine.text = paymentIdLine.text.trim()
            root.paymentClicked(addressLine.text, paymentIdLine.text, amountLine.text, scaleValueToMixinCount(privacyLevelItem.fillLevel),
                           priority, descriptionLine.text)

        }
    }

    StandardButton {
        id: sweepUnmixableButton
        anchors.right: parent.right
        anchors.top: descriptionLine.bottom
        anchors.rightMargin: 17
        anchors.topMargin: 17
        width: 60*2
        text: qsTr("SWEEP UNMIXABLE") + translationManager.emptyString
        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        enabled : true
        onClicked: {
            console.log("Transfer: sweepUnmixableClicked")
            root.sweepUnmixableClicked()

        }
    }

    Rectangle {
        id:desaturate
        color:"black"
        anchors.fill: parent
        opacity: 0.1
        visible: (pageRoot.enabled)? 0 : 1;
    }
    } // Rectangle

    Rectangle {
        x: root.width/2 - width/2
        y: root.height/2 - height/2
        height:statusText.paintedHeight + 50
        width:statusText.paintedWidth + 40
        visible: statusText.text != ""
        opacity: 0.9

        Text {
            id: statusText
            anchors.fill:parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            textFormat: Text.RichText
            onLinkActivated: { appWindow.startDaemon(appWindow.persistentSettings.daemonFlags); }
        }
    }

    Component.onCompleted: {
        //Disable password page until enabled by updateStatus
        pageRoot.enabled = false
    }

    // fires on every page load
    function onPageCompleted() {
        console.log("transfer page loaded")
        updateStatus();
    }

    //TODO: Add daemon sync status
    //TODO: enable send page when we're connected and daemon is synced

    function updateStatus() {
        console.log("updated transfer page status")
        if(typeof currentWallet === "undefined") {
            statusText.text = qsTr("Wallet is not connected to daemon.") + "<br>" + root.startLinkText
            return;
        }

        switch (currentWallet.connected) {
        case Wallet.ConnectionStatus_Disconnected:
            statusText.text = qsTr("Wallet is not connected to daemon.") + "<br>" + root.startLinkText
            break
        case Wallet.ConnectionStatus_WrongVersion:
            statusText.text = qsTr("Connected daemon is not compatible with GUI. \n" +
                                   "Please upgrade or connect to another daemon")
            break
        default:
            if(!appWindow.daemonSynced){
                statusText.text = qsTr("Waiting on daemon synchronization to finish")
            } else {
                // everything OK, enable transfer page
                pageRoot.enabled = true;
                statusText.text = "";
            }

        }
    }

    // Popuplate fields from addressbook.
    function sendTo(address, paymentId, description){
        addressLine.text = address
        paymentIdLine.text = paymentId
        descriptionLine.text = description
    }
}
