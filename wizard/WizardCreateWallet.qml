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
import moneroComponents.WalletManager 1.0
import moneroComponents.Wallet 1.0

import QtQuick.Dialogs 1.2
import 'utils.js' as Utils

Item {
    opacity: 0
    visible: false

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }


    onOpacityChanged: visible = opacity !== 0

    //! function called each time we display this page

    function onPageOpened(settingsOblect) {
        checkNextButton()
    }

    function onPageClosed(settingsObject) {
        settingsObject['account_name'] = uiItem.accountNameText
        settingsObject['words'] = uiItem.wordsTexttext
        settingsObject['wallet_path'] = uiItem.walletPath
        return true;
    }

    function checkNextButton() {
        var wordsArray = Utils.lineBreaksToSpaces(uiItem.wordsTextItem.memoText).split(" ");
        wizard.nextButton.enabled = wordsArray.length === 25;
    }

    //! function called each time we hide this page
    //


    function createWallet(settingsObject) {
        // TODO: create wallet in temporary filename and a) move it to the path specified by user after the final
        // page submitted or b) delete it when program closed before reaching final page

        var wallet_filename = oshelper.temporaryFilename();
        if (typeof settingsObject.wallet === 'undefined') {
            //var wallet = walletManager.createWallet(wallet_filename, "", settingsObject.language)
            var testnet = appWindow.persistentSettings.testnet;
            var wallet = walletManager.createWallet(wallet_filename, "", settingsObject.wallet_language,
                                                    testnet)
            uiItem.wordsTextItem.memoText = wallet.seed
            // saving wallet in "global" settings object
            // TODO: wallet should have a property pointing to the file where it stored or loaded from
            settingsObject.wallet = wallet
        } else {
            print("wallet already created. we just stepping back");
        }
        settingsObject.wallet_filename = wallet_filename
    }




    WizardManageWalletUI {
        id: uiItem
        titleText: qsTr("A new wallet has been created for you") + translationManager.emptyString
        wordsTextTitle: qsTr("This is the 25 word mnemonic for your wallet") + translationManager.emptyString
        wordsTextItem.clipboardButtonVisible: true
        wordsTextItem.tipTextVisible: true
        wordsTextItem.memoTextReadOnly: true
        restoreHeightVisible:false
    }
}
