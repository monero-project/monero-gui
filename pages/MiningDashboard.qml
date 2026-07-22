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

import QtQml.Models 2.2
import QtQuick 2.9
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents
import moneroComponents.DaemonManager 1.0
import moneroComponents.P2PoolManager 1.0
import moneroComponents.Wallet 1.0


Rectangle {
    id: root
    color: "transparent"

    ListModel { id: localModel }

    ListModel { id: poolModel }

    ListModel { id: networkModel }

    ListModel { id: advancedModel }

    property alias miningDashboardHeight: mainLayout.height
    property bool showAdvancedSection: false

    component DashboardTitle : ColumnLayout {
        property string description: ""
        property string text: ""

        MoneroComponents.Label {
            fontSize: 24
            text: parent.text
        }

        MoneroComponents.TextPlain {
            Layout.fillWidth: true

            color: MoneroComponents.Style.defaultFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14

            text: parent.description
            wrapMode: Text.Wrap
            textFormat: Text.RichText

            MouseArea {
                anchors.fill: parent
                cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.DefaultCursor

                onClicked: {
                    if (parent.hoveredLink) {
                        Qt.openUrlExternally(parent.hoveredLink);
                    }
                }
            }
        }
    }

    component DashboardHeader : MoneroComponents.LabelSubheader {
        Layout.fillWidth: true
        textFormat: Text.RichText
    }

    component DashboardColumn : ColumnLayout {
        Layout.alignment: Qt.AlignTop
        Layout.maximumWidth: 300
        spacing: 10
    }

    component DashboardRow : RowLayout {
        Layout.maximumWidth: 300
        Layout.leftMargin: 5
        Layout.rightMargin: 5
    }

    component DashboardLabel : MoneroComponents.Label {
        fontSize: 14
    }

    component DashboardValue : MoneroComponents.TextBlock {
        Layout.fillWidth: true

        color: MoneroComponents.Style.dimmedFontColor
        font.pixelSize: 14

        horizontalAlignment: Text.AlignRight
        textFormat: Text.RichText
    }

    ColumnLayout {
        id: mainLayout
        Layout.fillWidth: true
        anchors.margins: 20
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20

        MoneroComponents.StandardButton {
            small: true
            primary: true
            text: qsTr("Back") + translationManager.emptyString
            onClicked: {
                stateView.state = "Mining";
            }
        }

        DashboardTitle {
            text:
                qsTr("Mining Dashboard") + translationManager.emptyString
            description:
                qsTr("View detailed statistics about your hardware, the pool, and the overall network.") + translationManager.emptyString + "<br><br>" +
                qsTr("With P2Pool mining, payouts happen in bursts. You are paid only when the pool finds a block, and when you have a share in the 'window'. It can be normal to go long periods without seeing a payout.") + translationManager.emptyString + "<br><br>" +
                qsTr("For more consistent payouts, use the calculators available for <a href='%1'>nano</a>, <a href='%2'>mini</a>, and <a href='%3'>main</a>, and choose the chain where your average share time most closely matches the pool's average block time.")
                  .arg("https://nano.p2pool.observer/calculate-share-time")
                  .arg("https://mini.p2pool.observer/calculate-share-time")
                  .arg("https://p2pool.observer/calculate-share-time") + translationManager.emptyString + "<br><br>" + "<b>" +
                qsTr("Learn more about each value by mousing over the label.") + translationManager.emptyString
        }

        RowLayout {
            DashboardColumn {
                DashboardHeader { text: qsTr("Your PC") + translationManager.emptyString }
                Repeater {
                    model: localModel
                    delegate: DashboardRow {
                        DashboardLabel {
                            text: model.label
                            tooltip: model.tooltip
                        }
                        DashboardValue { text: model.value }
                    }
                }
            }

            DashboardColumn {
                DashboardHeader { text: qsTr("The Pool") + translationManager.emptyString }
                Repeater {
                    model: poolModel
                    delegate: DashboardRow {
                        DashboardLabel {
                            text: model.label
                            tooltip: model.tooltip
                        }
                        DashboardValue { text: model.value }
                    }
                }
            }

            DashboardColumn {
                DashboardHeader { text: qsTr("The Network") + translationManager.emptyString }
                Repeater {
                    model: networkModel
                    delegate: DashboardRow {
                        DashboardLabel {
                            text: model.label
                            tooltip: model.tooltip
                        }
                        DashboardValue { text: model.value }
                    }
                }
            }
        }

        RowLayout {
            DashboardColumn {
                MoneroComponents.CheckBox2 {
                    checked: showAdvancedSection
                    onClicked: showAdvancedSection = !showAdvancedSection
                    text: qsTr("Advanced (Raw Data)") + translationManager.emptyString
                }
                DashboardColumn {
                    visible: showAdvancedSection
                    Layout.maximumWidth: 500
                    spacing: 1
                    Repeater {
                        model: advancedModel
                        DashboardRow {
                            DashboardLabel { text: "    ".repeat(model.depth) + model.key }
                            DashboardValue { text: model.value }
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: timer
        interval: 5000
        repeat: true
        running: stateView.state === "Mining Dashboard" && p2poolManager !== null

        onTriggered: p2poolManager.p2poolStats.update()

        onRunningChanged: {
            if (running) {
                p2poolManager.p2poolStats.update();
            }
        }
    }

    function appendMapToModel(map, model, depth = 0) {
        for (var key in map) {
            var value = map[key] ?? "";
            if (typeof value === 'object' && value !== null) {
                model.append({"key": key + ":", "value": "", "depth": depth});
                appendMapToModel(value, model, depth + 1);
            } else {
                model.append({"key": key + ":", "value": value.toString(), "depth": depth});
            }
        }
    }

    Connections {
        target: p2poolManager.p2poolStats

        function onP2poolUpdateStats(local, pool, network, raw) {
            const format = (val) => String(val).includes("undefined") ? qsTr("syncing...") : String(val);

            const mappings = [
                { model: localModel, data: [
                    [qsTr("Hashrate:"), local.hashrate,
                     qsTr("Your current mining speed. Minor fluctuations are normal, but significant drops may indicate hardware issues or thermal throttling.")],

                    [qsTr("Hashrate (15m):"), local.hashrate_ema15m,
                     qsTr("Your hashrate averaged over the last 15 minutes. Useful for seeing immediate impact of system usage or thermal throttling. This field is only available after 15 minutes of mining.")],

                    [qsTr("Hashrate (1hr):"), local.hashrate_ema1h,
                     qsTr("Your hashrate averaged over the last hour. A good indicator of stable performance. This field is only available after an hour of mining.")],

                    [qsTr("Hashrate (24hr):"), local.hashrate_ema24h,
                     qsTr("Your hashrate averaged over the last day. This is the most accurate representation of your hardware's long-term contribution. This field is only available after a day of mining.")],

                    [qsTr("Effort (Now/Average):"), `${local.effort}/${local.effort_ema}`,
                     qsTr("Your current progress toward finding the next share. On average, it takes 100% effort to find a share. The second value tracks your long-term average.")]
                ]},
                { model: poolModel, data: [
                    [qsTr("Hashrate:"), pool.hashrate,
                     qsTr("The combined speed of this pool. This determines the difficulty of the P2Pool sidechain and sets the pace for how often you can expect to find a share.")],

                    [qsTr("Last Block Found:"), pool.last_block_found_time,
                     qsTr("Time elapsed since the pool found a block and paid out a reward. It could take anywhere from a couple minutes, to hours, to days for this field to populate, depending on the chain you've chosen.")],

                    [qsTr("Payment Scheme:"), `PPLNS (${pool.pplns_window_size} blocks)`,
                     qsTr("PPLNS (Pay Per Last N Shares) rewards miners based on shares found within a specific 'window' of time. Shares submitted to the pool are tied to your wallet address. If you have a share in this window when a block is found, you receive a payout. The more shares in the window, the higher your payout is.")],

                    [qsTr("In Window?"), pool.is_in_window === "yes" ? `<b>yes</b>` : pool.is_in_window,
                     qsTr("If 'yes', you are currently eligible for a payout. If 'no', you are still working toward finding a share to enter the window. Shares submitted to the pool are tied to your wallet address. This can switch from 'yes' to 'no' when shares fall out of the window.")]
                ]},
                { model: networkModel, data: [
                    [qsTr("Hashrate:"), network.hashrate,
                     qsTr("The combined speed of the entire Monero network. This determines the difficulty of the Monero blockchain and sets the pace for how often you can expect the pool to find a block.")],

                    [qsTr("Last Block Found:"), network.last_block_found_time,
                     qsTr("Time elapsed since the network found a block and paid out a reward. The protocol targets two minutes per block, and dynamically adjusts difficulty to maintain this.")]
                ]}
            ];

            mappings.forEach(m => {
                m.data.forEach((item, i) => {
                    m.model.set(i, {
                        label: item[0] + translationManager.emptyString,
                        value: format(item[1]),
                        tooltip: (item[2] || "") + translationManager.emptyString});
                });
            });

            advancedModel.clear();
            appendMapToModel(raw, advancedModel);
        }
    }
}
