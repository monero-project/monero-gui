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

import QtQuick 2.2
import moneroComponents.TranslationManager 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import "../components"
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
    property alias walletName : accountName.text
    property alias progressDotsModel : progressDots.model
    property alias recoverFromKeysAddress: addressLine.text;
    property alias recoverFromKeysViewKey: viewKeyLine.text;
    property alias recoverFromKeysSpendKey: spendKeyLine.text;
    // recover mode or create new wallet
    property bool recoverMode: false
    // Recover form seed or keys
    property bool recoverFromSeedMode: true
    property int rowSpacing: 10

    function checkFields(){
        var addressOK = walletManager.addressValid(addressLine.text, persistentSettings.testnet)
        var viewKeyOK = walletManager.keyValid(viewKeyLine.text, addressLine.text, true, persistentSettings.testnet)
        // Spendkey is optional
        var spendKeyOK = (spendKeyLine.text.length > 0)? walletManager.keyValid(spendKeyLine.text, addressLine.text, false, persistentSettings.testnet) : true

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
        return wordsArray.length === 25
    }

    RowLayout {
        id: dotsRow
        Layout.alignment: Qt.AlignRight
        spacing: 6

        ListModel {
            id: dotsModel
            ListElement { dotColor: "#36B05B" }
            //ListElement { dotColor: "#DBDBDB" }
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
            font.pixelSize: 28
            wrapMode: Text.Wrap
            color: "#3F3F3F"
        }
    }

    ColumnLayout {
        Layout.bottomMargin: rowSpacing

        Label {
            Layout.topMargin: 20
            fontSize: 14
            text:  qsTr("Wallet name")
                   + translationManager.emptyString
        }

        LineEdit {
            id: accountName
            Layout.fillWidth: true
            Layout.maximumWidth: 600
            Layout.minimumWidth: 200
            text: defaultAccountName
            onTextUpdated: checkNextButton()
        }
    }

    RowLayout{
        visible: recoverMode
        spacing: 0
        StandardButton {
            id: recoverFromSeedButton
            text: qsTr("Restore from seed") + translationManager.emptyString
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            enabled: recoverFromKeys.visible
            onClicked: {
                recoverFromSeedMode = true;
                checkNextButton();
            }
        }

        StandardButton {
            id: recoverFromKeysButton
            text: qsTr("Restore from keys") + translationManager.emptyString
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            enabled: recoverFromSeed.visible
            onClicked: {
                recoverFromSeedMode = false;
                checkNextButton();
            }
        }
    }

    // Recover from seed
    RowLayout {
        id: recoverFromSeed
        visible: !recoverMode || ( recoverMode && recoverFromSeedMode)
        WizardMemoTextInput {
            id : memoTextItem
            Layout.fillWidth: true
            Layout.maximumWidth: 600
            Layout.minimumWidth: 200
        }
    }

    // Recover from keys
    GridLayout {
        Layout.bottomMargin: page.rowSpacing
        rowSpacing: page.rowSpacing
        id: recoverFromKeys
        visible: recoverMode && !recoverFromSeedMode
        columns: 1
        LineEdit {
            Layout.fillWidth: true
            id: addressLine
            Layout.maximumWidth: 600
            Layout.minimumWidth: 200
            placeholderText: qsTr("Account address (public)") + translationManager.emptyString
            onTextUpdated: checkNextButton()
        }
        LineEdit {
            Layout.fillWidth: true
            id: viewKeyLine
            Layout.maximumWidth: 600
            Layout.minimumWidth: 200
            placeholderText: qsTr("View key (private)") + translationManager.emptyString
            onTextUpdated: checkNextButton()

        }
        LineEdit {
            Layout.fillWidth: true
            Layout.maximumWidth: 600
            Layout.minimumWidth: 200
            id: spendKeyLine
            placeholderText: qsTr("Spend key (private)") + translationManager.emptyString
            onTextUpdated: checkNextButton()
        }
    }
    
    // Restore Height
    RowLayout {
        LineEdit {
            id: restoreHeightItem
            Layout.fillWidth: true
            Layout.maximumWidth: 600
            Layout.minimumWidth: 200
            placeholderText: qsTr("Restore height (optional)") + translationManager.emptyString
            validator: IntValidator {
                bottom:0
            }
        }
    }

    // Wallet store location
    ColumnLayout {
        Label {
            Layout.fillWidth: true
            Layout.topMargin: 20
            fontSize: 14
            text: qsTr("Your wallet is stored in") + ": " + fileUrlInput.text;
        }

        LineEdit {
            Layout.fillWidth: true
            Layout.maximumWidth: 600
            Layout.minimumWidth: 200
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

