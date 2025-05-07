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
import QtQuick.Controls 2.0

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

Rectangle {
    id: statusBar
    property int customDecimals: persistentSettings.balanceDecimalPoint
    property bool progressBarVisible: false
    property int progressBarValue: 0
    property string statusText: qsTr("Welcome to Monero") + translationManager.emptyString
    property string balanceText: "?.??"
    property string balanceFiatText: "?.??"
    property string availableBalanceText: "?.??"
    property string availableBalanceFiatText: "?.??"
    property var balanceExactDoubleValue: null // Use this to avoid value manipulation in GUI side
    property var availableExactDoubleValue: null // Use this to avoid value manipulation in GUI side

    Layout.fillWidth: true
    color: MoneroComponents.Style.blackTheme ? "#0d0d0d" : "#f5f5f5"
    height: 36
    visible: true

    property alias progressBar: progressBar
    property alias daemonProgressBar: daemonProgressBar

    MoneroComponents.ProgressBar {
        id: progressBar
        hideDelay: 5000
        y: 0
        visible: false
        anchors.left: parent.left
        anchors.right: parent.right
    }

    MoneroComponents.ProgressBar {
        id: daemonProgressBar
        hideDelay: 5000
        y: statusBar.height - this.height
        anchors.left: parent.left
        anchors.right: parent.right
        visible: false
        backgroundColor: MoneroComponents.Style.blackTheme ? "#00401B" : "#EBF9F0"
        foregroundColor: MoneroComponents.Style.blackTheme ? "#00CA5F" : "#00401B"
    }

    MoneroComponents.TextPlain {
        id: statusText
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        font.pixelSize: 15
        font.family: MoneroComponents.Style.fontRegular.name
        color: MoneroComponents.Style.dimmedFontColor
        text: statusBar.statusText
        themeTransition: false
    }

    Row {
        id: networkStatus
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: 16
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        spacing: 4

        // I2P status
        Item {
            id: i2pStatusIcon
            visible: persistentSettings.useI2P
            height: parent.height
            width: 28
            
            Image {
                id: i2pIcon
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                source: "../images/i2p.svg"
                height: 28
                width: 28
                fillMode: Image.PreserveAspectFit
                mipmap: true
                opacity: i2pDaemonManager.running ? 1.0 : 0.3 // Fade when not running
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // Toggle I2P enabled state
                    if (i2pDaemonManager.running) {
                        i2pDaemonManager.stop()
                    } else {
                        i2pDaemonManager.start()
                    }
                }
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 1000
                ToolTip.visible: containsMouse
                ToolTip.text: i2pDaemonManager.running ? qsTr("I2P connection active") :
                                                         qsTr("I2P connection not active") + 
                                                         translationManager.emptyString
            }
        }
        
        // Existing status indicators
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            color: MoneroComponents.Style.blackTheme ? "#111111" : "#FFFFFF"
            radius: 12
            anchors.verticalCenter: parent.verticalCenter

            visible: true
            property bool connected: rootWindow.walletMode && (connectionStatus.connected())
            property double fillLevel: 0
            property string tooltipText: connectionStatus.tooltipText

            Rectangle {
                id: fillRect
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                height: networkStatus.height
                width: parent.width * fillLevel
                radius: 12
                color: {
                    if(networkStatus.connected){
                        if (currentWallet != undefined && currentWallet.viewOnly) {
                            return "red";
                        } else if (currentWallet != undefined && currentWallet.isDaemonBlockChainHeightLessThanWalletHeight()) {
                            return "red";
                        } else {
                            return "#6B0072";
                        }
                    } else {
                        return "red";
                    }
                }
            }

            Image {
                anchors.centerIn: parent
                width: 14
                height: 14
                source: {
                    if(networkStatus.connected){
                        return "qrc:///images/lightning-white.png"
                    } else {
                        return "qrc:///images/lightning.png"
                    }
                }
                mipmap: true
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    tooltip.text = networkStatus.tooltipText
                    tooltip.tooltipPopup.open()
                }
            }
        }
    }

    MoneroComponents.TextPlain {
        id: unlockedBalanceText
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: balanceText.left
        anchors.rightMargin: 16
        font.family: MoneroComponents.Style.fontRegular.name
        font.pixelSize: 15
        color: MoneroComponents.Style.defaultFontColor
        
        text: {
            // Round to 8 decimals for display
            const amountStr = statusBar.availableBalanceText
            
            // Show view only message if wallet is view-only
            if(currentWallet != undefined && currentWallet.viewOnly) return qsTr("VIEW ONLY") + translationManager.emptyString
            
            return amountStr != "?.??" ? "Unlocked: " + amountStr : "Unlocked: " + "?.??"
        }
        
        MouseArea {
            id: unlockedBalanceTextMouseArea
            hoverEnabled: true
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                unlockedBalanceText.color = MoneroComponents.Style.orange
            }
            onExited: {
                unlockedBalanceText.color = MoneroComponents.Style.defaultFontColor
            }
            onClicked: {
                appWindow.showPageRequest("Account")
            }
        }
    }

    MoneroComponents.TextPlain {
        id: balanceText
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 12
        font.family: MoneroComponents.Style.fontRegular.name
        font.pixelSize: 15
        color: MoneroComponents.Style.defaultFontColor
        
        text: {
            // Round to 8 decimals for display
            const amountStr = statusBar.balanceText
            
            // Show view only message if wallet is view-only
            if(currentWallet != undefined && currentWallet.viewOnly) return qsTr("VIEW ONLY") + translationManager.emptyString
            
            // Hide balance if the window is not active to prevent "balance peeking"
            if(!isWindowActive) return "Balance: HIDDEN"
            
            return amountStr != "?.??" ? "Balance: " + amountStr : "Balance: " + "?.??"
        }
        
        MouseArea {
            id: balanceTextMouseArea
            hoverEnabled: true
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                balanceText.color = MoneroComponents.Style.orange
            }
            onExited: {
                balanceText.color = MoneroComponents.Style.defaultFontColor
            }
            onClicked: {
                appWindow.showPageRequest("Account")
            }
        }
    }

    MoneroComponents.Tooltip {
        id: tooltip
        anchors.fill: parent
        tooltipLeft: true
    }
} 