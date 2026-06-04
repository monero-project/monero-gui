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

import QtQml.Models 2.2
import QtQuick 2.9
import QtQuick.Layouts 1.1
import "../components" as MoneroComponents
import moneroComponents.P2PoolManager 1.0

Rectangle {
    id: root
    color: "transparent"
    property alias miningStatsHeight: miningStatsContentColumn.height
    property int entryHeight: 24
    property int entryPixelSize: 14
    property bool showFullStats: false

    Timer {
        id: timer
        interval: 5000
        running: stateView.state === "MiningStats";
        repeat: true
        onTriggered: update()
    }

    function update()
    {
        if (persistentSettings.allow_p2pool_mining) {
            p2poolManager.getStats();
        }
    }

    function recursivelyFindPairs(statsMap, depth)
    {
        for (var key in statsMap)
        {
            var value = statsMap[key];
            if (typeof value === 'object') {
                miningStatsModel.append({"key": key + ":", "value": "", "depth": depth});
                recursivelyFindPairs(value, depth + 1);
            }
            else {
                miningStatsModel.append({"key": key + ":", "value": value.toString(), "depth": depth});
            }
        }
    }

    function updateSimpleMiningStats(statsMap)
    {
        var pool_statistics = statsMap["pool_statistics"];
        
        if (pool_statistics != null)
        {
            var statsData = [
                {"key": "Your hashrate:", "value": statsMap["current_hashrate"] + " H/s"},

                {"key": "Main chain height:", "value": statsMap["height"]},
                {"key": "Side chain height:", "value": pool_statistics["sidechainHeight"]},
                {"key": "PPLNS window:", "value": pool_statistics["pplnsWindowSize"] + " blocks"},
                {"key": "Your shares:", "value": statsMap["shares_found"] + " blocks"},
                {"key": "Block reward share:", "value": statsMap["block_reward_share_percent"] + "%"},

                {"key": "Connections: ", "value": statsMap["connections"] + " (" + statsMap["incoming_connections"] + " incoming)"},
                {"key": "Peer list size: ", "value": statsMap["peer_list_size"]},
                {"key": "Uptime: ", "value": statsMap["uptime"] + "s"}
            ];

            for (var element of statsData)
            {
                if (element.value != null)
                {
                    simpleMiningStatsModel.append({"key": element["key"], "value": element["value"].toString(), "depth": 0});
                }
            }
        }
    }

    function updateMiningStats(statsMap)
    {
        simpleMiningStatsModel.clear();
        updateSimpleMiningStats(statsMap);

        miningStatsModel.clear();
        recursivelyFindPairs(statsMap, 0);
    }

    ListModel { id: simpleMiningStatsModel }
    ListModel { id: miningStatsModel }

    Column {
        id: miningStatsContentColumn
        spacing: entryHeight

        MoneroComponents.StandardButton {
            id: backButton
            text: qsTr("Back") + translationManager.emptyString;
            width: 100
            primary: false
            onClicked: {
                stateView.state = "Mining";
            }
        }

        ListView {
            id: simpleMiningStatsView
            width: root.width
            height: count * entryHeight + entryHeight
            model: simpleMiningStatsModel
            interactive: false

            delegate: Rectangle {
                id: miningStatsDelegate
                color: "transparent"
                height: entryHeight
                Layout.fillWidth: true

                RowLayout {
                    MoneroComponents.TextBlock {
                        Layout.fillWidth: true
                        Layout.leftMargin: depth * entryPixelSize
                        font.pixelSize: entryPixelSize
                        text: key + translationManager.emptyString
                    }

                    MoneroComponents.TextBlock {
                        Layout.fillWidth: true
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: entryPixelSize
                        text: value + translationManager.emptyString
                    }
                }
            }
        }

        MoneroComponents.CheckBox2 {
            id: showFullStatsCheckbox
            checked: showFullStats
            onClicked: showFullStats = !showFullStats
            text: qsTr("Show full statistics") + translationManager.emptyString
        }

        ListView {
            visible: showFullStats
            id: miningStatsView
            width: root.width
            height: count * entryHeight + entryHeight
            model: miningStatsModel
            interactive: false

            delegate: Rectangle {
                id: miningStatsDelegate
                color: "transparent"
                height: entryHeight
                Layout.fillWidth: true

                RowLayout {
                    MoneroComponents.TextBlock {
                        Layout.fillWidth: true
                        Layout.leftMargin: depth * entryPixelSize
                        font.pixelSize: entryPixelSize
                        text: key + translationManager.emptyString
                    }

                    MoneroComponents.TextBlock {
                        Layout.fillWidth: true
                        color: MoneroComponents.Style.dimmedFontColor
                        font.pixelSize: entryPixelSize
                        text: value + translationManager.emptyString
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        p2poolManager.p2poolStats.connect(updateMiningStats);
    }
}
