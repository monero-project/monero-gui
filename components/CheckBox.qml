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
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

Item {
    id: checkBox
    property alias text: label.text
    property string checkedIcon: "../images/checkedIcon-black.png"
    property string uncheckedIcon
    property bool checked: false
    property alias background: backgroundRect.color
    property bool border: true
    property int fontSize: 14 * scaleRatio
    property alias fontColor: label.color
    property bool iconOnTheLeft: true
    signal clicked()
    height: 25 * scaleRatio
    width: checkBoxLayout.width

    function toggle(){
        checkBox.checked = !checkBox.checked
        checkBox.clicked()
    }

    RowLayout {
        id: checkBoxLayout
        layoutDirection: iconOnTheLeft ? Qt.LeftToRight : Qt.RightToLeft
        spacing: (!isMobile ? 10 : 8) * scaleRatio

        Item {
            id: checkMark
            height: checkBox.height
            width: checkBox.height

            Rectangle {
                id: backgroundRect
                anchors.fill: parent
                radius: 3
                color: "transparent"
                border.color:
                    if(checkBox.checked){
                        return MoneroComponents.Style.inputBorderColorActive;
                    } else {
                        return MoneroComponents.Style.inputBorderColorInActive;
                    }
                visible: checkBox.border
            }

            Image {
                anchors.centerIn: parent
                source: {
                    if (checkBox.checked || checkBox.uncheckedIcon == "") {
                        return checkBox.checkedIcon;
                    }
                    return checkBox.uncheckedIcon;
                }
                visible: checkBox.checked || checkBox.uncheckedIcon != ""
            }
        }

        Text {
            id: label
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: checkBox.fontSize
            color: MoneroComponents.Style.defaultFontColor
            textFormat: Text.RichText
            wrapMode: Text.Wrap
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggle()
        }
    }
}
