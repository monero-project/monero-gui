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

import QtQuick 2.0
import moneroComponents.Wallet 1.0

import "../components" as MoneroComponents

Rectangle {
    id: item
    property int fillLevel: 0
    property string syncType // Wallet or Daemon
    property string syncText: qsTr("%1 blocks remaining: ").arg(syncType)
    visible: false
    color: "transparent"

    function updateProgress(currentBlock,targetBlock, blocksToSync, statusTxt){
        if(targetBlock > 0) {
            var remaining = (currentBlock < targetBlock) ? targetBlock - currentBlock : 0
            var progressLevel = (blocksToSync > 0 && blocksToSync != remaining) ? (100*(blocksToSync - remaining)/blocksToSync).toFixed(0) : (100*(currentBlock / targetBlock)).toFixed(0)
            fillLevel = progressLevel
            if(typeof statusTxt != "undefined" && statusTxt != "") {
                progressText.text = statusTxt;
            } else {
                progressText.text = syncText + remaining.toFixed(0);
            }
        }
    }

    Item {
        anchors.top: item.top
        anchors.topMargin: 10 * scaleRatio
        anchors.leftMargin: 15 * scaleRatio
        anchors.rightMargin: 15 * scaleRatio
        anchors.fill: parent

        Text {
            id: progressText
            anchors.top: parent.top
            anchors.topMargin: 6
            font.family: MoneroComponents.Style.fontMedium.name
            font.pixelSize: 13 * scaleRatio
            font.bold: true
            color: "white"
            text: qsTr("Synchronizing %1").arg(syncType)
            height: 18 * scaleRatio
        }

        Text {
            id: progressTextValue
            anchors.top: parent.top
            anchors.topMargin: 6
            anchors.right: parent.right
            font.family: MoneroComponents.Style.fontMedium.name
            font.pixelSize: 13 * scaleRatio
            font.bold: true
            color: "white"
            height:18 * scaleRatio
        }


        Rectangle {
            id: bar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: progressText.bottom
            anchors.topMargin: 4
            height: 8 * scaleRatio
            radius: 8 * scaleRatio
            color: "#333333" // progressbar bg

            Rectangle {
                id: fillRect
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                height: bar.height
                property int maxWidth: bar.width * scaleRatio
                width: (maxWidth * fillLevel) / 100
                radius: 8
                // could change color based on progressbar status; if(item.fillLevel < 99 )
                color: "#FA6800"
            }

            Rectangle {
                color:"#333"
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 8 * scaleRatio
            }
        }

    }



}
