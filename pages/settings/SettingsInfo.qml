// Copyright (c) 2014-2018, The Monero Project
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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import "../../js/Wizard.js" as Wizard
import "../../js/Utils.js" as Utils
import "../../version.js" as Version
import "../../components" as MoneroComponents


Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias infoHeight: infoLayout.height
    property string walletModeString: {
        if(appWindow.walletMode === 0){
          return qsTr("Simple mode") + translationManager.emptyString;
        } else if(appWindow.walletMode === 1){
          return qsTr("Simple mode") + " (bootstrap)" + translationManager.emptyString;
        } else if(appWindow.walletMode === 2){
          return "%1 (%2)".arg(qsTr("Advanced mode")).arg(persistentSettings.useRemoteNode ? qsTr("Remote node") : qsTr("Local node")) + translationManager.emptyString;
        }
    }

    ColumnLayout {
        id: infoLayout
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 30

        GridLayout {
            columns: 2
            columnSpacing: 0

            MoneroComponents.TextBlock {
                font.pixelSize: 14
                text: qsTr("GUI version: ") + translationManager.emptyString
            }

            MoneroComponents.TextBlock {
                font.pixelSize: 14
                color: MoneroComponents.Style.dimmedFontColor
                text: Version.GUI_VERSION + " (Qt " + qtRuntimeVersion + ")" + translationManager.emptyString
            }

            Rectangle {
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            MoneroComponents.TextBlock {
                id: guiMoneroVersion
                font.pixelSize: 14
                text: qsTr("Embedded Monero version: ") + translationManager.emptyString
            }

            MoneroComponents.TextBlock {
                font.pixelSize: 14
                color: MoneroComponents.Style.dimmedFontColor
                text: moneroVersion
            }

            Rectangle {
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            MoneroComponents.TextBlock {
                Layout.fillWidth: true
                font.pixelSize: 14
                text: qsTr("Wallet log path: ") + translationManager.emptyString
            }

            MoneroComponents.TextBlock {
                Layout.fillWidth: true
                color: MoneroComponents.Style.dimmedFontColor
                font.pixelSize: 14
                text: "\
                    <style type='text/css'>\
                        a {cursor:pointer;text-decoration: none; color: #FF6C3C}\
                    </style>\
                    <a href='#'>%1</a>".arg(logger.logFilePath)
                textFormat: Text.RichText
                onLinkActivated: oshelper.openContainingFolder(logger.logFilePath)

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }

            Rectangle {
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            MoneroComponents.TextBlock {
                Layout.fillWidth: true
                font.pixelSize: 14
                text: qsTr("Wallet mode: ") + translationManager.emptyString
            }

            MoneroComponents.TextBlock {
                Layout.fillWidth: true
                color: MoneroComponents.Style.dimmedFontColor
                font.pixelSize: 14
                text: walletModeString
            }

            Rectangle {
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            MoneroComponents.TextBlock {
                Layout.fillWidth: true
                font.pixelSize: 14
                text: qsTr("Graphics mode: ") + translationManager.emptyString
            }

            MoneroComponents.TextBlock {
                Layout.fillWidth: true
                color: MoneroComponents.Style.dimmedFontColor
                font.pixelSize: 14
                text: isOpenGL ? "OpenGL" : "Low graphics mode"
            }

            Rectangle {
                visible: isTails
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                visible: isTails
                height: 1
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                Layout.fillWidth: true
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            MoneroComponents.TextBlock {
                visible: isTails
                Layout.fillWidth: true
                font.pixelSize: 14
                text: qsTr("Tails: ") + translationManager.emptyString
            }

            MoneroComponents.TextBlock {
                visible: isTails
                Layout.fillWidth: true
                color: MoneroComponents.Style.dimmedFontColor
                font.pixelSize: 14
                text: tailsUsePersistence ? qsTr("persistent") + translationManager.emptyString : qsTr("persistence disabled") + translationManager.emptyString;
            }
        }

        RowLayout {
            spacing: 20;

            MoneroComponents.StandardButton {
                small: true
                text: qsTr("Copy to clipboard") + translationManager.emptyString
                onClicked: {
                    var data = "";
                    data += "GUI version: " + Version.GUI_VERSION + " (Qt " + qtRuntimeVersion + ")";
                    data += "\nEmbedded Monero version: " + moneroVersion;
                    data += "\nWallet path: " + walletLocation.walletPath;

                    data += "\nWallet restore height: ";
                    if(currentWallet)
                        data += currentWallet.walletCreationHeight;

                    data += "\nWallet log path: " + logger.logFilePath;
                    data += "\nWallet mode: " + walletModeString;
                    data += "\nGraphics mode: " + isOpenGL ? "OpenGL" : "Low graphics mode";
                    if (isTails)
                        data += "\nTails: " + tailsUsePersistence ? "persistent" : "persistence disabled";

                    console.log("Copied to clipboard");
                    clipboard.setText(data);
                    appWindow.showStatusMessage(qsTr("Copied to clipboard"), 3);
                }
            }

            MoneroComponents.StandardButton {
                small: true
                text: qsTr("Donate to Monero") + translationManager.emptyString
                onClicked: {
                    middlePanel.sendTo("888tNkZrPN6JsEgekjMnABU4TBzc2Dt29EPAvkRxbANsAnjyPbb3iQ1YBRk1UXcdRsiKc9dhwMVgN5S9cQUiyoogDavup3H", "", "Donation to Monero Core Team");
                }
            }
        }
    }
}
