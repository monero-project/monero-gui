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
import QtQuick.Layouts 1.1

Item {
    id: item
    property alias text: label.text
    property alias color: label.color
    property alias textFormat: label.textFormat
    property string tipText: ""
    property int fontSize: 16 * scaleRatio
    property alias wrapMode: label.wrapMode
    property alias horizontalAlignment: label.horizontalAlignment
    signal linkActivated()
    width: icon.x + icon.width * scaleRatio
    height: icon.height * scaleRatio
    Layout.topMargin: 10 * scaleRatio

    Text {
        id: label
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2 * scaleRatio
        anchors.left: parent.left
        font.family: "Arial"
        font.pixelSize: fontSize
        color: "#555555"
        onLinkActivated: item.linkActivated()
    }

    Image {
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: label.right
        anchors.leftMargin: 5 * scaleRatio
        source: "../images/whatIsIcon.png"
        visible: appWindow.whatIsEnable
    }

//    MouseArea {
//        anchors.fill: icon
//        enabled: appWindow.whatIsEnable
//        hoverEnabled: true
//        onEntered: {
//            icon.visible = false
//            var pos = appWindow.mapFromItem(icon, 0, -15)
//            tipItem.text = item.tipText
//            tipItem.x = pos.x
//            if(tipItem.height > 30)
//                pos.y -= tipItem.height - 28
//            tipItem.y = pos.y
//            tipItem.visible = true
//        }
//        onExited: {
//            icon.visible = Qt.binding(function(){ return appWindow.whatIsEnable; })
//            tipItem.visible = false
//        }
//    }
}
