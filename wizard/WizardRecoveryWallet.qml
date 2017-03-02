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

import QtQuick 2.2
import QtQuick.Dialogs 1.2
import moneroComponents.Wallet 1.0
import QtQuick.Layouts 1.1
import 'utils.js' as Utils

ColumnLayout {
    opacity: 0
    visible: false

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    function onWizardRestarted() {
        // reset account name field
        uiItem.accountNameText = defaultAccountName
        // Empty seedText
        uiItem.wordsTextItem.memoText = ""
        uiItem.recoverFromKeysAddress = ""
        uiItem.recoverFromKeysSpendKey = ""
        uiItem.recoverFromKeysViewKey = ""
    }

    function onPageOpened(settingsObject) {
        console.log("on page opened")
        uiItem.checkNextButton();
    }

    function onPageClosed(settingsObject) {
        settingsObject['account_name'] = uiItem.accountNameText
        settingsObject['words'] = Utils.lineBreaksToSpaces(uiItem.wordsTextItem.memoText)
        settingsObject['wallet_path'] = uiItem.walletPath
        settingsObject['recover_address'] = uiItem.recoverFromKeysAddress
        settingsObject['recover_viewkey'] = uiItem.recoverFromKeysViewKey
        settingsObject['recover_spendkey'] = uiItem.recoverFromKeysSpendKey


        var restoreHeight = parseInt(uiItem.restoreHeight);
        settingsObject['restore_height'] = isNaN(restoreHeight)? 0 : restoreHeight
        var walletFullPath = wizard.createWalletPath(uiItem.walletPath,uiItem.accountNameText);
        if(!wizard.walletPathValid(walletFullPath)){
           return false
        }
        return recoveryWallet(settingsObject, uiItem.recoverFromSeedMode)
    }

    function recoveryWallet(settingsObject, fromSeed) {
        var testnet = appWindow.persistentSettings.testnet;
        var restoreHeight = settingsObject.restore_height;
        var tmp_wallet_filename = oshelper.temporaryFilename()
        console.log("Creating temporary wallet", tmp_wallet_filename)

        // From seed or keys
        if(fromSeed)
            var wallet = walletManager.recoveryWallet(tmp_wallet_filename, settingsObject.words, testnet, restoreHeight)
        else
            var wallet = walletManager.createWalletFromKeys(tmp_wallet_filename, settingsObject.language, testnet,
                                                            settingsObject.recover_address, settingsObject.recover_viewkey,
                                                            settingsObject.recover_spendkey, restoreHeight)


        var success = wallet.status === Wallet.Status_Ok;
        if (success) {
            settingsObject['wallet'] = wallet;
            settingsObject['is_recovering'] = true;
            settingsObject['tmp_wallet_filename'] = tmp_wallet_filename
        } else {
            console.log(wallet.errorString)
            walletErrorDialog.text = wallet.errorString;
            walletErrorDialog.open();
            walletManager.closeWallet();
        }
        return success;
    }



    WizardManageWalletUI {
        id: uiItem
        accountNameText: defaultAccountName
        titleText: qsTr("Restore wallet") + translationManager.emptyString
        wordsTextItem.clipboardButtonVisible: false
        wordsTextItem.tipTextVisible: false
        wordsTextItem.memoTextReadOnly: false
        wordsTextItem.memoText: ""
        wordsTextItem.visible: true
        restoreHeightVisible: true
        recoverMode: true
        wordsTextItem.onMemoTextChanged: {
            checkNextButton();
        }
    }

    Component.onCompleted: {
        parent.wizardRestarted.connect(onWizardRestarted)
    }
}
