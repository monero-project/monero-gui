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

import "../js/Wizard.js" as Wizard
import "../components"
import "../components" as MoneroComponents

import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0


ColumnLayout {
    property string title: ""
    property string subtitle: ""
    spacing: 4
    Layout.maximumWidth: wizardController.wizardSubViewWidth

    TextArea {
        text: title
        Layout.fillWidth: true
        font.family: MoneroComponents.Style.fontRegular.name
        color: MoneroComponents.Style.defaultFontColor
        opacity: MoneroComponents.Style.blackTheme ? 1.0 : 0.8
        font.pixelSize: {
            if(wizardController.layoutScale === 2 ){
                return 34;
            } else {
                return 28;
            }
        }

        selectionColor: MoneroComponents.Style.textSelectionColor
        selectedTextColor: MoneroComponents.Style.textSelectedColor

        selectByMouse: true
        wrapMode: Text.WordWrap
        textMargin: 0
        leftPadding: 0
        topPadding: 0
        bottomPadding: 0
        readOnly: true
    }

    TextArea {
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter
        visible: parent.subtitle !== ""

        color: MoneroComponents.Style.dimmedFontColor
        text: subtitle

        font.family: MoneroComponents.Style.fontRegular.name
        font.pixelSize: {
            if(wizardController.layoutScale === 2 ){
                return 16;
            } else {
                return 14;
            }
        }

        selectionColor: MoneroComponents.Style.textSelectionColor
        selectedTextColor: MoneroComponents.Style.textSelectedColor

        selectByMouse: true
        wrapMode: Text.WordWrap
        textMargin: 0
        leftPadding: 0
        topPadding: 0
        readOnly: true
    }
}
