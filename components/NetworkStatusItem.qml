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
import QtQuick.Layouts 1.1

import FontAwesome 1.0
import moneroComponents.Wallet 1.0
import "../components" as MoneroComponents

Rectangle {
    id: item
    color: "transparent"
    property var connected: Wallet.ConnectionStatus_Disconnected

    function getConnectionStatusString(status) {
        switch (appWindow.daemonStartStopInProgress)
        {
            case 1:
                return qsTr("Starting the node");
            case 2:
                return qsTr("Stopping the node");
            default:
                break;
        }
        switch (status) {
            case Wallet.ConnectionStatus_Connected:
                if (!appWindow.daemonSynced)
                    return qsTr("Synchronizing");
                if (persistentSettings.useRemoteNode && persistentSettings.allowRemoteNodeMining && appWindow.isMining)
                    return qsTr("Remote node") + " + " + qsTr("Mining");
                if (persistentSettings.useRemoteNode)
                    return qsTr("Remote node");
                return appWindow.isMining ? qsTr("Connected") + " + " + qsTr("Mining"): qsTr("Connected");
            case Wallet.ConnectionStatus_WrongVersion:
                return qsTr("Wrong version");
            case Wallet.ConnectionStatus_Disconnected:
                if (appWindow.walletMode <= 1) {
                    return qsTr("Searching node") + translationManager.emptyString;
                }
                return qsTr("Disconnected");
            case Wallet.ConnectionStatus_Connecting:
                return qsTr("Connecting");
            default:
                return qsTr("Invalid connection status");
        }
    }

    RowLayout {
        Layout.preferredHeight: 40

        Item {
            id: iconItem
            width: 40
            height: 40
            opacity: {
                if(item.connected == Wallet.ConnectionStatus_Connected){
                    return 1
                } else {
                    MoneroComponents.Style.blackTheme ? 0.5 : 0.3
                }
            }

            Image {
                anchors.top: parent.top
                anchors.topMargin: !appWindow.isMining ? 6 : 4
                anchors.right: parent.right
                anchors.rightMargin: !appWindow.isMining ? 11 : 0
                source: {
                    if(appWindow.isMining) {
                       return "qrc:///images/miningxmr.png"
                    } else if(item.connected == Wallet.ConnectionStatus_Connected || !MoneroComponents.Style.blackTheme) {
                        return "qrc:///images/lightning.png"
                    } else {
                        return "qrc:///images/lightning-white.png"
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    visible: appWindow.walletMode >= 2
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(!appWindow.isMining) {
                            middlePanel.settingsView.settingsStateViewState = "Node";
                            appWindow.showPageRequest("Settings");
                        } else {
                            appWindow.showPageRequest("Mining")
                        }
                    }
                }
            }
        }

        Item {
            height: 40
            width: 260

            MoneroComponents.TextPlain {
                id: statusText
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 0
                font.family: MoneroComponents.Style.fontMedium.name
                font.bold: true
                font.pixelSize: 13
                color: MoneroComponents.Style.blackTheme ? MoneroComponents.Style.dimmedFontColor : MoneroComponents.Style.defaultFontColor
                opacity: MoneroComponents.Style.blackTheme ? 0.65 : 0.75
                text: qsTr("Network status") + translationManager.emptyString
                themeTransition: false
            }

            MoneroComponents.TextPlain {
                id: statusTextVal
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 14
                font.family: MoneroComponents.Style.fontMedium.name
                font.pixelSize: 20
                color: MoneroComponents.Style.defaultFontColor
                text: getConnectionStatusString(item.connected) + translationManager.emptyString
                opacity: MoneroComponents.Style.blackTheme ? 1.0 : 0.7
                themeTransition: false

                MouseArea {
                    anchors.fill: parent
                    visible: appWindow.walletMode >= 2
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(!appWindow.isMining) {
                            middlePanel.settingsView.settingsStateViewState = "Node";
                            appWindow.showPageRequest("Settings");
                        } else {
                            appWindow.showPageRequest("Mining")
                        }
                    }
                }
            }

            MoneroComponents.TextPlain {
                anchors.left: statusTextVal.right
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                color: refreshMouseArea.containsMouse ?  MoneroComponents.Style.defaultFontColor : MoneroComponents.Style.dimmedFontColor
                font.family: FontAwesome.fontFamilySolid
                font.pixelSize: 24
                font.styleName: "Solid"
                opacity: 0.85
                text: FontAwesome.random
                themeTransition: false
                tooltip: qsTr("Switch to another public remote node") + translationManager.emptyString;
                visible: (
                    !appWindow.disconnected &&
                    !persistentSettings.useRemoteNode &&
                    (persistentSettings.bootstrapNodeAddress == "auto" || persistentSettings.walletMode < 2)
                )

                MouseArea {
                    id: refreshMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    visible: true
                    onEntered: parent.tooltipPopup.open()
                    onExited: parent.tooltipPopup.close()
                    onClicked: {
                        const callback = function(result) {
                            refreshMouseArea.visible = true;
                            if (result) {
                                appWindow.showStatusMessage(qsTr("Successfully switched to another public node"), 3);
                                appWindow.currentWallet.refreshHeightAsync();
                            } else {
                                appWindow.showStatusMessage(qsTr("Failed to switch public node"), 3);
                            }
                        };

                        daemonManager.sendCommandAsync(
                            ["set_bootstrap_daemon", "auto"],
                            appWindow.currentWallet.nettype,
                            persistentSettings.blockchainDataDir,
                            callback);

                        refreshMouseArea.visible = false;
                        appWindow.showStatusMessage(qsTr("Switching to another public node"), 3);
                    }
                }
            }
        }
    }
}
