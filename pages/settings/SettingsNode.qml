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

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import FontAwesome 1.0

import "../../components" as MoneroComponents
import "../../components/effects" as MoneroEffects

Rectangle{
    color: "transparent"
    height: 1400
    Layout.fillWidth: true

    /* main layout */
    ColumnLayout {
        id: root
        anchors.margins: 20
        anchors.topMargin: 0

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 0
        property int labelWidth: 120
        property int editWidth: 400
        property int lineEditFontSize: 14
        property int buttonWidth: 110

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            color: "transparent"

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
                color: MoneroComponents.Style.blackTheme ? "white" : "darkgrey"
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

                    // @TODO: Legacy. Remove after Qt 5.8.
                    // https://stackoverflow.com/questions/41990013
                    MouseArea {
                        anchors.fill: parent
                        enabled: false
                    }
                }   
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
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
                color: MoneroComponents.Style.blackTheme ? "white" : "darkgrey"
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

                    // @TODO: Legacy. Remove after Qt 5.8.
                    // https://stackoverflow.com/questions/41990013
                    MouseArea {
                        anchors.fill: parent
                        enabled: false
                    }
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
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

        ColumnLayout {
            id: remoteNodeLayout
            anchors.margins: 0
            spacing: 20
            Layout.fillWidth: true
            Layout.topMargin: 20
            visible: persistentSettings.useRemoteNode

            MoneroComponents.WarningBox {
                Layout.topMargin: 26
                Layout.bottomMargin: 6
                text: qsTr("To find a remote node, type 'Monero remote node' into your favorite search engine. Please ensure the node is run by a trusted third-party.") + translationManager.emptyString
            }

            MoneroComponents.RemoteNodeEdit {
                id: remoteNodeEdit
                Layout.minimumWidth: 100
                placeholderFontSize: 15

                daemonAddrLabelText: qsTr("Address")
                daemonPortLabelText: qsTr("Port")

                property var rna: persistentSettings.remoteNodeAddress
                daemonAddrText: rna.search(":") != -1 ? rna.split(":")[0].trim() : ""
                daemonPortText: rna.search(":") != -1 ? (rna.split(":")[1].trim() == "") ? appWindow.getDefaultDaemonRpcPort(persistentSettings.nettype) : rna.split(":")[1] : ""
                onEditingFinished: {
                    persistentSettings.remoteNodeAddress = remoteNodeEdit.getAddress();
                    console.log("setting remote node to " + persistentSettings.remoteNodeAddress);
                    if (persistentSettings.is_trusted_daemon) {
                        persistentSettings.is_trusted_daemon = !persistentSettings.is_trusted_daemon
                        currentWallet.setTrustedDaemon(persistentSettings.is_trusted_daemon)
                        setTrustedDaemonCheckBox.checked = !setTrustedDaemonCheckBox.checked
                        appWindow.showStatusMessage(qsTr("Remote node updated. Trusted daemon has been reset. Mark again, if desired."), 8);
                    }
                }
            }

            GridLayout {
                columns: 2
                columnSpacing: 32

                MoneroComponents.LineEdit {
                    id: daemonUsername
                    Layout.fillWidth: true
                    labelText: qsTr("Daemon username") + translationManager.emptyString
                    text: persistentSettings.daemonUsername
                    placeholderText: qsTr("(optional)") + translationManager.emptyString
                    placeholderFontSize: 15
                    labelFontSize: 14
                    fontSize: 15
                }

                MoneroComponents.LineEdit {
                    id: daemonPassword
                    Layout.fillWidth: true
                    labelText: qsTr("Daemon password") + translationManager.emptyString
                    text: persistentSettings.daemonPassword
                    placeholderText: qsTr("Password") + translationManager.emptyString
                    echoMode: TextInput.Password
                    placeholderFontSize: 15
                    labelFontSize: 14
                    fontSize: 15
                }
            }

            MoneroComponents.CheckBox {
                id: setTrustedDaemonCheckBox
                checked: persistentSettings.is_trusted_daemon
                onClicked: {
                    persistentSettings.is_trusted_daemon = !persistentSettings.is_trusted_daemon
                    currentWallet.setTrustedDaemon(persistentSettings.is_trusted_daemon)
                }
                text: qsTr("Mark as Trusted Daemon") + translationManager.emptyString
            }

            MoneroComponents.StandardButton {
                id: btnConnectRemote
                enabled: remoteNodeEdit.isValid()
                small: true
                text: qsTr("Connect") + translationManager.emptyString
                onClicked: {
                    // Update daemon login
                    persistentSettings.remoteNodeAddress = remoteNodeEdit.getAddress();
                    persistentSettings.daemonUsername = daemonUsername.text;
                    persistentSettings.daemonPassword = daemonPassword.text;
                    persistentSettings.useRemoteNode = true

                    currentWallet.setDaemonLogin(persistentSettings.daemonUsername, persistentSettings.daemonPassword);

                    appWindow.connectRemoteNode()
                }
            }
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
                    labelText: qsTr("Blockchain location") + style + qsTr(" <a href='#'> (change)</a>") + translationManager.emptyString
                    placeholderText: qsTr("(default)") + translationManager.emptyString
                    placeholderFontSize: 15
                    readOnly: true
                    text: {
                        if(persistentSettings.blockchainDataDir.length > 0){
                            return persistentSettings.blockchainDataDir;
                        } else { return "" }
                    }
                    addressValidation: false
                    onInputLabelLinkActivated: {
                        //mouse.accepted = false
                        if(persistentSettings.blockchainDataDir !== ""){
                            blockchainFileDialog.folder = "file://" + persistentSettings.blockchainDataDir;
                        }
                        blockchainFileDialog.open();
                        blockchainFolder.focus = true;
                    }
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
                onEditingFinished: persistentSettings.daemonFlags = daemonFlags.text;
            }

            RowLayout {
                visible: !persistentSettings.useRemoteNode

                ColumnLayout {
                    Layout.fillWidth: true

                    MoneroComponents.RemoteNodeEdit {
                        id: bootstrapNodeEdit
                        Layout.minimumWidth: 100
                        Layout.bottomMargin: 20

                        daemonAddrLabelText: qsTr("Bootstrap Address")
                        daemonPortLabelText: qsTr("Bootstrap Port")
                        daemonAddrText: persistentSettings.bootstrapNodeAddress.split(":")[0].trim()
                        daemonPortText: {
                            var node_split = persistentSettings.bootstrapNodeAddress.split(":");
                            if(node_split.length == 2){
                                (node_split[1].trim() == "") ? appWindow.getDefaultDaemonRpcPort(persistentSettings.nettype) : node_split[1];
                            } else {
                                return ""
                            }
                        }
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
    }
}

