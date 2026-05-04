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
import moneroComponents.Wallet 1.0

import "../components" as MoneroComponents

Rectangle {
    id: item
    property int fillLevel: 0
    property string syncType // Wallet or Daemon
    property alias bar: bar
    property bool isSynchronizing: true
    height: progressText.height + (bar.visible ? 20 : 0)
    color: "transparent"

    function updateProgress(currentBlock,targetBlock, blocksToSync, statusTxt){
        if(targetBlock > 0) {
            var remaining = (currentBlock < targetBlock) ? targetBlock - currentBlock : 0
            var progressLevel = (blocksToSync > 0 ) ? (100*(blocksToSync - remaining)/blocksToSync).toFixed(0) : 100
            fillLevel = progressLevel
            if(typeof statusTxt != "undefined" && statusTxt != "") {
                progressText.text = statusTxt;
                bar.visible = false;
                item.isSynchronizing = false;
            } else {
                progressText.text = qsTr("%1: synchronizing. Blocks remaining: %2").arg(syncType).arg(remaining.toFixed(0));
                bar.visible = true;
                item.isSynchronizing = true;
            }
        }
    }

    Rectangle {
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.fill: parent
        color: "transparent"

        MoneroComponents.TextPlain {
            id: progressText
            anchors.top: parent.top
            anchors.topMargin: 0
            font.family: MoneroComponents.Style.fontMedium.name
            font.pixelSize: 12
            color: MoneroComponents.Style.blackTheme ? MoneroComponents.Style.dimmedFontColor : MoneroComponents.Style.defaultFontColor
            opacity: MoneroComponents.Style.blackTheme ? 0.65 : 0.75
            text: qsTr("%1: synchronizing").arg(syncType) + translationManager.emptyString
            height: 18
            tooltip: {
                if (syncType == qsTr("Node")) {
                    if (persistentSettings.useRemoteNode) {
                        if (item.isSynchronizing) {
                            return qsTr("Checking remote node synchronization") + translationManager.emptyString;
                        } else if (!item.isSynchronizing && appWindow.currentBlockHeight != 0) {
                            return qsTr("The remote node is synchronized and the last block received was block #") + appWindow.currentBlockHeight + translationManager.emptyString;
                        } else if (!item.isSynchronizing) {
                            return qsTr("Your wallet is connected to a remote node that is synchronized") + translationManager.emptyString;
                        }
                    } else if (!persistentSettings.useRemoteNode) {
                        if (item.isSynchronizing) {
                            return qsTr("Your local node is downloading the blockchain") + translationManager.emptyString;
                        } else if (!item.isSynchronizing && appWindow.currentBlockHeight != 0) {
                            return qsTr("Your local node is synchronized and the last block received was block #") + appWindow.currentBlockHeight + translationManager.emptyString;
                        } else if (!item.isSynchronizing) {
                            return qsTr("Your local node is synchronized") + translationManager.emptyString;
                        }
                    }
                } else {
                    if (item.isSynchronizing) {
                        return qsTr("Currently scanning the blockchain for transactions that occured after block #") + (currentWallet ? currentWallet.walletCreationHeight.toFixed(0) : "") + "<br>" +
                               qsTr("After scanning is complete, your balance should be correct.") + translationManager.emptyString;
                    } else {
                        return qsTr("The wallet has finished scanning the blockchain for transactions that occured after block #") + (currentWallet ? currentWallet.walletCreationHeight.toFixed(0) : "") + "<br>" +
                               qsTr("If you have received a transaction in a block before this block height, go to Settings > Info page") + "<br>" +
                               qsTr("and change the 'Wallet restore height' to the block height of your first transaction.") + translationManager.emptyString;
                    }
                }
            }

            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onEntered: parent.tooltipPopup.open()
                onExited: parent.tooltipPopup.close()
                onClicked: {
                    middlePanel.settingsView.settingsStateViewState = "Info";
                    appWindow.showPageRequest("Settings");
                }
            }
        }

        Rectangle {
            id: bar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: progressText.bottom
            anchors.topMargin: 4
            height: 8
            radius: 8
            color: MoneroComponents.Style.progressBarBackgroundColor
            visible: fillRect.width != 0

            states: [
                State {
                    name: "black";
                    when: MoneroComponents.Style.blackTheme
                    PropertyChanges { target: bar; color: MoneroComponents.Style._b_progressBarBackgroundColor}
                }, State {
                    name: "white";
                    when: !MoneroComponents.Style.blackTheme
                    PropertyChanges { target: bar; color: MoneroComponents.Style._w_progressBarBackgroundColor}
                }
            ]

            transitions: Transition {
                enabled: appWindow.themeTransition
                ColorAnimation { properties: "color"; easing.type: Easing.InOutQuad; duration: 300 }
            }

            Rectangle {
                id: fillRect
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                height: bar.height
                property int maxWidth: bar.width
                width: (maxWidth * fillLevel) / 100
                radius: 8
                color: "#FA6800"
            }

            Rectangle {
                color:"#333"
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 8
            }
        }

    }
}
