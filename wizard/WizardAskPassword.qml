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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import FontAwesome 1.0

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

ColumnLayout {
    id: root
    Layout.fillWidth: true
    property alias password: passwordInput.text
    property int passwordFill: 0
    property string passwordStrengthText: qsTr("Strength: ") + translationManager.emptyString

    function calcStrengthAndVerify(){
        calcPasswordStrength();
        return passwordInput.text === passwordInputConfirm.text;
    }

    function calcPasswordStrength(inp) {
        if(!progressLayout.visible) return;
        if(passwordInput.text.length <= 1){
            root.passwordFill = 0;
            progressText.text = passwordStrengthText + qsTr("Low") + translationManager.emptyString;
        }

        // scorePassword returns value from 0 to... lots
        var strength = walletManager.getPasswordStrength(passwordInput.text);
        // consider anything below 10 bits as dire
        strength -= 10
        if (strength < 0)
          strength = 0;
        // use a slight parabola to discourage short passwords
        strength = strength ^ 1.2 / 3
        strength += 20;
        if (strength > 100)
          strength = 100;

        root.passwordFill = strength;

        var strengthString;
        if(strength <= 33){
            strengthString = qsTr("Low");
        } else if(strength <= 66){
            strengthString = qsTr("Medium");
        } else {
            strengthString = qsTr("High");
        }

        progressText.text = passwordStrengthText + strengthString + translationManager.emptyString;
    }

    spacing: 20

    WizardHeader{
        title: qsTr("Give your wallet a password") + translationManager.emptyString
        subtitle: qsTr("This password cannot be recovered. If you forget it then the wallet will have to be restored from your %1.").arg(!wizardController.walletOptionsIsRecoveringFromDevice ? qsTr("25 word mnemonic seed") : qsTr("hardware wallet"))+ translationManager.emptyString
    }

    MoneroComponents.WarningBox {
        text: "<b>%1</b> (%2).".arg(qsTr("Enter a strong password")).arg(qsTr("Using letters, numbers, and/or symbols")) + translationManager.emptyString
    }

    ColumnLayout {
        id: progressLayout
        spacing: 0
        visible: !isAndroid && walletManager.getPasswordStrength !== undefined
        Layout.fillWidth: true

        TextInput {
            id: progressText
            Layout.topMargin: 6
            Layout.bottomMargin: 6
            font.family: MoneroComponents.Style.fontMedium.name
            font.pixelSize: 14
            font.bold: false
            color: MoneroComponents.Style.defaultFontColor
            height: 18
            passwordCharacter: "*"
        }

        Rectangle {
            id: bar
            Layout.fillWidth: true
            Layout.preferredHeight: 8

            radius: 8
            color: MoneroComponents.Style.progressBarBackgroundColor

            Rectangle {
                id: fillRect
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                height: bar.height
                property int maxWidth: bar.width
                width: (maxWidth * root.passwordFill) / 100
                radius: 8
                color: MoneroComponents.Style.orange
            }

            Rectangle {
                color: MoneroComponents.Style.defaultFontColor
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 8
            }
        }
    }

    MoneroComponents.LineEdit {
        id: passwordInput
        Layout.fillWidth: true
        KeyNavigation.tab: passwordInputConfirm

        labelFontSize: 14
        password: true

        labelText: qsTr("Password") + translationManager.emptyString
        text: walletOptionsPassword
    }

    MoneroComponents.LineEdit {
        id: passwordInputConfirm
        Layout.fillWidth: true
        Layout.topMargin: 8
        KeyNavigation.tab: passwordInputConfirm

        labelFontSize: 14
        passwordLinked: passwordInput

        labelText: qsTr("Password (confirm)") + translationManager.emptyString
        text: walletOptionsPassword
    }
}
