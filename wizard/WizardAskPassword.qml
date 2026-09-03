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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import FontAwesome 1.0

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

ColumnLayout {
    id: root
    Layout.fillWidth: true
    property alias password: passwordInput.text
    property alias passwordConfirm: passwordInputConfirm.text
    property alias passwordFill: passwordStrengthBar.passwordFill
    property alias passwordStrengthText: passwordStrengthBar.passwordStrengthText

    function passwordsMatch(){
        return passwordInput.text === passwordInputConfirm.text;
    }

    function calcPasswordStrength() {
        passwordStrengthBar.calcPasswordStrength();
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
        Layout.fillWidth: true

        MoneroComponents.LineEdit {
            id: passwordInput
            Layout.fillWidth: true
            KeyNavigation.tab: passwordInputConfirm
            labelFontSize: 14
            password: true
            labelText: qsTr("Password") + translationManager.emptyString
        }

        MoneroComponents.PasswordStrengthBar {
            id: passwordStrengthBar
            Layout.fillWidth: true
            Layout.topMargin: 0
            password: passwordInput.text
        }
    }

    ColumnLayout {
        Layout.fillWidth: true

        MoneroComponents.LineEdit {
            id: passwordInputConfirm
            property bool firstUserInput: true
            Layout.fillWidth: true
            Layout.topMargin: 8
            KeyNavigation.tab: passwordInputConfirm
            error: !passwordInputMessage.passwordsMatch && passwordInputMessage.visible
            errorWhenEmpty: passwordInputMessage.passwordsMatch && passwordInputMessage.visible
            labelFontSize: 14
            passwordLinked: passwordInput
            labelText: qsTr("Password (confirm)") + translationManager.emptyString
            onTextChanged:{
                if (passwordInputConfirm.text.length == passwordInput.text.length) {
                    firstUserInput = false;
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 0
            Layout.minimumHeight: passwordInputMessage.height + 3

            MoneroComponents.TextPlain {
                visible: passwordInputMessage.visible
                font.family: FontAwesome.fontFamilySolid
                font.styleName: "Solid"
                font.pixelSize: 15
                text: passwordInputMessage.passwordsMatch ? FontAwesome.checkCircle : FontAwesome.exclamationCircle
                color: passwordInputMessage.color
                themeTransition: false
            }

            MoneroComponents.TextPlain {
                id: passwordInputMessage
                property bool passwordsMatch: passwordInputConfirm.text === passwordInput.text
                property bool partialPasswordsMatch: passwordInputConfirm.text === passwordInput.text.substring(0, passwordInputConfirm.text.length)
                visible: passwordInputConfirm.text.length > 0 && !passwordInputConfirm.firstUserInput || passwordInputConfirm.firstUserInput && !passwordInputMessage.partialPasswordsMatch
                Layout.topMargin: 3
                text: passwordsMatch ? qsTr("Passwords match!") : qsTr("Passwords do not match") + translationManager.emptyString
                textFormat: Text.PlainText
                color: passwordsMatch ? (MoneroComponents.Style.blackTheme ? "#00FF00" : "#008000") : "#FF0000"
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                themeTransition: false
            }
        }
    }
}
