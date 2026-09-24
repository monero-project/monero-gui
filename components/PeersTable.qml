// Copyright (c) 2026, The Monero Project
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

import "." as MoneroComponents
import "effects/" as MoneroEffects
import "../js/Utils.js" as Utils
import moneroComponents.Clipboard 1.0

ColumnLayout {
    id: peersTable
    spacing: 0

    property var model
    property bool loading: model ? model.loading : false
    property int hoveredIndex: -1

    Clipboard {
        id: clipboard
    }

    function formatBytes(bytes) {
        if (bytes < 1024)
            return bytes + " B";
        if (bytes < 1024 * 1024)
            return (bytes / 1024).toFixed(1) + " KB";
        return (bytes / (1024 * 1024)).toFixed(1) + " MB";
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 8
        columnSpacing: 24
        rowSpacing: 6

        MoneroComponents.TextPlain {
            Layout.row: 0
            Layout.column: 0
            font.bold: true
            text: qsTr("Direction") + translationManager.emptyString
            color: MoneroComponents.Style.dimmedFontColor
        }

        MoneroComponents.TextPlain {
            Layout.row: 0
            Layout.column: 1
            Layout.maximumWidth: 220
            font.bold: true
            text: qsTr("Address") + translationManager.emptyString
            color: MoneroComponents.Style.dimmedFontColor
        }

        MoneroComponents.TextPlain {
            Layout.row: 0
            Layout.column: 2
            font.bold: true
            text: qsTr("Network") + translationManager.emptyString
            color: MoneroComponents.Style.dimmedFontColor
        }

        MoneroComponents.TextPlain {
            Layout.row: 0
            Layout.column: 3
            font.bold: true
            text: qsTr("Block height") + translationManager.emptyString
            color: MoneroComponents.Style.dimmedFontColor
        }

        MoneroComponents.TextPlain {
            Layout.row: 0
            Layout.column: 4
            font.bold: true
            text: qsTr("Connected since") + translationManager.emptyString
            color: MoneroComponents.Style.dimmedFontColor
        }

        MoneroComponents.TextPlain {
            Layout.row: 0
            Layout.column: 5
            font.bold: true
            text: qsTr("Time connected") + translationManager.emptyString
            color: MoneroComponents.Style.dimmedFontColor
        }

        MoneroComponents.TextPlain {
            Layout.row: 0
            Layout.column: 6
            font.bold: true
            text: qsTr("Sent") + translationManager.emptyString
            color: MoneroComponents.Style.dimmedFontColor
        }

        MoneroComponents.TextPlain {
            Layout.row: 0
            Layout.column: 7
            font.bold: true
            text: qsTr("Received") + translationManager.emptyString
            color: MoneroComponents.Style.dimmedFontColor
        }

        Rectangle {
            Layout.row: 1
            Layout.column: 0
            Layout.columnSpan: 8
            Layout.fillWidth: true
            Layout.topMargin: 2
            Layout.bottomMargin: 2
            height: 1
            color: MoneroComponents.Style.dividerColor
            opacity: MoneroComponents.Style.dividerOpacity
        }

        Repeater {
            model: peersTable.model
            Rectangle {
                Layout.row: index + 2
                Layout.column: 0
                Layout.columnSpan: 8
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: peersTable.hoveredIndex === index ? MoneroComponents.Style.titleBarButtonHoverColor : "transparent"

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: peersTable.hoveredIndex = index
                    onExited: if (peersTable.hoveredIndex === index) peersTable.hoveredIndex = -1
                    onClicked: {
                        clipboard.setText(address);
                        appWindow.showStatusMessage(qsTr("Address copied to clipboard"), 3);
                    }
                }
            }
        }

        Repeater {
            id: peersRepeater
            model: peersTable.model
            MoneroComponents.TextPlain {
                Layout.row: index + 2
                Layout.column: 0
                text: incoming ? qsTr("Inbound") : qsTr("Outbound")
                color: MoneroComponents.Style.defaultFontColor
            }
        }
        Repeater {
            model: peersTable.model
            MoneroComponents.TextPlain {
                Layout.row: index + 2
                Layout.column: 1
                Layout.maximumWidth: 220
                text: address
                elide: Text.ElideMiddle
                color: MoneroComponents.Style.defaultFontColor
            }
        }
        Repeater {
            model: peersTable.model
            MoneroComponents.TextPlain {
                Layout.row: index + 2
                Layout.column: 2
                text: addressType
                color: MoneroComponents.Style.defaultFontColor
            }
        }
        Repeater {
            model: peersTable.model
            MoneroComponents.TextPlain {
                Layout.row: index + 2
                Layout.column: 3
                text: blockHeight
                color: MoneroComponents.Style.defaultFontColor
            }
        }
        Repeater {
            model: peersTable.model
            MoneroComponents.TextPlain {
                Layout.row: index + 2
                Layout.column: 4
                text: Qt.formatDateTime(new Date((Date.now() / 1000 - liveTime) * 1000), "yyyy-MM-dd hh:mm")
                color: MoneroComponents.Style.defaultFontColor
            }
        }
        Repeater {
            model: peersTable.model
            MoneroComponents.TextPlain {
                Layout.row: index + 2
                Layout.column: 5
                text: Utils.ago(Date.now() / 1000 - liveTime)
                color: MoneroComponents.Style.defaultFontColor
            }
        }
        Repeater {
            model: peersTable.model
            MoneroComponents.TextPlain {
                Layout.row: index + 2
                Layout.column: 6
                text: peersTable.formatBytes(sendCount)
                color: MoneroComponents.Style.defaultFontColor
            }
        }
        Repeater {
            model: peersTable.model
            MoneroComponents.TextPlain {
                Layout.row: index + 2
                Layout.column: 7
                text: peersTable.formatBytes(recvCount)
                color: MoneroComponents.Style.defaultFontColor
            }
        }
    }

    MoneroComponents.TextPlain {
        Layout.topMargin: 8
        color: MoneroComponents.Style.dimmedFontColor
        visible: peersRepeater.count === 0 && !peersTable.loading
        text: qsTr("No connected peers") + translationManager.emptyString
    }
}
