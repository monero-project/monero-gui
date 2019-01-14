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

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

Rectangle {
    id: wizardRestoreWallet1

    color: "transparent"
    property string viewName: "wizardCreateWallet1"

    function verify() {
        if(wizardController.walletRestoreMode === "keys") {
            var valid = wizardRestoreWallet1.verifyFromKeys();
            return valid;
        } else if(wizardController.walletRestoreMode === "seed") {
            var valid = wizardWalletInput.verify();
            if(!valid) return false;
            valid = Wizard.checkSeed(seedInput.text);
            return valid;
        }

        return false;
    }

    function verifyFromKeys() {
        var result = Wizard.restoreWalletCheckViewSpendAddress(
            walletManager,
            persistentSettings.nettype,
            viewKeyLine.text,
            spendKeyLine.text,
            addressLine.text
        );

        var addressLineLength = addressLine.text.length
        var viewKeyLineLength = viewKeyLine.text.length
        var spendKeyLineLength = spendKeyLine.text.length

        addressLine.error = !result[0] && addressLineLength != 0
        viewKeyLine.error = !result[1] && viewKeyLineLength != 0
        spendKeyLine.error = !result[2] && spendKeyLineLength != 0

        return (!addressLine.error && !viewKeyLine.error && !spendKeyLine.error && 
            addressLineLength != 0 && viewKeyLineLength != 0 && spendKeyLineLength != 0)
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 20 * scaleRatio

            WizardHeader {
                title: qsTr("Restore wallet") + translationManager.emptyString
                subtitle: qsTr("Restore wallet from keys or mnemonic seed.") + translationManager.emptyString
            }

            WizardWalletInput{
                id: wizardWalletInput
            }

            GridLayout{
                columns: 3

                MoneroComponents.StandardButton {
                    text: qsTr("Restore from seed") + translationManager.emptyString
                    small: true
                    enabled: wizardController.walletRestoreMode !== 'seed'

                    onClicked: {
                        wizardController.walletRestoreMode = 'seed';
                    }
                }

                MoneroComponents.StandardButton {
                    text: qsTr("Restore from keys") + translationManager.emptyString
                    small: true
                    enabled: wizardController.walletRestoreMode !== 'keys'

                    onClicked: {
                        wizardController.walletRestoreMode = 'keys';
                    }
                }

                MoneroComponents.StandardButton {
                    text: qsTr("From QR Code") + translationManager.emptyString
                    small: true
                    visible: appWindow.qrScannerEnabled
                    enabled: wizardController.walletRestoreMode !== 'qr'

                    onClicked: {
                        wizardController.walletRestoreMode = 'qr';
                        cameraUi.state = "Capture"
                        cameraUi.qrcode_decoded.connect(Wizard.updateFromQrCode)
                    }
                }
            }

            ColumnLayout {
                // seed textarea
                visible: wizardController.walletRestoreMode === 'seed'
                Layout.preferredHeight: 100 * scaleRatio
                Layout.fillWidth: true

                Rectangle {
                    color: "transparent"
                    radius: 4

                    Layout.preferredHeight: 100 * scaleRatio
                    Layout.fillWidth: true

                    border.width: 1
                    border.color: {
                        if(seedInput.text !== "" && seedInput.error){
                            return MoneroComponents.Style.inputBorderColorInvalid;
                        } else if(seedInput.activeFocus){
                            return MoneroComponents.Style.inputBorderColorActive;
                        } else {
                            return MoneroComponents.Style.inputBorderColorInActive;
                        }
                    }

                    TextArea {
                        id: seedInput
                        property bool error: false
                        width: parent.width
                        height: 100 * scaleRatio

                        color: MoneroComponents.Style.defaultFontColor
                        textMargin: 2 * scaleRatio
                        text: ""

                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 16 * scaleRatio
                        selectionColor: MoneroComponents.Style.dimmedFontColor
                        selectedTextColor: MoneroComponents.Style.defaultFontColor
                        wrapMode: TextInput.Wrap

                        selectByMouse: true

                        Text {
                            id: memoTextPlaceholder
                            opacity: 0.35
                            anchors.fill:parent
                            font.pixelSize: 16 * scaleRatio
                            anchors.margins: 8 * scaleRatio
                            anchors.leftMargin: 10 * scaleRatio
                            font.family: MoneroComponents.Style.fontRegular.name
                            text: qsTr("Enter your 25 (or 24) word mnemonic seed") + translationManager.emptyString
                            color: MoneroComponents.Style.defaultFontColor
                            visible: !seedInput.text && !parent.focus
                        }
                    }
                }
            }

            MoneroComponents.LineEdit {
                id: addressLine
                visible: wizardController.walletRestoreMode === 'keys'
                Layout.fillWidth: true
                placeholderFontSize: 16 * scaleRatio
                placeholderText: qsTr("Account address (public)") + translationManager.emptyString

                onTextUpdated: {
                    wizardRestoreWallet1.verifyFromKeys();
                }
            }

            MoneroComponents.LineEdit {
                id: viewKeyLine
                visible: wizardController.walletRestoreMode === 'keys'
                Layout.fillWidth: true
                placeholderFontSize: 16 * scaleRatio
                placeholderText: qsTr("View key (private)") + translationManager.emptyString

                onTextUpdated: {
                    wizardRestoreWallet1.verifyFromKeys();
                }
            }

            MoneroComponents.LineEdit {
                id: spendKeyLine
                visible: wizardController.walletRestoreMode === 'keys'
                Layout.fillWidth: true
                placeholderFontSize: 16 * scaleRatio
                placeholderText: qsTr("Spend key (private)") + translationManager.emptyString

                onTextUpdated: {
                    wizardRestoreWallet1.verifyFromKeys();
                }
            }

            GridLayout{
                MoneroComponents.LineEdit {
                    id: restoreHeight
                    Layout.fillWidth: true
                    labelText: qsTr("Restore height") + translationManager.emptyString
                    labelFontSize: 14 * scaleRatio
                    placeholderFontSize: 16 * scaleRatio
                    placeholderText: qsTr("Restore height") + translationManager.emptyString
                    validator: RegExpValidator { regExp: /(\d+)?$/ }
                    text: "0"
                }

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    Layout.fillWidth: true
                }
            }

            WizardNav {
                id: nav
                progressSteps: 4
                progress: 1
                btnNext.enabled: wizardRestoreWallet1.verify();
                btnPrev.text: qsTr("Back to menu") + translationManager.emptyString
                onPrevClicked: {
                    wizardStateView.state = "wizardHome";
                }
                onNextClicked: {
                    wizardController.walletOptionsName = wizardWalletInput.walletName.text;
                    wizardController.walletOptionsLocation = wizardWalletInput.walletLocation.text;
                    wizardController.walletOptionsSeed = seedInput.text;
                    if(restoreHeight.text)
                        wizardController.walletOptionsRestoreHeight = parseInt(restoreHeight.text);

                    wizardStateView.state = "wizardRestoreWallet2";
                }
            }
        }
    }

    function onPageCompleted(previousView){
        if(previousView.viewName == "wizardHome"){
            // cleanup
            seedInput.text = "";
            addressLine.text = "";
            spendKeyLine.text = "";
            restoreHeight.text = "";
        }
    }
}
