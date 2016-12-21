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

import moneroComponents.WalletManager 1.0
import QtQuick 2.2
import "../components"
import "utils.js" as Utils

Item {

    id: passwordPage
    opacity: 0
    visible: false

    property alias titleText: titleText.text
    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0


    function onPageOpened(settingsObject) {
        wizard.nextButton.enabled = true
        handlePassword();

        if (wizard.currentPath === "create_wallet") {
           passwordPage.titleText = qsTr("Give your wallet a password") + translationManager.emptyString
        } else {
           passwordPage.titleText = qsTr("Give your wallet a password") + translationManager.emptyString
        }

        passwordItem.focus = true;
    }

    function onPageClosed(settingsObject) {
        // TODO: set password on the final page
        // settingsObject.wallet.setPassword(passwordItem.password)
        settingsObject['wallet_password'] = passwordItem.password
        return true
    }

    function onWizardRestarted(){
        // Reset password fields
        passwordItem.password = "";
        retypePasswordItem.password = "";
    }

    function handlePassword() {
        // allow to forward step only if passwords match

        wizard.nextButton.enabled = passwordItem.password === retypePasswordItem.password

        // scorePassword returns value from 0 to... lots
        var strength = walletManager.getPasswordStrength(passwordItem.password);
        // consider anything below 10 bits as dire
        strength -= 10
        if (strength < 0)
            strength = 0
        // use a slight parabola to discourage short passwords
        strength = strength ^ 1.2 / 3
        // privacyLevel component uses 1..13 scale
        privacyLevel.fillLevel = Utils.mapScope(1, 100, 1, 13, strength)

    }



    Row {
        id: dotsRow
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 85
        spacing: 6

        ListModel {
            id: dotsModel
            ListElement { dotColor: "#36B05B" }
            ListElement { dotColor: "#FFE00A" }
            ListElement { dotColor: "#DBDBDB" }
            ListElement { dotColor: "#DBDBDB" }
        }

        Repeater {
            model: dotsModel
            delegate: Rectangle {
                width: 12; height: 12
                radius: 6
                color: dotColor
            }
        }
    }

    Column {
        id: headerColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.top: parent.top
        anchors.topMargin: 74
        spacing: 24

        Text {
            id: titleText
            anchors.left: parent.left
            width: headerColumn.width - dotsRow.width - 16
            font.family: "Arial"
            font.pixelSize: 28
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            //renderType: Text.NativeRendering
            color: "#3F3F3F"

        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 18
            wrapMode: Text.Wrap
            //renderType: Text.NativeRendering
            color: "#4A4646"
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Note: this password cannot be recovered. If you forget it then the wallet will have to be restored from its 25 word mnemonic seed.<br/><br/>
                        Enter a secure password (using letters, numbers, and/or symbols):")
                    + translationManager.emptyString
        }
    }


    WizardPasswordInput {
        id: passwordItem
        anchors.top: headerColumn.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        width: 300
        height: 62
        placeholderText : qsTr("Password") + translationManager.emptyString;
        KeyNavigation.tab: retypePasswordItem
        onChanged: handlePassword()

    }

    WizardPasswordInput {
        id: retypePasswordItem
        anchors.top: passwordItem.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        width: 300
        height: 62
        placeholderText : qsTr("Confirm password") + translationManager.emptyString;
        KeyNavigation.tab: passwordItem
        onChanged: handlePassword()
    }

    PrivacyLevelSmall {
        id: privacyLevel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: retypePasswordItem.bottom
        anchors.topMargin: 60
        background: "#F0EEEE"
        interactive: false
    }

    Component.onCompleted: {
        parent.wizardRestarted.connect(onWizardRestarted)
    }
}
