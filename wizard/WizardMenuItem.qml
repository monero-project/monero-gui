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

import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../components" as MoneroComponents

RowLayout {
    id: rowlayout
    Layout.fillWidth: true
    Layout.bottomMargin: 10 * scaleRatio
    property alias imageIcon: icon.source
    property alias headerText: header.text
    property alias bodyText: body.text
    signal menuClicked();
    spacing: 10 * scaleRatio

    Item {
        Layout.preferredWidth: 70 * scaleRatio
        Layout.preferredHeight: 70 * scaleRatio

        Image {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source: ""
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked: {
                rowlayout.menuClicked();
            }
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true
        spacing: 0

        Text {
            id: header
            Layout.fillWidth: true
            leftPadding: parent.leftPadding
            topPadding: 0
            color: MoneroComponents.Style.defaultFontColor
            font.bold: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: {
                if(wizardController.layoutScale === 2 ){
                    return 22 * scaleRatio;
                } else {
                    return 16 * scaleRatio;
                }
            }

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    rowlayout.menuClicked();
                }
            }
        }

        Text {
            id: body
            Layout.fillWidth: true
            color: MoneroComponents.Style.dimmedFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: {
                if(wizardController.layoutScale === 2 ){
                    return 16 * scaleRatio;
                } else {
                    return 14 * scaleRatio;
                }
            }
            topPadding: 4 * scaleRatio
            wrapMode: Text.WordWrap;

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: {
                    rowlayout.menuClicked();
                }
            }
        }
    }
}
