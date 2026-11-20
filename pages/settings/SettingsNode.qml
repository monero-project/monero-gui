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

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import FontAwesome

import "../../components" as MoneroComponents
import "../../components/effects" as MoneroEffects

Rectangle{
    color: "transparent"
    Layout.fillWidth: true
    enabled: !appWindow.currentWallet || !appWindow.currentWallet.initializing
    property alias nodeHeight: root.height
    readonly property string customI2PSam: appWindow.i2pSamFlagValue(persistentSettings.daemonFlags)
    readonly property bool i2pAcceptsInbound: customI2PSam
        ? appWindow.i2pSamValueAcceptsInbound(customI2PSam)
        : appWindow.persistentSettings.i2pAcceptInbound
    readonly property bool i2pRouterIsRemote: {
        var host = customI2PSam ? appWindow.i2pSamValueHost(customI2PSam) : i2pRouterAddress.text;
        return walletManager.i2pSamEndpoint(host, "1") !== "" && !walletManager.i2pSamHostIsLoopback(host);
    }

    function i2pFieldsValid() {
        return walletManager.i2pSamEndpoint(i2pRouterAddress.text, i2pSamPort.text) !== "";
    }

    function commitI2PSettings() {
        if (appWindow.persistentSettings.anonymityNetworkType !== 1)
            return true;
        if (!i2pFieldsValid())
            return false;
        appWindow.persistentSettings.i2pRouterAddress = i2pRouterAddress.text.trim();
        appWindow.persistentSettings.i2pSamPort = i2pSamPort.text.trim();
        return true;
    }

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
                        // Commit fields that may still be focused, since editingFinished hasn't fired yet
                        persistentSettings.daemonFlags = daemonFlags.text;
                        if (!commitI2PSettings())
                            return;
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
                            blockchainFileDialog.currentFolder = "file://" + persistentSettings.blockchainDataDir;
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

            Timer {
                id: i2pStatusTimer
                property bool probeInFlight: false
                interval: 5000
                // Only poll while the I2P settings are on screen for a local node
                running: i2pSettings.visible && !customI2PSam
                repeat: true
                triggeredOnStart: true
                onRunningChanged: if (running) i2pStatus.state = "checking"
                onTriggered: {
                    if (probeInFlight)
                        return;
                    var host = appWindow.persistentSettings.i2pRouterAddress;
                    var port = appWindow.persistentSettings.i2pSamPort;
                    if (!walletManager.i2pSamEndpoint(host, port)) {
                        i2pStatus.state = "invalid";
                        return;
                    }
                    probeInFlight = true;
                    walletManager.checkI2PSamAsync(host, port, function(reachable) {
                        probeInFlight = false;
                        i2pStatus.state = reachable ? "online" : "offline";
                    });
                }
            }

            MoneroComponents.Label {
                id: soloTitleLabel
                fontSize: 18
                text: qsTr("Anonymity network") + translationManager.emptyString
            }

            ColumnLayout {
                spacing: 20
                Layout.fillWidth: true
                id: networkColumn
                z: parent.z + 1

                MoneroComponents.StandardDropdown {
                    id: anonymityNetworkDropdown
                    Layout.maximumWidth: 200
                    dataModel: anonymityNetworkModel
                    currentIndex: appWindow.persistentSettings.anonymityNetworkType
                    enabled: !customI2PSam
                    onChanged: {
                        appWindow.persistentSettings.anonymityNetworkType = currentIndex;
                    }
                }

                MoneroComponents.TextPlain {
                    visible: customI2PSam !== ""
                    text: qsTr("I2P is configured by the --i2p-sam startup flag (%1), which overrides the settings on this page.").arg(customI2PSam) + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 14
                    color: "#fa6800"
                }

                ColumnLayout {
                    id: i2pSettings
                    spacing: 20
                    Layout.fillWidth: true
                    visible: appWindow.persistentSettings.anonymityNetworkType === 1 || customI2PSam !== ""

                    MoneroComponents.TextPlain {
                        id: soloMainLabel
                        text: qsTr("Configure your I2P connection settings. Most users should stick to the default settings.") + translationManager.emptyString
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 14
                        color: MoneroComponents.Style.defaultFontColor
                    }

                    RowLayout {
                        spacing: 32
                        Layout.fillWidth: true
                        visible: !customI2PSam

                        MoneroComponents.LineEdit {
                            id: i2pRouterAddress
                            Layout.fillWidth: true
                            Layout.preferredWidth: 300
                            labelFontSize: 14
                            labelText: qsTr("Router address") + translationManager.emptyString
                            text: appWindow.persistentSettings.i2pRouterAddress || "127.0.0.1"
                            placeholderText: "127.0.0.1"
                            placeholderFontSize: 14
                            fontSize: 14
                            error: !i2pFieldsValid()
                            onEditingFinished: commitI2PSettings()
                        }

                        MoneroComponents.LineEdit {
                            id: i2pSamPort
                            Layout.fillWidth: true
                            Layout.preferredWidth: 100
                            labelFontSize: 14
                            labelText: qsTr("SAM port") + translationManager.emptyString
                            text: appWindow.persistentSettings.i2pSamPort || "7656"
                            placeholderText: "7656"
                            placeholderFontSize: 14
                            fontSize: 14
                            error: !i2pFieldsValid()
                            onEditingFinished: commitI2PSettings()
                        }
                    }

                    MoneroComponents.CheckBox {
                        id: i2pAcceptInboundCheckBox
                        // Keep the checked binding
                        toggleOnClick: false
                        checked: i2pAcceptsInbound
                        enabled: !customI2PSam
                        onClicked: appWindow.persistentSettings.i2pAcceptInbound = !appWindow.persistentSettings.i2pAcceptInbound
                        text: qsTr("Accept inbound I2P connections") + translationManager.emptyString
                    }

                    MoneroComponents.TextPlain {
                        text: (i2pAcceptsInbound
                            ? qsTr("Your node will create a persistent I2P address, store its key in the blockchain data directory, and announce it to other nodes. ")
                            : "")
                            + qsTr("Only transactions are relayed over I2P; the blockchain is still downloaded over the public network.") + translationManager.emptyString
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 14
                        color: MoneroComponents.Style.dimmedFontColor
                    }

                    MoneroComponents.TextPlain {
                        visible: i2pRouterIsRemote
                        text: qsTr("The provided router address is not on this computer, so your connection to it will be unencrypted. Only use a router you trust, over a secure channel such as an SSH tunnel or VPN.")
                            + (i2pAcceptsInbound
                                ? qsTr(" With inbound connections enabled, the node also sends its private I2P key to the router.")
                                : "")
                            + translationManager.emptyString
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 14
                        color: MoneroComponents.Style.errorColor
                    }

                    Text {
                        id: i2pStatus
                        visible: !customI2PSam
                        state: "checking"
                        property string color: "#fa6800"
                        property string label: qsTr("Checking router status...")
                        textFormat: Text.RichText
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 14
                        text: "<span style='color: " + color + ";'>" + label + "</span>" + translationManager.emptyString
                        states: [
                            State {
                                name: "online"
                                PropertyChanges { target: i2pStatus; color: MoneroComponents.Style.blackTheme ? "lime" : "green"; label: qsTr("Router is online") }
                            }, State {
                                name: "offline"
                                PropertyChanges { target: i2pStatus; color: MoneroComponents.Style.errorColor; label: qsTr("Router is offline") }
                            }, State {
                                name: "invalid"
                                PropertyChanges { target: i2pStatus; color: MoneroComponents.Style.errorColor; label: qsTr("Invalid router address or SAM port") }
                            }
                        ]
                    }
                }

                MoneroComponents.TextPlain {
                    visible: appWindow.i2pRestartPending()
                    text: qsTr("Restart the daemon to apply the anonymity network settings. Until then, the running daemon keeps its previous settings.") + translationManager.emptyString
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 14
                    color: "#fa6800"
                }
            }

            ListModel {
                id: anonymityNetworkModel
                ListElement {
                    column1: "None"
                }
                ListElement {
                    column1: "I2P"
                }
            }
        }
    }
}

