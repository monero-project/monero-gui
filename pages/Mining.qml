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
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../components" as MoneroComponents
import moneroComponents.Wallet 1.0

Rectangle {
    id: root
    color: "transparent"
    property alias miningHeight: mainLayout.height
    property double currentHashRate: 0
    property int threads: idealThreadCount / 2

    ColumnLayout {
        id: mainLayout
        Layout.fillWidth: true
        anchors.margins: 20
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 20

        MoneroComponents.Label {
            id: soloTitleLabel
            fontSize: 24
            text: qsTr("Solo mining") + translationManager.emptyString
        }

        MoneroComponents.WarningBox {
            Layout.bottomMargin: 8
            text: qsTr("Mining is only available on local daemons.") + translationManager.emptyString
            visible: persistentSettings.useRemoteNode
        }

        MoneroComponents.WarningBox {
            Layout.bottomMargin: 8
            text: qsTr("Your daemon must be synchronized before you can start mining") + translationManager.emptyString
            visible: !persistentSettings.useRemoteNode && !appWindow.daemonSynced
        }

        MoneroComponents.TextPlain {
            id: soloMainLabel
            text: qsTr("Mining with your computer helps strengthen the Monero network. The more that people mine, the harder it is for the network to be attacked, and every little bit helps.\n\nMining also gives you a small chance to earn some Monero. Your computer will create hashes looking for block solutions. If you find a block, you will get the associated reward. Good luck!") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.WarningBox {
            id: warningLabel
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            text: qsTr("Mining may reduce the performance of other running applications and processes.") + translationManager.emptyString
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 20
            rowSpacing: 16

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                MoneroComponents.Label {
                    id: soloMinerThreadsLabel
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("CPU threads") + translationManager.emptyString
                    fontSize: 16
                    wrapMode: Text.WordWrap
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    MoneroComponents.StandardButton {
                        id: removeThreadButton
                        small: true
                        primary: false
                        text: "−"
                        enabled: threads > 1
                        onClicked: threads--
                    }

                    MoneroComponents.TextPlain {
                        Layout.bottomMargin: 1
                        Layout.minimumWidth: 45
                        color: MoneroComponents.Style.defaultFontColor
                        text: threads
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 16

                        MouseArea {
                            anchors.fill: parent
                            scrollGestureEnabled: false
                            onWheel: {
                                if (wheel.angleDelta.y > 0 && threads < idealThreadCount) {
                                    return threads++
                                } else if (wheel.angleDelta.y < 0 && threads > 1) {
                                    return threads--
                                }
                            }
                        }
                    }

                    MoneroComponents.StandardButton {
                        id: addThreadButton
                        small: true
                        primary: false
                        text: "+"
                        enabled: threads < idealThreadCount
                        onClicked: threads++
                    }
                }

                RowLayout {
                    MoneroComponents.StandardButton {
                        id: autoRecommendedThreadsButton
                        small: true
                        primary: false
                        text: qsTr("Use half (recommended)") +  translationManager.emptyString
                        enabled: startSoloMinerButton.enabled
                        onClicked: {
                                threads = idealThreadCount / 2
                                appWindow.showStatusMessage(qsTr("Set to use recommended # of threads"),3)
                        }
                    }

                    MoneroComponents.StandardButton {
                        id: autoSetMaxThreadsButton
                        small: true
                        primary: false
                        text: qsTr("Use all threads") + " (" + idealThreadCount + ")" + translationManager.emptyString
                        enabled: startSoloMinerButton.enabled
                        onClicked: {
                            threads = idealThreadCount
                            appWindow.showStatusMessage(qsTr("Set to use all threads") + translationManager.emptyString,3)
                        }
                    }
                }

                RowLayout {
                    // Disable this option until stable
                    visible: false
                    MoneroComponents.CheckBox {
                        id: ignoreBattery
                        enabled: startSoloMinerButton.enabled
                        checked: !persistentSettings.miningIgnoreBattery
                        onClicked: {persistentSettings.miningIgnoreBattery = !checked}
                        text: qsTr("Enable mining when running on battery") + translationManager.emptyString
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.minimumWidth: 140

                MoneroComponents.Label {
                    id: optionsLabel
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("Options") + translationManager.emptyString
                    fontSize: 16
                    wrapMode: Text.Wrap
                    Layout.preferredWidth: manageSoloMinerLabel.textWidth
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    MoneroComponents.CheckBox {
                        id: backgroundMining
                        enabled: startSoloMinerButton.enabled
                        checked: persistentSettings.allow_background_mining
                        onClicked: persistentSettings.allow_background_mining = checked
                        text: qsTr("Background mining (experimental)") + translationManager.emptyString
                    }
                }
            }

            ColumnLayout {
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                MoneroComponents.Label {
                    id: manageSoloMinerLabel
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("Manage miner") + translationManager.emptyString
                    fontSize: 16
                    wrapMode: Text.Wrap
                    Layout.preferredWidth: manageSoloMinerLabel.textWidth
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    MoneroComponents.StandardButton {
                        visible: true
                        id: startSoloMinerButton
                        small: true
                        primary: !stopSoloMinerButton.enabled
                        text: qsTr("Start mining") + translationManager.emptyString
                        onClicked: {
                            var success = walletManager.startMining(appWindow.currentWallet.address(0, 0), threads, persistentSettings.allow_background_mining, persistentSettings.miningIgnoreBattery)
                            if (success) {
                                update()
                            } else {
                                errorPopup.title  = qsTr("Error starting mining") + translationManager.emptyString;
                                errorPopup.text = qsTr("Couldn't start mining.<br>") + translationManager.emptyString
                                if (persistentSettings.useRemoteNode)
                                    errorPopup.text += qsTr("Mining is only available on local daemons. Run a local daemon to be able to mine.<br>") + translationManager.emptyString
                                errorPopup.icon = StandardIcon.Critical
                                errorPopup.open()
                            }
                        }
                    }

                    MoneroComponents.StandardButton {
                        visible: true
                        id: stopSoloMinerButton
                        small: true
                        primary: stopSoloMinerButton.enabled
                        text: qsTr("Stop mining") + translationManager.emptyString
                        onClicked: {
                            walletManager.stopMining()
                            update()
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                MoneroComponents.Label {
                    id: statusLabel
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("Status") + translationManager.emptyString
                    fontSize: 16
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                MoneroComponents.LineEditMulti {
                    id: statusText
                    Layout.minimumWidth: 300
                    text: qsTr("Not mining") + translationManager.emptyString
                    borderDisabled: true
                    readOnly: true
                    wrapMode: Text.Wrap
                    inputPaddingLeft: 0
                }
            }
        }
    }

    function updateStatusText() {
        if (appWindow.isMining) {
            var userHashRate = walletManager.miningHashRate();
            if (userHashRate === 0) {
                statusText.text = qsTr("Mining temporarily suspended.") + translationManager.emptyString;
            }
            else {
                var blockTime = 120;
                var blocksPerDay = 86400 / blockTime;
                var globalHashRate = walletManager.networkDifficulty() / blockTime;
                var probabilityFindNextBlock = userHashRate / globalHashRate;
                var probabilityFindBlockDay = 1 - Math.pow(1 - probabilityFindNextBlock, blocksPerDay);
                var chanceFindBlockDay = Math.round(1 / probabilityFindBlockDay);
                statusText.text = qsTr("Mining at %1 H/s. It gives you a 1 in %2 daily chance of finding a block.").arg(userHashRate).arg(chanceFindBlockDay) + translationManager.emptyString;
            }
        }
        else {
            statusText.text = qsTr("Not mining") + translationManager.emptyString;
        }
    }

    function onMiningStatus(isMining) {
        var daemonReady = !persistentSettings.useRemoteNode && appWindow.daemonSynced
        appWindow.isMining = isMining;
        updateStatusText()
        startSoloMinerButton.enabled = !appWindow.isMining && daemonReady
        stopSoloMinerButton.enabled = !startSoloMinerButton.enabled && daemonReady
    }

    function update() {
        walletManager.miningStatusAsync();
    }

    MoneroComponents.StandardDialog {
        id: errorPopup
        cancelVisible: false
    }

    Timer {
        id: timer
        interval: 2000; running: false; repeat: true
        onTriggered: update()
    }

    function onPageCompleted() {
        console.log("Mining page loaded");
        update()
        timer.running = !persistentSettings.useRemoteNode
    }

    function onPageClosed() {
        timer.running = false
    }

    Component.onCompleted: {
        walletManager.miningStatus.connect(onMiningStatus);
    }
}
