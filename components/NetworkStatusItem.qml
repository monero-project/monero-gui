// Copyright (c) 2014-2015, The Monero Project
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

import QtQuick 2.0
import moneroComponents.Wallet 1.0

Row {
    id: item
    property var connected: Wallet.ConnectionStatus_Disconnected

    function getConnectionStatusImage(status) {
        if (status == Wallet.ConnectionStatus_Connected)
            return "../images/statusConnected.png"
        else
            return "../images/statusDisconnected.png"
    }

    function getConnectionStatusColor(status) {
        if (status == Wallet.ConnectionStatus_Connected)
            return "#FF6C3B"
        else
            return "#AAAAAA"
    }

    function getConnectionStatusString(status) {
        if (status == Wallet.ConnectionStatus_Connected) {
            if(!appWindow.daemonSynced)
                return qsTr("Synchronizing")
            return qsTr("Connected")
        }
        if (status == Wallet.ConnectionStatus_WrongVersion)
            return qsTr("Wrong version")
        if (status == Wallet.ConnectionStatus_Disconnected)
            return qsTr("Disconnected")
        return qsTr("Invalid connection status")
    }

    Item {
        id: iconItem
        anchors.bottom: parent.bottom
        width: 50
        height: 50

        Image {
            anchors.centerIn: parent
            source: getConnectionStatusImage(item.connected)
        }
    }

    Column {
        anchors.bottom: parent.bottom
        height: 53
        spacing: 3

        Text {
            anchors.left: parent.left
            font.family: "Arial"
            font.pixelSize: 12
            color: "#545454"
            text: qsTr("Network status") + translationManager.emptyString
        }

        Text {
            anchors.left: parent.left
            font.family: "Arial"
            font.pixelSize: 18
            color: getConnectionStatusColor(item.connected)
            text: getConnectionStatusString(item.connected) + translationManager.emptyString
        }
    }
}
