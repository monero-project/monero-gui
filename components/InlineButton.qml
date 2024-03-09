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
import QtGraphicalEffects 1.0

import FontAwesome 1.0

import "." as MoneroComponents
import "./effects/" as MoneroEffects

Item {
    id: inlineButton

    property bool small: false
    property string textColor: MoneroComponents.Style.inlineButtonTextColor
    property alias text: inlineText.text
    property alias fontPixelSize: inlineText.font.pixelSize
    property alias fontFamily: inlineText.font.family
    property alias fontStyleName: inlineText.font.styleName
    property bool isFontAwesomeIcon: fontFamily == FontAwesome.fontFamily || fontFamily == FontAwesome.fontFamilySolid
    property alias buttonColor: rect.color
    property alias tooltip: tooltip.text
    property alias tooltipLeft: tooltip.tooltipLeft
    property alias tooltipBottom: tooltip.tooltipBottom

    height: isFontAwesomeIcon ? 30 : 24
    width: isFontAwesomeIcon ? height : inlineText.width + 16

    signal clicked()

    function doClick() {
        // Android workaround
        releaseFocus();
        clicked();
    }

    Rectangle{
        id: rect
        anchors.fill: parent
        color: buttonArea.containsMouse ? MoneroComponents.Style.buttonInlineBackgroundColorHover : MoneroComponents.Style.buttonInlineBackgroundColor
        radius: 4
        border.width: parent.focus && parent.enabled ? 1 : 0

        MoneroComponents.TextPlain {
            id: inlineText
            font.family: MoneroComponents.Style.fontBold.name
            font.bold: true
            font.pixelSize: inlineButton.isFontAwesomeIcon ? 22 : inlineButton.small ? 14 : 16
            color: inlineButton.textColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            themeTransition: false

            MoneroEffects.ColorTransition {
                targetObj: inlineText
                blackColor: MoneroComponents.Style._b_inlineButtonTextColor
                whiteColor: MoneroComponents.Style._w_inlineButtonTextColor
            }
        }

        MoneroComponents.Tooltip {
            id: tooltip
            anchors.fill: parent
        }

        MouseArea {
            id: buttonArea
            cursorShape: rect.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            hoverEnabled: true
            anchors.fill: parent
            onClicked: {
                tooltip.text ? tooltip.tooltipPopup.close() : ""
                doClick()
            }
            onEntered: {
                tooltip.text ? tooltip.tooltipPopup.open() : ""
            }
            onExited: {
                tooltip.text ? tooltip.tooltipPopup.close() : ""
            }
        }
    }

    DropShadow {
        visible: !MoneroComponents.Style.blackTheme
        anchors.fill: rect
        horizontalOffset: 2
        verticalOffset: 2
        radius: 7.0
        samples: 10
        color: "#1B000000"
        cached: true
        source: rect
    }

    Keys.enabled: inlineButton.visible
    Keys.onSpacePressed: doClick()
    Keys.onEnterPressed: Keys.onReturnPressed(event)
    Keys.onReturnPressed: doClick()
}
