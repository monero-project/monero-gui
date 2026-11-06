// Copyright (c) 2014-2024, The Monero Project
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

import QtQml.Models
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import FontAwesome

import moneroComponents.Clipboard 1.0
import moneroComponents.PendingTransaction 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.NetworkType 1.0
import "../components"
import "../components" as MoneroComponents
import "." 1.0
import "../js/TxUtils.js" as TxUtils
import "../js/Utils.js" as Utils


Rectangle {
    id: root
    signal paymentClicked(var recipients, string paymentId, int mixinCount, int priority, string description)
    signal sweepUnmixableClicked()

    color: "transparent"
    property alias transferHeight1: pageRoot.height
    property alias transferHeight2: advancedLayout.height
    property int mixin: 15  // (ring size 16)
    property string warningContent: ""
    property string sendButtonWarning: {
        // Currently opened wallet is not view-only
        if (appWindow.viewOnly) {
            return qsTr("Wallet is view-only and sends are only possible by using offline transaction signing. " +
                        "Unless key images are imported, the balance reflects only incoming but not outgoing transactions.") + translationManager.emptyString;
        }

        // There are sufficient unlocked funds available
        if (recipientModel.getAmountTotal() > appWindow.getUnlockedBalance()) {
            return qsTr("Amount is more than unlocked balance.") + translationManager.emptyString;
        }

        if (!recipientModel.hasEmptyAddress()) {
            // Address is valid
            if (recipientModel.hasInvalidAddress()) {
                return qsTr("Address is invalid.") + translationManager.emptyString;
            }

            // Amount is nonzero
            if (recipientModel.hasEmptyAmount()) {
                return qsTr("Enter an amount.") + translationManager.emptyString;
            }
        }

        return "";
    }
    property string startLinkText: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style><a href='#'>(%1)</a>".arg(qsTr("Start daemon")) + translationManager.emptyString
    property bool warningLongPidDescription: descriptionLine.text.match(/^[0-9a-f]{64}$/i)
    property bool paymentIdBlocked: paymentIdCheckbox.checked || warningLongPidDescription
    property bool hasTransferWarnings: warningContent !== "" || paymentIdBlocked
    property bool hasValidTransferInfo: !recipientModel.hasEmptyAddress()
                                     && !recipientModel.hasEmptyAmount()
                                     && !recipientModel.hasInvalidAddress()
                                     && recipientModel.getAmountTotal() <= appWindow.getUnlockedBalance()
    property bool canSendTransaction: !sendButtonWarningBox.visible
                                   && !hasTransferWarnings
                                   && hasValidTransferInfo
    property bool canCreateOfflineTx: appWindow.viewOnly
                                   && appWindow.daemonSynced
                                   && !hasTransferWarnings
                                   && hasValidTransferInfo

    Clipboard { id: clipboard }

    function oa_message(text) {
      oaPopup.title = qsTr("OpenAlias error") + translationManager.emptyString
      oaPopup.text = text
      oaPopup.onCloseCallback = null
      oaPopup.open()
    }

    function oa_confirm(openAlias, resolvedAddress, onAccepted) {
      confirmationDialog.title = qsTr("OpenAlias warning") + translationManager.emptyString
      confirmationDialog.text = qsTr("Address found, but the DNSSEC signatures could not be verified, so this address may be spoofed.") + "\n\n" +
                                qsTr("OpenAlias: ") + openAlias + "\n\n" +
                                qsTr("Resolved address: ") + resolvedAddress + "\n\n" +
                                qsTr("Only use this address if you trust this OpenAlias result.") + translationManager.emptyString
      confirmationDialog.cancelText = qsTr("Cancel") + translationManager.emptyString
      confirmationDialog.okText = qsTr("Use address") + translationManager.emptyString
      confirmationDialog.onAcceptedCallback = onAccepted
      confirmationDialog.onRejectedCallback = null
      confirmationDialog.open()
    }

    function fillPaymentDetails(address, payment_id, amount, tx_description, recipient_name) {
        if (recipientModel.count > 0) {
            const last = recipientModel.count - 1;
            if (recipientModel.get(recipientModel.count - 1).address == "") {
                recipientModel.remove(last);
            }
        }

        recipientModel.newRecipient(address, Utils.removeTrailingZeros(amount || ""));
        setPaymentId(payment_id || "");
        setDescription((recipient_name ? recipient_name + (tx_description ? " (" + tx_description + ")" : "") : (tx_description || "")));
    }

    function updateFromQrCode(address, payment_id, amount, tx_description, recipient_name) {
        console.log("updateFromQrCode")
        fillPaymentDetails(address, payment_id, amount, tx_description, recipient_name);
        cameraUi.qrcode_decoded.disconnect(updateFromQrCode)
    }

    function setDescription(value) {
        descriptionLine.text = value;
        descriptionCheckbox.checked = descriptionLine.text != "";
    }

    function setPaymentId(value) {
        paymentIdLine.text = value;
        paymentIdCheckbox.checked = paymentIdLine.text != "";
    }

    function clearFields() {
        recipientModel.clear();
        fillPaymentDetails("", "", "", "", "");
        priorityDropdown.currentIndex = 0
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

    ColumnLayout {
      id: pageRoot
      anchors.margins: 20
      anchors.topMargin: 40

      anchors.left: parent.left
      anchors.top: parent.top
      anchors.right: parent.right

      spacing: 30

      RowLayout {
          visible: root.warningContent !== ""

          MoneroComponents.WarningBox {
              text: warningContent
              onLinkActivated: {
                  appWindow.start