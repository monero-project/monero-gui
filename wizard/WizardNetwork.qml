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

                MoneroComponents.WarningBox{
                    Layout.topMargin: 14
                    Layout.bottomMargin: 6
                    text: qsTr("Some countries and ISPs may prohibit or censor use of these networks. <b>Please check your local laws and internet policies before using them.</b>") + translationManager.emptyString
                }

                MoneroComponents.CheckBox {
                    id: torCheckbox
                    Layout.topMargin: 6
                    checked: persistentSettings.torEnabled
                    enabled: torStartStopInProgress == 0
                    text: qsTr("Enable TOR") + translationManager.emptyString

                    onClicked: {
                        persistentSettings.torEnabled = !persistentSettings.torEnabled;

                        if (persistentSettings.torEnabled && !torManager.isInstalled()) {
                            confirmationDialog.title = qsTr("Tor installation") + translationManager.emptyString;
                            confirmationDialog.text  = qsTr("Tor will be installed at %1. Proceed?").arg(applicationDirectory) + translationManager.emptyString;
                            confirmationDialog.icon = StandardIcon.Question;
                            confirmationDialog.cancelText = qsTr("No") + translationManager.emptyString;
                            confirmationDialog.okText = qsTr("Yes") + translationManager.emptyString;
                            confirmationDialog.onAcceptedCallback = function() {
                                torManager.download();
                                torStartStopInProgress = 3;
                                statusMessageText.text = "Downloading Tor...";
                                statusMessage.visible = true
                            }
                            confirmationDialog.onRejectedCallback = function() {
                                persistentSettings.torEnabled = false;
                                torCheckbox.checked = false;
                            }
                            confirmationDialog.open();
                        }
                    }
                }

                MoneroComponents.CheckBox {
                    id: i2pCheckbox
                    Layout.topMargin: 6
                    checked: persistentSettings.i2pEnabled
                    text: qsTr("Enable I2P") + translationManager.emptyString

                    onClicked: {
                        persistentSettings.i2pEnabled = !persistentSettings.i2pEnabled;
                    }
                }

                WizardNav {
                    Layout.topMargin: 4
                    progressSteps: 0

                    onPrevClicked: {
                        if (previousView.includes("wizardModeSelection")) {
                            wizardController.wizardState = "wizardModeSelection";
                        }
                        else wizardController.wizardState = previousView;
                    }

                    onNextClicked: {
                        wizardController.wizardState = 'wizardHome';
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
        persistentSettings.torEnabled = persistentSettings.torEnabled && torManager.isInstalled();
        i2pCheckbox.checked = persistentSettings.i2pEnabled;
        torCheckbox.checked = persistentSettings.torEnabled;
        wizardNetwork.previousView = previousView.viewName;
    }
}
