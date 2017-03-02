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
import QtQuick.Layouts 1.1
import "../components"
import "utils.js" as Utils

ColumnLayout {
    property alias password: passwordItem.password
    property alias confirmPassword: retypePasswordItem.password
    property bool passwordsMatch: passwordItem.password === retypePasswordItem.password

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
      // mapScope does not clamp
      if (strength > 100)
          strength = 100
      // privacyLevel component uses 1..13 scale
      privacyLevel.fillLevel = Utils.mapScope(1, 100, 1, 13, strength)      
    }

    function resetFocus() {
        passwordItem.focus = true
    }

    WizardPasswordInput {
        id: passwordItem
        Layout.fillWidth: true
        Layout.maximumWidth: 300
        Layout.minimumWidth: 200
        Layout.alignment: Qt.AlignHCenter
        placeholderText : qsTr("Password") + translationManager.emptyString;
        KeyNavigation.tab: retypePasswordItem
        onChanged: handlePassword()
        focus: true
    }

    WizardPasswordInput {
        id: retypePasswordItem
        Layout.fillWidth: true
        Layout.maximumWidth: 300
        Layout.minimumWidth: 200
        Layout.alignment: Qt.AlignHCenter
        placeholderText : qsTr("Confirm password") + translationManager.emptyString;
        KeyNavigation.tab: passwordItem
        onChanged: handlePassword()
    }

    PrivacyLevelSmall {
        Layout.topMargin: isMobile ? 20 : 40
        Layout.fillWidth: true
        id: privacyLevel
        background: "#F0EEEE"
        interactive: false
    }

    Component.onCompleted: {
        //parent.wizardRestarted.connect(onWizardRestarted)
    }
}
