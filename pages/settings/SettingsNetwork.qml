// Copyright (c) 2014-2018, The Monero Project
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
import QtQuick.Dialogs 1.2

import moneroComponents.I2PDManager 1.0
import moneroComponents.DaemonManager 1.0

import "../../components" as MoneroComponents

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias networkHeight: networkLayout.height

    ColumnLayout {
        id: networkLayout
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 30

        MoneroComponents.Label {
            id: networkTitleLabel
            fontSize: 24
            text: qsTr("Network traffic protection") + translationManager.emptyString
        }
        
        MoneroComponents.TextPlain {
            id: networkMainLabel
            text: qsTr("Your wallet communicates with a set node and other nodes on the\nMonero network. This communication can be used to identify you.\nUse the options below to protect your privacy. Please check your\nlocal laws and internet policies before protecting your connection\nusing i2p, an anonymizing software.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
        }

        ColumnLayout {
            id: modeButtonsColumn
            Layout.topMargin: 8

            MoneroComponents.RadioButton {
                id: handleProtectButton
                text: qsTr("Protect my network connection") + translationManager.emptyString
                fontSize: 16
                enabled: !checked
                checked: false
                onClicked: {
                    handleProtectButton.checked = true;
                    handleUnprotectButton.checked = false;
                    startI2PD();
                }
            }

            MoneroComponents.RadioButton {
                id: handleUnprotectButton
                text: qsTr("Do not protect my connection") + translationManager.emptyString
                fontSize: 16
                enabled: !checked
                checked: true
                onClicked: {
                    handleUnprotectButton.checked = true;
                    handleProtectButton.checked = false;
                    stopI2PD();
                }
            }
        }

        RowLayout
        {
            MoneroComponents.Label {
                id: networkProtectionStatusLabel
                fontSize: 20
                text: qsTr("Status: ") + translationManager.emptyString
            }

            MoneroComponents.Label {
                id: networkProtectionStatus
                fontSize: 20
                text: qsTr("Unprotected") + translationManager.emptyString
            }
        }
    }

    function startI2PD()
    {
        /*
        var noSync = false;
        //these args will be deleted because DaemonManager::start will re-add them later.
        //removing '--tx-proxy=i2p,...' lets us blindly add '--tx-proxy i2p,...' later without risking duplication.
        var defaultArgs = ["--detach","--data-dir","--bootstrap-daemon-address","--prune-blockchain","--no-sync","--check-updates","--non-interactive","--max-concurrency","--tx-proxy=i2p,127.0.0.1:4447"]
        var customDaemonArgsArray = args.split(' ');
        var flag = "";
        var allArgs = [];
        var i2pdArgs = ["--tx-proxy i2p,127.0.0.1:4447"];
        //create an array (allArgs) of ['--arg value','--arg2','--arg3']
        for (let i = 0; i < customDaemonArgsArray.length; i++) {
            if(!customDaemonArgsArray[i].startsWith("--")) {
                flag += " " + customDaemonArgsArray[i]
            } else {
                if(flag){
                    allArgs.push(flag)
                }
                flag = customDaemonArgsArray[i]
            }
        }
        allArgs.push(flag)
        //pop from allArgs if value is inside the deleteme array (defaultArgs)
        allArgs = allArgs.filter( ( el ) => !defaultArgs.includes( el.split(" ")[0] ) )
        //append required i2pd flags
        for (let i = 0; i < i2pdArgs.length; i++) {
            if(!allArgs.includes(i2pdArgs[i])) {
                allArgs.push(i2pdArgs[i])
                continue
            }
        }
        var success = daemonManager.start(allArgs.join(" "), persistentSettings.nettype, persistentSettings.blockchainDataDir, persistentSettings.bootstrapNodeAddress, noSync, persistentSettings.pruneBlockchain)
        if (success) {
            */
        i2pdManager.start();
        //}       
    }

    function stopI2PD()
    {
        i2pdManager.stop();
    }

    function onI2PDStatus(isRunning)
    {
        
    }

    Component.onCompleted: {
        i2pdManager.i2pdStatus.connect(onI2PDStatus);
    }
}
