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
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

// Modal that prompts the user for the 6-digit pairing code shown on a
// Trezor Safe 7 during the THP CodeEntry pairing flow.
FocusScope {
    id: root
    visible: false

    // onAcceptedCallback is invoked with the entered code (string of 6
    // ASCII digits).  onRejectedCallback is invoked when the user cancels.
    // Both are cleared once one of them has fired.
    property var onAcceptedCallback
    property var onRejectedCallback

    // Message shown above the input, set by the caller when a previous
    // code was rejected by the device.
    property string errorText

    function open() {
        // Same modal behaviour as PasswordDialog: a wallet pool thread
        // is blocked waiting for the code, so the UI behind the dialog
        // must not accept input (e.g. starting a second wallet open
        // would hang forever on the same device).
        leftPanel.enabled = false;
        middlePanel.enabled = false;
        wizard.enabled = false;
        titleBar.state = "essentials";
        root.visible = true;
        codeInput.text = "";
        codeInput.forceActiveFocus();
    }

    function close() {
        leftPanel.enabled = true;
        middlePanel.enabled = true;
        wizard.enabled = !wizard.deviceWalletCreationInProgress;
        if (rootItem.state == "wizard") {
            titleBar.state = "essentials";
        } else {
            titleBar.state = "default";
        }
        root.visible = false;
        root.errorText = "";
    }

    function onOk() {
        if (codeInput.text.length !== 6) {
            return;
        }
        var entered = codeInput.text;
        var callback = root.onAcceptedCallback;
        root.onAcceptedCallback = null;
        root.onRejectedCallback = null;
        root.close();
        if (callback) {
            callback(entered);
        }
    }

    function onCancel() {
        if (!root.visible) {
            return;
        }
        var callback = root.onRejectedCallback;
        root.onAcceptedCallback = null;
        root.onRejectedCallback = null;
        root.close();
        if (callback) {
            callback();
        }
    }

    Keys.enabled: root.visible
    Keys.onEscapePressed: root.onCancel()

    ColumnLayout {
        id: mainLayout
        spacing: 10
        anchors.fill: parent
        anchors.margins: 35

        ColumnLayout {
            id: column

            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.maximumWidth: 480

            Label {
                Layout.fillWidth: true
                text: qsTr("Trezor Safe 7 - pair this computer") + translationManager.emptyString
                font.pixelSize: 18
                font.family: MoneroComponents.Style.fontBold.name
                font.bold: true
                color: MoneroComponents.Style.defaultFontColor
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 12
                text: qsTr("Your Trezor is showing a 6-digit code on its screen. " +
                           "Type that exact code here to confirm this computer is allowed to talk to it. " +
                           "After this one-time pairing, the computer is remembered and you won't be asked again.") + translationManager.emptyString
                font.pixelSize: 14
                font.family: MoneroComponents.Style.fontLight.name
                color: MoneroComponents.Style.defaultFontColor
                wrapMode: Text.WordWrap
            }

            Label {
                id: errorTextLabel
                visible: text !== ""
                text: root.errorText
                Layout.fillWidth: true
                Layout.topMargin: 12
                font.pixelSize: 14
                font.family: MoneroComponents.Style.fontLight.name
                color: MoneroComponents.Style.errorColor
                wrapMode: Text.WordWrap
            }

            MoneroComponents.Input {
                id: codeInput
                focus: true
                Layout.topMargin: 16
                Layout.fillWidth: true
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                font.family: MoneroComponents.Style.fontBold.name
                font.pixelSize: 32
                font.letterSpacing: 6
                bottomPadding: 12
                leftPadding: 10
                topPadding: 12
                color: MoneroComponents.Style.defaultFontColor
                selectionColor: MoneroComponents.Style.textSelectionColor
                selectedTextColor: MoneroComponents.Style.textSelectedColor
                inputMethodHints: Qt.ImhDigitsOnly

                // js replacement for `RegExpValidator { regExp: /[0-9]{0,6}/ }`,
                // which rejects a paste outright: a code copied as
                // "12 34 56" or "123-456" would insert nothing at all.
                onTextChanged: {
                    var digits = codeInput.text.replace(/[^0-9]/g, "").substring(0, 6);
                    if (digits !== codeInput.text) {
                        codeInput.text = digits;
                        codeInput.cursorPosition = digits.length;
                    }
                }

                background: Rectangle {
                    radius: 2
                    border.color: MoneroComponents.Style.inputBorderColorActive
                    border.width: 1
                    color: MoneroComponents.Style.blackTheme ? "black" : "#A9FFFFFF"
                }

                Keys.enabled: root.visible
                Keys.onEnterPressed: root.onOk()
                Keys.onReturnPressed: root.onOk()
                Keys.onEscapePressed: root.onCancel()
            }

            Label {
                Layout.fillWidth: true
                Layout.topMargin: 8
                text: qsTr("Tip: nobody, not even a fake Trezor, can guess this code. " +
                           "If you mistype it, pairing starts over and the device shows a fresh code.") + translationManager.emptyString
                font.pixelSize: 12
                font.italic: true
                font.family: MoneroComponents.Style.fontLight.name
                color: MoneroComponents.Style.dimmedFontColor
                wrapMode: Text.WordWrap
            }

            RowLayout {
                spacing: 16
                Layout.topMargin: 16
                Layout.alignment: Qt.AlignRight

                MoneroComponents.StandardButton {
                    primary: false
                    small: true
                    width: 120
                    fontSize: 14
                    text: qsTr("Cancel") + translationManager.emptyString
                    onClicked: root.onCancel()
                }
                MoneroComponents.StandardButton {
                    small: true
                    width: 120
                    fontSize: 14
                    text: qsTr("Confirm") + translationManager.emptyString
                    enabled: codeInput.text.length === 6
                    onClicked: root.onOk()
                }
            }
        }
    }
}
