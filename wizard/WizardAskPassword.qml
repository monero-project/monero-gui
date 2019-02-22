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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

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

    spacing: 20 * scaleRatio

    WizardHeader{
        title: qsTr("Give your wallet a password") + translationManager.emptyString
        subtitle: qsTr("This password cannot be recovered. If you forget it then the wallet will have to be restored from its 25 word mnemonic seed.") + translationManager.emptyString
    }

    MoneroComponents.WarningBox {
        text: qsTr("<b>Enter a strong password</b> (Using letters, numbers, and/or symbols).") + translationManager.emptyString
    }

    ColumnLayout {
        spacing: 0
        visible: !isAndroid
        Layout.fillWidth: true

        TextInput {
            id: progressText
            anchors.top: parent.top
            anchors.topMargin: 6
            font.family: MoneroComponents.Style.fontMedium.name
            font.pixelSize: 14 * scaleRatio
            font.bold: false
            color: MoneroComponents.Style.defaultFontColor
            text: root.passwordStrengthText + '-'
            height: 18 * scaleRatio
            passwordCharacter: "*"
        }

        TextInput {
            id: progressTextValue
            font.family: MoneroComponents.Style.fontMedium.name
            font.pixelSize: 13 * scaleRatio
            font.bold: true
            color: MoneroComponents.Style.defaultFontColor
            height:18 * scaleRatio
            passwordCharacter: "*"
        }

        Rectangle {
            id: bar
            Layout.fillWidth: true
            Layout.preferredHeight: 8

            radius: 8 * scaleRatio
            color: "#333333" // progressbar bg

            Rectangle {
                id: fillRect
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                height: bar.height
                property int maxWidth: bar.width * scaleRatio
                width: (maxWidth * root.passwordFill) / 100
                radius: 8
                color: "#FA6800"
            }

            Rectangle {
                color:"#333"
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.leftMargin: 8 * scaleRatio
            }
        }

    }

    ColumnLayout {
        spacing: 4 * scaleRatio
        Layout.fillWidth: true

        Label {
            text: qsTr("Password")
            Layout.fillWidth: true

            font.pixelSize: 14 * scaleRatio
            font.family: MoneroComponents.Style.fontLight.name

            color: MoneroComponents.Style.defaultFontColor
        }

        TextField {
            id: passwordInput

            Layout.topMargin: 6 * scaleRatio
            Layout.fillWidth: true

            bottomPadding: 10 * scaleRatio
            leftPadding: 10 * scaleRatio
            topPadding: 10 * scaleRatio

            horizontalAlignment: TextInput.AlignLeft
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            KeyNavigation.tab: passwordInputConfirm

            font.family: MoneroComponents.Style.fontLight.name
            font.pixelSize: 15 * scaleRatio
            color: MoneroComponents.Style.defaultFontColor
            selectionColor: MoneroComponents.Style.dimmedFontColor
            selectedTextColor: MoneroComponents.Style.defaultFontColor

            text: walletOptionsPassword

            background: Rectangle {
                radius: 4
                border.color: Qt.rgba(255, 255, 255, 0.35)
                border.width: 1
                color: "transparent"

                Image {
                    width: 12 * scaleRatio
                    height: 16 * scaleRatio
                    source: "../images/lockIcon.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
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

            font.pixelSize: 14 * scaleRatio
            font.family: MoneroComponents.Style.fontLight.name

            color: MoneroComponents.Style.defaultFontColor
        }

        TextField {
            id : passwordInputConfirm
            
            Layout.topMargin: 6 * scaleRatio
            Layout.fillWidth: true

            bottomPadding: 10 * scaleRatio
            leftPadding: 10 * scaleRatio
            topPadding: 10 * scaleRatio

            horizontalAlignment: TextInput.AlignLeft
            verticalAlignment: TextInput.AlignVCenter
            echoMode: TextInput.Password
            KeyNavigation.tab: passwordInputConfirm

            font.family: MoneroComponents.Style.fontLight.name
            font.pixelSize: 15 * scaleRatio
            color: MoneroComponents.Style.defaultFontColor
            selectionColor: MoneroComponents.Style.dimmedFontColor
            selectedTextColor: MoneroComponents.Style.defaultFontColor

            text: walletOptionsPassword

            background: Rectangle {
                radius: 4
                border.color: Qt.rgba(255, 255, 255, 0.35)
                border.width: 1
                color: "transparent"

                Image {
                    width: 12
                    height: 16
                    source: "../images/lockIcon.png"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                }
            }
        }
    }
}
