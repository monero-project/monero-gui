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
import FontAwesome 1.0

import "../../components" as MoneroComponents
import "../../components/effects" as MoneroEffects
import moneroComponents.I2PManager 1.0

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias i2pHeight: root.height

    /* main layout */
    ColumnLayout {
        id: root
        anchors.margins: 20
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 20

        // I2P Router Section Header
        MoneroComponents.Label {
            Layout.topMargin: 20
            fontSize: 18
            text: qsTr("I2P Router") + translationManager.emptyString
        }

        MoneroComponents.WarningBox {
            Layout.fillWidth: true
            text: qsTr("I2P provides anonymous routing for Monero transactions. Enable this to enhance your privacy by routing transactions through the I2P network.") + translationManager.emptyString
        }

        // Enable I2P Checkbox
        MoneroComponents.CheckBox {
            id: enableI2PCheckbox
            Layout.fillWidth: true
            checked: persistentSettings.useI2P
            text: qsTr("Enable I2P Router") + translationManager.emptyString
            onClicked: {
                persistentSettings.useI2P = checked
                if (!checked && i2pManager.running) {
                    i2pManager.stop()
                }
            }
        }

        // Status Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: enableI2PCheckbox.checked

            MoneroComponents.Label {
                fontSize: 16
                text: qsTr("Status") + translationManager.emptyString
            }

            // Installation Status
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                MoneroComponents.Label {
                    text: qsTr("Installation:") + translationManager.emptyString
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }

                MoneroComponents.Label {
                    text: i2pManager.installed ? qsTr("Installed") : qsTr("Not installed")
                    fontSize: 14
                    color: i2pManager.installed ? "green" : "red"
                }
            }

            // Router Status
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: i2pManager.installed

                MoneroComponents.Label {
                    text: qsTr("Router Status:") + translationManager.emptyString
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }

                MoneroComponents.Label {
                    text: {
                        switch(i2pManager.status) {
                            case I2PManager.Starting: return qsTr("Starting...")
                            case I2PManager.Running: return qsTr("Running")
                            case I2PManager.Stopping: return qsTr("Stopping...")
                            case I2PManager.Stopped: return qsTr("Stopped")
                            case I2PManager.Error: return qsTr("Error")
                            default: return qsTr("Unknown")
                        }
                    }
                    fontSize: 14
                    color: i2pManager.running ? "green" : MoneroComponents.Style.defaultFontColor
                }
            }

            // Version
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: i2pManager.installed

                MoneroComponents.Label {
                    text: qsTr("Version:") + translationManager.emptyString
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }

                MoneroComponents.Label {
                    text: i2pManager.version
                    fontSize: 14
                }
            }

            // Network Statistics
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: i2pManager.running

                MoneroComponents.Label {
                    fontSize: 15
                    text: qsTr("Network Statistics") + translationManager.emptyString
                    color: MoneroComponents.Style.accentColor
                }

                // Health Status
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        MoneroComponents.Label {
                            text: qsTr("Network Health:") + translationManager.emptyString
                            fontSize: 13
                            color: MoneroComponents.Style.dimmedFontColor
                        }

                        RowLayout {
                            spacing: 10

                            Rectangle {
                                width: 12
                                height: 12
                                radius: 6
                                color: {
                                    switch(i2pManager.networkHealth) {
                                        case "Good": return "#4CAF50"
                                        case "Fair": return "#FFC107"
                                        case "Poor": return "#FF5722"
                                        default: return "#9E9E9E"
                                    }
                                }
                            }

                            MoneroComponents.Label {
                                text: i2pManager.networkHealth
                                fontSize: 13
                                color: {
                                    switch(i2pManager.networkHealth) {
                                        case "Good": return "#4CAF50"
                                        case "Fair": return "#FFC107"
                                        case "Poor": return "#FF5722"
                                        default: return MoneroComponents.Style.dimmedFontColor
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        MoneroComponents.Label {
                            text: qsTr("Inbound Peers:") + translationManager.emptyString
                            fontSize: 13
                            color: MoneroComponents.Style.dimmedFontColor
                        }

                        MoneroComponents.Label {
                            text: i2pManager.inboundPeers.toString()
                            fontSize: 13
                            color: MoneroComponents.Style.defaultFontColor
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        MoneroComponents.Label {
                            text: qsTr("Outbound Peers:") + translationManager.emptyString
                            fontSize: 13
                            color: MoneroComponents.Style.dimmedFontColor
                        }

                        MoneroComponents.Label {
                            text: i2pManager.outboundPeers.toString()
                            fontSize: 13
                            color: MoneroComponents.Style.defaultFontColor
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        MoneroComponents.Label {
                            text: qsTr("Active Tunnels:") + translationManager.emptyString
                            fontSize: 13
                            color: MoneroComponents.Style.dimmedFontColor
                        }

                        MoneroComponents.Label {
                            text: i2pManager.activeTunnels.toString()
                            fontSize: 13
                            color: MoneroComponents.Style.defaultFontColor
                        }
                    }
                }
            }

            // I2P Address
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                visible: i2pManager.running && i2pManager.i2pAddress !== ""

                MoneroComponents.Label {
                    text: qsTr("I2P Address:") + translationManager.emptyString
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }

                MoneroComponents.Label {
                    text: i2pManager.i2pAddress
                    fontSize: 11
                    Layout.fillWidth: true
                    elide: Text.ElideMiddle
                }

                MoneroComponents.StandardButton {
                    text: qsTr("Copy") + translationManager.emptyString
                    small: true
                    onClicked: {
                        clipboard.setText(i2pManager.i2pAddress)
                        appWindow.showStatusMessage(qsTr("I2P address copied to clipboard"), 3)
                    }
                }
            }
        }

        // Download Section
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: enableI2PCheckbox.checked && !i2pManager.installed

            MoneroComponents.Label {
                fontSize: 16
                text: qsTr("Download i2pd") + translationManager.emptyString
            }

            MoneroComponents.TextPlain {
                Layout.fillWidth: true
                text: qsTr("i2pd (I2P daemon) needs to be downloaded before you can use I2P routing. The binary will be downloaded from the official i2pd GitHub releases.") + translationManager.emptyString
                wrapMode: Text.Wrap
                font.pixelSize: 14
                color: MoneroComponents.Style.dimmedFontColor
            }

            MoneroComponents.StandardButton {
                text: qsTr("Download i2pd") + translationManager.emptyString
                enabled: !i2pManager.downloading
                onClicked: {
                    i2pManager.download()
                }
            }

            // Download progress
            ColumnLayout {
                Layout.fillWidth: true
                visible: i2pManager.downloading
                spacing: 5

                MoneroComponents.ProgressBar {
                    Layout.fillWidth: true
                    value: i2pManager.downloadProgress
                }

                MoneroComponents.Label {
                    text: qsTr("Downloading... %1%").arg(Math.round(i2pManager.downloadProgress * 100))
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }
            }
        }

        // Control Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            visible: enableI2PCheckbox.checked && i2pManager.installed

            MoneroComponents.StandardButton {
                text: qsTr("Start") + translationManager.emptyString
                enabled: !i2pManager.running && i2pManager.status !== I2PManager.Starting
                onClicked: {
                    i2pManager.start()
                }
            }

            MoneroComponents.StandardButton {
                text: qsTr("Stop") + translationManager.emptyString
                enabled: i2pManager.running || i2pManager.status === I2PManager.Starting
                onClicked: {
                    i2pManager.stop()
                }
            }

            MoneroComponents.StandardButton {
                text: qsTr("Test Connection") + translationManager.emptyString
                enabled: i2pManager.running
                onClicked: {
                    if (i2pManager.testConnection()) {
                        appWindow.showStatusMessage(qsTr("I2P connection test successful"), 3)
                    } else {
                        appWindow.showStatusMessage(qsTr("I2P connection test failed"), 3)
                    }
                }
            }
        }

        // Monerod I2P Integration Status
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: enableI2PCheckbox.checked && i2pManager.installed

            MoneroComponents.Label {
                fontSize: 16
                text: qsTr("Monerod Integration") + translationManager.emptyString
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    color: {
                        if (i2pManager.isProxyReady()) {
                            return "#4CAF50"  // Green
                        } else {
                            return MoneroComponents.Style.dimmedFontColor
                        }
                    }
                }

                MoneroComponents.Label {
                    text: i2pManager.isProxyReady() ? 
                        qsTr("I2P proxy ready - monerod will use I2P for anonymity") :
                        qsTr("I2P proxy not ready - start I2P router to enable")
                    fontSize: 13
                    color: MoneroComponents.Style.defaultFontColor
                    Layout.fillWidth: true
                }
            }

            MoneroComponents.TextPlain {
                Layout.fillWidth: true
                text: {
                    if (i2pManager.isProxyReady()) {
                        return qsTr("When you start monerod, it will automatically use I2P routing. Your connection to Monero nodes will be routed through the I2P network for enhanced privacy.") + translationManager.emptyString
                    } else {
                        return qsTr("Start the I2P router above to enable I2P integration with monerod. Once running, all monerod connections will be routed through I2P automatically.") + translationManager.emptyString
                    }
                }
                wrapMode: Text.Wrap
                font.pixelSize: 12
                color: MoneroComponents.Style.dimmedFontColor
            }
        }

        // I2P Node Configuration
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: enableI2PCheckbox.checked && i2pManager.installed

            MoneroComponents.Label {
                fontSize: 16
                text: qsTr("I2P Node Configuration") + translationManager.emptyString
            }

            MoneroComponents.WarningBox {
                Layout.fillWidth: true
                text: qsTr("To use I2P with Monero, you need to connect to a Monero node that has an I2P address. Enter the node's I2P address below (e.g., example.b32.i2p:18081)") + translationManager.emptyString
            }

            MoneroComponents.LineEdit {
                id: i2pNodeAddress
                Layout.fillWidth: true
                labelText: qsTr("I2P Node Address") + translationManager.emptyString
                placeholderText: qsTr("e.g., node.b32.i2p:18081") + translationManager.emptyString
                text: persistentSettings.i2pNodeAddress
                onEditingFinished: {
                    persistentSettings.i2pNodeAddress = text
                }
            }

            MoneroComponents.TextPlain {
                Layout.fillWidth: true
                text: qsTr("Note: Finding I2P-enabled Monero nodes requires manual configuration. There is currently no automatic discovery mechanism.") + translationManager.emptyString
                wrapMode: Text.Wrap
                font.pixelSize: 12
                color: MoneroComponents.Style.dimmedFontColor
            }
        }

        // Advanced Settings
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10
            visible: enableI2PCheckbox.checked && i2pManager.installed

            MoneroComponents.Label {
                fontSize: 16
                text: qsTr("Advanced Settings") + translationManager.emptyString
            }

            // Auto-start option with explanation
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                MoneroComponents.CheckBox {
                    id: autoStartI2PCheckbox
                    Layout.fillWidth: true
                    checked: i2pManager.isAutoStartEnabled()
                    text: qsTr("Auto-start I2P router when wallet opens") + translationManager.emptyString
                    onClicked: {
                        i2pManager.setAutoStart(checked)
                    }
                }

                MoneroComponents.TextPlain {
                    Layout.fillWidth: true
                    visible: autoStartI2PCheckbox.checked
                    text: qsTr("i2pd will automatically start when the wallet launches if this is enabled.") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    font.pixelSize: 12
                    color: MoneroComponents.Style.dimmedFontColor
                }
            }

            // Log level setting
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                MoneroComponents.Label {
                    text: qsTr("Log Level:") + translationManager.emptyString
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }

                MoneroComponents.StandardDropdown {
                    id: logLevelDropdown
                    Layout.fillWidth: true
                    currentIndex: 1 // Default to "Info"
                    model: [
                        qsTr("Debug") + translationManager.emptyString,
                        qsTr("Info") + translationManager.emptyString,
                        qsTr("Warning") + translationManager.emptyString,
                        qsTr("Error") + translationManager.emptyString
                    ]
                    onCurrentIndexChanged: {
                        // TODO: Apply log level to i2pd.conf
                    }
                }
            }

            // Port configuration
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                MoneroComponents.Label {
                    text: qsTr("SOCKS Proxy Port:") + translationManager.emptyString
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }

                MoneroComponents.LineEdit {
                    id: socksPortEdit
                    Layout.fillWidth: true
                    text: "4447"
                    placeholderText: "4447"
                    validator: IntValidator { bottom: 1024; top: 65535 }
                    onEditingFinished: {
                        // TODO: Apply port to i2pd.conf
                    }
                }

                MoneroComponents.Label {
                    text: qsTr("SAM Bridge Port:") + translationManager.emptyString
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }

                MoneroComponents.Label {
                    text: "7656"
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }
            }

            // Data directory
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                MoneroComponents.Label {
                    text: qsTr("Data Directory:") + translationManager.emptyString
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }

                MoneroComponents.TextPlain {
                    Layout.fillWidth: true
                    text: i2pManager.dataDir
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    color: MoneroComponents.Style.dimmedFontColor
                    selectByMouse: true
                }
            }

            // Bandwidth limits
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5

                MoneroComponents.Label {
                    text: qsTr("Bandwidth Limits (KB/s):") + translationManager.emptyString
                    fontSize: 14
                    color: MoneroComponents.Style.dimmedFontColor
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    ColumnLayout {
                        Layout.fillWidth: true

                        MoneroComponents.Label {
                            text: qsTr("Inbound:") + translationManager.emptyString
                            fontSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                        }

                        MoneroComponents.LineEdit {
                            id: inboundBandwidth
                            Layout.fillWidth: true
                            text: "128"
                            placeholderText: "128"
                            validator: IntValidator { bottom: 0; top: 999999 }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true

                        MoneroComponents.Label {
                            text: qsTr("Outbound:") + translationManager.emptyString
                            fontSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                        }

                        MoneroComponents.LineEdit {
                            id: outboundBandwidth
                            Layout.fillWidth: true
                            text: "128"
                            placeholderText: "128"
                            validator: IntValidator { bottom: 0; top: 999999 }
                        }
                    }
                }

                MoneroComponents.TextPlain {
                    Layout.fillWidth: true
                    text: qsTr("Leave at 0 for unlimited bandwidth. Values are in kilobytes per second.") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    font.pixelSize: 11
                    color: MoneroComponents.Style.dimmedFontColor
                }
            }
        }

        // Error Messages
        MoneroComponents.WarningBox {
            Layout.fillWidth: true
            visible: i2pManager.lastError !== ""
            text: i2pManager.lastError
            icon: MoneroComponents.Style.errorIcon
        }

        // Spacer
        Item {
            Layout.fillHeight: true
        }
    }

    // Signal handlers
    Connections {
        target: i2pManager

        function onStarted() {
            appWindow.showStatusMessage(qsTr("I2P router started successfully"), 3)
        }

        function onStopped() {
            appWindow.showStatusMessage(qsTr("I2P router stopped"), 3)
        }

        function onErrorOccurred(error) {
            appWindow.showStatusMessage(qsTr("I2P error: %1").arg(error), 5)
        }

        function onDownloadFinished(success) {
            if (success) {
                appWindow.showStatusMessage(qsTr("i2pd downloaded successfully"), 3)
            } else {
                appWindow.showStatusMessage(qsTr("Failed to download i2pd"), 5)
            }
        }
    }

    // Auto-start I2P if enabled
    Component.onCompleted: {
        if (persistentSettings.useI2P && persistentSettings.autoStartI2P && i2pManager.installed && !i2pManager.running) {
            i2pManager.start()
        }
    }
}
