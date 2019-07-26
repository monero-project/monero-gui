// Copyright (c) 2019-2019, Nejcraft
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
import "../components" as NejCoinComponents

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
        if(isAndroid) return;
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

    NejCoinComponents.WarningBox {
        text: qsTr("<b>Enter a strong password</b> (Using letters, numbers, and/or symbols).") + translationManager.emptyString
    }

    ColumnLayout {
        spacing: 0
        visible: !isAndroid
        Layout.fillWidth: true

        TextInput {
            id: progressText
            Layout.topMargin: 6
            Layout.bottomMargin: 6
            font.family: NejCoinComponents.Style.fontMedium.name
            font.pixelSize: 14
            font.bold: false
            color: NejCoinComponents.Style.defaultFontColor
            height: 18
            passwordCharacter: "*"
        }

        Rectangle {
            id: bar
            Layout.fillWidth: true
            Layout.preferredHeight: 8

            radius: 8
            color: NejCoinComponents.Style.progressBarBackgroundColor

            Rectangle {
                id: fillRect
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                height: bar.height
                property int maxWidth: bar.width
                width: (maxWidth * root.passwordFill) / 100
                radius: 8
                color: NejCoinComponents.Style.orange
            }

            Rectangle {
                color: NejCoinComponents.Style.defaultFontColor
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 8
            }
        }
    }

    ColumnLayout {
        spacing: 4
        Layout.fillWidth: true

        Label {
            text: qsTr("Password") + translationManager.emptyString
            Layout.fillWidth: true

            font.pixelSize: 14
            font.family: NejCoinComponents.Style.fontLight.name

            color: NejCoinComponents.Style.defaultFontColor
        }

        TextField {
            id: passwordInput

            Layout.topMargin: 6
            Layout.fillWidth: true

            bottomPadding: 10
            leftPadding: 10
            topPadding: 10

            horizontalAlignment: TextInput.AlignLeft
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            KeyNavigation.tab: passwordInputConfirm

            font.family: NejCoinComponents.Style.fontLight.name
            font.pixelSize: 15
            color: NejCoinComponents.Style.defaultFontColor
            selectionColor: NejCoinComponents.Style.textSelectionColor
            selectedTextColor: NejCoinComponents.Style.textSelectedColor

            text: walletOptionsPassword

            background: Rectangle {
                radius: 4
                border.color: NejCoinComponents.Style.inputBorderColorActive
                border.width: 1
                color: "transparent"

                NejCoinComponents.Label {
                    fontSize: 20
                    text: FontAwesome.lock
                    opacity: 0.5
                    fontFamily: FontAwesome.fontFamily
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 3
                }
            }
        }
    }

    ColumnLayout {
        spacing: 4
        Layout.fillWidth: true

        Label {
            text: qsTr("Password (confirm)") + translationManager.emptyString
            Layout.fillWidth: true

            font.pixelSize: 14
            font.family: NejCoinComponents.Style.fontLight.name

            color: NejCoinComponents.Style.defaultFontColor
        }

        TextField {
            id : passwordInputConfirm
            
            Layout.topMargin: 6
            Layout.fillWidth: true

            bottomPadding: 10
            leftPadding: 10
            topPadding: 10

            horizontalAlignment: TextInput.AlignLeft
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            KeyNavigation.tab: passwordInputConfirm

            font.family: NejCoinComponents.Style.fontLight.name
            font.pixelSize: 15
            color: NejCoinComponents.Style.defaultFontColor
            selectionColor: NejCoinComponents.Style.textSelectionColor
            selectedTextColor: NejCoinComponents.Style.textSelectedColor

            text: walletOptionsPassword

            background: Rectangle {
                radius: 4
                border.color: NejCoinComponents.Style.inputBorderColorActive
                border.width: 1
                color: "transparent"

                NejCoinComponents.Label {
                    fontSize: 20
                    text: FontAwesome.lock
                    opacity: 0.5
                    fontFamily: FontAwesome.fontFamily
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 3
                }
            }
        }
    }
}
