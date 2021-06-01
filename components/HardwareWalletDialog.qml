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

import QtQuick 2.9
import QtQuick.Window 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

Rectangle {
    id: root
    color: MoneroComponents.Style.blackTheme ? "black" : "white"
    visible: false
    radius: 10
    border.color: MoneroComponents.Style.blackTheme ? Qt.rgba(255, 255, 255, 0.25) : Qt.rgba(0, 0, 0, 0.25)
    border.width: 1
    z: 11
    property alias titleText: messageTitle.text
    property alias imgSource: image.source
    property alias messageInstructions1: messageInstructions1.text
    property alias messageInstructions2: messageInstructions2.text
    property alias okButtonText: okButton.text

    width: 100
    height: 50

    // same signals as Dialog has
    signal accepted()
    signal rejected()
    signal closeCallback();

    function show() {
        root.visible = true;
    }

    function close() {
        root.visible = false;
    }

    ColumnLayout {
        id: rootLayout
        spacing: 10
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 20

        Image {
            id: image
            visible: image.source != ""
            Layout.alignment: Qt.AlignHCenter
            mipmap: true
        }

        MoneroComponents.TextPlain {
            id: messageTitle
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true
            themeTransition: false
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.TextPlain {
            id: messageInstructions1
            visible: messageInstructions1.text
            font.pixelSize: 14
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.fillWidth: true
            themeTransition: false
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.TextPlain {
            id: messageInstructions2
            visible: messageInstructions2.text
            font.pixelSize: 14
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.fillWidth: true
            themeTransition: false
            color: MoneroComponents.Style.defaultFontColor
        }

        RowLayout {
            id: buttons
            spacing: 60
            Layout.alignment: Qt.AlignHCenter

            MoneroComponents.StandardButton {
                id: cancelButton
                text: qsTr("Cancel") + translationManager.emptyString
                primary: false
                onClicked: {
                    root.close()
                    root.rejected()
                }
            }

            MoneroComponents.StandardButton {
                id: okButton
                KeyNavigation.tab: cancelButton
                onClicked: {
                    root.close()
                    root.accepted()
                }
            }
        }
    }
}
