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
import QtQuick.Controls 2.2

import "../components/effects/" as MoneroEffects
import FontAwesome 1.0

import "../js/Wizard.js" as Wizard
import "../js/Utils.js" as Utils
import "../components" as MoneroComponents
import "networks" as MoneroWizardNetworks

Rectangle {
    id: wizardAnonymityNetworks
    
    color: "transparent"
    property string viewName: "wizardAnonymityNetworks"
    property int anonymityOption: 1

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
            spacing: 20

            WizardHeader {
                title: qsTr("Monero can protect your internet connection") + translationManager.emptyString
                subtitle: qsTr("Connect to the Monero network using anonymization software for enhanced privacy.") + translationManager.emptyString
            }

            MoneroComponents.WarningBox {
                Layout.bottomMargin: 6
                text: qsTr("Some countries and ISPs may prohibit or censor use of these networks. Please check your local laws and internet policies before using them.") + translationManager.emptyString
            }

            ColumnLayout {
                spacing: 10

                Layout.fillWidth: true

                RowLayout {
                    id: anonChoiceRow
                    spacing: 0
                    Layout.topMargin: 20
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter

                    ColumnLayout {
                        spacing: 20
                        Layout.fillWidth: true

                        MoneroComponents.TextPlain {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 32
                            themeTransitionBlackColor: MoneroComponents.Style._b_lightGreyFontColor
                            themeTransitionWhiteColor: MoneroComponents.Style._w_lightGreyFontColor
                            font.pixelSize: 24
                            font.bold: true
                            font.family: MoneroComponents.Style.fontBold.name                            
                            color: MoneroComponents.Style.lightGreyFontColor
                            text: "Clearnet"
                        }

                        MoneroComponents.TextPlain {
                            text: qsTr("Do not use an anonymity network.") + translationManager.emptyString
                            themeTransitionBlackColor: MoneroComponents.Style._b_lightGreyFontColor
                            themeTransitionWhiteColor: MoneroComponents.Style._w_lightGreyFontColor
                            wrapMode: Text.WordWrap

                            font.family: MoneroComponents.Style.fontRegular.name
                            font.pixelSize: 16
                            color: MoneroComponents.Style.lightGreyFontColor
                        }

                        MoneroComponents.RadioButton {
                            id: clearNetworkRadioButton
                            text: qsTr("Direct connection") + translationManager.emptyString
                            fontSize: 16
                            checked: wizardAnonymityNetworks.anonymityOption === 0
                            onClicked: {
                                wizardAnonymityNetworks.directConnection();
                                checked = true;
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 51

                        Rectangle {
                            width: 1
                            height: parent.height
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: MoneroComponents.Style.appWindowBorderColor
                        }
                    }

                    ColumnLayout {
                        spacing: 20
                        Layout.fillWidth: true

                        Image {
                            Layout.preferredWidth: 120
                            Layout.preferredHeight: 32
                            source: "qrc:///images/i2p-zero-ti.png"
                        }

                        MoneroComponents.TextPlain {
                            text: qsTr("A small footprint I2P Router.") + translationManager.emptyString
                            themeTransitionBlackColor: MoneroComponents.Style._b_lightGreyFontColor
                            themeTransitionWhiteColor: MoneroComponents.Style._w_lightGreyFontColor
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true

                            font.family: MoneroComponents.Style.fontRegular.name
                            font.pixelSize: 16
                            color: MoneroComponents.Style.lightGreyFontColor
                        }

                        MoneroComponents.RadioButton {
                            id: i2pNetworkRadioButton
                            opacity: isTails ? 0.5 : 1.0
                            text: {
                                if(isTails) return "Not available on Tails.";
                                if(I2PZero.available){
                                    return qsTr("Use i2p-zero (bundled)") + translationManager.emptyString;
                                } else {
                                    return qsTr("Not available.") + translationManager.emptyString;
                                }
                            }
                            fontSize: 16
                            checked: wizardAnonymityNetworks.anonymityOption === 1
                            onClicked: {
                                if(isTails) return;
                                wizardAnonymityNetworks.i2pSelected();
                                checked = true;
                            }
                        }
                        
                    }
                }

                WizardNav {
                    Layout.preferredHeight: 60
                    Layout.fillWidth: true
                    progressEnabled: false
                    btnNext.visible: false
                    btnPrev.text: qsTr("Back to menu") + translationManager.emptyString
                    onPrevClicked: {
                        wizardStateView.state = "wizardHome";
                    }
                    onNextClicked: {
                        if(wizardAnonymityNetworks.anonymityOption == 1){
                            if(I2PZero.state <= 1){
                                I2PZero.start();
                                return;
                            }
                        }
                        wizardController.walletOptionsName = walletInput.walletName.text;
                        wizardController.walletOptionsLocation = walletInput.walletLocation.text;
                        wizardStateView.state = "wizardCreateWallet2";
                    }
                }
            }
        }
    }

    function onPageCompleted(previousView){
        if(previousView.viewName == "wizardHome"){

        }
    }

    function onI2PStateChanged(){
        console.log("qml i2p state changed: " + I2PZero.state);
        if(I2PZero.state == 0){
            i2pStatusText.text = qsTr("Could not start I2P-Zero.") + translationManager.emptyString;
            if(I2PZero.errorString)
                i2pStatusDetailedText.text = I2PZero.errorString;
        }
    }

    function i2pSelected() {
        clearNetworkRadioButton.checked = false;
        wizardAnonymityNetworks.anonymityOption = 1;
        persistentSettings.isI2P = true;
        return true;
    }

    function i2pStatusConsoleChanged(){
        console.log(I2PZero.statusConsole);
    }

    function directConnection(){
        if(I2PZero.state >= 2)
            I2PZero.stop();

        i2pNetworkRadioButton.checked = false;
        wizardAnonymityNetworks.anonymityOption = 0;
        persistentSettings.isI2P = false;
        return true;
    }

    Component.onCompleted: {
        I2PZero.stateChanged.connect(onI2PStateChanged);
        I2PZero.statusConsoleChanged.connect(i2pStatusConsoleChanged);

        if(isTails) wizardAnonymityNetworks.directConnection();
        else wizardAnonymityNetworks.i2pSelected();
    }
}
