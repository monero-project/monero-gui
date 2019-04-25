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

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

Rectangle {
    id: wizardModeSelection1
    color: "transparent"

    property string viewName: "wizardModeSelection1"

    ColumnLayout {
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
                title: qsTr("Mode selection.") + translationManager.emptyString
                subtitle: qsTr("Please select the statement that best matches you.") + translationManager.emptyString
            }

            WizardMenuItem {
                opacity: appWindow.persistentSettings.nettype == 0 ? 1.0 : 0.5
                Layout.topMargin: 20
                headerText: qsTr("Simple mode") + translationManager.emptyString
                bodyText: {
                    if(appWindow.persistentSettings.nettype == 0){
                        return qsTr("Easy access to sending, receiving and basic functionality.") + translationManager.emptyString;
                    } else {
                        return "Available on mainnet.";
                    }
                }

                imageIcon: "qrc:///images/remote-node.png"

                onMenuClicked: {
                    if(appWindow.persistentSettings.nettype == 0){
                        appWindow.changeWalletMode(0);
                        wizardController.wizardState = 'wizardModeRemoteNodeWarning';
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 5
                Layout.bottomMargin: 10
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                opacity: appWindow.persistentSettings.nettype == 0 ? 1.0 : 0.5
                headerText: qsTr("Simple mode") + " (bootstrap)" + translationManager.emptyString
                bodyText: {
                    if(appWindow.persistentSettings.nettype == 0){
                        return qsTr("Easy access to sending, receiving and basic functionality. The blockchain is downloaded to your computer.") + translationManager.emptyString;
                    } else {
                        return "Available on mainnet.";
                    }
                }
                imageIcon: "qrc:///images/local-node.png"

                onMenuClicked: {
                    if(appWindow.persistentSettings.nettype == 0){
                        appWindow.changeWalletMode(1);
                        wizardController.wizardState = 'wizardModeBootstrap';
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: 1
                Layout.topMargin: 5
                Layout.bottomMargin: 10
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            WizardMenuItem {
                headerText: qsTr("Advanced mode") + translationManager.emptyString
                bodyText: qsTr("Includes extra features like mining and message verification. The blockchain is downloaded to your computer.") + translationManager.emptyString
                imageIcon: "qrc:///images/local-node-full.png"

                onMenuClicked: {
                    appWindow.changeWalletMode(2);
                    wizardController.wizardState = 'wizardHome';
                }
            }

            WizardNav {
                Layout.topMargin: 5
                btnPrevText: qsTr("Change language") + translationManager.emptyString
                btnNext.visible: false
                progressSteps: 0

                onPrevClicked: {
                    wizardController.wizardState = 'wizardLanguage';
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 200;
            easing.type: Easing.InCubic;
        }
    }
}
