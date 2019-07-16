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
    z: parent.z + 2

    property bool isHidden: true
    property alias password: passwordInput1.text
    property string walletName
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
        isHidden = true
        capsLockTextLabel.visible = oshelper.isCapsLock();
        passwordInput1.echoMode = TextInput.Password
        passwordInput2.echoMode = TextInput.Password
        passwordInput1.text = ""
        passwordInput2.text = ""
        passwordInput1.forceActiveFocus();
        inactiveOverlay.visible = true // draw appwindow inactive
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

    function open(walletName, errorText) {
        passwordDialogMode = true;
        passphraseDialogMode = false;
        newPasswordDialogMode = false;
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
        inactiveOverlay.visible = false
        leftPanel.enabled = true
        middlePanel.enabled = true
        wizard.enabled = true
        titleBar.state = "default"

        root.visible = false;
        appWindow.hideBalanceForced = false;
        appWindow.updateBalance();
        closeCallback();
    }

    function toggleIsHidden() {
        passwordInput1.echoMode = isHidden ? TextInput.Normal : TextInput.Password;
        passwordInput2.echoMode = isHidden ? TextInput.Normal : TextInput.Password;
        isHidden = !isHidden;
    }

    ColumnLayout {
        z: inactiveOverlay.z + 1
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

            TextField {
                id: passwordInput1
                Layout.topMargin: 6
                Layout.fillWidth: true
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: TextInput.AlignVCenter
                font.family: MoneroComponents.Style.fontLight.name
                font.pixelSize: 24
                echoMode: TextInput.Password
                KeyNavigation.tab: {
                    if (passwordDialogMode) {
                        return okButton
                    } else {
                        return passwordInput2
                    }
                }
                bottomPadding: 10
                leftPadding: 10
                topPadding: 10
                color: MoneroComponents.Style.defaultFontColor
                selectionColor: MoneroComponents.Style.textSelectionColor
                selectedTextColor: MoneroComponents.Style.textSelectedColor
                onTextChanged: capsLockTextLabel.visible = oshelper.isCapsLock();

                background: Rectangle {
                    radius: 2
                    color: MoneroComponents.Style.blackTheme ? "black" : "#A9FFFFFF"
                    border.color: MoneroComponents.Style.inputBorderColorInActive
                    border.width: 1

                    MoneroEffects.ColorTransition {
                        targetObj: parent
                        blackColor: "black"
                        whiteColor: "#A9FFFFFF"
                    }

                    MoneroComponents.Label {
                        fontSize: 20
                        text: isHidden ? FontAwesome.eye : FontAwesome.eyeSlash
                        opacity: 0.7
                        fontFamily: FontAwesome.fontFamily
                        anchors.right: parent.right
                        anchors.rightMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                toggleIsHidden();
                            }
                            onEntered: {
                                parent.opacity = 0.9
                                parent.fontSize = 24
                            }
                            onExited: {
                                parent.opacity = 0.7
                                parent.fontSize = 20
                            }
                        }
                    }
                }

                Keys.enabled: root.visible
                Keys.onReturnPressed: {
                    root.close()
                    if (passwordDialogMode) {
                        root.accepted()
                    } else if (newPasswordDialogMode) {
                        root.acceptedNewPassword()
                    } else if (passphraseDialogMode) {
                        root.acceptedPassphrase()
                    }
                }
                Keys.onEscapePressed: {
                    root.close()
                    if (passwordDialogMode) {
                        root.rejected()
                    } else if (newPasswordDialogMode) {
                        root.rejectedNewPassword()
                    } else if (passphraseDialogMode) {
                        root.rejectedPassphrase()
                    }
                }
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

            TextField {
                id: passwordInput2
                visible: !passwordDialogMode
                Layout.topMargin: 6
                Layout.fillWidth: true
                horizontalAlignment: TextInput.AlignLeft
                verticalAlignment: TextInput.AlignVCenter
                font.family: MoneroComponents.Style.fontLight.name
                font.pixelSize: 24
                echoMode: TextInput.Password
                KeyNavigation.tab: okButton
                bottomPadding: 10
                leftPadding: 10
                topPadding: 10
                color: MoneroComponents.Style.defaultFontColor
                selectionColor: MoneroComponents.Style.textSelectionColor
                selectedTextColor: MoneroComponents.Style.textSelectedColor
                onTextChanged: capsLockTextLabel.visible = oshelper.isCapsLock();

                background: Rectangle {
                    radius: 2
                    border.color: MoneroComponents.Style.inputBorderColorInActive
                    border.width: 1
                    color: MoneroComponents.Style.blackTheme ? "black" : "#A9FFFFFF"

                    MoneroComponents.Label {
                        fontSize: 20
                        text: isHidden ? FontAwesome.eye : FontAwesome.eyeSlash
                        opacity: 0.7
                        fontFamily: FontAwesome.fontFamily
                        anchors.right: parent.right
                        anchors.rightMargin: 15
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: {
                                toggleIsHidden()
                            }
                            onEntered: {
                                parent.opacity = 0.9
                                parent.fontSize = 24
                            }
                            onExited: {
                                parent.opacity = 0.7
                                parent.fontSize = 20
                            }
                        }
                    }
                }

                Keys.onReturnPressed: {
                    if (passwordInput1.text === passwordInput2.text) {
                        root.close()
                        if (newPasswordDialogMode) {
                            root.acceptedNewPassword()
                        } else if (passphraseDialogMode) {
                            root.acceptedPassphrase()
                        }
                    }
                }
                Keys.onEscapePressed: {
                    root.close()
                    if (newPasswordDialogMode) {
                        root.rejectedNewPassword()
                    } else if (passphraseDialogMode) {
                        root.rejectedPassphrase()
                    }
                }
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
                    small: true
                    text: root.walletName.length > 0 ? qsTr("Change wallet") + translationManager.emptyString : qsTr("Cancel") + translationManager.emptyString
                    KeyNavigation.tab: passwordInput1
                    onClicked: {
                        root.close()
                        if (passwordDialogMode) {
                            root.rejected()
                        } else if (newPasswordDialogMode) {
                            root.rejectedNewPassword()
                        } else if (passphraseDialogMode) {
                            root.rejectedPassphrase()
                        }
                    }
                }

                MoneroComponents.StandardButton {
                    id: okButton
                    small: true
                    text: qsTr("Continue") + translationManager.emptyString
                    KeyNavigation.tab: cancelButton
                    enabled: (passwordDialogMode == true) ? true : passwordInput1.text === passwordInput2.text
                    onClicked: {
                        root.close()
                        if (passwordDialogMode) {
                            root.accepted()
                        } else if (newPasswordDialogMode) {
                            root.acceptedNewPassword()
                        } else if (passphraseDialogMode) {
                            root.acceptedPassphrase()
                        }
                    }
                }
            }
        }
    }
}
