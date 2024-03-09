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

import QtQml.Models 2.2
import QtQuick 2.9
import QtQuick.Controls 1.4
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

    Clipboard { id: clipboard }

    function oa_message(text) {
      oaPopup.title = qsTr("OpenAlias error") + translationManager.emptyString
      oaPopup.text = text
      oaPopup.icon = StandardIcon.Information
      oaPopup.onCloseCallback = null
      oaPopup.open()
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
                  appWindow.startDaemon(appWindow.persistentSettings.daemonFlags);
              }
          }
      }

      RowLayout {
          visible: leftPanel.minutesToUnlock !== ""

          MoneroComponents.WarningBox {
              text: qsTr("Spendable funds: %1 XMR. Please wait ~%2 minutes for your whole balance to become spendable.").arg(leftPanel.balanceUnlockedString).arg(leftPanel.minutesToUnlock)
          }
      }

        ListModel {
            id: recipientModel

            readonly property int maxRecipients: 16

            ListElement {
                address: ""
                amount: ""
            }

            function newRecipient(address, amount) {
                if (recipientModel.count < maxRecipients) {
                    recipientModel.append({address: address, amount: amount});
                    return true;
                }
                return false;
            }

            function getRecipients() {
                var recipients = [];
                for (var index = 0; index < recipientModel.count; ++index) {
                    const recipient = recipientModel.get(index);
                    recipients.push({
                        address: recipient.address,
                        amount: recipient.amount,
                    });
                }
                return recipients;
            }

            function getAmountTotal() {
                var sum = [];
                for (var index = 0; index < recipientModel.count; ++index) {
                    const amount = recipientModel.get(index).amount;
                    if (amount == "(all)") {
                        return appWindow.getUnlockedBalance();
                    }
                    sum.push(amount || "0");
                }
                return walletManager.amountsSumFromStrings(sum);
            }

            function hasEmptyAmount() {
                for (var index = 0; index < recipientModel.count; ++index) {
                    if (recipientModel.get(index).amount === "") {
                        return true;
                    }
                }
                return false;
            }

            function hasEmptyAddress() {
                for (var index = 0; index < recipientModel.count; ++index) {
                    if (recipientModel.get(index).address === "") {
                        return true;
                    }
                }
                return false;
            }

            function hasInvalidAddress() {
                for (var index = 0; index < recipientModel.count; ++index) {
                    if (!TxUtils.checkAddress(recipientModel.get(index).address, appWindow.persistentSettings.nettype)) {
                        return true;
                    }
                }
                return false;
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: recipientLayout.height

            ColumnLayout {
                id: recipientLayout
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                readonly property int colSpacing: 10
                readonly property int rowSpacing: 10
                readonly property int secondRowWidth: 125
                readonly property int thirdRowWidth: 50

                RowLayout {
                    Layout.bottomMargin: recipientLayout.rowSpacing / 2
                    spacing: recipientLayout.colSpacing

                    RowLayout {
                        id: addressLabel
                        spacing: 6
                        Layout.fillWidth: true

                        MoneroComponents.TextPlain {
                            font.family: MoneroComponents.Style.fontRegular.name
                            font.pixelSize: 16
                            color: MoneroComponents.Style.defaultFontColor
                            text: qsTr("Address") + translationManager.emptyString
                        }

                        MoneroComponents.InlineButton {
                            fontFamily: FontAwesome.fontFamilySolid
                            fontStyleName: "Solid"
                            fontPixelSize: 18
                            text: FontAwesome.desktop
                            tooltip: qsTr("Grab QR code from screen") + translationManager.emptyString
                            onClicked: {
                                clearFields();
                                const codes = oshelper.grabQrCodesFromScreen();
                                for (var index = 0; index < codes.length; ++index) {
                                    const parsed = walletManager.parse_uri_to_object(codes[index]);
                                    if (!parsed.error) {
                                        fillPaymentDetails(parsed.address, parsed.payment_id, parsed.amount, parsed.tx_description, parsed.recipient_name);
                                        break;
                                    } else if (walletManager.addressValid(codes[index], appWindow.persistentSettings.nettype)) {
                                        fillPaymentDetails(codes[index]);
                                        break;
                                    }
                                }
                            }
                        }

                        MoneroComponents.InlineButton {
                            fontFamily: FontAwesome.fontFamilySolid
                            fontStyleName: "Solid"
                            text: FontAwesome.qrcode
                            visible: appWindow.qrScannerEnabled
                            tooltip: qsTr("Scan QR code") + translationManager.emptyString
                            onClicked: {
                                cameraUi.state = "Capture"
                                cameraUi.qrcode_decoded.connect(updateFromQrCode)
                            }
                        }

                        MoneroComponents.InlineButton {
                            fontFamily: FontAwesome.fontFamily
                            text: FontAwesome.addressBook
                            tooltip: qsTr("Import from address book") + translationManager.emptyString
                            onClicked: {
                                middlePanel.addressBookView.selectAndSend = true;
                                appWindow.showPageRequest("AddressBook");
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        id: amountLabel
                        spacing: 6
                        Layout.preferredWidth: 125
                        Layout.maximumWidth: recipientLayout.secondRowWidth

                        MoneroComponents.TextPlain {
                            font.family: MoneroComponents.Style.fontRegular.name
                            font.pixelSize: 16
                            color: MoneroComponents.Style.defaultFontColor
                            text: qsTr("Amount") + translationManager.emptyString
                        }

                        MoneroComponents.InlineButton {
                            fontFamily: FontAwesome.fontFamilySolid
                            fontStyleName: "Solid"
                            fontPixelSize: 16
                            text: FontAwesome.infinity
                            visible: recipientModel.count == 1
                            tooltip: qsTr("Send all unlocked balance of this account") + translationManager.emptyString
                            onClicked: recipientRepeater.itemAt(0).children[1].children[2].text = "(all)";
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Item {
                        Layout.preferredWidth: recipientLayout.thirdRowWidth
                    }
                }

                Repeater {
                    id: recipientRepeater
                    model: recipientModel

                    ColumnLayout {
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: -1
                            Layout.leftMargin: 1
                            Layout.rightMargin: recipientLayout.thirdRowWidth + 1
                            color: MoneroComponents.Style.inputBorderColorInActive
                            height: 1
                            visible: index > 0
                        }

                        RowLayout {
                            spacing: 0

                            MoneroComponents.LineEditMulti {
                                KeyNavigation.backtab: index > 0 ? recipientRepeater.itemAt(index - 1).children[1].children[2] : sendButton
                                KeyNavigation.tab: parent.children[2]
                                Layout.alignment: Qt.AlignVCenter
                                Layout.topMargin: index > 0 ? 0 : 1
                                Layout.bottomMargin: 2
                                Layout.fillWidth: true
                                addressValidation: true
                                borderDisabled: true
                                fontColor: error && text != "" ? MoneroComponents.Style.errorColor : MoneroComponents.Style.defaultFontColor
                                fontFamily: MoneroComponents.Style.fontMonoRegular.name
                                fontSize: 14
                                inputPaddingBottom: 0
                                inputPaddingTop: 0
                                inputPaddingRight: 0
                                placeholderFontFamily: MoneroComponents.Style.fontMonoRegular.name
                                placeholderFontSize: 14
                                spacing: 0
                                wrapMode: Text.WrapAnywhere
                                placeholderText: {
                                    if(persistentSettings.nettype == NetworkType.MAINNET){
                                        return "4.. / 8.. / monero:.. / OpenAlias";
                                    } else if (persistentSettings.nettype == NetworkType.STAGENET){
                                        return "5.. / 7.. / monero:..";
                                    } else if(persistentSettings.nettype == NetworkType.TESTNET){
                                        return "9.. / B.. / monero:..";
                                    }
                                }
                                onTextChanged: {
                                    const parsed = walletManager.parse_uri_to_object(text);
                                    if (!parsed.error) {
                                        fillPaymentDetails(parsed.address, parsed.payment_id, parsed.amount, parsed.tx_description, parsed.recipient_name);
                                    }
                                    address = text;
                                }
                                text: address

                                MoneroComponents.InlineButton {
                                    small: true
                                    text: qsTr("Resolve") + translationManager.emptyString
                                    visible: TxUtils.isValidOpenAliasAddress(address)
                                    onClicked: {
                                        const response = TxUtils.handleOpenAliasResolution(address, descriptionLine.text);
                                        if (response) {
                                            if (response.message) {
                                                oa_message(response.message);
                                            }
                                            if (response.address) {
                                                recipientRepeater.itemAt(index).children[1].children[0].text = response.address;
                                            }
                                            if (response.description) {
                                                descriptionLine.text = response.description;
                                                descriptionCheckbox.checked = true;
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.topMargin: index > 0 ? 0 : 1
                                Layout.bottomMargin: 1
                                Layout.leftMargin: recipientLayout.colSpacing / 2 - width
                                Layout.rightMargin: recipientLayout.colSpacing / 2
                                color: MoneroComponents.Style.inputBorderColorInActive
                                width: 1
                            }

                            MoneroComponents.LineEdit {
                                KeyNavigation.backtab: parent.children[0]
                                KeyNavigation.tab: index + 1 < recipientRepeater.count ? recipientRepeater.itemAt(index + 1).children[1].children[0] : sendButton
                                Layout.alignment: Qt.AlignVCenter
                                Layout.topMargin: index > 0 ? 0 : 1
                                Layout.bottomMargin: 2
                                Layout.rightMargin: recipientLayout.colSpacing / 2
                                Layout.preferredWidth: 125
                                Layout.maximumWidth: 125
                                borderDisabled: true
                                fontFamily: MoneroComponents.Style.fontMonoRegular.name
                                fontSize: 14
                                inputPaddingLeft: 0
                                inputPaddingRight: 0
                                inputPaddingTop: 0
                                inputPaddingBottom: 0
                                placeholderFontFamily: MoneroComponents.Style.fontMonoRegular.name
                                placeholderFontSize: 14
                                placeholderLeftMargin: 0
                                placeholderText: "0.00"
                                text: amount
                                onTextChanged: {
                                    text = text.trim().replace(",", ".");
                                    const match = text.match(/^0+(\d.*)/);
                                    if (match) {
                                        const cursorPosition = cursorPosition;
                                        text = match[1];
                                        cursorPosition = Math.max(cursorPosition, 1) - 1;
                                    } else if(text.indexOf('.') === 0){
                                        text = '0' + text;
                                        if (text.length > 2) {
                                            cursorPosition = 1;
                                        }
                                    }
                                    error = walletManager.amountFromString(text) > appWindow.getUnlockedBalance();

                                    amount = text;
                                }
                                validator: RegExpValidator {
                                    regExp: /^\s*(\d{1,8})?([\.,]\d{1,12})?\s*$/
                                }
                            }

                            MoneroComponents.TextPlain {
                                Layout.leftMargin: recipientLayout.colSpacing / 2
                                Layout.preferredWidth: recipientLayout.thirdRowWidth
                                font.family: FontAwesome.fontFamilySolid
                                font.styleName: "Solid"
                                horizontalAlignment: Text.AlignHCenter
                                opacity: mouseArea.containsMouse ? 1 : 0.85
                                text: FontAwesome.times
                                tooltip: qsTr("Remove recipient")  + translationManager.emptyString
                                tooltipLeft: true
                                visible: recipientModel.count > 1

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onEntered: parent.tooltipPopup.open()
                                    onExited: parent.tooltipPopup.close()
                                    onClicked: recipientModel.remove(index);
                                }
                            }

                            MoneroComponents.TextPlain {
                                Layout.leftMargin: recipientLayout.colSpacing / 2
                                Layout.preferredWidth: recipientLayout.thirdRowWidth
                                horizontalAlignment: Text.AlignHCenter
                                font.family: MoneroComponents.Style.fontRegular.name
                                text: "XMR"
                                visible: recipientModel.count == 1
                            }
                        }
                    }
                }

                GridLayout {
                    id: totalLayout
                    Layout.topMargin: recipientLayout.rowSpacing / 2
                    Layout.fillWidth: true
                    columns: 3
                    columnSpacing: recipientLayout.colSpacing
                    rowSpacing: 0

                    RowLayout {
                        Layout.column: 0
                        Layout.row: 0
                        Layout.fillWidth: true
                        Layout.topMargin: recipientModel.count > 1 ? 0 : -1
                        spacing: 0

                        CheckBox {
                            border: false
                            checked: false
                            enabled: {
                                if (recipientModel.count > 0 && recipientModel.get(0).amount == "(all)") {
                                    return false;
                                }
                                if (recipientModel.count >= recipientModel.maxRecipients) {
                                    return false;
                                }
                                return true;
                            }
                            fontAwesomeIcons: true
                            fontSize: descriptionLine.labelFontSize
                            iconOnTheLeft: true
                            text: qsTr("Add recipient") + translationManager.emptyString
                            toggleOnClick: false
                            uncheckedIcon: FontAwesome.plusCircle
                            onClicked: {
                                recipientModel.newRecipient("", "");
                            }
                        }

                        MoneroComponents.TextPlain {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            font.family: MoneroComponents.Style.fontRegular.name
                            font.pixelSize: 16
                            text: recipientModel.count > 1 ? qsTr("Total") + translationManager.emptyString : ""
                        }
                    }

                    MoneroComponents.LineEdit {
                        id: totalValue
                        Layout.column: 1
                        Layout.row: 0
                        Layout.preferredWidth: recipientLayout.secondRowWidth
                        Layout.topMargin: recipientModel.count > 1 ? 0 : -1
                        Layout.maximumWidth: recipientLayout.secondRowWidth
                        borderDisabled: true
                        fontFamily: MoneroComponents.Style.fontMonoRegular.name
                        fontSize: 14
                        inputHeight: 30
                        inputPaddingLeft: 0
                        inputPaddingRight: 0
                        inputPaddingTop: 0
                        inputPaddingBottom: 0
                        readOnly: true
                        text: Utils.removeTrailingZeros(walletManager.displayAmount(recipientModel.getAmountTotal()))
                        visible: recipientModel.count > 1
                    }

                    MoneroComponents.TextPlain {
                        Layout.column: 2
                        Layout.row: 0
                        Layout.preferredWidth: recipientLayout.thirdRowWidth
                        Layout.maximumWidth: recipientLayout.thirdRowWidth
                        horizontalAlignment: Text.AlignHCenter
                        font.family: MoneroComponents.Style.fontRegular.name
                        text: "XMR"
                        visible: recipientModel.count > 1
                    }

                    MoneroComponents.LineEdit {
                        Layout.column: 1
                        Layout.row: recipientModel.count > 1 ? 1 : 0
                        Layout.preferredWidth: recipientLayout.secondRowWidth
                        Layout.topMargin: recipientModel.count > 1 ? 0 : -1
                        Layout.maximumWidth: recipientLayout.secondRowWidth
                        borderDisabled: true
                        fontFamily: MoneroComponents.Style.fontMonoRegular.name
                        fontSize: 14
                        inputHeight: 30
                        inputPaddingLeft: 0
                        inputPaddingRight: 0
                        inputPaddingTop: 0
                        inputPaddingBottom: 0
                        opacity: 0.7
                        readOnly: true
                        text: fiatApiConvertToFiat(walletManager.displayAmount(recipientModel.getAmountTotal()))
                        visible: persistentSettings.fiatPriceEnabled
                    }

                    MoneroComponents.TextPlain {
                        Layout.column: 2
                        Layout.row: recipientModel.count > 1 ? 1 : 0
                        Layout.preferredWidth: recipientLayout.thirdRowWidth
                        Layout.topMargin: recipientModel.count > 1 ? 0 : -1
                        Layout.maximumWidth: recipientLayout.thirdRowWidth
                        font.family: MoneroComponents.Style.fontRegular.name
                        horizontalAlignment: Text.AlignHCenter
                        opacity: 0.7
                        text: fiatApiCurrencySymbol()
                        visible: persistentSettings.fiatPriceEnabled
                    }
                }
            }

            Rectangle {
                anchors.top: recipientLayout.top
                anchors.topMargin: addressLabel.height + recipientLayout.rowSpacing / 2
                anchors.bottom: recipientLayout.bottom
                anchors.bottomMargin: totalLayout.height + recipientLayout.rowSpacing / 2
                anchors.left: recipientLayout.left
                anchors.right: recipientLayout.right
                anchors.rightMargin: recipientLayout.thirdRowWidth
                color: "transparent"
                border.color: MoneroComponents.Style.inputBorderColorInActive
                border.width: 1
                radius: 4
            }
        }

        ColumnLayout {
            spacing: 0
            visible: appWindow.walletMode >= 2

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
                ListElement { column1: qsTr("Slow (x0.2 fee)") ; column2: ""; priority: 1}
                ListElement { column1: qsTr("Normal (x1 fee)") ; column2: ""; priority: 2 }
                ListElement { column1: qsTr("Fast (x5 fee)") ; column2: ""; priority: 3 }
                ListElement { column1: qsTr("Fastest (x200 fee)")  ; column2: "";  priority: 4 }
            }

            RowLayout {
                Layout.topMargin: 5
                spacing: 10

                StandardDropdown {
                    Layout.maximumWidth: 200
                    id: priorityDropdown
                    currentIndex: 0
                    dataModel: priorityModelV5
                    labelText: qsTr("Transaction priority") + translationManager.emptyString
                    labelFontSize: 16
                }

                MoneroComponents.TextPlain {
                    id: feeLabel
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 11
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 14
                    color: MoneroComponents.Style.defaultFontColor
                    opacity: 0.7
                    property bool estimating: false
                    property var estimatedFee: null
                    property string estimatedFeeFiat: {
                        if (!persistentSettings.fiatPriceEnabled || estimatedFee == null) {
                            return "";
                        }
                        const fiatFee = fiatApiConvertToFiat(estimatedFee);
                        return " (%1 %3)".arg(fiatFee < 0.01 ? "<0.01" : "~" + fiatFee).arg(fiatApiCurrencySymbol());
                    }
                    property var fee: {
                        estimatedFee = null;
                        estimating = sendButton.enabled;
                        if (!sendButton.enabled || !currentWallet) {
                            return;
                        }
                        var addresses = [];
                        var amounts = [];
                        for (var index = 0; index < recipientModel.count; ++index) {
                            const recipient = recipientModel.get(index);
                            addresses.push(recipient.address);
                            amounts.push(walletManager.amountFromString(recipient.amount));
                        }
                        currentWallet.estimateTransactionFeeAsync(
                            addresses,
                            amounts,
                            priorityModelV5.get(priorityDropdown.currentIndex).priority,
                            function (amount) {
                                if (amount) {
                                    estimatedFee = Utils.removeTrailingZeros(amount);
                                }
                                estimating = false;
                            });
                    }
                    text: {
                        if (!sendButton.enabled || estimatedFee == null) {
                            return ""
                        }
                        return "~%1 XMR%2 %3".arg(estimatedFee)
                            .arg(estimatedFeeFiat)
                            .arg(qsTr("fee") + translationManager.emptyString);
                    }

                    BusyIndicator {
                        anchors.left: parent.left
                        running: feeLabel.estimating
                        height: parent.height
                        width: height
                    }
                }
            }
        }

      MoneroComponents.WarningBox {
          text: qsTr("Description field contents match long payment ID format. \
          Please don't paste long payment ID into description field, your funds might be lost.") + translationManager.emptyString;
          visible: warningLongPidDescription
      }

      ColumnLayout {
          spacing: 15

          ColumnLayout {
              CheckBox {
                  id: descriptionCheckbox
                  border: false
                  checkedIcon: FontAwesome.minusCircle
                  uncheckedIcon: FontAwesome.plusCircle
                  fontAwesomeIcons: true
                  fontSize: descriptionLine.labelFontSize
                  iconOnTheLeft: true
                  Layout.fillWidth: true
                  text: qsTr("Add description") + translationManager.emptyString
                  onClicked: {
                      if (!descriptionCheckbox.checked) {
                        descriptionLine.text = "";
                      }
                  }
              }

              LineEdit {
                  id: descriptionLine
                  placeholderFontSize: 16
                  fontSize: 16
                  placeholderText: qsTr("Saved to local wallet history") + " (" + qsTr("only visible to you") + ")" + translationManager.emptyString
                  Layout.fillWidth: true
                  visible: descriptionCheckbox.checked
              }
          }

          ColumnLayout {
              visible: paymentIdCheckbox.checked
              CheckBox {
                  id: paymentIdCheckbox
                  border: false
                    checkedIcon: FontAwesome.minusCircle
                    uncheckedIcon: FontAwesome.plusCircle
                    fontAwesomeIcons: true
                  fontSize: paymentIdLine.labelFontSize
                  iconOnTheLeft: true
                  Layout.fillWidth: true
                  text: qsTr("Add payment ID") + translationManager.emptyString
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
                  readOnly: true
                  Layout.fillWidth: true
                  wrapMode: Text.WrapAnywhere
                  addressValidation: false
                  visible: paymentIdCheckbox.checked
                  error: paymentIdCheckbox.checked
              }
          }
      }

      MoneroComponents.WarningBox {
          id: paymentIdWarningBox
          text: qsTr("Long payment IDs are obsolete. \
          Long payment IDs were not encrypted on the blockchain and would harm your privacy. \
          If the party you're sending to still requires a long payment ID, please notify them.") + translationManager.emptyString;
          visible: paymentIdCheckbox.checked || warningLongPidDescription
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
              Layout.topMargin: 4
              text: qsTr("Send") + translationManager.emptyString
              enabled: !sendButtonWarningBox.visible && !warningContent && !recipientModel.hasEmptyAddress() && !paymentIdWarningBox.visible
              onClicked: {
                  console.log("Transfer: paymentClicked")
                  var priority = priorityModelV5.get(priorityDropdown.currentIndex).priority
                  console.log("priority: " + priority)
                  setPaymentId(paymentIdLine.text.trim());
                  root.paymentClicked(recipientModel.getRecipients(), paymentIdLine.text, root.mixin, priority, descriptionLine.text)
              }
          }
      }

      function checkInformation() {
        return !recipientModel.hasEmptyAmount() &&
            recipientModel.getAmountTotal() <= appWindow.getUnlockedBalance() &&
            !recipientModel.hasInvalidAddress();
      }

    } // pageRoot

    ColumnLayout {
        id: advancedLayout
        anchors.top: pageRoot.bottom
        anchors.left: parent.left
        anchors.margins: 20
        anchors.topMargin: 32
        spacing: 10
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

        AdvancedOptionsItem {
            visible: persistentSettings.transferShowAdvanced && appWindow.walletMode >= 2
            title: qsTr("Outputs") + translationManager.emptyString
            button1.text: qsTr("Export") + translationManager.emptyString
            button1.enabled: appWindow.viewOnly
            button1.onClicked: {
                console.log("Transfer: export outputs clicked")
                exportOutputsDialog.open();
            }
            button2.text: qsTr("Import") + translationManager.emptyString
            button2.enabled: !appWindow.viewOnly
            button2.onClicked: {
                console.log("Transfer: import outputs clicked")
                importOutputsDialog.open();
            }
            tooltip: {
                var header = qsTr("Required for cold wallets to sign their corresponding key images") + translationManager.emptyString;
                return "<style type='text/css'>.header{ font-size: 13px; } p{line-height:20px; margin-top:0px; margin-bottom:0px; " +
                       ";} p.orange{color:#ff9323;}</style>" +
                       "<div class='header'>" + header + "</div>" +
                       "<p>" + qsTr("1. Using view-only wallet, export the outputs into a file") + "</p>" +
                       "<p>" + qsTr("2. Using cold wallet, import the outputs file") + "</p>" +
                       translationManager.emptyString
            }
        }

        AdvancedOptionsItem {
            visible: persistentSettings.transferShowAdvanced && appWindow.walletMode >= 2
            title: qsTr("Key images") + translationManager.emptyString
            button1.text: qsTr("Export") + translationManager.emptyString
            button1.enabled: !appWindow.viewOnly
            button1.onClicked: {
                console.log("Transfer: export key images clicked")
                exportKeyImagesDialog.open();
            }
            button2.text: qsTr("Import") + translationManager.emptyString
            button2.enabled: appWindow.viewOnly && appWindow.isTrustedDaemon()
            button2.onClicked: {
                console.log("Transfer: import key images clicked")
                importKeyImagesDialog.open(); 
            }
            tooltip: {
                var errorMessage = "";
                if (appWindow.viewOnly && !appWindow.isTrustedDaemon()){
                    errorMessage = "<p class='orange'>" + qsTr("* To import, you must connect to a local node or a trusted remote node") + "</p>";
                }
                var header = qsTr("Required for view-only wallets to display the real balance") + translationManager.emptyString;
                return "<style type='text/css'>.header{ font-size: 13px; } p{line-height:20px; margin-top:0px; margin-bottom:0px; " +
                       ";} p.orange{color:#ff9323;}</style>" +
                       "<div class='header'>" + header + "</div>" +
                       "<p>" + qsTr("1. Using cold wallet, export the key images into a file") + "</p>" +
                       "<p>" + qsTr("2. Using view-only wallet, import the key images file") + "</p>" +
                       errorMessage + translationManager.emptyString
            }
        }

        AdvancedOptionsItem {
            visible: persistentSettings.transferShowAdvanced && appWindow.walletMode >= 2
            title: qsTr("Offline transaction signing") + translationManager.emptyString
            button1.text: qsTr("Create") + translationManager.emptyString
            button1.enabled: appWindow.viewOnly && pageRoot.checkInformation() && appWindow.daemonSynced
            button1.onClicked: {
                console.log("Transfer: saveTx Clicked")
                var priority = priorityModelV5.get(priorityDropdown.currentIndex).priority
                console.log("priority: " + priority)
                setPaymentId(paymentIdLine.text.trim());
                root.paymentClicked(recipientModel.getRecipients(), paymentIdLine.text, root.mixin, priority, descriptionLine.text)
            }
            button2.text: qsTr("Sign (offline)") + translationManager.emptyString
            button2.enabled: !appWindow.viewOnly
            button2.onClicked: {
                console.log("Transfer: sign tx clicked")
                signTxDialog.open();
            }
            button3.text: qsTr("Submit") + translationManager.emptyString
            button3.enabled: appWindow.viewOnly
            button3.onClicked: {
                console.log("Transfer: submit tx clicked")
                submitTxDialog.open();
            }
            tooltip: {
                var errorMessage = "";
                if (appWindow.viewOnly && !pageRoot.checkInformation()) {
                    errorMessage = "<p class='orange'>" + qsTr("* To create a transaction file, please enter address and amount above") + "</p>";
                }
                var header = qsTr("Spend XMR from a cold (offline) wallet") + translationManager.emptyString;
                return "<style type='text/css'>.header{ font-size: 13px; } p{line-height:20px; margin-top:0px; margin-bottom:0px; " +
                       ";} p.orange{color:#ff9323;}</style>" +
                       "<div class='header'>" + header + "</div>" +
                       "<p>" + qsTr("1. Using view-only wallet, export the outputs into a file") + "</p>" +
                       "<p>" + qsTr("2. Using cold wallet, import the outputs file and export the key images") + "</p>" +
                       "<p>" + qsTr("3. Using view-only wallet, import the key images file and create a transaction file") + "</p>" +
                       errorMessage +
                       "<p>" + qsTr("4. Using cold wallet, sign your transaction file") + "</p>" +
                       "<p>" + qsTr("5. Using view-only wallet, submit your signed transaction") + "</p>" + translationManager.emptyString
            }
        }

        AdvancedOptionsItem {
            visible: persistentSettings.transferShowAdvanced && appWindow.walletMode >= 2
            title: qsTr("Unmixable outputs") + translationManager.emptyString
            button1.text: qsTr("Sweep") + translationManager.emptyString
            button1.enabled : pageRoot.enabled
            button1.onClicked: {
                console.log("Transfer: sweepUnmixableClicked")
                root.sweepUnmixableClicked()
            }
            tooltip: qsTr("Create a transaction that spends old unmovable outputs") + translationManager.emptyString
        }
    }

    //SignTxDialog
    FileDialog {
        id: signTxDialog
        title: qsTr("Please choose a file") + translationManager.emptyString
        folder: "file://" + appWindow.accountsDir
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
                confirmationDialog.text =  qsTr("\nConfirmation message:\n ") + transaction.confirmationMessage
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
        folder: "file://" + appWindow.accountsDir
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
    
    FileDialog {
        id: exportOutputsDialog
        selectMultiple: false
        selectExisting: false
        onAccepted: {
            console.log(walletManager.urlToLocalPath(exportOutputsDialog.fileUrl))
            if (currentWallet.exportOutputs(walletManager.urlToLocalPath(exportOutputsDialog.fileUrl), true)) {
                appWindow.showStatusMessage(qsTr("Outputs successfully exported to file") + translationManager.emptyString, 3);
            } else {
                appWindow.showStatusMessage(currentWallet.errorString, 5);
            }
        }
        onRejected: {
            console.log("Canceled");
        }
    }

    FileDialog {
        id: importOutputsDialog
        selectMultiple: false
        selectExisting: true
        title: qsTr("Please choose a file") + translationManager.emptyString
        onAccepted: {
            console.log(walletManager.urlToLocalPath(importOutputsDialog.fileUrl))
            if (currentWallet.importOutputs(walletManager.urlToLocalPath(importOutputsDialog.fileUrl))) {
                appWindow.showStatusMessage(qsTr("Outputs successfully imported to wallet") + translationManager.emptyString, 3);
            } else {
                appWindow.showStatusMessage(currentWallet.errorString, 5);
            }
        }
        onRejected: {
            console.log("Canceled");
        }
    }

    //ExportKeyImagesDialog
    FileDialog {
        id: exportKeyImagesDialog
        selectMultiple: false
        selectExisting: false
        onAccepted: {
            console.log(walletManager.urlToLocalPath(exportKeyImagesDialog.fileUrl))
            if (currentWallet.exportKeyImages(walletManager.urlToLocalPath(exportKeyImagesDialog.fileUrl), true)) {
                appWindow.showStatusMessage(qsTr("Key images successfully exported to file") + translationManager.emptyString, 3);
            } else {
                appWindow.showStatusMessage(currentWallet.errorString, 5);
            }
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
            if (currentWallet.importKeyImages(walletManager.urlToLocalPath(importKeyImagesDialog.fileUrl))) {
                appWindow.showStatusMessage(qsTr("Key images successfully imported to wallet") + translationManager.emptyString, 3);
            } else {
                appWindow.showStatusMessage(currentWallet.errorString, 5);
            }
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
    }

    //TODO: Add daemon sync status
    //TODO: enable send page when we're connected and daemon is synced

    function updateStatus() {
        var messageNotConnected = qsTr("Wallet is not connected to daemon.");
        if(appWindow.walletMode >= 2 && !persistentSettings.useRemoteNode) messageNotConnected += root.startLinkText;
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
        case Wallet.ConnectionStatus_Connecting:
            root.warningContent = qsTr("Wallet is connecting to daemon.")
            break
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
    function sendTo(address, paymentId, description, amount) {
        middlePanel.state = 'Transfer';

        fillPaymentDetails(address, paymentId, amount, description);
    }
}
