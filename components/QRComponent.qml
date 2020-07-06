// Copyright (c) 2014-2020, The Monero Project
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
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import FontAwesome 1.0

import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects

import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionHistoryModel 1.0
import moneroComponents.Subaddress 1.0
import moneroComponents.SubaddressModel 1.0
import "../js/TxUtils.js" as TxUtils

ColumnLayout {
    id: root
    property string address
    property int qrSize: 220
    property bool deviceButtonVisible: true
    signal showOnDeviceClicked()

    Rectangle {
        id: qrContainer
        color: MoneroComponents.Style.blackTheme ? "white" : "transparent"
        Layout.fillWidth: true
        Layout.maximumWidth: parent.qrSize
        Layout.preferredHeight: width
        radius: 4

        Image {
            id: qrCode
            anchors.fill: parent
            anchors.margins: 1

            smooth: false
            fillMode: Image.PreserveAspectFit
            source: "image://qrcode/" + TxUtils.makeQRCodeString(root.address)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onPressAndHold: qrFileDialog.open()
            }
        }
    }

    MoneroComponents.StandardButton {
        Layout.preferredWidth: 220
        small: true
        text: FontAwesome.save + "  %1".arg(qsTr("Save as image")) + translationManager.emptyString
        label.font.family: FontAwesome.fontFamily
        fontSize: 13
        onClicked: qrFileDialog.open()
    }

    MoneroComponents.StandardButton {
        Layout.preferredWidth: 220
        small: true
        text: FontAwesome.clipboard + "  %1".arg(qsTr("Copy to clipboard")) + translationManager.emptyString
        label.font.family: FontAwesome.fontFamily
        fontSize: 13
        onClicked: {
            clipboard.setText(TxUtils.makeQRCodeString(root.address));
            appWindow.showStatusMessage(qsTr("Copied to clipboard") + translationManager.emptyString, 3);
        }
    }

    MoneroComponents.StandardButton {
        id: showOnDeviceButton
        Layout.preferredWidth: 220
        small: true
        text: FontAwesome.eye + "  %1".arg(qsTr("Show on device")) + translationManager.emptyString
        label.font.family: FontAwesome.fontFamily
        fontSize: 13
        visible: root.deviceButtonVisible && appWindow.currentWallet ? appWindow.currentWallet.isHwBacked() : false
        onClicked: {
            showOnDeviceClicked();
        }
    }

    FileDialog {
        id: qrFileDialog
        title: qsTr("Please choose a name") + translationManager.emptyString
        folder: shortcuts.pictures
        selectExisting: false
        nameFilters: ["Image (*.png)"]
        onAccepted: {
            if(!walletManager.saveQrCode(TxUtils.makeQRCodeString(appWindow.current_address), walletManager.urlToLocalPath(fileUrl))) {
                console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                receivePageDialog.title = qsTr("Save QrCode") + translationManager.emptyString;
                receivePageDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                receivePageDialog.icon = StandardIcon.Error
                receivePageDialog.open()
            }
        }
    }
}
