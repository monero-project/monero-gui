// Copyright (c) 2017-2018, The Monero Project
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
import QtQuick.Controls 1.4
import moneroComponents.Wallet 1.0

Item {
    id: item
    property string message: ""
    property bool active: false
    height: 120
    width: 240
    property int margin: 15
    x: parent.width - width - margin
    y: parent.height - height * scale.yScale - margin * scale.yScale

    Rectangle {
        color: "#FF6C3C"
        border.color: "black"
        anchors.fill: parent

        TextArea {
            id:versionText
            readOnly: true
            backgroundVisible: false
            textFormat: TextEdit.AutoText
            anchors.fill: parent
            font.family: "Arial"
            font.pixelSize: 12
            textMargin: 20
            textColor: "white"
            text: item.message
        }
    }

    transform: Scale {
        id: scale
        yScale: item.active ? 1 : 0

        Behavior on yScale {
            NumberAnimation { duration: 500; easing.type: Easing.InOutCubic }
        }
    }

    Timer {
        id: hider
        interval: 12000; running: false; repeat: false
        onTriggered: { item.active = false }
    }

    function show(message) {
        item.visible = true
        item.message = message
        item.active = true
        hider.running = true
    }
}
