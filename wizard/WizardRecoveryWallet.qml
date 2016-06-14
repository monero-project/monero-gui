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
import moneroComponents 1.0
import QtQuick.Dialogs 1.2
import Bitmonero.Wallet 1.0

Item {
    opacity: 0
    visible: false

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    function onPageClosed(settingsObject) {
        settingsObject['account_name'] = uiItem.accountNameText
        settingsObject['words'] = cleanWordsInput(uiItem.wordsTextItem.memoText)
        settingsObject['wallet_path'] = uiItem.walletPath
        return recoveryWallet(settingsObject)
    }

    function recoveryWallet(settingsObject) {
        var testnet = true;
        var wallet = walletManager.recoveryWallet(oshelper.temporaryFilename(), settingsObject.words, testnet);
        var success = wallet.status === Wallet.Status_Ok;
        if (success) {
            settingsObject['wallet'] = wallet;
        } else {
            walletManager.closeWallet(wallet);
        }
        return success;
    }

    function cleanWordsInput(text) {
        return text.trim().replace(/(\r\n|\n|\r)/gm, " ");
    }

    WizardManageWalletUI {
        id: uiItem
        accountNameText: qsTr("My account name")
        titleText: qsTr("We're ready to recover your account")
        wordsTextTitle: qsTr("Please enter your 25 word private key")
        wordsTextItem.clipboardButtonVisible: false
        wordsTextItem.tipTextVisible: false
        wordsTextItem.memoTextReadOnly: false
        wordsTextItem.memoText: ""
        wordsTextItem.onMemoTextChanged: {
            var wordsArray = cleanWordsInput(wordsTextItem.memoText).split(" ");
            wizard.nextButton.enabled = wordsArray.length === 25
        }
    }
}
