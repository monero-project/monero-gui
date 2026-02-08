// Copyright (c) 2014-2026, The Monero Project
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

    component DashboardTitle : MoneroComponents.Label {
        fontSize: 24
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

    component DashboardLabel : MoneroComponents.TextBlock {
        color: MoneroComponents.Style.defaultFontColor
        font.pixelSize: 14
        tooltipIconVisible: true
    }

    component DashboardValue : MoneroComponents.TextBlock {
        Layout.fillWidth: true
        color: MoneroComponents.Style.dimmedFontColor
        font.pixelSize: 14
        horizontalAlignment: Text.AlignRight
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
            text: qsTr("Mining Dashboard") + translationManager.emptyString
        }

        RowLayout {
            DashboardColumn {
                DashboardHeader { text: qsTr("Your PC") + translationManager.emptyString }
                Repeater {
                    model: localModel
                    delegate: DashboardRow {
                        DashboardLabel { text: model.label }
                        DashboardValue { text: model.value }
                    }
                }
            }

            DashboardColumn {
                DashboardHeader { text: qsTr("The Pool") + translationManager.emptyString }
                Repeater {
                    model: poolModel
                    delegate: DashboardRow {
                        DashboardLabel { text: model.label }
                        DashboardValue { text: model.value }
                    }
                }
            }

            DashboardColumn {
                DashboardHeader { text: qsTr("The Network") + translationManager.emptyString }
                Repeater {
                    model: networkModel
                    delegate: DashboardRow {
                        DashboardLabel { text: model.label }
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
        interval: 1000
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
                    [qsTr("Hashrate (15 min)"), local.hashrate_ema15m],
                    [qsTr("Hashrate (1 hr)"), local.hashrate_ema1h],
                    [qsTr("Hashrate (24 hr)"), local.hashrate_ema24h],
                    [qsTr("Shares (Valid/Invalid)"), `${local.shares_found}/${local.shares_failed}`]
                ]},
                { model: poolModel, data: [
                    [qsTr("Hashrate"), pool.hashrate],
                    [qsTr("Last Block Found"), pool.last_block_found_time],
                    [qsTr("Payment Scheme"), `PPLNS (${pool.pplns_window_size} blocks)`]
                ]},
                { model: networkModel, data: [
                    [qsTr("Hashrate"), network.hashrate],
                    [qsTr("Last Block Found"), network.last_block_found_time]
                ]}
            ];

            mappings.forEach(m => {
                m.data.forEach((item, i) => {
                    m.model.set(i, {
                        label: item[0] + ":" + translationManager.emptyString,
                        value: format(item[1]) });
                });
            });

            advancedModel.clear();
            appendMapToModel(raw, advancedModel);
        }
    }
}
