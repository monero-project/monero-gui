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
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

import "../js/TxUtils.js" as TxUtils
import moneroComponents.AddressBook 1.0
import moneroComponents.AddressBookModel 1.0
import moneroComponents.Clipboard 1.0
import moneroComponents.NetworkType 1.0
import FontAwesome 1.0

Rectangle {
    id: root
    color: "transparent"
    property alias addressbookHeight: mainLayout.height
    property bool selectAndSend: false
    property bool editEntry: false

    Clipboard { id: clipboard }

    ColumnLayout {
        id: mainLayout
        anchors.margins: 20
        anchors.topMargin: 40

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        spacing: 20

        ColumnLayout {
            id: addressBookEmptyLayout
            visible: addressBookListView.count == 0
            spacing: 0
            Layout.fillWidth: true

            Text {
                id: titleLabel
                Layout.fillWidth: true
                color: MoneroComponents.Style.defaultFontColor
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 32
                horizontalAlignment: TextInput.AlignLeft
                wrapMode: Text.WordWrap;
                leftPadding: 0
                topPadding: 0
                text: qsTr("Save your most used addresses here") + translationManager.emptyString
                width: parent.width
            }

            Text {
                Layout.fillWidth: true
                color: MoneroComponents.Style.dimmedFontColor
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 16
                horizontalAlignment: TextInput.AlignLeft
                wrapMode: Text.WordWrap;
                leftPadding: 0
                topPadding: 0
                text: qsTr("This makes it easier to send or receive Monero and reduces errors when typing in addresses manually.") + translationManager.emptyString
                width: parent.width
            }

            MoneroComponents.StandardButton {
                id: addFirstEntryButton
                Layout.topMargin: 20
                text: qsTr("Add an address") + translationManager.emptyString
                onClicked: {
                    root.showAddAddress();
                }
            }
        }

        ColumnLayout {
            id: addressBookLayout
            visible: addressBookListView.count >= 1
            spacing: 0

            MoneroComponents.Label {
                Layout.bottomMargin: 20
                fontSize: 32
                text: qsTr("Address book") + translationManager.emptyString
            }

            ColumnLayout {
                id: addressBookListRow
                property int addressBookListItemHeight: 50
                Layout.fillWidth: true
                Layout.minimumWidth: 240
                Layout.preferredHeight: addressBookListItemHeight * addressBookListView.count

                ListView {
                    id: addressBookListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    boundsBehavior: ListView.StopAtBounds
                    interactive: false
                    delegate: Rectangle {
                        id: tableItem2
                        height: addressBookListRow.addressBookListItemHeight
                        width: parent ? parent.width : undefined
                        Layout.fillWidth: true
                        color: "transparent"

                        function doSend() {
                            console.log("Sending to: ", address +" "+ paymentId);
                            middlePanel.sendTo(address, paymentId);
                            leftPanel.selectItem(middlePanel.state)
                        }

                        Rectangle {
                            color: MoneroComponents.Style.appWindowBorderColor
                            anchors.right: parent.right
                            anchors.left: parent.left
                            anchors.top: parent.top
                            height: 1

                            MoneroEffects.ColorTransition {
                                targetObj: parent
                                blackColor: MoneroComponents.Style._b_appWindowBorderColor
                                whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 5
                            anchors.rightMargin: 110
                            color: "transparent"

                            MoneroComponents.Label {
                                id: descriptionLabel
                                color: MoneroComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                fontSize: 16
                                text: description
                                elide: Text.ElideRight
                                textWidth: addressLabel.x - descriptionLabel.x - 1
                            }

                            MoneroComponents.Label {
                                id: addressLabel
                                color: MoneroComponents.Style.defaultFontColor
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.right
                                anchors.leftMargin: -addressLabel.width - 5

                                fontSize: 16
                                fontFamily: MoneroComponents.Style.fontMonoRegular.name;
                                text: TxUtils.addressTruncatePretty(address, mainLayout.width < 540 ? 1 : (mainLayout.width < 700 ? 2 : 3));
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                visible: root.selectAndSend
                                onClicked: {
                                    doSend();
                                }
                            }
                        }

                        RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 6
                            height: 21
                            spacing: 10

                            MoneroComponents.IconButton {
                                id: sendToButton
                                image: "qrc:///images/arrow-right-in-circle-outline-medium-white.svg"
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                onClicked: {
                                    doSend();
                                }
                            }

                            MoneroComponents.IconButton {
                                id: renameButton
                                image: "qrc:///images/edit.svg"
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.5
                                Layout.preferredWidth: 23
                                Layout.preferredHeight: 21

                                onClicked: {
                                    addressBookListView.currentIndex = index;
                                    root.showEditAddress(address, description);
                                }
                            }

                            MoneroComponents.IconButton {
                                id: copyButton
                                image: "qrc:///images/copy.svg"
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 21
                                color: MoneroComponents.Style.defaultFontColor
                                opacity: 0.5

                                onClicked: {
                                    console.log("Address copied to clipboard");
                                    clipboard.setText(address);
                                    appWindow.showStatusMessage(qsTr("Address copied to clipboard"), 3);
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: border2
                color: MoneroComponents.Style.appWindowBorderColor
                Layout.fillWidth: true
                height: 1

                MoneroEffects.ColorTransition {
                    targetObj: border2
                    blackColor: MoneroComponents.Style._b_appWindowBorderColor
                    whiteColor: MoneroComponents.Style._w_appWindowBorderColor
                }
            }

            MoneroComponents.CheckBox {
                id: addNewEntryCheckbox
                border: false
                uncheckedIcon: FontAwesome.plusCircle
                toggleOnClick: false
                fontAwesomeIcons: true
                fontSize: 16
                iconOnTheLeft: true
                Layout.fillWidth: true
                Layout.topMargin: 10
                text: qsTr("Add address") + translationManager.emptyString;
                onClicked: {
                    root.showAddAddress();
                }
            }

        }
        ColumnLayout {
            id: addContactLayout
            visible: false
            spacing: 0

            MoneroComponents.Label {
                fontSize: 32
                wrapMode: Text.WordWrap
                text: (root.editEntry ? qsTr("Edit an address") : qsTr("Add an address")) + translationManager.emptyString
            }

            MoneroComponents.LineEditMulti {
                id: addressLine
                Layout.topMargin: 20
                labelText: "<style type='text/css'>a {text-decoration: none; color: #858585; font-size: 14px;}</style> %1"
                    .arg(qsTr("Address")) + translationManager.emptyString
                placeholderText: {
                    if(persistentSettings.nettype == NetworkType.MAINNET){
                        return "4.. / 8.. / OpenAlias";
                    } else if (persistentSettings.nettype == NetworkType.STAGENET){
                        return "5.. / 7..";
                    } else if(persistentSettings.nettype == NetworkType.TESTNET){
                        return "9.. / B..";
                    }
                }
                wrapMode: Text.WrapAnywhere
                addressValidation: true
                pasteButton: true
                onTextChanged: {
                    const parsed = walletManager.parse_uri_to_object(addressLine.text);
                    if (!parsed.error) {
                        addressLine.text = parsed.address;
                        descriptionLine.text = parsed.tx_description;
                    }
                }

                MoneroComponents.InlineButton {
                    buttonColor: MoneroComponents.Style.orange
                    fontFamily: FontAwesome.fontFamily
                    text: FontAwesome.qrcode
                    visible : appWindow.qrScannerEnabled && !addressLine.text
                    onClicked: {
                        cameraUi.state = "Capture"
                        cameraUi.qrcode_decoded.connect(root.updateFromQrCode)
                    }
                }
            }

            MoneroComponents.StandardButton {
                id: resolveButton
                Layout.topMargin: 10
                text: qsTr("Resolve") + translationManager.emptyString
                visible: TxUtils.isValidOpenAliasAddress(addressLine.text)
                enabled : visible
                onClicked: {
                    var result = walletManager.resolveOpenAlias(addressLine.text)
                    if (result) {
                        var parts = result.split("|")
                        if (parts.length === 2) {
                            var address_ok = walletManager.addressValid(parts[1], appWindow.persistentSettings.nettype)
                            if (parts[0] === "true") {
                                if (address_ok) {
                                    // prepend openalias to description
                                    descriptionLine.text = descriptionLine.text ? addressLine.text + " " + descriptionLine.text : addressLine.text
                                    addressLine.text = parts[1]
                                } else {
                                    root.oa_message(qsTr("No valid address found at this OpenAlias address"))
                                }
                            } else if (parts[0] === "false") {
                                if (address_ok) {
                                    addressLine.text = parts[1]
                                    root.oa_message(qsTr("Address found, but the DNSSEC signatures could not be verified, so this address may be spoofed"))
                                } else {
                                    root.oa_message(qsTr("No valid address found at this OpenAlias address, but the DNSSEC signatures could not be verified, so this may be spoofed"))
                                }
                            } else {
                                root.oa_message(qsTr("Internal error"))
                            }
                        } else {
                            root.oa_message(qsTr("Internal error"))
                        }
                    } else {
                        root.oa_message(qsTr("No address found"))
                    }
                }
            }

            MoneroComponents.LineEditMulti {
                id: descriptionLine
                Layout.topMargin: 20
                labelText: "<style type='text/css'>a {text-decoration: none; color: #858585; font-size: 14px;}</style> %1"
                    .arg(qsTr("Description")) + translationManager.emptyString
                placeholderText: qsTr("Add a name...") + translationManager.emptyString
            }
            RowLayout {
                Layout.topMargin: 20
                MoneroComponents.StandardButton {
                    id: addButton
                    text: (root.editEntry ? qsTr("Save") : qsTr("Add")) + translationManager.emptyString
                    enabled: root.checkInformation(addressLine.text, appWindow.persistentSettings.nettype)
                    onClicked: {
                        console.log("Add")
                        if (!currentWallet.addressBook.addRow(addressLine.text.trim(),"", descriptionLine.text)) {
                            informationPopup.title = qsTr("Error") + translationManager.emptyString;
                            // TODO: check currentWallet.addressBook.errorString() instead.
                            if(currentWallet.addressBook.errorCode() === AddressBook.Invalid_Address)
                                 informationPopup.text  = qsTr("Invalid address") + translationManager.emptyString
                            else if(currentWallet.addressBook.errorCode() === AddressBook.Invalid_Payment_Id)
                                 informationPopup.text  = currentWallet.addressBook.errorString()
                            else
                                 informationPopup.text  = qsTr("Can't create entry") + translationManager.emptyString

                            informationPopup.onCloseCallback = null
                            informationPopup.open();
                        } else {
                            if (root.editEntry) {
                                currentWallet.addressBook.deleteRow(addressBookListView.currentIndex);
                            }
                            root.showAddressBook();
                        }
                    }
                }

                Text {
                    id: cancelButton
                    Layout.leftMargin: 20
                    font.pixelSize: 16
                    font.bold: false
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("Cancel") + translationManager.emptyString

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showAddressBook();
                    }
                }

                Text {
                    id: deleteButton
                    visible: root.editEntry
                    Layout.leftMargin: 20
                    font.pixelSize: 16
                    font.bold: false
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("Delete") + translationManager.emptyString

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            currentWallet.addressBook.deleteRow(addressBookListView.currentIndex);
                            root.showAddressBook();
                        }
                    }
                }
            }
        }
    }

    function checkInformation(address, nettype) {
        address = address.trim()
        var address_ok = walletManager.addressValid(address, nettype)
        addressLine.error = !address_ok
        return address_ok
    }

    function clearFields() {
        addressLine.text = "";
        descriptionLine.text = "";
    }

    function showAddressBook() {
        addressBookEmptyLayout.visible = addressBookListView.count == 0
        addressBookLayout.visible = addressBookListView.count >= 1;
        addContactLayout.visible = false;
        clearFields();
    }

    function showAddAddress() {
        root.editEntry = false;
        addressBookEmptyLayout.visible = false
        addressBookLayout.visible = false;
        addContactLayout.visible = true;
    }

    function showEditAddress(address, description) {
        //TODO: real contact editing, requires API change
        root.editEntry = true;
        addressBookEmptyLayout.visible = false
        addressBookLayout.visible = false;
        addContactLayout.visible = true;
        addressLine.text = address;
        descriptionLine.text = description;
    }

    function updateFromQrCode(address, payment_id, amount, tx_description, recipient_name) {
        console.log("updateFromQrCode")
        addressLine.text = address
        descriptionLine.text = recipient_name + " " + tx_description
        cameraUi.qrcode_decoded.disconnect(updateFromQrCode)
    }

    function oa_message(text) {
      oaPopup.title = qsTr("OpenAlias error") + translationManager.emptyString
      oaPopup.text = text
      oaPopup.icon = StandardIcon.Information
      oaPopup.onCloseCallback = null
      oaPopup.open()
    }

    MoneroComponents.StandardDialog {
        // dynamically change onclose handler
        property var onCloseCallback
        id: oaPopup
        cancelVisible: false
        onAccepted: {
            if (onCloseCallback) {
                onCloseCallback()
            }
        }
    }
    function onPageCompleted() {
        console.log("adress book");
        addressBookListView.model = currentWallet.addressBookModel;
        showAddressBook();
    }

    function onPageClosed() {
        root.selectAndSend = false;
        root.editEntry = false;
        clearFields();
    }
}
