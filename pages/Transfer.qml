// Copyright (c) 2014-2019, The Monero Project
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

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import moneroComponents.Clipboard 1.0
import moneroComponents.PendingTransaction 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.NetworkType 1.0
import FontAwesome 1.0
import "../components"
import "../components" as MoneroComponents
import "." 1.0
import "../js/TxUtils.js" as TxUtils


Rectangle {
    id: root
    signal paymentClicked(string address, string paymentId, string amount, int mixinCount,
                          int priority, string description)
    signal sweepUnmixableClicked()

    color: "transparent"
    property int mixin: 10  // (ring size 11)
    property string warningContent: ""
    property string sendButtonWarning: ""
    property string startLinkText: qsTr("<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 14px;}</style><font size='2'> (</font><a href='#'>Start daemon</a><font size='2'>)</font>") + translationManager.emptyString
    property bool showAdvanced: false

    Clipboard { id: clipboard }

    function oa_message(text) {
      oaPopup.title = qsTr("OpenAlias error") + translationManager.emptyString
      oaPopup.text = text
      oaPopup.icon = StandardIcon.Information
      oaPopup.onCloseCallback = null
      oaPopup.open()
    }

    function updateFromQrCode(address, payment_id, amount, tx_description, recipient_name) {
        console.log("updateFromQrCode")
        addressLine.text = address
        setPaymentId(payment_id);
        amountLine.text = amount
        setDescription(recipient_name + " " + tx_description);
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
        addressLine.text = ""
        setPaymentId("");
        amountLine.text = ""
        root.sendButtonWarning = ""
        setDescription("");
        priorityDropdown.currentIndex = 0
        updatePriorityDropdown()
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
      anchors.margins: (isMobile)? 17 : 20
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
                  appWindow.startDaemon(appWindow.persistentSettings.daemonFlags);
              }
          }
      }

      GridLayout {
          columns: (isMobile)? 1 : 2
          Layout.fillWidth: true
          columnSpacing: 32

          ColumnLayout {
              Layout.fillWidth: true
              Layout.minimumWidth: 200

              // Amount input
              LineEdit {
                  id: amountLine
                  Layout.fillWidth: true
                  inlineIcon: true
                  labelText: qsTr("<style type='text/css'>a {text-decoration: none; color: #858585; font-size: 14px;}</style>\
                                   Amount <font size='2'>  ( </font> <a href='#'>Change account</a><font size='2'> )</font>")
                             + translationManager.emptyString
                  onLabelLinkActivated: {
                      middlePanel.accountView.selectAndSend = true;
                      appWindow.showPageRequest("Account")
                  }
                  placeholderText: "0.00"
                  width: 100
                  fontBold: true
                  inlineButtonText: qsTr("All") + translationManager.emptyString
                  inlineButton.onClicked: amountLine.text = "(all)"
                  onTextChanged: {
                      if(amountLine.text.indexOf('.') === 0){
                          amountLine.text = '0' + amountLine.text;
                      }
                  }

                  validator: RegExpValidator {
                      regExp: /^(\d{1,8})?([\.]\d{1,12})?$/
                  }
              }
          }

          ColumnLayout {
              Layout.fillWidth: true
              Label {
                  id: transactionPriority
                  Layout.topMargin: 12
                  text: qsTr("Transaction priority") + translationManager.emptyString
                  fontBold: false
                  fontSize: 16
              }
              // Note: workaround for translations in listElements
              // ListElement: cannot use script for property value, so
              // code like this wont work:
              // ListElement { column1: qsTr("LOW") + translationManager.emptyString ; column2: ""; priority: PendingTransaction.Priority_Low }
              // For translations to work, the strings need to be listed in
              // the file components/StandardDropdown.qml too.

              // Priorites after v5
              ListModel {
                   id: priorityModelV5

                   ListElement { column1: qsTr("Automatic") ; column2: ""; priority: 0}
                   ListElement { column1: qsTr("Slow (x0.25 fee)") ; column2: ""; priority: 1}
                   ListElement { column1: qsTr("Normal (x1 fee)") ; column2: ""; priority: 2 }
                   ListElement { column1: qsTr("Fast (x5 fee)") ; column2: ""; priority: 3 }
                   ListElement { column1: qsTr("Fastest (x41.5 fee)")  ; column2: "";  priority: 4 }
               }

              StandardDropdown {
                  Layout.fillWidth: true
                  id: priorityDropdown
                  Layout.topMargin: 5
                  currentIndex: 0
              }
          }
          // Make sure dropdown is on top
          z: parent.z + 1
      }

      // recipient address input
      RowLayout {
          id: addressLineRow
          Layout.fillWidth: true

          LineEditMulti {
              id: addressLine
              spacing: 0
              fontBold: true
              labelText: qsTr("<style type='text/css'>a {text-decoration: none; color: #858585; font-size: 14px;}</style>\
                Address <font size='2'>  ( </font> <a href='#'>Address book</a><font size='2'> )</font>")
                + translationManager.emptyString
              labelButtonText: qsTr("Resolve") + translationManager.emptyString
              placeholderText: {
                  if(persistentSettings.nettype == NetworkType.MAINNET){
                      return "4.. / 8.. / OpenAlias";
                  } else if (persistentSettings.nettype == NetworkType.STAGENET){
                      return "5.. / 7..";
                  } else if(persistentSettings.nettype == NetworkType.TESTNET){
                      return "9.. / B..";
                  }
              }
              wrapMode: Text.WrapAnywhere
              addressValidation: true
              onInputLabelLinkActivated: {
                  middlePanel.addressBookView.selectAndSend = true;
                  appWindow.showPageRequest("AddressBook");
              }
              pasteButton: true
              onPaste: function(clipboardText) {
                  const parsed = walletManager.parse_uri_to_object(clipboardText);
                  if (!parsed.error) {
                    addressLine.text = parsed.address;
                    setPaymentId(parsed.payment_id);
                    amountLine.text = parsed.amount;
                    setDescription(parsed.tx_description);
                  } else {
                     addressLine.text = clipboardText; 
                  }
              }

              inlineButton.text: FontAwesome.qrcode
              inlineButton.fontPixelSize: 22
              inlineButton.fontFamily: FontAwesome.fontFamily
              inlineButton.textColor: MoneroComponents.Style.defaultFontColor
              inlineButton.buttonColor: MoneroComponents.Style.orange
              inlineButton.onClicked: {
                  cameraUi.state = "Capture"
                  cameraUi.qrcode_decoded.connect(updateFromQrCode)
              }
              inlineButtonVisible : appWindow.qrScannerEnabled && !addressLine.text
          }
      }

      StandardButton {
          id: resolveButton
          width: 80
          text: qsTr("Resolve") + translationManager.emptyString
          visible: TxUtils.isValidOpenAliasAddress(addressLine.text)
          enabled : visible
          onClicked: {
              var result = walletManager.resolveOpenAlias(addressLine.text)
              if (result) {
                  var parts = result.split("|")
                  if (parts.length == 2) {
                      var address_ok = walletManager.addressValid(parts[1], appWindow.persistentSettings.nettype)
                      if (parts[0] === "true") {
                          if (address_ok) {
                              // prepend openalias to description
                              descriptionLine.text = descriptionLine.text ? addressLine.text + " " + descriptionLine.text : addressLine.text
                              descriptionCheckbox.checked = true
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

      ColumnLayout {
          visible: appWindow.persistentSettings.showPid || paymentIdCheckbox.checked 

          CheckBox {
              id: paymentIdCheckbox
              border: false
              checkedIcon: "qrc:///images/minus-white.png"
              uncheckedIcon: "qrc:///images/plus-white.png"
              imgWidth: 12
              imgHeight: 12
              fontSize: paymentIdLine.labelFontSize
              iconOnTheLeft: false
              Layout.fillWidth: true
              text: qsTr("Payment ID <font size='2'>( Optional )</font>") + translationManager.emptyString
              onClicked: {
                  if (!paymentIdCheckbox.checked) {
                    paymentIdLine.text = "";
                  }
              }
          }

          // payment id input
          LineEditMulti {
              id: paymentIdLine
              fontBold: true
              placeholderText: qsTr("64 hexadecimal characters") + translationManager.emptyString
              Layout.fillWidth: true
              wrapMode: Text.WrapAnywhere
              addressValidation: false
              visible: paymentIdCheckbox.checked
          }
      }

      ColumnLayout {
        CheckBox {
              id: descriptionCheckbox
              border: false
              checkedIcon: "qrc:///images/minus-white.png"
              uncheckedIcon: "qrc:///images/plus-white.png"
              imgWidth: 12
              imgHeight: 12
              fontSize: descriptionLine.labelFontSize
              iconOnTheLeft: false
              Layout.fillWidth: true
              text: qsTr("Description <font size='2'>( Optional )</font>") + translationManager.emptyString
              onClicked: {
                  if (!descriptionCheckbox.checked) {
                    descriptionLine.text = "";
                  }
              }
          }

          LineEditMulti {
              id: descriptionLine
              placeholderText: qsTr("Saved to local wallet history") + translationManager.emptyString
              Layout.fillWidth: true
              visible: descriptionCheckbox.checked
              onTextChanged: {
                  paymentIdWarningBox.visible = walletManager.paymentIdValid(text) && !persistentSettings.showPid
              }
          }
      }

      MoneroComponents.WarningBox {
          // @TODO: remove after pid removal hardfork
          id: paymentIdWarningBox
          text: qsTr("You can enable transfers with payment ID on the settings page.") + translationManager.emptyString;
          visible: false
      }

      MoneroComponents.WarningBox {
          id: sendButtonWarningBox
          text: root.sendButtonWarning
          visible: root.sendButtonWarning !== ""
      }

      RowLayout {
          StandardButton {
              id: sendButton
              rightIcon: "qrc:///images/rightArrow.png"
              rightIconInactive: "qrc:///images/rightArrowInactive.png"
              Layout.topMargin: 4
              text: qsTr("Send") + translationManager.emptyString
              enabled: {
                updateSendButton()
              }
              onClicked: {
                  console.log("Transfer: paymentClicked")
                  var priority = priorityModelV5.get(priorityDropdown.currentIndex).priority
                  console.log("priority: " + priority)
                  console.log("amount: " + amountLine.text)
                  addressLine.text = addressLine.text.trim()
                  setPaymentId(paymentIdLine.text.trim());
                  root.paymentClicked(addressLine.text, paymentIdLine.text, amountLine.text, root.mixin, priority, descriptionLine.text)
              }
          }
      }

      function checkInformation(amount, address, payment_id, nettype) {
        address = address.trim()
        payment_id = payment_id.trim()

        var amount_ok = amount.length > 0
        var address_ok = walletManager.addressValid(address, nettype)
        var payment_id_ok = payment_id.length == 0 || (payment_id.length == 64 && walletManager.paymentIdValid(payment_id))
        var ipid = walletManager.paymentIdFromAddress(address, nettype)
        if (ipid.length > 0 && payment_id.length > 0)
           payment_id_ok = false

        addressLine.error = !address_ok
        amountLine.error = !amount_ok
        paymentIdLine.error = !payment_id_ok

        return amount_ok && address_ok && payment_id_ok
      }

    } // pageRoot

    Rectangle {
        id: desaturate
        color:"black"
        anchors.fill: parent
        opacity: 0.1
        visible: (pageRoot.enabled)? 0 : 1;
    }

    ColumnLayout {
        anchors.top: pageRoot.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: (isMobile)? 17 : 20
        anchors.topMargin: 32
        spacing: 26
        enabled: !viewOnly || pageRoot.enabled

        RowLayout {
            visible: appWindow.walletMode >= 2
            CheckBox2 {
                id: showAdvancedCheckbox
                checked: persistentSettings.transferShowAdvanced
                onClicked: {
                    persistentSettings.transferShowAdvanced = !persistentSettings.transferShowAdvanced
                }
                text: qsTr("Advanced options") + translationManager.emptyString
            }
        }

        GridLayout {
            visible: persistentSettings.transferShowAdvanced && appWindow.walletMode >= 2
            columns: (isMobile) ? 2 : 6

            StandardButton {
                id: sweepUnmixableButton
                text: qsTr("Sweep Unmixable") + translationManager.emptyString
                enabled : pageRoot.enabled
                small: true
                onClicked: {
                    console.log("Transfer: sweepUnmixableClicked")
                    root.sweepUnmixableClicked()
                }
            }

            StandardButton {
                id: saveTxButton
                text: qsTr("Create tx file") + translationManager.emptyString
                visible: appWindow.viewOnly
                enabled: pageRoot.checkInformation(amountLine.text, addressLine.text, paymentIdLine.text, appWindow.persistentSettings.nettype)
                small: true
                onClicked: {
                    console.log("Transfer: saveTx Clicked")
                    var priority = priorityModelV5.get(priorityDropdown.currentIndex).priority
                    console.log("priority: " + priority)
                    console.log("amount: " + amountLine.text)
                    addressLine.text = addressLine.text.trim()
                    setPaymentId(paymentIdLine.text.trim());
                    root.paymentClicked(addressLine.text, paymentIdLine.text, amountLine.text, root.mixin, priority, descriptionLine.text)

                }
            }

            StandardButton {
                id: signTxButton
                text: qsTr("Sign tx file") + translationManager.emptyString
                small: true
                visible: !appWindow.viewOnly
                onClicked: {
                    console.log("Transfer: sign tx clicked")
                    signTxDialog.open();
                }
            }

            StandardButton {
                id: submitTxButton
                text: qsTr("Submit tx file") + translationManager.emptyString
                small: true
                visible: appWindow.viewOnly
                enabled: pageRoot.enabled
                onClicked: {
                    console.log("Transfer: submit tx clicked")
                    submitTxDialog.open();
                }
            }
            
            StandardButton {
                id: exportKeyImagesButton
                text: qsTr("Export key images") + translationManager.emptyString
                small: true
                visible: !appWindow.viewOnly
                enabled: pageRoot.enabled
                onClicked: {
                    console.log("Transfer: export key images clicked")
                    exportKeyImagesDialog.open();
                }
            }

            StandardButton {
                id: importKeyImagesButton
                text: qsTr("Import key images") + translationManager.emptyString
                small: true
                visible: appWindow.viewOnly && walletManager.isDaemonLocal(appWindow.currentDaemonAddress)
                enabled: pageRoot.enabled
                onClicked: {
                    console.log("Transfer: import key images clicked")
                    importKeyImagesDialog.open();
                }
            }
        }
    }

    //SignTxDialog
    FileDialog {
        id: signTxDialog
        title: qsTr("Please choose a file") + translationManager.emptyString
        folder: "file://" +moneroAccountsDir
        nameFilters: [ "Unsigned transfers (*)"]

        onAccepted: {
            var path = walletManager.urlToLocalPath(fileUrl);
            // Load the unsigned tx from file
            var transaction = currentWallet.loadTxFile(path);

            if (transaction.status !== PendingTransaction.Status_Ok) {
                console.error("Can't load unsigned transaction: ", transaction.errorString);
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                informationPopup.text  = qsTr("Can't load unsigned transaction: ") + transaction.errorString
                informationPopup.icon  = StandardIcon.Critical
                informationPopup.onCloseCallback = null
                informationPopup.open();
                // deleting transaction object, we don't want memleaks
                transaction.destroy();
            } else {
                    confirmationDialog.text =  qsTr("\nNumber of transactions: ") + transaction.txCount
                for (var i = 0; i < transaction.txCount; ++i) {
                    confirmationDialog.text += qsTr("\nTransaction #%1").arg(i+1)
                    +qsTr("\nRecipient: ") + transaction.recipientAddress[i]
                    + (transaction.paymentId[i] == "" ? "" : qsTr("\n\payment ID: ") + transaction.paymentId[i])
                    + qsTr("\nAmount: ") + walletManager.displayAmount(transaction.amount(i))
                    + qsTr("\nFee: ") + walletManager.displayAmount(transaction.fee(i))
                    + qsTr("\nRingsize: ") + (transaction.mixin(i)+1)

                    // TODO: add descriptions to unsigned_tx_set?
    //              + (transactionDescription === "" ? "" : (qsTr("\n\nDescription: ") + transactionDescription))
                    + translationManager.emptyString
                    if (i > 0) {
                        confirmationDialog.text += "\n\n"
                    }

                }

                console.log(transaction.confirmationMessage);

                // Show confirmation dialog
                confirmationDialog.title = qsTr("Confirmation") + translationManager.emptyString
                confirmationDialog.icon = StandardIcon.Question
                confirmationDialog.onAcceptedCallback = function() {
                    transaction.sign(path+"_signed");
                    transaction.destroy();
                };
                confirmationDialog.onRejectedCallback = transaction.destroy;

                confirmationDialog.open()
            }

        }
        onRejected: {
            // File dialog closed
            console.log("Canceled")
        }
    }

    //SignTxDialog
    FileDialog {
        id: submitTxDialog
        title: qsTr("Please choose a file") + translationManager.emptyString
        folder: "file://" +moneroAccountsDir
        nameFilters: [ "signed transfers (*)"]

        onAccepted: {
            if(!currentWallet.submitTxFile(walletManager.urlToLocalPath(fileUrl))){
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                informationPopup.text  = qsTr("Can't submit transaction: ") + currentWallet.errorString
                informationPopup.icon  = StandardIcon.Critical
                informationPopup.onCloseCallback = null
                informationPopup.open();
            } else {
                informationPopup.title = qsTr("Information") + translationManager.emptyString
                informationPopup.text  = qsTr("Monero sent successfully") + translationManager.emptyString
                informationPopup.icon  = StandardIcon.Information
                informationPopup.onCloseCallback = null
                informationPopup.open();
            }
        }
        onRejected: {
            console.log("Canceled")
        }

    }
    
    //ExportKeyImagesDialog
    FileDialog {
        id: exportKeyImagesDialog
        selectMultiple: false
        selectExisting: false
        onAccepted: {
            console.log(walletManager.urlToLocalPath(exportKeyImagesDialog.fileUrl))
            currentWallet.exportKeyImages(walletManager.urlToLocalPath(exportKeyImagesDialog.fileUrl));
        }
        onRejected: {
            console.log("Canceled");
        }
    }

    //ImportKeyImagesDialog
    FileDialog {
        id: importKeyImagesDialog
        selectMultiple: false
        selectExisting: true
        title: qsTr("Please choose a file") + translationManager.emptyString
        onAccepted: {
            console.log(walletManager.urlToLocalPath(importKeyImagesDialog.fileUrl))
            currentWallet.importKeyImages(walletManager.urlToLocalPath(importKeyImagesDialog.fileUrl));
        }
        onRejected: {
            console.log("Canceled");
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
        updatePriorityDropdown()
    }

    function updatePriorityDropdown() {
        priorityDropdown.dataModel = priorityModelV5;
        priorityDropdown.update()
    }

    //TODO: Add daemon sync status
    //TODO: enable send page when we're connected and daemon is synced

    function updateStatus() {
        var messageNotConnected = qsTr("Wallet is not connected to daemon.");
        if(appWindow.walletMode >= 2) messageNotConnected += root.startLinkText;
        pageRoot.enabled = true;
        if(typeof currentWallet === "undefined") {
            root.warningContent = messageNotConnected;
            return;
        }

        if (currentWallet.viewOnly) {
           // warningText.text = qsTr("Wallet is view only.")
           //return;
        }
        //pageRoot.enabled = false;

        switch (currentWallet.connected()) {
        case Wallet.ConnectionStatus_Disconnected:
            root.warningContent = messageNotConnected;
            break
        case Wallet.ConnectionStatus_WrongVersion:
            root.warningContent = qsTr("Connected daemon is not compatible with GUI. \n" +
                                   "Please upgrade or connect to another daemon")
            break
        default:
            if(!appWindow.daemonSynced){
                root.warningContent = qsTr("Waiting on daemon synchronization to finish.")
            } else {
                // everything OK, enable transfer page
                // Light wallet is always ready
                pageRoot.enabled = true;
                root.warningContent = "";
            }
        }
    }

    // Popuplate fields from addressbook.
    function sendTo(address, paymentId, description){
        addressLine.text = address
        setPaymentId(paymentId);
        setDescription(description);
    }

    function updateSendButton(){
        // reset message
        root.sendButtonWarning = "";

        // Currently opened wallet is not view-only
        if(appWindow.viewOnly){
            root.sendButtonWarning = qsTr("Wallet is view-only and sends are not possible.") + translationManager.emptyString;
            return false;
        }

        // There are sufficient unlocked funds available
        if(parseFloat(amountLine.text) > parseFloat(middlePanel.unlockedBalanceText)){
            root.sendButtonWarning = qsTr("Amount is more than unlocked balance.") + translationManager.emptyString;
            return false;
        }

        // There is no warning box displayed
        if(root.warningContent !== ""){
            return false;
        }

        // The transactional information is correct
        if(!pageRoot.checkInformation(amountLine.text, addressLine.text, paymentIdLine.text, appWindow.persistentSettings.nettype)){
            if(amountLine.text && addressLine.text)
                root.sendButtonWarning = qsTr("Transaction information is incorrect.") + translationManager.emptyString;
            return false;
        }
        return true;
    }
}
