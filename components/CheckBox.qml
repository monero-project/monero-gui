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

RowLayout {
    id: checkBox
    property alias text: label.text
    property string checkedIcon
    property string uncheckedIcon
    property bool checked: false
    property alias background: backgroundRect.color
    property int fontSize: 14 * scaleRatio
    property alias fontColor: label.color
    signal clicked()
    height: 25 * scaleRatio

    function toggle(){
        checkBox.checked = !checkBox.checked
        checkBox.clicked()
    }

    RowLayout {
        Layout.fillWidth: true
        Rectangle {
            anchors.left: parent.left
            width: 25 * scaleRatio
            height: checkBox.height - 1
            //radius: 4
            y: 0
            color: "#DBDBDB"
        }

        Rectangle {
            id: backgroundRect
            anchors.left: parent.left
            width: 25 * scaleRatio
            height: checkBox.height - 1
            //radius: 4
            y: 1
            color: "#FFFFFF"

            Image {
                anchors.centerIn: parent
                source: checkBox.checked ? checkBox.checkedIcon :
                                           checkBox.uncheckedIcon
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    toggle()
                }
            }
        }

        Text {
            id: label
            font.family: "Arial"
            font.pixelSize: checkBox.fontSize
            color: "#525252"
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    toggle()
                }
            }
        }
    }
}
