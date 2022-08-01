// Copyright (c) 2021, The Monero Project
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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../js/Wizard.js" as Wizard
import "../js/Utils.js" as Utils
import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateMultisig1
    
    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardCreateMultisig1"

    ColumnLayout {
        id: pageRoot
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
            spacing: 20

            WizardHeader {
                title: qsTr("Create a new wallet") + translationManager.emptyString
                subtitle: qsTr("Creates a new wallet on this computer.") + translationManager.emptyString
            }

            WizardWalletInput{
                id: walletInput
            }

            MoneroComponents.LineEdit {
                id: passwordInput
                Layout.fillWidth: true
                KeyNavigation.tab: passwordInputConfirm
                labelFontSize: 14
                password: true
                labelText: qsTr("Password") + translationManager.emptyString
                text: walletOptionsPassword
            }

            MoneroComponents.LineEdit {
                id: passwordInputConfirm
                Layout.fillWidth: true
                Layout.topMargin: 8
                KeyNavigation.tab: passwordInputConfirm
                labelFontSize: 14
                passwordLinked: passwordInput

                labelText: qsTr("Password (confirm)") + translationManager.emptyString
                text: walletOptionsPassword
            }

            MoneroComponents.WarningBox {
                text: "<b>%1</b> (%2).".arg(qsTr("Enter a strong password")).arg(qsTr("Beware this password cannot be recovered")) + translationManager.emptyString
            }

            MoneroComponents.LineEdit {
                    id: thresholdText
                    Layout.maximumWidth: 180

                    labelText: qsTr("Threshold (max signers = 16):") + translationManager.emptyString
                    labelFontSize: 14
                    fontSize: 16
                    placeholderFontSize: 16
                    placeholderText: "2"
                    validator: IntValidator { bottom: 2 }
                    text: persistentSettings.multisigThreshold ? persistentSettings.multisigThreshold : "2"
                    onTextChanged: {
                        persistentSettings.multisigThreshold = parseInt(thresholdText.text) >= 2 && parseInt(thresholdText.text) <= 16 ? parseInt(thresholdText.text) : 2;
                    }
                }

            WizardNav {
                progressSteps: 4
                progress: 0
                btnNext.enabled: walletInput.verify();
                btnPrev.text: qsTr("Back to menu") + translationManager.emptyString
                onPrevClicked: {
                    wizardStateView.state = "wizardHome";
                }
                onNextClicked: {
                    wizardController.walletOptionsName = walletInput.walletName.text;
                    wizardController.walletOptionsLocation = walletInput.walletLocation.text;
                    if (passwordInput.text === passwordInputConfirm.text)
                      wizardController.walletOptionsPassword = passwordInputConfirm.text;
                    // TODO: else handle mismatch
                    wizardStateView.state = "wizardCreateMultisig2";
                }
            }
        }
    }

    function onPageCompleted(previousView){
        if(previousView.viewName == "wizardHome"){
            walletInput.reset();
        }
    }
}
