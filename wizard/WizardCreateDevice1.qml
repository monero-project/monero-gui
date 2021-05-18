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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import moneroComponents.Wallet 1.0
import "../js/Wizard.js" as Wizard
import "../js/Utils.js" as Utils
import "../components"
import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateDevice1

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardCreateDevice1"

    property var deviceName: deviceNameModel.get(deviceNameDropdown.currentIndex).column2

    ListModel {
        id: deviceNameModel
        ListElement { column1: qsTr("Choose your hardware device"); column2: "";}
        ListElement { column1: "Ledger Nano S/X"; column2: "Ledger";}
        ListElement { column1: "Trezor Model T"; column2: "Trezor";}
    }

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
                subtitle: qsTr("Using a hardware device.") + translationManager.emptyString
            }

            WizardWalletInput{
                id: walletInput
            }

            ColumnLayout {
                spacing: 0
                Layout.topMargin: 10
                Layout.fillWidth: true

                MoneroComponents.RadioButton {
                    id: newDeviceWallet
                    text: qsTr("Create a new wallet from device.") + translationManager.emptyString
                    fontSize: 16
                    checked: true
                    onClicked: {
                        checked = true;
                        restoreDeviceWallet.checked = false;
                        wizardController.walletOptionsDeviceIsRestore = false;
                    }
                }

                MoneroComponents.RadioButton {
                    id: restoreDeviceWallet
                    Layout.topMargin: 10
                    text: qsTr("Restore a wallet from device. Use this if you used your hardware wallet before.") + translationManager.emptyString
                    fontSize: 16
                    checked: false
                    onClicked: {
                        checked = true;
                        newDeviceWallet.checked = false;
                        wizardController.walletOptionsDeviceIsRestore = true;
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 20

                MoneroComponents.LineEdit {
                    id: restoreHeight
                    visible: !newDeviceWallet.checked
                    Layout.fillWidth: true
                    labelText: qsTr("Wallet creation date as `YYYY-MM-DD` or restore height") + translationManager.emptyString
                    labelFontSize: 14
                    placeholderFontSize: 16
                    placeholderText: qsTr("Restore height") + translationManager.emptyString
                    validator: RegExpValidator {
                        regExp: /^(\d+|\d{4}-\d{2}-\d{2})$/
                    }
                    text: "0"
                }

                MoneroComponents.StandardDropdown {
                    id: deviceNameDropdown
                    dataModel: deviceNameModel
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    z: 3
                }

                CheckBox2 {
                    id: showAdvancedCheckbox
                    checked: false
                    text: qsTr("Advanced options") + translationManager.emptyString
                }

                MoneroComponents.LineEdit {
                    id: lookahead
                    Layout.fillWidth: true
                    visible: showAdvancedCheckbox.checked
                    labelText: qsTr("Subaddress lookahead (optional)") + translationManager.emptyString
                    labelFontSize: 14
                    placeholderText: "<major>:<minor>"
                    placeholderFontSize: 16
                    validator: RegExpValidator { regExp: /(\d+):(\d+)?$/ }
                }
            }

            Text {
                id: errorMsg
                text: qsTr("Error writing wallet from hardware device. Check application logs.") + translationManager.emptyString;
                visible: errorMsg.text !== ""
                Layout.fillWidth: true
                font.family: MoneroComponents.Style.fontRegular.name
                color: MoneroComponents.Style.errorColor
                font.pixelSize: 16

                wrapMode: Text.WordWrap
                leftPadding: 0
                topPadding: 0
                bottomPadding: 0
            }

            WizardNav {
                progressSteps: appWindow.walletMode <= 1 ? 3 : 4
                progress: 0
                btnNext.enabled: walletInput.verify() && wizardCreateDevice1.deviceName;
                btnPrev.text: qsTr("Back to menu") + translationManager.emptyString
                btnNext.text: qsTr("Create wallet") + translationManager.emptyString
                onPrevClicked: {
                    wizardStateView.state = "wizardHome";
                }
                onNextClicked: {
                    wizardController.walletOptionsName = walletInput.walletName.text;
                    wizardController.walletOptionsLocation = walletInput.walletLocation.text;
                    wizardController.walletOptionsDeviceName = wizardCreateDevice1.deviceName;
                    if(lookahead.text)
                        wizardController.walletOptionsSubaddressLookahead = lookahead.text;
                    var _restoreHeight = 0;
                    if(restoreHeight.text){
                        // Parse date string or restore height as integer
                        if(restoreHeight.text.indexOf('-') === 4 && restoreHeight.text.length === 10){
                            _restoreHeight = Wizard.getApproximateBlockchainHeight(restoreHeight.text, Utils.netTypeToString());
                        } else {
                            _restoreHeight = parseInt(restoreHeight.text)
                        }
                        wizardController.walletOptionsRestoreHeight = _restoreHeight;
                    }

                    wizardController.walletCreatedFromDevice.connect(onCreateWalletFromDeviceCompleted);
                    wizardController.createWalletFromDevice();
                }
            }
        }
    }

    Component.onCompleted: {
        errorMsg.text = "";
    }

    function onPageCompleted(previousView){
        if(previousView.viewName == "wizardHome"){
            walletInput.reset();
        }
    }

    function onCreateWalletFromDeviceCompleted(written){
        hideProcessingSplash();
        if(written){
            wizardStateView.state = "wizardCreateWallet2";
        } else {
            errorMsg.text = qsTr("Error writing wallet from hardware device. Check application logs.") + translationManager.emptyString;
        }
        wizardController.walletCreatedFromDevice.disconnect(onCreateWalletFromDeviceCompleted);
    }
}
