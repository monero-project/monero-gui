// Copyright (c) 2026, The Monero Project
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
import QtQuick.Layouts 1.2

import "." as MoneroComponents

ColumnLayout {
    id: root

    property string password
    property int passwordFill: 0
    property string passwordStrengthText: qsTr("Strength: ") + translationManager.emptyString
    readonly property bool passwordStrengthAvailable: !isAndroid && walletManager.getPasswordStrength !== undefined
    readonly property int strengthLevel: passwordFill <= 33 ? 0 : (passwordFill <= 66 ? 1 : 2)
    readonly property string strengthString: {
        if (strengthLevel === 0) {
            return qsTr("Low") + translationManager.emptyString;
        } else if (strengthLevel === 1) {
            return qsTr("Medium") + translationManager.emptyString;
        }
        return qsTr("High") + translationManager.emptyString;
    }
    readonly property color strengthColor: {
        if (strengthLevel === 0) {
            return "#FF0000";
        } else if (strengthLevel === 1) {
            return MoneroComponents.Style.blackTheme ? "#FFFF00" : "#FFCC00";
        }
        return MoneroComponents.Style.blackTheme ? "#00FF00" : "#008000";
    }

    visible: passwordStrengthAvailable
    spacing: 0

    onPasswordChanged: calcPasswordStrength()
    onVisibleChanged: {
        if (visible) {
            calcPasswordStrength();
        }
    }

    function calcPasswordStrength() {
        if (!visible) {
            return;
        }
        if (password.length <= 1) {
            root.passwordFill = 0;
        }

        // getPasswordStrength returns a value from 0 to... lots
        var strength = walletManager.getPasswordStrength(password);
        // consider anything below 10 bits as dire
        strength -= 10;
        if (strength < 0) {
            strength = 0;
        }
        // use a slight parabola to discourage short passwords
        strength = Math.pow(strength, 1.2) / 3;
        strength += 20;
        if (strength > 100) {
            strength = 100;
        }

        root.passwordFill = strength;
    }

    MoneroComponents.TextPlain {
        Layout.topMargin: 6
        Layout.bottomMargin: 6
        font.family: MoneroComponents.Style.fontMedium.name
        font.pixelSize: 14
        font.bold: false
        color: MoneroComponents.Style.defaultFontColor
        height: 18
        text: root.passwordStrengthText + root.strengthString
    }

    Rectangle {
        id: bar
        Layout.fillWidth: true
        Layout.preferredHeight: 8

        radius: 8
        color: MoneroComponents.Style.progressBarBackgroundColor

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            height: bar.height
            width: (bar.width * root.passwordFill) / 100
            radius: 8
            color: root.strengthColor
        }
    }
}
