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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../../components/effects/" as MoneroEffects
import FontAwesome 1.0

import "../../js/Wizard.js" as Wizard
import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents

RowLayout {
    id: root
    spacing: 0
    property string text: ""
    property int state: 0 // 0: unchecked 1: checked 2: error

    Rectangle {
        color: "transparent"
        Layout.preferredHeight: 30
        Layout.preferredWidth: 40

        Text {
            text: {
                if(root.state === 0){
                    return FontAwesome.squareO;
                } else if(root.state === 1){
                    return FontAwesome.checkSquareO;
                } else if(root.state === 2){
                    return FontAwesome.warning;
                }
            }

            font.family: FontAwesome.fontFamily
            font.pixelSize: 18
            color: root.state <= 1 ? MoneroComponents.Style.lightGreyFontColor : "red"
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 1
        }
    }

    MoneroComponents.TextPlain {
        Layout.alignment: Qt.AlignVCenter
        text: root.text
        themeTransitionBlackColor: MoneroComponents.Style._b_lightGreyFontColor
        themeTransitionWhiteColor: MoneroComponents.Style._w_lightGreyFontColor
        wrapMode: Text.WordWrap

        font.family: MoneroComponents.Style.fontRegular.name
        font.pixelSize: 16
        color: MoneroComponents.Style.lightGreyFontColor
    }
    
}
