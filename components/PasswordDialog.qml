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
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0
import FontAwesome 1.0

import "." as MoneroComponents
import "effects/" as MoneroEffects
import "../js/Utils.js" as Utils

Item {
    id: root
    visible: false

    property alias password: passwordInput1.text
    property string walletName
    property var okButtonText
    property string okButtonIcon
    property string errorText
    property bool passwordDialogMode
    property bool passphraseDialogMode
    property bool newPasswordDialogMode

    // same signals as Dialog has
    signal accepted()
    signal acceptedNewPassword()
    signal acceptedPassphrase()
    signal rejected()
    signal rejectedNewPassword()
    signal rejectedPassphrase()
    signal closeCallback()

    function _openInit(walletName, errorText) {
        capsLockTextLabel.visible = oshelper.isCapsLock();
        passwordInput1.reset();
        passwordInput2.reset();
        if(!appWindow.currentWallet || appWindow.active)
            passwordInput1.input.forceActiveFocus();
        root.walletName = walletName ? walletName : ""
        errorTextLabel.text = errorText ? errorText : "";
        leftPanel.enabled = false
        middlePanel.enabled = false
        wizard.enabled = false
        titleBar.state = "essentials"
        root.visible = true;
        appWindow.hideBalanceForced = true;
        appWindow.updateBalance();
    }

    function open(walletName, errorText, okButtonText, okButtonIcon) {
        passwordDialogMode = true;
        passphraseDialogMode = false;
        newPasswordDialogMode = false;
        root.okButtonText = okButtonText;
        root.okButtonIcon = okButtonIcon ? okButtonIcon : "";
        _openInit(walletName, errorText);
    }

    function openPassphraseDialog() {
        passwordDialogMode = false;
        passphraseDialogMode = true;
        newPasswordDialogMode = false;
        _openInit("", "");
    }

    function openNewPasswordDialog() {
        passwordDialogMode = false;
        passphraseDialogMode = false;
        newPasswordDialogMode = true;
        _openInit("", "");
    }

    function showError(errorText) {
        open(root.walletName, errorText);
    }

    function close() {
        leftPanel.enabled = true
        middlePanel.enabled = true
        wizard.enabled = true
        if (rootItem.state == "wizard") {
            titleBar.state = "essentials"
        } else {
            titleBar.state = "default"
        }

        root.visible = false;
        appWindow.hideBalanceForced = false;
        appWindow.updateBalance();
        closeCallback();
    }

    function onOk() {
        if (!passwordDialogMode && passwordInput1.text !== passwordInput2.text) {
            return;
        }
        root.close()
        if (passwordDialogMode) {
            root.accepted()
        } else if (newPasswordDialogMode) {
            root.acceptedNewPassword()
        } else if (passphraseDialogMode) {
            root.acceptedPassphrase()
        }
    }

    function onCancel() {
        root.close()
        if (passwordDialogMode) {
            root.rejected()
        } else if (newPasswordDialogMode) {
            root.rejectedNewPassword()
        } else if (passphraseDialogMode) {
            root.rejectedPassphrase()
        }
    }

    ColumnLayout {
        id: mainLayout
        spacing: 10
        anchors { fill: parent; margins: 35 }

        ColumnLayout {
            id: column

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 400

            Label {
                text: {
                    if (newPasswordDialogMode) {
                        return qsTr("Please enter new wallet password") + translationManager.emptyString;
                    } else {
                        var device = passwordDialogMode ? qsTr("wallet password") : qsTr("wallet device passphrase");
                        return (root.walletName.length > 0 ? qsTr("Please enter %1 for: ").arg(device) + root.walletName : qsTr("Please enter %1").arg(device)) + translationManager.emptyString;
                    }
                }
                Layout.fillWidth: true

                font.pixelSize: 16
                font.family: MoneroComponents.Style.fontLight.name

                color: MoneroComponents.Style.defaultFontColor
            }

            Label {
                text: qsTr("Warning: passphrase entry on host is a security risk as it can be captured by malware. It is advised to prefer device-based passphrase entry.") + translationManager.emptyString
                visible: passphraseDialogMode
                Layout.fillWidth: true
                wrapMode: Text.Wrap

                font.pixelSize: 14
                font.family: MoneroComponents.Style.fontLight.name

                color: MoneroComponents.Style.warningColor
            }

            Label {
                id: errorTextLabel
                visible: root.errorText || text !== ""
                color: MoneroComponents.Style.errorColor
                font.pixelSize: 16
                font.family: MoneroComponents.Style.fontLight.name
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            Label {
                id: capsLockTextLabel
                visible: false
                color: MoneroComponents.Style.errorColor
                font.pixelSize: 16
                font.family: MoneroComponents.Style.fontLight.name
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                text: qsTr("CAPSLOCKS IS ON.") + translationManager.emptyString;
            }

            MoneroComponents.LineEdit {
                id: passwordInput1
                password: true
                Layout.topMargin: 6
                Layout.fillWidth: true
                KeyNavigation.tab: {
                    if (passwordDialogMode) {
                        return okButton
                    } else {
                        return passwordInput2
                    }
                }
                onTextChanged: capsLockTextLabel.visible = oshelper.isCapsLock();

                Keys.enabled: root.visible
                Keys.onEnterPressed: root.onOk()
                Keys.onReturnPressed: root.onOk()
                Keys.onEscapePressed: root.onCancel()
            }

            // padding
            Rectangle {
                visible: !passwordDialogMode
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                height: 10
                opacity: 0
                color: "black"
            }

            Label {
                visible: !passwordDialogMode
                text: newPasswordDialogMode ? qsTr("Please confirm new password") : qsTr("Please confirm wallet device passphrase") + translationManager.emptyString
                Layout.fillWidth: true

                font.pixelSize: 16
                font.family: MoneroComponents.Style.fontLight.name

                color: MoneroComponents.Style.defaultFontColor
            }

            MoneroComponents.LineEdit {
                id: passwordInput2
                passwordLinked: passwordInput1
                visible: !passwordDialogMode
                Layout.topMargin: 6
                Layout.fillWidth: true
                KeyNavigation.tab: okButton
                onTextChanged: capsLockTextLabel.visible = oshelper.isCapsLock();

                Keys.enabled: root.visible
                Keys.onEnterPressed: root.onOk()
                Keys.onReturnPressed: root.onOk()
                Keys.onEscapePressed: root.onCancel()
            }

            // padding
            Rectangle {
                visible: !passwordDialogMode
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                height: 10
                opacity: 0
                color: "black"
            }

            // Ok/Cancel buttons
            RowLayout {
                id: buttons
                spacing: 16
                Layout.topMargin: 16
                Layout.alignment: Qt.AlignRight

                MoneroComponents.StandardButton {
                    id: cancelButton
                    primary: false
                    small: true
                    text: qsTr("Cancel") + translationManager.emptyString
                    KeyNavigation.tab: passwordInput1
                    onClicked: onCancel()
                }

                MoneroComponents.StandardButton {
                    id: okButton
                    fontAwesomeIcon: true
                    rightIcon: okButtonIcon
                    small: true
                    text: okButtonText ? okButtonText : qsTr("Ok") + translationManager.emptyString
                    KeyNavigation.tab: cancelButton
                    enabled: (passwordDialogMode == true) ? true : passwordInput1.text === passwordInput2.text
                    onClicked: onOk()
                }
            }
        }
    }
}
