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
// 3. Neither the name of the copyright holder nor the names of its contribuproxys may be
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
import QtQuick.Dialogs 1.2

import "../../components" as MoneroComponents
import "../../components/effects" as MoneroEffects

Rectangle{
    color: "transparent"
    Layout.fillWidth: true
    property alias networkHeight: root.height

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

            Rectangle {
                id: proxySettingsDivider
                Layout.fillWidth: true
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                visible: persistentSettings.showProxySettings
                Layout.fillHeight: true
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "darkgrey"
                width: 2
            }

            Rectangle {
                width: parent.width
                height: proxySettingsHeader.height + proxySettingsArea.contentHeight
                color: "transparent";
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: proxySettingsIcon
                    color: "transparent"
                    height: 32
                    width: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    MoneroComponents.Label {
                        fontSize: 28
                        text: FontAwesome.wifi
                        fontFamily: FontAwesome.fontFamilySolid
                        styleName: "Solid"
                        anchors.centerIn: parent
                        fontColor: MoneroComponents.Style.defaultFontColor
                    }
                }

                MoneroComponents.TextPlain {
                    id: proxySettingsHeader
                    anchors.left: proxySettingsIcon.right
                    anchors.leftMargin: 14
                    anchors.top: parent.top
                    color: MoneroComponents.Style.defaultFontColor
                    opacity: MoneroComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("Proxy") + translationManager.emptyString
                }

                Text {
                    id: proxySettingsArea
                    anchors.top: proxySettingsHeader.bottom
                    anchors.topMargin: 4
                    anchors.left: proxySettingsIcon.right
                    anchors.leftMargin: 14
                    color: MoneroComponents.Style.dimmedFontColor
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    horizontalAlignment: TextInput.AlignLeft
                    wrapMode: Text.WordWrap;
                    leftPadding: 0
                    topPadding: 0
                    text: qsTr("Proxy network settings.") + translationManager.emptyString
                    width: parent.width - (proxySettingsIcon.width + proxySettingsIcon.anchors.leftMargin + anchors.leftMargin)
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    enabled: !persistentSettings.showProxySettings
                    onClicked: {
                      persistentSettings.showTorSettings = false;
                      persistentSettings.showI2pSettings = false;
                      persistentSettings.showProxySettings = true;
                    }
                }
            }

            Rectangle {
                id: proxySettingsBottomDivider
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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            color: "transparent"
            visible: !isAndroid

            Rectangle {
                id: i2pSettingsDivider
                Layout.fillWidth: true
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                visible: persistentSettings.showI2pSettings
                Layout.fillHeight: true
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "darkgrey"
                width: 2
            }

            Rectangle {
                width: parent.width
                height: i2pSettingsHeader.height + i2pSettingsArea.contentHeight
                color: "transparent";
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: i2pSettingsIcon
                    color: "transparent"
                    height: 32
                    width: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    MoneroComponents.Label {
                        fontSize: 32
                        text: FontAwesome.mehBlank
                        fontFamily: FontAwesome.fontFamilySolid
                        anchors.centerIn: parent
                        fontColor: MoneroComponents.Style.defaultFontColor
                        styleName: "Solid"
                    }
                }

                MoneroComponents.TextPlain {
                    id: i2pSettingsHeader
                    anchors.left: i2pSettingsIcon.right
                    anchors.leftMargin: 14
                    anchors.top: parent.top
                    color: MoneroComponents.Style.defaultFontColor
                    opacity: MoneroComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("I2P") + translationManager.emptyString
                }

                Text {
                    id: i2pSettingsArea
                    anchors.top: i2pSettingsHeader.bottom
                    anchors.topMargin: 4
                    anchors.left: i2pSettingsIcon.right
                    anchors.leftMargin: 14
                    color: MoneroComponents.Style.dimmedFontColor
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    horizontalAlignment: TextInput.AlignLeft
                    wrapMode: Text.WordWrap;
                    leftPadding: 0
                    topPadding: 0
                    text: qsTr("I2P network settings.") + translationManager.emptyString
                    width: parent.width - (i2pSettingsIcon.width + i2pSettingsIcon.anchors.leftMargin + anchors.leftMargin)
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                enabled: !persistentSettings.showI2pSettings
                onClicked: {
                    persistentSettings.showTorSettings = false;
                    persistentSettings.showProxySettings = false;
                    persistentSettings.showI2pSettings = true;
                }
            }

            Rectangle {
                id: i2pSettingsBottomDivider
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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            color: "transparent"

            Rectangle {
                id: torSettingsDivider
                Layout.fillWidth: true
                anchors.topMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: MoneroComponents.Style.dividerColor
                opacity: MoneroComponents.Style.dividerOpacity
            }

            Rectangle {
                visible: persistentSettings.showTorSettings
                Layout.fillHeight: true
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: "darkgrey"
                width: 2
            }

            Rectangle {
                width: parent.width
                height: torSettingsHeader.height + torSettingsArea.contentHeight
                color: "transparent";
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    id: torSettingsIcon
                    color: "transparent"
                    height: 32
                    width: 32
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter

                    MoneroComponents.Label {
                        fontSize: 28
                        text: FontAwesome.bullseye
                        fontFamily: FontAwesome.fontFamilySolid
                        styleName: "Solid"
                        anchors.centerIn: parent
                        fontColor: MoneroComponents.Style.defaultFontColor
                    }
                }

                MoneroComponents.TextPlain {
                    id: torSettingsHeader
                    anchors.left: torSettingsIcon.right
                    anchors.leftMargin: 14
                    anchors.top: parent.top
                    color: MoneroComponents.Style.defaultFontColor
                    opacity: MoneroComponents.Style.blackTheme ? 1.0 : 0.8
                    font.bold: true
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 16
                    text: qsTr("TOR") + translationManager.emptyString
                }

                Text {
                    id: torSettingsArea
                    anchors.top: torSettingsHeader.bottom
                    anchors.topMargin: 4
                    anchors.left: torSettingsIcon.right
                    anchors.leftMargin: 14
                    color: MoneroComponents.Style.dimmedFontColor
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    horizontalAlignment: TextInput.AlignLeft
                    wrapMode: Text.WordWrap;
                    leftPadding: 0
                    topPadding: 0
                    text: qsTr("TOR network settings.") + translationManager.emptyString
                    width: parent.width - (torSettingsIcon.width + torSettingsIcon.anchors.leftMargin + anchors.leftMargin)
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    enabled: !persistentSettings.showTorSettings
                    onClicked: {
                      persistentSettings.showI2pSettings = false;
                      persistentSettings.showProxySettings = false;
                      persistentSettings.showTorSettings = true;
                    }
                }
            }

            Rectangle {
                id: torSettingsBottomDivider
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
            text: qsTr("The usage of anonymity networks is still considered experimental, there are a few pessimistic cases where privacy is leaked.") + translationManager.emptyString
            visible: persistentSettings.showTorSettings || persistentSettings.showI2pSettings
        }

        ColumnLayout {
            id: proxySettingsLayout
            spacing: 20
            Layout.topMargin: 40
            visible: persistentSettings.showProxySettings
            
            MoneroComponents.CheckBox {
                id: proxyCheckbox
                Layout.topMargin: 6
                enabled: !socksProxyFlagSet && !daemonRunning
                checked: socksProxyFlagSet ? socksProxyFlag : persistentSettings.proxyEnabled
                onClicked: {
                    persistentSettings.proxyEnabled = !persistentSettings.proxyEnabled;
                }
                text: qsTr("Socks5 proxy (%1%2)")
                    .arg(appWindow.walletMode >= 2 ? qsTr("remote node connections, ") : "")
                    .arg(qsTr("updates downloading, fetching price sources")) + translationManager.emptyString
            }

            ListModel {
                 id: proxyType
                 ListElement { column1: "custom"; name: "custom"; }
                 ListElement { column1: "TOR"; name: "TOR"; }
                 ListElement { column1: "I2P"; name: "I2P"; }
            }

            MoneroComponents.StandardDropdown {
                id: proxyTypeDropdown
                dataModel: proxyType
                itemTopMargin: 1
                currentIndex: persistentSettings.proxyType === "TOR" ? 1 : persistentSettings.proxyType === "I2P" ? 2 : 0
                visible: proxyCheckbox.checked
                enabled: !daemonRunning
                onChanged: {
                    persistentSettings.proxyType = proxyTypeDropdown.currentIndex === 1 ? "TOR" : proxyTypeDropdown.currentIndex === 2 ? "I2P" : "custom" ;
                }
                Layout.fillWidth: true
                Layout.preferredWidth: logColumn.width
                z: parent.z + 1
            }

            MoneroComponents.RemoteNodeEdit {
                id: proxyEdit
                enabled: proxyCheckbox.enabled && !daemonRunning
                Layout.leftMargin: 36
                Layout.topMargin: 6
                Layout.minimumWidth: 100
                placeholderFontSize: 15
                visible: proxyCheckbox.checked && persistentSettings.proxyType === "custom"

                daemonAddrLabelText: qsTr("IP address") + translationManager.emptyString
                daemonPortLabelText: qsTr("Port") + translationManager.emptyString

                initialAddress: socksProxyFlagSet ? socksProxyFlag : persistentSettings.proxyAddress
                onEditingFinished: {
                    persistentSettings.proxyAddress = proxyEdit.getAddress();
                }
            }

            MoneroComponents.WarningBox {
                Layout.topMargin: 44
                text: qsTr("Enable %1%2")
                    .arg(persistentSettings.proxyType === "TOR" ? qsTr("TOR ") : qsTr("I2P "))
                    .arg(qsTr("network in order to use socks5 proxy")) + translationManager.emptyString
                visible: persistentSettings.showProxySettings && persistentSettings.proxyEnabled && ((persistentSettings.proxyType === "TOR" && !persistentSettings.torEnabled) || (persistentSettings.proxyType === "I2P" && !persistentSettings.i2pEnabled))
            }
        }

        ColumnLayout {
            id: torSettingsLayout
            spacing: 20
            Layout.topMargin: 40
            visible: persistentSettings.showTorSettings

            MoneroComponents.CheckBox {
                id: torEnabledCheckbox
                Layout.topMargin: 6
                checked: persistentSettings.torEnabled
                visible: persistentSettings.showTorSettings
                enabled: !daemonRunning && torStartStopInProgress == 0
                text: qsTr("Enable TOR") + translationManager.emptyString

                onClicked: {
                    persistentSettings.torEnabled = !persistentSettings.torEnabled;

                    if (!torManager.isInstalled()) {
                        confirmationDialog.title = qsTr("Tor installation") + translationManager.emptyString;
                        confirmationDialog.text  = qsTr("Tor will be installed at %1. Proceed?").arg(applicationDirectory) + translationManager.emptyString;
                        confirmationDialog.icon = StandardIcon.Question;
                        confirmationDialog.cancelText = qsTr("No") + translationManager.emptyString;
                        confirmationDialog.okText = qsTr("Yes") + translationManager.emptyString;
                        confirmationDialog.onAcceptedCallback = function() {
                            torManager.download();
                            torStartStopInProgress = 3;
                            statusMessageText.text = "Downloading Tor...";
                            statusMessage.visible = true
                        }
                        confirmationDialog.onRejectedCallback = function() {
                            persistentSettings.torEnabled = false;
                            torEnabledCheckbox.checked = false;
                        }
                        confirmationDialog.open();
                    }
                    else if (persistentSettings.useRemoteNode) {
                        if (persistentSettings.torEnabled) {
                            startTorDaemon();
                        }
                        else {
                            stopTorDaemon();
                        }
                    }
                }
            }
            
            MoneroComponents.CheckBox {
                id: torAllowIncomingConnectionsCheckbox
                Layout.topMargin: 6
                checked: persistentSettings.torAllowIncomingConnections
                visible: persistentSettings.showTorSettings && persistentSettings.torEnabled && !persistentSettings.useRemoteNode
                enabled: !daemonRunning && torStartStopInProgress == 0
                text: qsTr("Allow incoming connections") + translationManager.emptyString

                onClicked: {
                    persistentSettings.torAllowIncomingConnections = !persistentSettings.torAllowIncomingConnections;
                }
            }
        }

        ColumnLayout {
            id: i2pSettingsLayout
            spacing: 20
            Layout.topMargin: 40
            visible: persistentSettings.showI2pSettings
            
            MoneroComponents.CheckBox {
                id: i2pEnabledCheckbox
                Layout.topMargin: 6
                checked: persistentSettings.i2pEnabled
                visible: persistentSettings.showI2pSettings
                enabled: !daemonRunning
                text: qsTr("Enable I2P") + translationManager.emptyString

                onClicked: {
                    persistentSettings.i2pEnabled = !persistentSettings.i2pEnabled;

                    if (persistentSettings.useRemoteNode) {
                        if (persistentSettings.i2pEnabled) {
                            startI2PDaemon();
                        }
                        else {
                            stopI2PDaemon();
                        }
                    }
                }
            }
            
            MoneroComponents.CheckBox {
                id: i2pAllowIncomingConnectionsCheckbox
                Layout.topMargin: 6
                checked: persistentSettings.i2pAllowIncomingConnections
                visible: persistentSettings.showI2pSettings && persistentSettings.i2pEnabled && !persistentSettings.useRemoteNode
                enabled: !daemonRunning
                text: qsTr("Allow incoming connections") + translationManager.emptyString

                onClicked: {
                    persistentSettings.i2pAllowIncomingConnections = !persistentSettings.i2pAllowIncomingConnections;
                }
            }

            MoneroComponents.CheckBox {
                id: i2pOutproxyCheckbox
                Layout.topMargin: 6
                checked: persistentSettings.i2pOutproxyEnabled
                visible: persistentSettings.showI2pSettings && persistentSettings.i2pEnabled
                enabled: !daemonRunning

                onClicked: {
                    persistentSettings.i2pOutproxyEnabled = !persistentSettings.i2pOutproxyEnabled;
                
                    if (persistentSettings.useRemoteNode) {
                        stopI2PDaemon();
                        startI2PDaemon();
                    }
                }
                text: qsTr("Enable outproxy (%1%2)")
                    .arg(appWindow.walletMode >= 2 ? qsTr("remote node connections, ") : "")
                    .arg(qsTr("updates downloading, fetching price sources")) + translationManager.emptyString
            }

            MoneroComponents.CheckBox {
                id: i2pTorAsOutproxyCheckbox
                Layout.topMargin: 6
                checked: persistentSettings.i2pTorAsOutproxy
                visible: persistentSettings.showI2pSettings && persistentSettings.i2pEnabled && persistentSettings.i2pOutproxyEnabled && persistentSettings.torEnabled
                enabled: !daemonRunning
                onClicked: {
                    persistentSettings.i2pTorAsOutproxy = !persistentSettings.i2pTorAsOutproxy;
                    
                    if (persistentSettings.useRemoteNode) {
                        stopI2PDaemon();
                        startI2PDaemon();
                    }
                }
                text: qsTr("Use Tor as outproxy") + translationManager.emptyString
            }

            RowLayout {
                visible: persistentSettings.showI2pSettings && persistentSettings.i2pEnabled && persistentSettings.i2pOutproxyEnabled && !(persistentSettings.i2pTorAsOutproxy && persistentSettings.torEnabled)

                ColumnLayout {
                    Layout.fillWidth: true

                    MoneroComponents.RemoteNodeEdit {
                        id: i2pOutproxyEdit
                        Layout.minimumWidth: 100
                        Layout.bottomMargin: 20
                        enabled: !daemonRunning

                        daemonAddrLabelText: qsTr("Outproxy") + translationManager.emptyString
                        daemonPortLabelText: qsTr("Outproxy Port") + translationManager.emptyString
                        initialAddress: persistentSettings.i2pOutproxy + ":" + persistentSettings.i2pOutproxyPort
                        onEditingFinished: {
                            if (i2pOutproxyEdit.isValid()) {
                                persistentSettings.i2pOutproxy = i2pOutproxyEdit.daemonAddr.text.trim();
                                persistentSettings.i2pOutproxyPort = parseInt(i2pOutproxyEdit.daemonPort.text.trim());                                
                                console.log("setting i2p outproxy node to " + i2pOutproxyEdit.getAddress())
                            }
                            else {
                                persistentSettings.i2pOutproxy = "";
                                persistentSettings.i2pOutproxyPort = 0;
                            }
                        }
                    }
                }
            }
        }
    }

    function torDownloadFailed(errorCode) {
        torStartStopInProgress = 0;
        statusMessage.visible = false
        persistentSettings.torEnabled = false
        errorPopup.title = qsTr("Tor Installation Failed") + translationManager.emptyString;
        switch (errorCode) {
            case TorManager.HashVerificationFailed:
                errorPopup.text = qsTr("Hash verification failed.") + translationManager.emptyString;
                break;
            case TorManager.BinaryNotAvailable:
                errorPopup.text = qsTr("Tor download is not available.") + translationManager.emptyString;
                break;
            case TorManager.ConnectionIssue:
                errorPopup.text = qsTr("Tor download failed due to a connection issue.") + translationManager.emptyString;
                break;
            case TorManager.InstallationFailed:
                errorPopup.text = qsTr("Tor installation failed.") + (isWindows ? (" " + qsTr("Try starting the program with administrator privileges.")) : "")
                break;
            default:
                errorPopup.text = qsTr("Unknown error.") + translationManager.emptyString;
        }
        errorPopup.icon = StandardIcon.Critical
        errorPopup.open()
    }

    function torDownloadSucceeded() {
        torStartStopInProgress = 0;
        torVersion = torManager.getVersion();
        statusMessage.visible = false
        informationPopup.title  = qsTr("Tor Installation Succeeded") + translationManager.emptyString;
        informationPopup.text = persistentSettings.useRemoteNode ? qsTr("Tor has successfully installed.") : qsTr("Tor has successfully installed. Daemon will start now.");
        informationPopup.icon = StandardIcon.Critical
        informationPopup.open()

        persistentSettings.daemonFlags = daemonFlags.text;
        if (!persistentSettings.useRemoteNode) appWindow.startDaemon(persistentSettings.daemonFlags);
        else if (persistentSettings.torEnabled) startTorDaemon();
    }

    Component.onCompleted: {
        torManager.torDownloadFailure.connect(torDownloadFailed);
        torManager.torDownloadSuccess.connect(torDownloadSucceeded);
    }
}

