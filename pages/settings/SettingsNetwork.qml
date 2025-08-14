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

        MoneroComponents.TextPlain {
            Layout.bottomMargin: 2
            color: MoneroComponents.Style.defaultFontColor
            font.pixelSize: 18
            font.family: MoneroComponents.Style.fontRegular.name
            text: qsTr("Proxy") + translationManager.emptyString
        }

        ColumnLayout {
            id: proxySettingsLayout
            spacing: 20

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
                enabled: !daemonRunning
                Layout.topMargin: 6
                onChanged: {
                    persistentSettings.proxyType = proxyTypeDropdown.currentIndex === 1 ? "TOR" : proxyTypeDropdown.currentIndex === 2 ? "I2P" : "custom" ;
                    walletManager.proxyAddress = persistentSettings.getWalletProxyAddress();
                }
                Layout.fillWidth: true
                Layout.preferredWidth: logColumn.width
                z: parent.z + 1
            }

            MoneroComponents.RemoteNodeEdit {
                id: proxyEdit
                enabled: !daemonRunning
                Layout.leftMargin: 36
                Layout.topMargin: 6
                Layout.minimumWidth: 100
                placeholderFontSize: 15
                visible: persistentSettings.proxyType === "custom"

                daemonAddrLabelText: qsTr("IP address") + translationManager.emptyString
                daemonPortLabelText: qsTr("Port") + translationManager.emptyString

                initialAddress: socksProxyFlagSet ? socksProxyFlag : persistentSettings.proxyAddress
                onEditingFinished: {
                    persistentSettings.proxyAddress = proxyEdit.getAddress();
                    walletManager.proxyAddress = persistentSettings.getWalletProxyAddress();
                }
            }

            MoneroComponents.WarningBox {
                Layout.topMargin: 10
                text: qsTr("The usage of anonymity networks is still considered experimental, there are a few pessimistic cases where privacy is leaked.") + translationManager.emptyString
                visible: persistentSettings.proxyType === "TOR" || persistentSettings.proxyType === "I2P"
            }
        }
    }

    function torDownloadFailed(errorCode) {
        torStartStopInProgress = 0;
        statusMessage.visible = false
        
        persistentSettings.proxyType = "custom"
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

        if (daemonFlags && daemonFlags.text) {
            persistentSettings.daemonFlags = daemonFlags.text;
            if (!persistentSettings.useRemoteNode) appWindow.startDaemon(persistentSettings.daemonFlags);
            else if (persistentSettings.proxyType === "TOR") startTorDaemon();
        }
    }

    Component.onCompleted: {
        torManager.torDownloadFailure.connect(torDownloadFailed);
        torManager.torDownloadSuccess.connect(torDownloadSucceeded);
    }
}

