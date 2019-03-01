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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../js/Wizard.js" as Wizard
import "../components"
import "../components" as MoneroComponents

GridLayout {
    Layout.fillWidth: true
    property alias walletName: walletName
    property alias walletLocation: walletLocation

    columnSpacing: 20 * scaleRatio
    columns: 3

    function verify() {
        if(walletName.text !== '' && walletLocation.text !== ''){
            if(!walletName.error){
                return true;
            }
        }
        return false;
    }

    function reset() {
        walletName.error = !walletName.verify();
        walletLocation.error = walletLocation.text === "";
    }

    MoneroComponents.LineEdit {
        id: walletName
        Layout.fillWidth: true

        function verify(){
            if(walletLocation === "") return false;

            var exists = Wizard.walletPathExists(walletLocation.text, walletName.text, isIOS, walletManager);
            return !exists && walletLocation.error === false;
        }

        labelText: qsTr("Wallet name") + translationManager.emptyString
        labelFontSize: 14 * scaleRatio
        placeholderFontSize: 16 * scaleRatio
        placeholderText: "-"
        text: defaultAccountName

        onTextChanged: walletName.error = !walletName.verify();
        Component.onCompleted: walletName.error = !walletName.verify();
    }

    MoneroComponents.LineEdit {
        id: walletLocation
        Layout.fillWidth: true

        labelText: qsTr("Wallet location") + translationManager.emptyString
        labelFontSize: 14 * scaleRatio
        placeholderText: "..."
        placeholderFontSize: 16 * scaleRatio
        text: moneroAccountsDir + "/"
        inlineButton.small: true
        inlineButtonText: qsTr("Browse") + translationManager.emptyString
        inlineButton.onClicked: {
            fileWalletDialog.folder = walletManager.localPathToUrl(walletLocation.text)
            fileWalletDialog.open()
            walletLocation.focus = true
        }
        onTextChanged: {
            walletLocation.error = walletLocation.text === "";
        }
    }

    FileDialog {
        id: fileWalletDialog
        selectMultiple: false
        selectFolder: true
        title: qsTr("Please choose a directory")  + translationManager.emptyString
        onAccepted: {
            walletLocation.text = walletManager.urlToLocalPath(fileWalletDialog.folder);
            fileWalletDialog.visible = false;
            walletName.error = !walletName.verify();
        }
        onRejected: {
            fileWalletDialog.visible = false;
        }
    }
}
