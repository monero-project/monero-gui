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
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../components" as MoneroComponents
import moneroComponents.P2PoolManager 1.0
import FontAwesome 1.0

Rectangle {
    id: root
    color: "transparent"
    property alias statsHeight: mainLayout.height

    property var poolStats: ({})
    property var minerStats: ({})
    property var stratumStats: ({})
    property var networkStats: ({})

    Timer {
        id: updateTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: p2poolManager.getStats()
    }

    function updateStats(stats) {
        poolStats = stats.pool_stats || {}
        minerStats = stats.miner_stats || {}
        stratumStats = stats.stratum_stats || {}
        networkStats = stats.network_stats || {}
    }

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 20

        MoneroComponents.Label {
            fontSize: 24
            text: qsTr("P2Pool Mining Dashboard") + translationManager.emptyString
        }

        MoneroComponents.StandardButton {
            id: backButton
            text: qsTr("Back to Mining") + translationManager.emptyString
            width: 120
            primary: false
            onClicked: {
                stateView.state = "Mining"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 2
            color: MoneroComponents.Style.dividerColor
            opacity: MoneroComponents.Style.dividerOpacity
        }

        // Tab bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            MoneroComponents.StandardButton {
                id: statusTabButton
                text: qsTr("Status") + translationManager.emptyString
                small: true
                primary: tabView.currentIndex === 0
                onClicked: tabView.currentIndex = 0
            }

            MoneroComponents.StandardButton {
                id: peersTabButton
                text: qsTr("Peers") + translationManager.emptyString
                small: true
                primary: tabView.currentIndex === 1
                onClicked: tabView.currentIndex = 1
            }

            MoneroComponents.StandardButton {
                id: workersTabButton
                text: qsTr("Workers") + translationManager.emptyString
                small: true
                primary: tabView.currentIndex === 2
                onClicked: tabView.currentIndex = 2
            }

            MoneroComponents.StandardButton {
                id: bansTabButton
                text: qsTr("Bans") + translationManager.emptyString
                small: true
                primary: tabView.currentIndex === 3
                onClicked: tabView.currentIndex = 3
            }
        }

        // Tab content
        StackLayout {
            id: tabView
            Layout.fillWidth: true
            currentIndex: 0

            // Status Tab
            ColumnLayout {
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true
                    
                    MoneroComponents.Label {
                        text: qsTr("Pool Status") + translationManager.emptyString
                        fontSize: 18
                        Layout.fillWidth: true
                    }

                    MoneroComponents.IconButton {
                        fontAwesomeFallbackIcon: FontAwesome.questionCircle
                        fontAwesomeFallbackSize: 22
                        color: MoneroComponents.Style.defaultFontColor
                        fontAwesomeFallbackOpacity: 0.5
                        onClicked: {
                            informationPopup.title = qsTr("Pool Status Help") + translationManager.emptyString
                            informationPopup.text = qsTr("Displays current P2Pool mining statistics including hashrate, shares found, and pool information.") + translationManager.emptyString
                            informationPopup.icon = StandardIcon.Information
                            informationPopup.onCloseCallback = null
                            informationPopup.open()
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 10

                    MoneroComponents.TextPlain {
                        text: qsTr("Your Hashrate:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (minerStats.current_hashrate || 0) + " H/s"
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Pool Hashrate:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (poolStats.pool_statistics ? (poolStats.pool_statistics.hashrate || 0) : 0) + " H/s"
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Shares Found:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (minerStats.shares_found || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Block Reward Share:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (minerStats.block_reward_share_percent || 0) + "%"
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Main Chain Height:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (poolStats.height || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Side Chain Height:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (poolStats.pool_statistics ? (poolStats.pool_statistics.sidechainHeight || 0) : 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("PPLNS Window:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (poolStats.pool_statistics ? (poolStats.pool_statistics.pplnsWindowSize || 0) : 0) + " blocks"
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Uptime:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: formatUptime(poolStats.uptime || 0)
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }
                }
            }

            // Peers Tab
            ColumnLayout {
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true
                    
                    MoneroComponents.Label {
                        text: qsTr("P2Pool Peers") + translationManager.emptyString
                        fontSize: 18
                        Layout.fillWidth: true
                    }

                    MoneroComponents.IconButton {
                        fontAwesomeFallbackIcon: FontAwesome.questionCircle
                        fontAwesomeFallbackSize: 22
                        color: MoneroComponents.Style.defaultFontColor
                        fontAwesomeFallbackOpacity: 0.5
                        onClicked: {
                            informationPopup.title = qsTr("Peers Help") + translationManager.emptyString
                            informationPopup.text = qsTr("Shows connected P2Pool peers in the decentralized mining network.") + translationManager.emptyString
                            informationPopup.icon = StandardIcon.Information
                            informationPopup.onCloseCallback = null
                            informationPopup.open()
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 10

                    MoneroComponents.TextPlain {
                        text: qsTr("Total Connections:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (poolStats.connections || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Incoming Connections:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (poolStats.incoming_connections || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Outgoing Connections:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: ((poolStats.connections || 0) - (poolStats.incoming_connections || 0)).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Peer List Size:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (poolStats.peer_list_size || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }
                }
            }

            // Workers Tab
            ColumnLayout {
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true
                    
                    MoneroComponents.Label {
                        text: qsTr("Stratum Workers") + translationManager.emptyString
                        fontSize: 18
                        Layout.fillWidth: true
                    }

                    MoneroComponents.IconButton {
                        fontAwesomeFallbackIcon: FontAwesome.questionCircle
                        fontAwesomeFallbackSize: 22
                        color: MoneroComponents.Style.defaultFontColor
                        fontAwesomeFallbackOpacity: 0.5
                        onClicked: {
                            informationPopup.title = qsTr("Workers Help") + translationManager.emptyString
                            informationPopup.text = qsTr("Displays mining workers connected to your local Stratum server.") + translationManager.emptyString
                            informationPopup.icon = StandardIcon.Information
                            informationPopup.onCloseCallback = null
                            informationPopup.open()
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 10

                    MoneroComponents.TextPlain {
                        text: qsTr("Connected Workers:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (stratumStats.connections || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Total Hashrate:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (stratumStats.hashrate || 0) + " H/s"
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Shares Submitted:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (stratumStats.shares_submitted || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Shares Failed:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (stratumStats.shares_failed || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }
                }
            }

            // Bans Tab
            ColumnLayout {
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true
                    
                    MoneroComponents.Label {
                        text: qsTr("Banned Peers") + translationManager.emptyString
                        fontSize: 18
                        Layout.fillWidth: true
                    }

                    MoneroComponents.IconButton {
                        fontAwesomeFallbackIcon: FontAwesome.questionCircle
                        fontAwesomeFallbackSize: 22
                        color: MoneroComponents.Style.defaultFontColor
                        fontAwesomeFallbackOpacity: 0.5
                        onClicked: {
                            informationPopup.title = qsTr("Bans Help") + translationManager.emptyString
                            informationPopup.text = qsTr("Shows peers that have been banned due to misbehavior or invalid data.") + translationManager.emptyString
                            informationPopup.icon = StandardIcon.Information
                            informationPopup.onCloseCallback = null
                            informationPopup.open()
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 10

                    MoneroComponents.TextPlain {
                        text: qsTr("Total Bans:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (poolStats.banned_peers || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }

                    MoneroComponents.TextPlain {
                        text: qsTr("Stratum Bans:") + translationManager.emptyString
                        color: MoneroComponents.Style.defaultFontColor
                        font.pixelSize: 14
                    }
                    MoneroComponents.TextPlain {
                        text: (stratumStats.bans || 0).toString()
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: 14
                    }
                }

                MoneroComponents.TextPlain {
                    text: poolStats.banned_peers > 0 || stratumStats.bans > 0 
                        ? qsTr("Banned peers are automatically removed after the ban period expires.")
                        : qsTr("No peers are currently banned.")
                    color: MoneroComponents.Style.dimmedFontColor
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
    }

    function formatUptime(seconds) {
        var days = Math.floor(seconds / 86400)
        var hours = Math.floor((seconds % 86400) / 3600)
        var minutes = Math.floor((seconds % 3600) / 60)
        var secs = seconds % 60
        
        if (days > 0) {
            return days + "d " + hours + "h " + minutes + "m"
        } else if (hours > 0) {
            return hours + "h " + minutes + "m " + secs + "s"
        } else if (minutes > 0) {
            return minutes + "m " + secs + "s"
        } else {
            return secs + "s"
        }
    }

    Component.onCompleted: {
        p2poolManager.p2poolStats.connect(updateStats)
        p2poolManager.getStats()
    }
}
