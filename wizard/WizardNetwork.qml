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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import FontAwesome 1.0
import QtQuick.Dialogs 1.2

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

Rectangle {
    id: wizardNetwork

    color: "transparent"
    property alias pageHeight: pageRoot.height
    property string viewName: "wizardNetwork"
    property string previousView: ""
    property string originalProxyType: ""

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.alignment: Qt.AlignHCenter
            spacing: 0

            WizardHeader {
                title: qsTr("Protect your internet connection") + translationManager.emptyString
                subtitle: ""
            }

            ColumnLayout {
                spacing: 20

                Layout.topMargin: 10
                Layout.fillWidth: true

                MoneroComponents.TextPlain {
                    text: qsTr("Monero can optionally connect to the network using anonymizing software to better protect your identity.") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.topMargin: 14
                    Layout.fillWidth: true
                    textFormat: Text.RichText

                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    color: MoneroComponents.Style.lightGreyFontColor
                }

                MoneroComponents.TextPlain {
                    text: qsTr("The usage of these networks is still considered experimental, there are a few pessimistic cases where privacy is leaked. The design is intended to maximize privacy of the source of a transaction by broadcasting it over an anonymity network, while relying on IPv4 for the remainder of messages to make surrounding node attacks (via sybil) more difficult.") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.topMargin: 8
                    Layout.fillWidth: true

                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    color: MoneroComponents.Style.lightGreyFontColor
                }

                MoneroComponents.WarningBox {
                    Layout.topMargin: 14
                    Layout.bottomMargin: 6
                    text: qsTr("Some countries and ISPs may prohibit or censor use of these networks. <b>Please check your local laws and internet policies before using them.</b>") + translationManager.emptyString
                }

                MoneroComponents.WarningBox {
                    Layout.topMargin: 14
                    Layout.bottomMargin: 6
                    visible: persistentSettings.proxyType === "I2P" && appWindow.walletMode === 1
                    text: qsTr("When choosing I2P, transactions will be pushed over anonymity network and only I2P bootstrap nodes will be picked, but local node blockchain synchronization will still happen via clearnet.</b>") + translationManager.emptyString
                }

                ListModel {
                    id: proxyType
                    ListElement { column1: "None"; name: "custom"; }
                    ListElement { column1: "TOR"; name: "TOR"; }
                    ListElement { column1: "I2P"; name: "I2P"; }
                }

                MoneroComponents.StandardDropdown {
                    id: proxyTypeDropdown
                    dataModel: proxyType
                    itemTopMargin: 1
                    currentIndex: persistentSettings.proxyType === "TOR" ? 1 : persistentSettings.proxyType === "I2P" ? 2 : 0
                    onChanged: {
                        persistentSettings.proxyType = proxyTypeDropdown.currentIndex === 1 ? "TOR" : proxyTypeDropdown.currentIndex === 2 ? "I2P" : "custom" ;
                        walletManager.proxyAddress = persistentSettings.getWalletProxyAddress();
                    }
                    Layout.fillWidth: true
                    z: parent.z + 1
                }

                WizardNav {
                    Layout.topMargin: 4
                    progressSteps: 0

                    onPrevClicked: {
                        if (wizardNetwork.previousView.includes('wizardModeSelection')) {
                            wizardController.wizardState = 'wizardModeSelection';
                        }
                        else wizardController.wizardState = wizardNetwork.previousView;
                    }

                    onNextClicked: {
                        const tor = persistentSettings.proxyType === "TOR";
                        const i2p = persistentSettings.proxyType === "I2P";
                        if (tor && !torManager.isInstalled()) {
                            confirmationDialog.title = qsTr("Tor installation") + translationManager.emptyString;
                            confirmationDialog.text  = qsTr("Tor will be installed at %1. Proceed?").arg(applicationDirectory) + translationManager.emptyString;
                            confirmationDialog.icon = StandardIcon.Question;
                            confirmationDialog.cancelText = qsTr("No") + translationManager.emptyString;
                            confirmationDialog.okText = qsTr("Yes") + translationManager.emptyString;
                            confirmationDialog.onAcceptedCallback = function() {
                                torManager.download();
                                torStartStopInProgress = 3;
                                appWindow.showProcessingSplash(qsTr("Downloading Tor..."));
                            }
                            confirmationDialog.onRejectedCallback = function() {

                            }
                            confirmationDialog.open();
                        } else {
                            if ((appWindow.torRunning && !tor) || (appWindow.i2pRunning && !i2p)) {
                                const callback = function(result) {
                                    wizardController.wizardState = 'wizardHome';
                                };
                                appWindow.stopDaemon(callback, true);
                            } else {
                                wizardController.wizardState = 'wizardHome';
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: regionModel
        ListElement {column1: "Unspecified"; region: ""}
        ListElement {column1: "Africa"; region: "af"}
        ListElement {column1: "Asia"; region: "as"}
        ListElement {column1: "Central America"; region: "ca";}
        ListElement {column1: "North America"; region: "na";}
        ListElement {column1: "Europe"; region: "eu";}
        ListElement {column1: "Oceania"; region: "oc";}
        ListElement {column1: "South America"; region: "sa";}
    }

    function onPageCompleted(previousView){
        wizardNetwork.previousView = previousView.viewName ? previousView.viewName : 'wizardModeSelection';
    }

    function torDownloadFailed(errorCode) {
        torStartStopInProgress = 0;
        persistentSettings.proxyType = "custom"
        hideProcessingSplash();
        errorPopup.title = qsTr("Tor Installation Failed") + translationManager.emptyString;
        switch (errorCode) {
            case TorManager.HashVerificationFailed:
                errorPopup.text = qsTr("Hash verification failed.") + translationManager.emptyString;
                break;
            case TorManager.BinaryNotAvailable:
                errorPopup.text = qsTr("Tor download is not available.") + translationManager.emptyString;
                break;
            case TorManager.ConnectionIssue:
                errorPopup.text = qsTr("Tor download failed due to a connection issue.") + translationManager.emptyString;
                break;
            case TorManager.InstallationFailed:
                errorPopup.text = qsTr("Tor installation failed.") + (isWindows ? (" " + qsTr("Try starting the program with administrator privileges.")) : "")
                break;
            default:
                errorPopup.text = qsTr("Unknown error.") + translationManager.emptyString;
        }
        errorPopup.icon = StandardIcon.Critical
        errorPopup.open()
    }

    function torDownloadSucceeded() {
        torStartStopInProgress = 0;
        torVersion = torManager.getVersion();
        hideProcessingSplash();
        informationPopup.title  = qsTr("Tor Installation Succeeded") + translationManager.emptyString;
        informationPopup.text = qsTr("Tor has successfully installed.");
        informationPopup.icon = StandardIcon.Critical
        informationPopup.open()
    }

    Component.onCompleted: {
        torManager.torDownloadFailure.connect(torDownloadFailed);
        torManager.torDownloadSuccess.connect(torDownloadSucceeded);
    }
}
