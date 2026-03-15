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

Rectangle{
    color: "transparent"
    Layout.fillWidth: true
    property alias nodeHeight: root.height

    /* main layout */
    ColumnLayout {
        id: root
        anchors.margins: 20
        anchors.topMargin: 0

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            color: "transparent"
            visible: !isAndroid

            Rectangle {
                id: localNodeDivider
                Layout.fillWidth: true
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                visible: !persistentSettings.useRemoteNode
                Layout.fillHeight: true
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "darkgrey"
                width: 2
            }

            Rectangle {
                width: parent.width
                height: localNodeHeader.height + localNodeArea.contentHeight
                color: "transparent";
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: localNodeIcon
                    color: "transparent"
                    height: 32
                    width: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    MoneroComponents.Label {
                        fontSize: 32
                        text: FontAwesome.home
                        fontFamily: FontAwesome.fontFamilySolid
                        anchors.centerIn: parent
                        fontColor: MoneroComponents.Style.defaultFontColor
                        styleName: "Solid"
                    }
                }

                MoneroComponents.TextPlain {
                    id: localNodeHeader
                    anchors.left: localNodeIcon.right
                    anchors.leftMargin: 14
                    anchors.top: parent.top
                    color: MoneroComponents.Style.defaultFontColor
                    opacity: MoneroComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("Local node") + translationManager.emptyString
                }

                Text {
                    id: localNodeArea
                    anchors.top: localNodeHeader.bottom
                    anchors.topMargin: 4
                    anchors.left: localNodeIcon.right
                    anchors.leftMargin: 14
                    color: MoneroComponents.Style.dimmedFontColor
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    horizontalAlignment: TextInput.AlignLeft
                    wrapMode: Text.WordWrap;
                    leftPadding: 0
                    topPadding: 0
                    text: qsTr("The blockchain is downloaded to your computer. Provides higher security and requires more local storage.") + translationManager.emptyString
                    width: parent.width - (localNodeIcon.width + localNodeIcon.anchors.leftMargin + anchors.leftMargin)
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                enabled: persistentSettings.useRemoteNode
                onClicked: {
                    persistentSettings.useRemoteNode = false;
                    appWindow.disconnectRemoteNode();
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            color: "transparent"

            Rectangle {
                id: remoteNodeDivider
                Layout.fillWidth: true
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                visible: persistentSettings.useRemoteNode
                Layout.fillHeight: true
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "darkgrey"
                width: 2
            }

            Rectangle {
                width: parent.width
                height: remoteNodeHeader.height + remoteNodeArea.contentHeight
                color: "transparent";
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: remoteNodeIcon
                    color: "transparent"
                    height: 32
                    width: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    MoneroComponents.Label {
                        fontSize: 28
                        text: FontAwesome.cloud
                        fontFamily: FontAwesome.fontFamilySolid
                        styleName: "Solid"
                        anchors.centerIn: parent
                        fontColor: MoneroComponents.Style.defaultFontColor
                    }
                }

                MoneroComponents.TextPlain {
                    id: remoteNodeHeader
                    anchors.left: remoteNodeIcon.right
                    anchors.leftMargin: 14
                    anchors.top: parent.top
                    color: MoneroComponents.Style.defaultFontColor
                    opacity: MoneroComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("Remote node") + translationManager.emptyString
                }

                Text {
                    id: remoteNodeArea
                    anchors.top: remoteNodeHeader.bottom
                    anchors.topMargin: 4
                    anchors.left: remoteNodeIcon.right
                    anchors.leftMargin: 14
                    color: MoneroComponents.Style.dimmedFontColor
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    horizontalAlignment: TextInput.AlignLeft
                    wrapMode: Text.WordWrap;
                    leftPadding: 0
                    topPadding: 0
                    text: qsTr("Uses a third-party server to connect to the Monero network. Less secure, but easier on your computer.") + translationManager.emptyString
                    width: parent.width - (remoteNodeIcon.width + remoteNodeIcon.anchors.leftMargin + anchors.leftMargin)
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    enabled: !persistentSettings.useRemoteNode
                    onClicked: {
                        appWindow.connectRemoteNode();
                    }
                }
            }

            Rectangle {
                id: localNodeBottomDivider
                Layout.fillWidth: true
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }
        }

        MoneroComponents.WarningBox {
            Layout.topMargin: 46
            text: qsTr("To find a remote node, type 'Monero remote node' into your favorite search engine. Please ensure the node is run by a trusted third-party.") + translationManager.emptyString
            visible: persistentSettings.useRemoteNode
        }

        MoneroComponents.RemoteNodeList {
            Layout.fillWidth: true
            Layout.topMargin: 26
            visible: persistentSettings.useRemoteNode
        }

        ColumnLayout {
            id: localNodeLayout
            spacing: 20
            Layout.topMargin: 40
            visible: !persistentSettings.useRemoteNode

            MoneroComponents.StandardButton {
                small: true
                text: (appWindow.daemonRunning ? qsTr("Stop daemon") : qsTr("Start daemon")) + translationManager.emptyString
                onClicked: {
                    if (appWindow.daemonRunning) {
                        appWindow.stopDaemon();
                    } else {
                        persistentSettings.daemonFlags = daemonFlags.text;
                        appWindow.startDaemon(persistentSettings.daemonFlags);
                    }
                }
            }

            RowLayout {
                MoneroComponents.LineEditMulti {
                    id: blockchainFolder
                    Layout.preferredWidth: 200
                    Layout.fillWidth: true
                    fontSize: 15
                    labelFontSize: 14
                    property string style: "<style type='text/css'>a {cursor:pointer;text-decoration: none; color: #FF6C3C}</style>"
                    labelText: qsTr("Blockchain location") + style + " <a href='#'> (%1)</a>".arg(qsTr("Change")) + translationManager.emptyString
                    labelButtonText: qsTr("Reset") + translationManager.emptyString
                    labelButtonVisible: text
                    placeholderText: qsTr("(default)") + translationManager.emptyString
                    placeholderFontSize: 15
                    readOnly: true
                    text: persistentSettings.blockchainDataDir
                    addressValidation: false
                    onInputLabelLinkActivated: {
                        //mouse.accepted = false
                        if(persistentSettings.blockchainDataDir !== ""){
                            blockchainFileDialog.folder = "file://" + persistentSettings.blockchainDataDir;
                        }
                        blockchainFileDialog.open();
                        blockchainFolder.focus = true;
                    }
                    onLabelButtonClicked: persistentSettings.blockchainDataDir = ""
                }
            }

            MoneroComponents.LineEditMulti {
                id: daemonFlags
                Layout.fillWidth: true
                labelFontSize: 14
                fontSize: 15
                wrapMode: Text.WrapAnywhere
                labelText: qsTr("Daemon startup flags") + translationManager.emptyString
                placeholderText: qsTr("(optional)") + translationManager.emptyString
                placeholderFontSize: 15
                text: persistentSettings.daemonFlags
                addressValidation: false
                error: text.match(/(^|\s)--(data-dir|bootstrap-daemon-address|non-interactive)/)
                onEditingFinished: {
                    if (!daemonFlags.error) {
                        persistentSettings.daemonFlags = daemonFlags.text;
                    }
                }
            }

            RowLayout {
                visible: !persistentSettings.useRemoteNode

                ColumnLayout {
                    Layout.fillWidth: true

                    MoneroComponents.RemoteNodeEdit {
                        id: bootstrapNodeEdit
                        Layout.minimumWidth: 100
                        Layout.bottomMargin: 20

                        daemonAddrLabelText: qsTr("Bootstrap Address") + translationManager.emptyString
                        daemonPortLabelText: qsTr("Bootstrap Port") + translationManager.emptyString
                        initialAddress: persistentSettings.bootstrapNodeAddress
                        onEditingFinished: {
                            if (daemonAddrText == "auto") {
                                persistentSettings.bootstrapNodeAddress = daemonAddrText;
                            } else {
                                persistentSettings.bootstrapNodeAddress = daemonAddrText ? bootstrapNodeEdit.getAddress() : "";
                            }
                            console.log("setting bootstrap node to " + persistentSettings.bootstrapNodeAddress)
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: 30
            height: 1
            color: MoneroComponents.Style.dividerColor
            opacity: MoneroComponents.Style.dividerOpacity
        }

        ColumnLayout {
            id: i2pLayout
            Layout.topMargin: 30
            Layout.fillWidth: true
            spacing: 18

            property bool routerRunning: appWindow.i2pSupported && i2pManager.running

            MoneroComponents.TextPlain {
                font.bold: true
                font.pixelSize: 16
                color: MoneroComponents.Style.defaultFontColor
                text: qsTr("I2P connectivity (beta)") + translationManager.emptyString
            }

            MoneroComponents.TextPlain {
                wrapMode: Text.WordWrap
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("Run a bundled I2P router next to the GUI so local nodes can speak to the network without extra shell commands. This mimics how Bisq wraps Tor.") + translationManager.emptyString
            }

            MoneroComponents.CheckBox {
                text: qsTr("Enable built-in I2P router") + translationManager.emptyString
                checked: persistentSettings.i2pEnabled
                enabled: appWindow.i2pSupported
                onClicked: {
                    persistentSettings.i2pEnabled = !persistentSettings.i2pEnabled;
                    if (persistentSettings.i2pEnabled) {
                        appWindow.ensureI2pRouterRunning();
                    } else {
                        appWindow.stopI2pRouterIfNeeded(true);
                    }
                }
            }

            MoneroComponents.TextPlain {
                wrapMode: Text.WordWrap
                color: i2pLayout.routerRunning ? MoneroComponents.Style.goodColor : MoneroComponents.Style.dimmedFontColor
                text: appWindow.i2pSupported
                        ? ((i2pLayout.routerRunning ? qsTr("Status: running") : qsTr("Status: stopped")) + " – " + (i2pStatusMessage || qsTr("waiting")))
                        : qsTr("Status: unavailable (router binary missing)")
                + translationManager.emptyString
            }

            RowLayout {
                spacing: 12

                MoneroComponents.StandardButton {
                    Layout.preferredWidth: 180
                    text: i2pLayout.routerRunning ? qsTr("Stop router") : qsTr("Start router") + translationManager.emptyString
                    enabled: appWindow.i2pSupported && persistentSettings.i2pEnabled && !appWindow.i2pRouterStarting
                    onClicked: {
                        if (!appWindow.i2pSupported) {
                            return;
                        }
                        if (i2pManager.running) {
                            i2pManager.stop();
                        } else {
                            appWindow.ensureI2pRouterRunning();
                        }
                    }
                }

                MoneroComponents.StandardButton {
                    small: true
                    text: qsTr("Open data dir") + translationManager.emptyString
                    enabled: appWindow.i2pSupported
                    onClicked: Qt.openUrlExternally("file://" + appWindow.resolveI2pDataDir())
                }
            }

            MoneroComponents.LineEditMulti {
                Layout.fillWidth: true
                labelText: qsTr("Router data directory") + translationManager.emptyString
                text: persistentSettings.i2pDataDir ? persistentSettings.i2pDataDir : appWindow.resolveI2pDataDir()
                readOnly: true
                labelButtonVisible: true
                labelButtonText: qsTr("Change") + translationManager.emptyString
                onLabelButtonClicked: appWindow.openI2pDataDirDialog()
            }

            RowLayout {
                spacing: 18

                MoneroComponents.LineEdit {
                    Layout.fillWidth: true
                    labelText: qsTr("HTTP proxy port") + translationManager.emptyString
                    text: String(persistentSettings.i2pHttpProxyPort)
                    validator: IntValidator { bottom: 1; top: 65535 }
                    onEditingFinished: {
                        var value = parseInt(text);
                        if (!isNaN(value)) {
                            persistentSettings.i2pHttpProxyPort = value;
                        }
                    }
                }

                MoneroComponents.LineEdit {
                    Layout.fillWidth: true
                    labelText: qsTr("SOCKS proxy port") + translationManager.emptyString
                    text: String(persistentSettings.i2pSocksProxyPort)
                    validator: IntValidator { bottom: 1; top: 65535 }
                    onEditingFinished: {
                        var value = parseInt(text);
                        if (!isNaN(value)) {
                            persistentSettings.i2pSocksProxyPort = value;
                        }
                    }
                }
            }

            MoneroComponents.LineEdit {
                Layout.fillWidth: true
                labelText: qsTr("SAM port") + translationManager.emptyString
                text: String(persistentSettings.i2pSamPort)
                validator: IntValidator { bottom: 1; top: 65535 }
                onEditingFinished: {
                    var value = parseInt(text);
                    if (!isNaN(value)) {
                        persistentSettings.i2pSamPort = value;
                    }
                }
            }

            MoneroComponents.LineEditMulti {
                Layout.fillWidth: true
                labelText: qsTr("Extra router arguments") + translationManager.emptyString
                placeholderText: qsTr("(optional)") + translationManager.emptyString
                text: persistentSettings.i2pExtraArgs
                onEditingFinished: persistentSettings.i2pExtraArgs = text
            }

            MoneroComponents.CheckBox {
                text: qsTr("Start router with GUI") + translationManager.emptyString
                checked: persistentSettings.i2pAutostart
                onClicked: persistentSettings.i2pAutostart = !persistentSettings.i2pAutostart
            }

            MoneroComponents.CheckBox {
                text: qsTr("Stop router when daemon stops") + translationManager.emptyString
                checked: persistentSettings.i2pAutoStopWithDaemon
                onClicked: persistentSettings.i2pAutoStopWithDaemon = !persistentSettings.i2pAutoStopWithDaemon
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 10
                height: 1
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            MoneroComponents.CheckBox {
                text: qsTr("Share this node over I2P (anonymous inbound peers)") + translationManager.emptyString
                checked: persistentSettings.i2pInboundEnabled
                enabled: appWindow.i2pSupported
                onClicked: persistentSettings.i2pInboundEnabled = !persistentSettings.i2pInboundEnabled
            }

            MoneroComponents.TextPlain {
                visible: persistentSettings.i2pInboundEnabled
                wrapMode: Text.WordWrap
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("Use the published .b32.i2p address from your router's server tunnel so other nodes can reach you over I2P. The GUI will pass this data to --anonymous-inbound when the daemon starts.") + translationManager.emptyString
            }

            MoneroComponents.LineEditMulti {
                Layout.fillWidth: true
                enabled: persistentSettings.i2pInboundEnabled
                labelText: qsTr("Published I2P address (.b32 [+ :port])") + translationManager.emptyString
                placeholderText: qsTr("example.b32.i2p or example.b32.i2p:28083") + translationManager.emptyString
                text: persistentSettings.i2pInboundAddress
                onEditingFinished: persistentSettings.i2pInboundAddress = text
            }

            RowLayout {
                spacing: 18
                Layout.fillWidth: true

                MoneroComponents.LineEdit {
                    Layout.fillWidth: true
                    enabled: persistentSettings.i2pInboundEnabled
                    labelText: qsTr("Forward to host") + translationManager.emptyString
                    text: persistentSettings.i2pInboundLocalHost
                    onEditingFinished: persistentSettings.i2pInboundLocalHost = text.length ? text : "127.0.0.1"
                }

                MoneroComponents.LineEdit {
                    Layout.fillWidth: true
                    enabled: persistentSettings.i2pInboundEnabled
                    labelText: qsTr("Forward to port") + translationManager.emptyString
                    text: persistentSettings.i2pInboundLocalPort ? String(persistentSettings.i2pInboundLocalPort) : ""
                    validator: IntValidator { bottom: 1; top: 65535 }
                    onEditingFinished: {
                        var value = parseInt(text);
                        persistentSettings.i2pInboundLocalPort = isNaN(value) ? 0 : value;
                    }
                }
            }

            MoneroComponents.LineEdit {
                Layout.fillWidth: true
                enabled: persistentSettings.i2pInboundEnabled
                labelText: qsTr("Max inbound peers (optional)") + translationManager.emptyString
                text: persistentSettings.i2pInboundMaxConnections ? String(persistentSettings.i2pInboundMaxConnections) : ""
                validator: IntValidator { bottom: 0; top: 999 }
                onEditingFinished: {
                    var value = parseInt(text);
                    persistentSettings.i2pInboundMaxConnections = isNaN(value) ? 0 : value;
                }
            }

            MoneroComponents.LineEditMulti {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                readOnly: true
                wrapMode: Text.Wrap
                copyButton: true
                labelText: qsTr("Recent router log") + translationManager.emptyString
                placeholderText: qsTr("Log output will appear here once the router starts") + translationManager.emptyString
                text: appWindow.getI2pLogText()
            }

            RowLayout {
                spacing: 12
                MoneroComponents.StandardButton {
                    small: true
                    text: qsTr("Clear log") + translationManager.emptyString
                    enabled: appWindow.i2pLogLines.length > 0
                    onClicked: appWindow.clearI2pLogs()
                }
                Item { Layout.fillWidth: true }
            }
        }
    }
}
