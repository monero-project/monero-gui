// Copyright (c) 2021-2024, The Monero Project
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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import FontAwesome 1.0
import "." as MoneroComponents

Rectangle {
    property alias text: tooltip.text
    property alias tooltipPopup: popup
    property bool tooltipIconVisible: false
    property bool tooltipLeft: false
    property bool tooltipBottom: tooltipIconVisible ? false : true

    color: "transparent"
    height: tooltipIconVisible ? icon.height : parent.height
    width: tooltipIconVisible ? icon.width : parent.width
    visible: text != ""

    Text {
        id: icon
        visible: tooltipIconVisible
        color: MoneroComponents.Style.defaultFontColor
        font.family: FontAwesome.fontFamily
        font.pixelSize: 10
        font.styleName: "Regular"
        leftPadding: 5
        rightPadding: 5
        text: FontAwesome.questionCircle
        opacity: mouseArea.containsMouse ? 0.7 : 1

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.WhatsThisCursor
            onEntered: popup.open()
            onExited: popup.close()
        }
    }

    ToolTip {
        id: popup
        height: tooltip.height + 20

        background: Rectangle {
            border.color: MoneroComponents.Style.buttonInlineBackgroundColor
            border.width: 1
            color: MoneroComponents.Style.titleBarBackgroundGradientStart
            radius: 4
        }
        closePolicy: Popup.NoAutoClose
        padding: 10
        x: tooltipLeft
            ? (tooltipIconVisible ? icon.x - icon.width : parent.x - tooltip.width - 20 + parent.width/2)
            : (tooltipIconVisible ? icon.x + icon.width : parent.x + parent.width/2)
        y: tooltipBottom
            ? (tooltipIconVisible ? icon.y + height : parent.y + parent.height + 2)
            : (tooltipIconVisible ? icon.y - height : parent.y - tooltip.height - 20)
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
        }
        delay: 200

        RowLayout {
            Layout.maximumWidth: 370

            Text {
                id: tooltip
                width: contentWidth
                Layout.maximumWidth: 370
                color: MoneroComponents.Style.defaultFontColor
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 12
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
            }
        }
    }
}
