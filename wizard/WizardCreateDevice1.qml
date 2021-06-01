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
    property var ledgerType: deviceName == "Ledger" ? deviceNameModel.get(deviceNameDropdown.currentIndex).column1 : null
    property var hardwareWalletType: wizardCreateDevice1.deviceName;
    property string minimumLedgerNanoSFirmware: "v1.6.1"
    property string minimumLedgerNanoXFirmware: "v1.2.4-5"
    property string minimumMoneroAppVersion: "v1.7.6"
    property string minimumTrezorFirmware: "v2.3.5"

    ListModel {
        id: deviceNameModel
        ListElement { column1: qsTr("Choose your hardware wallet"); column2: "";}
        ListElement { column1: "Ledger Nano S"; column2: "Ledger";}
        ListElement { column1: "Ledger Nano X"; column2: "Ledger";}
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
            spacing: 15

            WizardHeader {
                title: qsTr("Create/restore a wallet using a hardware wallet") + translationManager.emptyString
                subtitle: qsTr("Create a new wallet or restore a previous wallet using a hardware wallet device.") + translationManager.emptyString
            }

            WizardWalletInput{
                id: walletInput
                Layout.maximumWidth: appWindow.walletMode >= 2 ? mainRow.width : deviceNameDropdown.width/2
            }

            RowLayout {
                id: mainRow
                spacing: 0
                Layout.topMargin: 10
                Layout.fillWidth: true

                ColumnLayout {
                    id: leftColumn
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    MoneroComponents.TextPlain {
                        font.family: Style.fontLight.name
                        font.pixelSize: 14
                        color: Style.defaultFontColor
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

                    MoneroComponents.TextPlain {
                        font.family: Style.fontLight.name
                        font.pixelSize: 13
                        color: MoneroComponents.Style.dimmedFontColor
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        themeTransition: false
                        text: {
                            if (hardwareWalletType) {
                              return qsTr("Required firmware") + ": " +
                              (hardwareWalletType == "Trezor" ? qsTr("%1 or higher").arg(minimumTrezorFirmware) + " " + qsTr("(available on Trezor Wallet or Trezor Suite)")
                                                              : qsTr("%1 or higher").arg(ledgerType == "Ledger Nano S" ? minimumLedgerNanoSFirmware : minimumLedgerNanoXFirmware) + " " + qsTr("(available on Ledger Live)")) + translationManager.emptyString;
                            } else {
                              return "";
                            }
                        }
                    }

                    MoneroComponents.TextPlain {
                        font.family: Style.fontLight.name
                        font.pixelSize: 13
                        color: MoneroComponents.Style.dimmedFontColor
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        themeTransition: false
                        text: {
                            if (hardwareWalletType == "Ledger") {
                              return  qsTr("Required Monero app: %1").arg(minimumMoneroAppVersion) + " " + qsTr("(available on Ledger Live)") + translationManager.emptyString;
                            } else {
                              return "";
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        MoneroComponents.TextPlain {
                            id: label2
                            font.family: Style.fontLight.name
                            font.pixelSize: 14
                            color: Style.defaultFontColor
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                            text: qsTr("Restore wallet?")
                        }

                        MoneroComponents.CheckBox {
                            id: restoreDeviceWallet
                            text: qsTr("Restore wallet and scan previous transactions") + translationManager.emptyString
                            tooltip: qsTr("Check this box if your hardware wallet already holds some Monero") + translationManager.emptyString
                            tooltipIconVisible: true
                            toggleOnClick: true
                            onClicked: {
                                wizardController.walletOptionsDeviceIsRestore = true;
                            }
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
                        id: imageRectangle
                        color: "transparent"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 0

                        Image {
                            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
                            source: hardwareWalletType == "Trezor" ? "qrc:///images/trezor.png" : hardwareWalletType == "Ledger" ? (ledgerType == "Ledger Nano S" ? "qrc:///images/ledgerNanoS.png" : "qrc:///images/ledgerNanoX.png") : ""
                            z: parent.z + 1
                            width: imageRectangle.width
                            height: 165
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                RowLayout {
                    spacing: 20

                    MoneroComponents.LineEdit {
                        Layout.leftMargin: 34
                        Layout.minimumWidth: 500
                        inputFieldWidth: 200
                        id: restoreHeight
                        opacity: restoreDeviceWallet.checked ? 1 : 0
                        labelText: qsTr("Approximate date (YYYY-MM) or block height of the first transaction") + translationManager.emptyString
                        labelFontSize: 14
                        placeholderFontSize: 15
                        placeholderText: qsTr("YYYY-MM or restore height") + translationManager.emptyString
                        validator: RegExpValidator {
                            regExp: /^(\d+|\d{4}-\d{2}-\d{2})$/
                        }
                        text:  hardwareWalletType == "Trezor" ? "2019-03" : hardwareWalletType == "Ledger" ? (ledgerType == "Ledger Nano S" ? "2018-11" : "2019-05") : "0"
                    }

                    MoneroComponents.LineEdit {
                        id: lookahead
                        Layout.fillWidth: true
                        inputFieldWidth: 150
                        opacity: appWindow.walletMode >= 2 && restoreDeviceWallet.checked ? 1 : 0
                        labelText: qsTr("Subaddress lookahead") + translationManager.emptyString
                        labelFontSize: 14
                        placeholderText: qsTr("<major>:<minor>") + translationManager.emptyString
                        placeholderFontSize: 15
                        validator: RegExpValidator { regExp: /(\d+):(\d+)?$/ }
                        text: "50:200"
                    }
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
                onPrevClicked: wizardStateView.state = "wizardHome"
                onNextClicked: createWallet();
            }
        }
    }

    Component.onCompleted: {
        errorMsg.text = "";
    }

    function createWallet() {
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

    function showhardwareWalletDialog() {
        leftPanel.enabled = false;
        middlePanel.enabled = false;
        titleBar.enabled = false;

        if (firstHardwareWalletConnection) {
            appWindow.hardwareWalletDialog.titleText = hardwareWalletType == "Ledger" ? qsTr("Connect your Ledger, unlock it and open Monero app...") : qsTr("Connect and unlock your Trezor to continue...") + translationManager.emptyString;
            appWindow.hardwareWalletDialog.imgSource = hardwareWalletType == "Ledger" ? (ledgerType == "Ledger Nano S" ? "qrc:///images/ledgerNanoS.png" : "qrc:///images/ledgerNanoX.png") : "qrc:///images/trezorPIN.png";
            appWindow.hardwareWalletDialog.messageInstructions1 = "";
            appWindow.hardwareWalletDialog.messageInstructions2 = "";
            appWindow.hardwareWalletDialog.okButtonText = qsTr("Create wallet") + translationManager.emptyString;
        } else {
            appWindow.hardwareWalletDialog.titleText = qsTr("Can't connect to %1").arg(hardwareWalletType) + translationManager.emptyString;
            appWindow.hardwareWalletDialog.imgSource = "";
            appWindow.hardwareWalletDialog.messageInstructions1 = hardwareWalletType == "Ledger" ? qsTr("Check if your Ledger has the Monero app installed (available in Ledger Live) and is running it.") : qsTr("Check if the USB cable is connected. Push the cable into your Trezor until you hear/feel a click.") + translationManager.emptyString;
            appWindow.hardwareWalletDialog.messageInstructions2 = hardwareWalletType == "Ledger" ? qsTr("Check if your Ledger has the most recent firmware version (available on Manager section of Ledger Live).") : qsTr("Check if your Trezor has firmware v%1 or higher (available on Trezor Wallet or Trezor Suite).").arg(trezorFirmwareVersion) + translationManager.emptyString;
            appWindow.hardwareWalletDialog.okButtonText = qsTr("Try again") + translationManager.emptyString;
        }

        appWindow.hardwareWalletDialog.onAcceptedCallback = function() {
            createWallet();
        }

        appWindow.hardwareWalletDialog.onRejectedCallback = function() {
            firstHardwareWalletConnection = true;
            leftPanel.enabled = true;
            middlePanel.enabled = true;
            titleBar.enabled = true;
            appWindow.hardwareWalletDialog.close();
        }

        appWindow.hardwareWalletDialog.show();
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
            wizardCreateDevice1.showhardwareWalletDialog();
            firstHardwareWalletConnection = false;
        }
        wizardController.walletCreatedFromDevice.disconnect(onCreateWalletFromDeviceCompleted);
    }
}
