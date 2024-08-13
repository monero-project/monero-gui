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
    property var ledgerType: deviceName == "Ledger" ? deviceNameModel.get(deviceNameDropdown.currentIndex).column1 : null
    property var trezorType: deviceName == "Trezor" ? deviceNameModel.get(deviceNameDropdown.currentIndex).column1 : null
    property var hardwareWalletType: wizardCreateDevice1.deviceName;

    ListModel {
        id: deviceNameModel
        ListElement { column1: qsTr("Choose your hardware wallet"); column2: "";}
        ListElement { column1: "Ledger Nano S"; column2: "Ledger";}
        ListElement { column1: "Ledger Nano S Plus"; column2: "Ledger";}
        ListElement { column1: "Ledger Nano X"; column2: "Ledger";}
        ListElement { column1: "Ledger Stax"; column2: "Ledger";}
        ListElement { column1: "Trezor Model T"; column2: "Trezor";}
        ListElement { column1: "Trezor Safe 3"; column2: "Trezor";}
        ListElement { column1: "Trezor Safe 5"; column2: "Trezor";}
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
                title: {
                    var nettype = persistentSettings.nettype;
                    return qsTr("Create a new wallet") + (nettype === 2 ? " (" + qsTr("stagenet") + ")"
                                                                        : nettype === 1 ? " (" + qsTr("testnet") + ")"
                                                                                        : "") + translationManager.emptyString
                }
                subtitle: qsTr("Using a hardware device.") + translationManager.emptyString
            }

            WizardWalletInput{
                id: walletInput
            }

            RowLayout {
                id: mainRow
                spacing: 0
                Layout.topMargin: -10
                Layout.fillWidth: true

                ColumnLayout {
                    id: leftColumn
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    MoneroComponents.TextPlain {
                         font.family: MoneroComponents.Style.fontRegular.name
                         font.pixelSize: 14
                         color: MoneroComponents.Style.defaultFontColor
                         wrapMode: Text.Wrap
                         Layout.fillWidth: true
                         text: qsTr("Hardware wallet model")
                     }

                     MoneroComponents.StandardDropdown {
                         id: deviceNameDropdown
                         dataModel: deviceNameModel
                         Layout.preferredWidth: 450
                         Layout.topMargin: 6
                         z: 3
                     }

                     MoneroComponents.RadioButton {
                         id: newDeviceWallet
                         Layout.topMargin: 20
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
                     id: rightColumn
                     Layout.alignment: Qt.AlignTop
                     Layout.preferredWidth: 305
                     Layout.minimumWidth: 120
                     Layout.preferredHeight: 165
                     Layout.maximumHeight: 165
                     Layout.leftMargin: 10
                     Layout.rightMargin: 10

                     Rectangle {
                         color: "transparent"
                         Layout.fillWidth: true
                         Layout.fillHeight: true
                         Layout.topMargin: 0

                         Image {
                             Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                             source: {
                                if (hardwareWalletType == "Trezor") {
                                    if (trezorType == "Trezor Model T") {
                                        return "qrc:///images/trezorT.png";
                                    } else if (trezorType == "Trezor Safe 3") {
                                        return "qrc:///images/trezor3.png";
                                    } else if (trezorType == "Trezor Safe 5") {
                                        return "qrc:///images/trezor5.png";
                                    }
                                } else if (hardwareWalletType == "Ledger") {
                                    if (ledgerType == "Ledger Nano S") {
                                        return "qrc:///images/ledgerNanoS.png";
                                    } else if (ledgerType == "Ledger Nano S Plus") {
                                        return "qrc:///images/ledgerNanoSPlus.png";
                                    } else if (ledgerType == "Ledger Nano X") {
                                        return "qrc:///images/ledgerNanoX.png";
                                    } else if (ledgerType == "Ledger Stax") {
                                        return "qrc:///images/ledgerStax.png";
                                    }
                                }
                                return "";
                             }
                             z: parent.z + 1
                             width: parent.width
                             height: 165
                             fillMode: Image.PreserveAspectFit
                             mipmap: true
                         }
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
                    text: "1"
                }

                CheckBox2 {
                    id: showAdvancedCheckbox
                    visible: appWindow.walletMode >= 2
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
                btnNext.text: newDeviceWallet.checked ? qsTr("Create wallet") : qsTr("Restore wallet") + translationManager.emptyString
                onPrevClicked: {
                    wizardStateView.state = "wizardHome";
                }
                onNextClicked: {
                    wizardController.walletOptionsName = walletInput.walletName.text;
                    wizardController.walletOptionsLocation = walletInput.walletLocation.text;
                    wizardController.walletOptionsDeviceName = wizardCreateDevice1.deviceName;
                    if(lookahead.text)
                        wizardController.walletOptionsSubaddressLookahead = lookahead.text;
                    if (restoreHeight.text && wizardController.walletOptionsDeviceIsRestore) {
                        wizardController.walletOptionsRestoreHeight = Utils.parseDateStringOrRestoreHeightAsInteger(restoreHeight.text);
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
            deviceNameDropdown.currentIndex = 0;
            newDeviceWallet.checked = true;
            restoreDeviceWallet.checked = false;
            wizardController.walletOptionsDeviceIsRestore = false;
            restoreHeight.text = "1";
            lookahead.text = "";
            errorMsg.text = "";
        }
    }

    function onCreateWalletFromDeviceCompleted(written){
        hideProcessingSplash();
        if(written){
            wizardStateView.state = "wizardCreateWallet3";
        } else {
            errorMsg.text = qsTr("Error writing wallet from hardware device. Check application logs.") + translationManager.emptyString;
        }
        wizardController.walletCreatedFromDevice.disconnect(onCreateWalletFromDeviceCompleted);
    }
}
