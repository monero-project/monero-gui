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

import QtQuick 2.2
import moneroComponents.TranslationManager 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import "../components" as MoneroComponents
import 'utils.js' as Utils

// Reusable component for mnaging wallet (account name, path, private key)
ColumnLayout {
    id: page
    Layout.leftMargin: wizardLeftMargin
    Layout.rightMargin: wizardRightMargin
    property alias titleText: titleText.text
    property alias accountNameText: accountName.text
    property alias walletPath: fileUrlInput.text
    property alias wordsTextItem : memoTextItem
    property alias restoreHeight : restoreHeightItem.text
    property alias restoreHeightVisible: restoreHeightItem.visible
    property alias subaddressLookahead : subaddressLookaheadItem.text
    property alias walletName : accountName.text
    property alias progressDotsModel : progressDots.model
    property alias recoverFromKeysAddress: addressLine.text;
    property alias recoverFromKeysViewKey: viewKeyLine.text;
    property alias recoverFromKeysSpendKey: spendKeyLine.text;
    // recover mode or create new wallet
    property bool recoverMode: false
    // Recover form seed or keys
    property bool recoverFromSeedMode: true
    // Recover form hardware device
    property bool recoverFromDevice: false
    property var deviceName: deviceNameModel.get(deviceNameDropdown.currentIndex).column2
    property alias deviceNameDropdown: deviceNameDropdown
    property int rowSpacing: 10

    function checkFields(){
        var addressOK = (viewKeyLine.text.length > 0 || spendKeyLine.text.length > 0)? walletManager.addressValid(addressLine.text, persistentSettings.nettype) : false
        var viewKeyOK = (viewKeyLine.text.length > 0)? walletManager.keyValid(viewKeyLine.text, addressLine.text, true, persistentSettings.nettype) : true
        // Spendkey is optional
        var spendKeyOK = (spendKeyLine.text.length > 0)? walletManager.keyValid(spendKeyLine.text, addressLine.text, false, persistentSettings.nettype) : true

        addressLine.error = !addressOK && addressLine.text.length != 0
        viewKeyLine.error = !viewKeyOK && viewKeyLine.text.length != 0
        spendKeyLine.error = !spendKeyOK && spendKeyLine.text.length != 0

        return addressOK && viewKeyOK && spendKeyOK
    }

    function checkNextButton(){
        wizard.nextButton.enabled = false
        console.log("check next", recoverFromSeed.visible)
        if(recoverMode && !recoverFromSeedMode) {
            console.log("checking key fields")
            wizard.nextButton.enabled = checkFields();
        } else if (recoverMode && recoverFromSeedMode) {
            wizard.nextButton.enabled = checkSeed()
        } else
            wizard.nextButton.enabled = true;
    }

    function checkSeed() {
        console.log("Checking seed")
        var wordsArray = Utils.lineBreaksToSpaces(uiItem.wordsTextItem.memoText).split(" ");
        return wordsArray.length === 25 || wordsArray.length === 24
    }

    function updateFromQrCode(address, payment_id, amount, tx_description, recipient_name, extra_parameters) {
        // Switch to recover from keys
        recoverFromSeedMode = false
        spendKeyLine.text = ""
        viewKeyLine.text = ""
        restoreHeightItem.text = ""


        if(typeof extra_parameters.secret_view_key != "undefined") {
            viewKeyLine.text = extra_parameters.secret_view_key
        }
        if(typeof extra_parameters.secret_spend_key != "undefined") {
            spendKeyLine.text = extra_parameters.secret_spend_key
        }
        if(typeof extra_parameters.restore_height != "undefined") {
            restoreHeightItem.text = extra_parameters.restore_height
        }
        addressLine.text = address

        cameraUi.qrcode_decoded.disconnect(updateFromQrCode)

        // Check if keys are correct
        checkNextButton();
    }

    RowLayout {
        id: dotsRow
        Layout.alignment: Qt.AlignRight
        spacing: 6

        ListModel {
            id: dotsModel
            ListElement { dotColor: "#FFE00A" }
            ListElement { dotColor: "#DBDBDB" }
            ListElement { dotColor: "#DBDBDB" }
            ListElement { dotColor: "#DBDBDB" }
        }

        Repeater {
            id: progressDots
            model: dotsModel
            delegate: Rectangle {
                width: 12; height: 12
                radius: 6
                color: dotColor
            }
        }
    }

    RowLayout {
        id: headerColumn
        Layout.fillWidth: true
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            id: titleText
            font.family: "Arial"
            font.pixelSize: 28 * scaleRatio
            wrapMode: Text.Wrap
            color: "#3F3F3F"
        }
    }

    ColumnLayout {
        Layout.bottomMargin: rowSpacing

        MoneroComponents.Label {
            Layout.topMargin: 20 * scaleRatio
            fontFamily: "Arial"
            fontColor: "#555555"
            fontSize: 14 * scaleRatio
            text:  qsTr("Wallet name")
                   + translationManager.emptyString
        }

        MoneroComponents.LineEdit {
            id: accountName
            Layout.fillWidth: true
            Layout.maximumWidth: 600 * scaleRatio
            Layout.minimumWidth: 200 * scaleRatio
            text: defaultAccountName
            onTextUpdated: checkNextButton()
            borderColor: Qt.rgba(0, 0, 0, 0.15)
            backgroundColor: "white"
            fontColor: "black"
            fontBold: false
        }

        MoneroComponents.WarningBox {
            color: "#DBDBDB"
            textColor: "#4A4646"
            visible: !recoverFromDevice && !recoverMode
            text: qsTr("WARNING: Copying your seed to clipboard can expose you to malicious software, which may record your seed and steal your Monero. Please write down your seed manually.") + translationManager.emptyString
        }
    }

    GridLayout{
        columns: (isMobile)? 2 : 4
        visible: recoverMode

        MoneroComponents.StandardButton {
            id: recoverFromSeedButton
            text: qsTr("Restore from seed") + translationManager.emptyString
            enabled: recoverFromKeys.visible
            onClicked: {
                recoverFromSeedMode = true;
                checkNextButton();
            }
        }

        MoneroComponents.StandardButton {
            id: recoverFromKeysButton
            text: qsTr("Restore from keys") + translationManager.emptyString
            enabled: recoverFromSeed.visible
            onClicked: {
                recoverFromSeedMode = false;
                checkNextButton();
            }
        }

        MoneroComponents.StandardButton {
            id: qrfinderButton
            text: qsTr("From QR Code") + translationManager.emptyString
            visible : appWindow.qrScannerEnabled
            enabled : visible
            onClicked: {
                cameraUi.state = "Capture"
                cameraUi.qrcode_decoded.connect(updateFromQrCode)
            }
        }

    }

    // Recover from seed
    RowLayout {
        id: recoverFromSeed
        visible: !recoverFromDevice && (!recoverMode || ( recoverMode && recoverFromSeedMode))
        WizardMemoTextInput {
            id : memoTextItem
            Layout.fillWidth: true
            Layout.maximumWidth: 600 * scaleRatio
            Layout.minimumWidth: 200 * scaleRatio
        }
    }

    // Recover from keys
    GridLayout {
        Layout.bottomMargin: page.rowSpacing
        rowSpacing: page.rowSpacing
        id: recoverFromKeys
        visible: recoverMode && !recoverFromSeedMode
        columns: 1
        MoneroComponents.LineEdit {
            Layout.fillWidth: true
            id: addressLine
            Layout.maximumWidth: 600 * scaleRatio
            Layout.minimumWidth: 200 * scaleRatio
            placeholderFontBold: true
            placeholderFontFamily: "Arial"
            placeholderColor: MoneroComponents.Style.legacy_placeholderFontColor
            placeholderText: qsTr("Account address (public)") + translationManager.emptyString
            placeholderOpacity: 1.0
            onTextUpdated: checkNextButton()
            borderColor: Qt.rgba(0, 0, 0, 0.15)
            backgroundColor: "white"
            fontColor: "black"
            fontBold: false
        }
        MoneroComponents.LineEdit {
            Layout.fillWidth: true
            id: viewKeyLine
            Layout.maximumWidth: 600 * scaleRatio
            Layout.minimumWidth: 200 * scaleRatio
            placeholderFontBold: true
            placeholderFontFamily: "Arial"
            placeholderColor: MoneroComponents.Style.legacy_placeholderFontColor
            placeholderText: qsTr("View key (private)") + translationManager.emptyString
            placeholderOpacity: 1.0
            onTextUpdated: checkNextButton()
            borderColor: Qt.rgba(0, 0, 0, 0.15)
            backgroundColor: "white"
            fontColor: "black"
            fontBold: false

        }
        MoneroComponents.LineEdit {
            Layout.fillWidth: true
            Layout.maximumWidth: 600 * scaleRatio
            Layout.minimumWidth: 200 * scaleRatio
            id: spendKeyLine
            placeholderFontBold: true
            placeholderFontFamily: "Arial"
            placeholderColor: MoneroComponents.Style.legacy_placeholderFontColor
            placeholderText: qsTr("Spend key (private)") + translationManager.emptyString
            placeholderOpacity: 1.0
            onTextUpdated: checkNextButton()
            borderColor: Qt.rgba(0, 0, 0, 0.15)
            backgroundColor: "white"
            fontColor: "black"
            fontBold: false
        }
    }
    
    // Restore Height
    RowLayout {
        MoneroComponents.LineEdit {
            id: restoreHeightItem
            Layout.fillWidth: true
            Layout.maximumWidth: 600 * scaleRatio
            Layout.minimumWidth: 200 * scaleRatio
            placeholderFontBold: true
            placeholderFontFamily: "Arial"
            placeholderColor: MoneroComponents.Style.legacy_placeholderFontColor
            placeholderText: qsTr("Restore height (optional)") + translationManager.emptyString
            placeholderOpacity: 1.0
            validator: IntValidator {
                bottom:0
            }
            borderColor: Qt.rgba(0, 0, 0, 0.15)
            backgroundColor: "white"
            fontColor: "black"
            fontBold: false
        }
    }
    
    // Subaddress lookahead
    RowLayout {
        visible: recoverFromDevice
        MoneroComponents.LineEdit {
            id: subaddressLookaheadItem
            Layout.fillWidth: true
            Layout.maximumWidth: 600 * scaleRatio
            Layout.minimumWidth: 200 * scaleRatio
            placeholderFontBold: true
            placeholderFontFamily: "Arial"
            placeholderColor: MoneroComponents.Style.legacy_placeholderFontColor
            placeholderText: qsTr("Subaddress lookahead (optional): <major>:<minor>") + translationManager.emptyString
            placeholderOpacity: 1.0
            borderColor: Qt.rgba(0, 0, 0, 0.15)
            backgroundColor: "white"
            fontColor: "black"
            fontBold: false
        }
    }

    // Device name
    ColumnLayout {
        visible: recoverFromDevice
        MoneroComponents.Label {
            Layout.topMargin: 20 * scaleRatio
            fontFamily: "Arial"
            fontColor: "#555555"
            fontSize: 14 * scaleRatio
            text:  qsTr("Device name") + translationManager.emptyString
        }
        ListModel {
            id: deviceNameModel
            ListElement { column1: qsTr("Ledger") ; column2: "Ledger"; }
//            ListElement { column1: qsTr("Trezor") ; column2: "Trezor"; }
        }
        MoneroComponents.StandardDropdown {
            id: deviceNameDropdown
            dataModel: deviceNameModel
            Layout.fillWidth: true
            Layout.topMargin: 6
            colorHeaderBackground: "black"
            releasedColor: "#363636"
            pressedColor: "#202020"
        }
    }

    // Wallet store location
    ColumnLayout {
        z: deviceNameDropdown.z - 1
        MoneroComponents.Label {
            Layout.fillWidth: true
            Layout.topMargin: 20 * scaleRatio
            fontSize: 14
            fontFamily: "Arial"
            fontColor: "#555555"
            text: qsTr("Your wallet is stored in") + ": " + fileUrlInput.text;
        }

        MoneroComponents.LineEdit {
            Layout.fillWidth: true
            Layout.maximumWidth: 600 * scaleRatio
            Layout.minimumWidth: 200 * scaleRatio
            id: fileUrlInput
            text: moneroAccountsDir + "/"

            // workaround for the bug "filechooser only opens once"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                    fileDialog.folder = walletManager.localPathToUrl(fileUrlInput.text)
                    fileDialog.open()
                    fileUrlInput.focus = true
                }
            }
            borderColor: Qt.rgba(0, 0, 0, 0.15)
            backgroundColor: "white"
            fontColor: "black"
            fontBold: false
        }

        FileDialog {
            id: fileDialog
            selectMultiple: false
            selectFolder: true
            title: qsTr("Please choose a directory")  + translationManager.emptyString
            onAccepted: {
                fileUrlInput.text = walletManager.urlToLocalPath(fileDialog.folder)
                fileDialog.visible = false
            }
            onRejected: {
                fileDialog.visible = false
            }
        }
    }
}

