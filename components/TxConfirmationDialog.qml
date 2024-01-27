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
import QtQuick.Controls 1.4 as QtQuickControls1
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents
import FontAwesome 1.0

Rectangle {
    id: root

    property int margins: 25

    x: parent.width/2 - root.width/2
    y: parent.height/2 - root.height/2
    // TODO: implement without hardcoding sizes
    width: 590
    height: layout.height + layout.anchors.margins * 2
    color: MoneroComponents.Style.blackTheme ? "black" : "white"
    visible: false
    radius: 10
    border.color: MoneroComponents.Style.blackTheme ? Qt.rgba(255, 255, 255, 0.25) : Qt.rgba(0, 0, 0, 0.25)
    border.width: 1
    Keys.enabled: true
    Keys.onEscapePressed: {
        root.close()
        root.clearFields()
        root.rejected()
    }
    KeyNavigation.tab: confirmButton

    property var recipients: []
    property var transactionAmount: ""
    property var transactionDescription: ""
    property var transactionFee: ""
    property var transactionPriority: ""
    property bool sweepUnmixable: false
    property alias errorText: errorText
    property alias confirmButton: confirmButton
    property alias backButton: backButton
    property alias bottomText: bottomText
    property alias bottomTextAnimation: bottomTextAnimation

    state: "default"
    states: [
        State {
            // waiting for user action, show tx details + back and confirm buttons
            name: "default";
            when: errorText.text == "" && bottomText.text == ""
            PropertyChanges { target: errorText; visible: false }
            PropertyChanges { target: txAmountText; visible: root.transactionAmount !== "(all)" || (root.transactionAmount === "(all)" && currentWallet.isHwBacked() === true) }
            PropertyChanges { target: txAmountBusyIndicator; visible: !txAmountText.visible }
            PropertyChanges { target: txFiatAmountText; visible: txAmountText.visible && persistentSettings.fiatPriceEnabled && root.transactionAmount !== "(all)" }
            PropertyChanges { target: txDetails; visible: true }
            PropertyChanges { target: bottom; visible: true }
            PropertyChanges { target: bottomMessage; visible: false }
            PropertyChanges { target: buttons; visible: true }
            PropertyChanges { target: backButton; visible: true; primary: false }
            PropertyChanges { target: confirmButton; visible: true; focus: true }
        }, State {
            // error message being displayed, show only back button
            name: "error";
            when: errorText.text !== ""
            PropertyChanges { target: dialogTitle; text: "Error" }
            PropertyChanges { target: errorText; visible: true }
            PropertyChanges { target: txAmountText; visible: false }
            PropertyChanges { target: txAmountBusyIndicator; visible: false }
            PropertyChanges { target: txFiatAmountText; visible: false }
            PropertyChanges { target: txDetails; visible: false }
            PropertyChanges { target: bottom; visible: true }
            PropertyChanges { target: bottomMessage; visible: false }
            PropertyChanges { target: buttons; visible: true }
            PropertyChanges { target: backButton; visible: true; primary: true; focus: true }
            PropertyChanges { target: confirmButton; visible: false }
        }, State {
            // creating or sending transaction, show tx details and don't show any button
            name: "bottomText";
            when: errorText.text == "" && bottomText.text !== ""
            PropertyChanges { target: errorText; visible: false }
            PropertyChanges { target: txAmountText; visible: root.transactionAmount !== "(all)" || (root.transactionAmount === "(all)" && currentWallet.isHwBacked() === true) }
            PropertyChanges { target: txAmountBusyIndicator; visible: !txAmountText.visible }
            PropertyChanges { target: txFiatAmountText; visible: txAmountText.visible && persistentSettings.fiatPriceEnabled && root.transactionAmount !== "(all)" }
            PropertyChanges { target: txDetails; visible: true }
            PropertyChanges { target: bottom; visible: true }
            PropertyChanges { target: bottomMessage; visible: true }
            PropertyChanges { target: buttons; visible: false }
        }
    ]

    // same signals as Dialog has
    signal accepted()
    signal rejected()

    function open() {
        root.visible = true;

        //clean previous error message
        errorText.text = "";
    }

    function close() {
        root.visible = false;
    }

    function clearFields() {
        root.recipients = [];
        root.transactionAmount = "";
        root.transactionDescription = "";
        root.transactionFee = "";
        root.transactionPriority = "";
        root.sweepUnmixable = false;
    }

    function showFiatConversion(valueXMR) {
        const fiatFee = fiatApiConvertToFiat(valueXMR);
        return "%1 %2".arg(fiatFee < 0.01 ? "&lt;0.01" : "~" + fiatFee).arg(fiatApiCurrencySymbol());
    }

    ColumnLayout {
        id: layout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: parent.margins
        spacing: 10

        RowLayout {
            Layout.topMargin: 10
            Layout.fillWidth: true

            MoneroComponents.Label {
                id: dialogTitle
                Layout.fillWidth: true
                fontSize: 18
                fontFamily: "Arial"
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (appWindow.viewOnly) {
                        return qsTr("Create transaction file") + translationManager.emptyString;
                    } else if (root.sweepUnmixable) {
                        return qsTr("Sweep unmixable outputs") + translationManager.emptyString;
                    } else {
                        return qsTr("Confirm send") + translationManager.emptyString;
                    }
                }
            }
        }

        Text {
            id: errorText
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: MoneroComponents.Style.defaultFontColor
            wrapMode: Text.Wrap
            font.pixelSize: 15
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.preferredHeight: 71

            QtQuickControls1.BusyIndicator {
                id: txAmountBusyIndicator
                Layout.fillHeight: true
                Layout.fillWidth: true
                running: root.transactionAmount == "(all)"
            }

            Text {
                id: txAmountText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: root.transactionAmount == "(all)" && currentWallet.isHwBacked() === true ? 32 : 42
                color: MoneroComponents.Style.defaultFontColor
                text: {
                    if (root.transactionAmount == "(all)" && currentWallet.isHwBacked() === true) {
                        return qsTr("All unlocked balance") +  translationManager.emptyString;
                    } else {
                        return root.transactionAmount + " XMR " +  translationManager.emptyString;
                    }
                }
            }

            Text {
                id: txFiatAmountText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                color: MoneroComponents.Style.buttonSecondaryTextColor
                text: showFiatConversion(transactionAmount) + translationManager.emptyString
            }
        }

        GridLayout {
            columns: 2
            id: txDetails
            Layout.fillWidth: true
            columnSpacing: 15
            rowSpacing: 16

            Text {
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("From") + ":" + translationManager.emptyString
                font.pixelSize: 15
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    color: MoneroComponents.Style.defaultFontColor
                    text: {
                        if (currentWallet) {
                            var walletTitle = function() {
                                if (currentWallet.isLedger()) {
                                    return "Ledger";
                                } else if (currentWallet.isTrezor()) {
                                    return "Trezor";
                                } else {
                                    return qsTr("My wallet");
                                }
                            }
                            var walletName = appWindow.walletName;
                            if (appWindow.currentWallet.numSubaddressAccounts() > 1) {
                                var currentSubaddressAccount = currentWallet.currentSubaddressAccount;
                                var currentAccountLabel =  currentWallet.getSubaddressLabel(currentWallet.currentSubaddressAccount, 0);
                                return walletTitle() + " (" + walletName + ")" + "<br>" + qsTr("Account #") + currentSubaddressAccount + (currentAccountLabel !== "" ? " (" + currentAccountLabel + ")" : "") + translationManager.emptyString;
                            } else {
                                return walletTitle() + " (" + walletName + ")" + translationManager.emptyString;
                            }
                        } else {
                            return "";
                        }
                    }
                }
            }

            Text {
                font.pixelSize: 15
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("To") + ":" + translationManager.emptyString
            }

            Flickable {
                id: flickable
                property int linesInMultipleRecipientsMode: 7
                Layout.fillWidth: true
                Layout.preferredHeight: recipients.length > 1
                    ? linesInMultipleRecipientsMode * (recipientsArea.contentHeight / recipientsArea.lineCount)
                    : recipientsArea.contentHeight
                boundsBehavior: isMac ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds
                clip: true

                TextArea.flickable: TextArea {
                    id : recipientsArea
                    color: MoneroComponents.Style.defaultFontColor
                    font.family: MoneroComponents.Style.fontMonoRegular.name
                    font.pixelSize: 14
                    topPadding: 0
                    bottomPadding: 0
                    leftPadding: 0
                    textMargin: 0
                    readOnly: true
                    selectByKeyboard: true
                    selectByMouse: true
                    selectionColor: MoneroComponents.Style.textSelectionColor
                    textFormat: TextEdit.RichText
                    wrapMode: TextEdit.Wrap
                    text: {
                        return recipients.map(function (recipient, index) {
                            var addressBookName = null;
                            if (currentWallet) {
                                addressBookName = currentWallet.addressBook.getDescription(recipient.address);
                            }
                            var title;
                            if (addressBookName) {
                                title = FontAwesome.addressBook + " " + addressBookName;
                            } else {
                                title = qsTr("Monero address") + translationManager.emptyString;
                            }
                            if (recipients.length > 1) {
                                title = "%1. %2 - %3 XMR".arg(index + 1).arg(title).arg(recipient.amount);
                                if (persistentSettings.fiatPriceEnabled) {
                                    title += " (%1)".arg(showFiatConversion(recipient.amount));
                                }
                            }
                            const spacedaddress = recipient.address.match(/.{1,4}/g).join(' ');
                            return title + "<br>" + spacedaddress;
                        }).join("<br><br>");
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: recipientsArea.contentHeight > flickable.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
                }
            }

            Text {
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("Fee") + ":" + translationManager.emptyString
                font.pixelSize: 15
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Text {
                    property bool maliciousTxFee: parseFloat(root.transactionFee) > 0.01
                    color: maliciousTxFee ? "red" : MoneroComponents.Style.defaultFontColor
                    font.pixelSize: maliciousTxFee ? 20 : 15
                    text: {
                        if (currentWallet) {
                            if (!root.transactionFee) {
                                if (currentWallet.isHwBacked() === true) {
                                    return qsTr("See on device") +  translationManager.emptyString;
                                } else {
                                    return qsTr("Calculating fee") + "..." +  translationManager.emptyString;
                                }
                            } else {
                                return root.transactionFee + " XMR" + (maliciousTxFee ? " (HIGH FEE)" : "")
                            }
                        } else {
                            return "";
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    color: MoneroComponents.Style.buttonSecondaryTextColor
                    visible: persistentSettings.fiatPriceEnabled && root.transactionFee
                    font.pixelSize: 15
                    text: showFiatConversion(root.transactionFee)
                }
            }
        }

        ColumnLayout {
            id: bottom
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
            Layout.fillWidth: true

            RowLayout {
                id: bottomMessage
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                QtQuickControls1.BusyIndicator {
                    visible: !bottomTextAnimation.running
                    running: !bottomTextAnimation.running
                    scale: .5
                }

                Text {
                    id: bottomText
                    color: MoneroComponents.Style.defaultFontColor
                    text: ""
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.pixelSize: 17
                    opacity: 1

                    SequentialAnimation{
                        id:bottomTextAnimation
                        running: false
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        NumberAnimation { target: bottomText; property: "opacity"; to: 0; duration: 500}
                        NumberAnimation { target: bottomText; property: "opacity"; to: 1; duration: 500}
                    }
                }
            }

            RowLayout {
                id: buttons
                spacing: 70
                Layout.fillWidth: true
                Layout.preferredHeight: 50

                MoneroComponents.StandardButton {
                    id: backButton
                    text: qsTr("Back") + translationManager.emptyString;
                    width: 200
                    primary: false
                    KeyNavigation.tab: confirmButton
                    onClicked: {
                        root.close()
                        root.clearFields()
                        root.rejected()
                    }
                }

                MoneroComponents.StandardButton {
                    id: confirmButton
                    text: qsTr("Confirm") + translationManager.emptyString;
                    rightIcon: "qrc:///images/rightArrow.png"
                    width: 200
                    KeyNavigation.tab: backButton
                    onClicked: {
                        root.close()
                        root.accepted()
                    }
                }
            }
        }
    }
}
