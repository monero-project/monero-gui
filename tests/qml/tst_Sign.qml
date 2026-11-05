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

import QtQuick
import QtTest

import moneroComponents.NetworkType 1.0
import moneroComponents.WalletManager 1.0
import "../../pages" as Pages

Item {
    id: appWindow
    width: 800
    height: 1000

    property var currentWallet
    property var currentItem
    property bool themeTransition: false

    function releaseFocus() {}

    WalletManager { id: walletManager }

    QtObject {
        id: hardwareWallet
        property int currentSubaddressAccount: 0
        property string walletAddress
        property bool viewOnly: false
        function numSubaddressAccounts() { return 1 }
        function address() { return walletAddress }
        function isHwBacked() { return true }
    }

    Pages.Sign {
        id: signView
        width: parent.width
        height: 850
    }

    TestCase {
        name: "Sign"
        when: windowShown

        function test_wallet_address_signing() {
            var wallet = walletManager.createWallet(moneroTestRoot + "/sign-wallet", "", "English", NetworkType.MAINNET, 1)
            compare(wallet.status, 0, wallet.errorString)
            appWindow.currentWallet = wallet
            signView.onPageCompleted()

            var addressLine = findChild(signView, "signingAddressLine")
            var signatureLine = findChild(signView, "signSignatureLine")
            var messageLine = findChild(signView, "signMessageLine")
            var messageButton = findChild(signView, "signMessageButton")
            var fileLine = findChild(signView, "signFileLine")
            var fileButton = findChild(signView, "signFileButton")
            var signSection = findChild(signView, "signSection")
            var verifySection = findChild(signView, "verifySection")
            var unavailableMessage = findChild(signView, "signingUnavailableMessage")
            verify(addressLine !== null && signatureLine !== null)
            verify(messageLine !== null && messageButton !== null)
            verify(fileLine !== null && fileButton !== null)
            verify(signSection !== null && verifySection !== null && unavailableMessage !== null)

            var primaryAddress = wallet.address(0, 0)
            compare(addressLine.text, primaryAddress)
            compare(wallet.viewOnly, false)
            verify(signSection.enabled && verifySection.enabled)
            verify(!unavailableMessage.visible)
            wallet.subaddressAccount.addRow("Second account")
            wallet.switchSubaddressAccount(1)
            var secondAddress = wallet.address(1, 0)
            verify(primaryAddress !== secondAddress)
            compare(addressLine.text, secondAddress)

            var legacySignature = wallet.signMessage("legacy one-argument call")
            verify(wallet.verifySignedMessageWithDetails("legacy one-argument call", primaryAddress, legacySignature, false).valid)
            legacySignature = wallet.signMessage("legacy two-argument call", false)
            verify(wallet.verifySignedMessageWithDetails("legacy two-argument call", primaryAddress, legacySignature, false).valid)

            addressLine.text = primaryAddress
            messageLine.text = "primary account"
            messageButton.doClick()
            var primarySignature = signatureLine.text
            verify(primarySignature.length > 0, wallet.errorString)
            verify(wallet.verifySignedMessageWithDetails("primary account", primaryAddress, primarySignature, false).valid)
            verify(!wallet.verifySignedMessageWithDetails("primary account", secondAddress, primarySignature, false).valid)

            addressLine.text = secondAddress
            compare(signatureLine.text, "")
            messageLine.text = "account one"
            verify(messageButton.enabled)
            messageButton.doClick()
            var signature = signatureLine.text
            verify(signature.length > 0, wallet.errorString)
            verify(wallet.verifySignedMessageWithDetails("account one", secondAddress, signature, false).valid)
            verify(!wallet.verifySignedMessageWithDetails("account one", primaryAddress, signature, false).valid)

            signView.onPageCompleted()
            compare(addressLine.text, secondAddress)
            compare(signatureLine.text, signature)

            wallet.addSubaddress("Extra address")
            var minorAddress = wallet.address(1, 1)
            verify(minorAddress !== secondAddress)
            addressLine.text = minorAddress
            compare(signatureLine.text, "")
            messageLine.text = "minor index one"
            messageButton.doClick()
            var minorSignature = signatureLine.text
            verify(minorSignature.length > 0, wallet.errorString)
            verify(wallet.verifySignedMessageWithDetails("minor index one", minorAddress, minorSignature, false).valid)
            verify(!wallet.verifySignedMessageWithDetails("minor index one", secondAddress, minorSignature, false).valid)

            var filePath = moneroTestRoot + "/signed-file"
            verify(settingsTestHelper.writeSetting(filePath, "test/value", "file contents"))
            signView.messageMode = false
            signView.fileMode = true
            fileLine.text = filePath
            verify(fileButton.enabled)
            fileButton.doClick()
            var fileSignature = signatureLine.text
            verify(fileSignature.length > 0, wallet.errorString)
            verify(wallet.verifySignedMessageWithDetails(filePath, minorAddress, fileSignature, true).valid)
            verify(!wallet.verifySignedMessageWithDetails(filePath, primaryAddress, fileSignature, true).valid)

            wallet.setSubaddressLabel(1, 0, "Renamed account")
            compare(addressLine.text, minorAddress)
            compare(signatureLine.text, fileSignature)
            signView.onPageCompleted()
            compare(addressLine.text, minorAddress)
            compare(signatureLine.text, fileSignature)

            wallet.subaddressAccount.addRow("Third account")
            wallet.switchSubaddressAccount(2)
            compare(addressLine.text, wallet.address(2, 0))
            compare(signatureLine.text, "")
            wallet.switchSubaddressAccount(0)
            compare(addressLine.text, primaryAddress)

            addressLine.text = ""
            verify(!fileButton.enabled)
            addressLine.text = primaryAddress

            fileLine.text = moneroTestRoot + "/missing-file"
            fileButton.doClick()
            var errorDialog = findChild(signView, "signingErrorMessage")
            verify(errorDialog !== null)
            compare(errorDialog.text, "Failed to sign")

            var previousWalletAddress = primaryAddress
            signatureLine.text = "stale signature"
            appWindow.currentWallet = undefined
            compare(addressLine.text, "")
            compare(signatureLine.text, "")
            verify(!signSection.enabled && verifySection.enabled)

            var otherWallet = walletManager.createWallet(moneroTestRoot + "/other-sign-wallet", "", "English", NetworkType.MAINNET, 1)
            compare(otherWallet.status, 0, otherWallet.errorString)
            appWindow.currentWallet = otherWallet
            var otherAddress = otherWallet.address(0, 0)
            compare(addressLine.text, otherAddress)
            verify(otherAddress !== previousWalletAddress)
            signView.messageMode = true
            signView.fileMode = false
            messageLine.text = "foreign address"
            addressLine.text = previousWalletAddress
            messageButton.doClick()
            compare(signatureLine.text, "")
            compare(errorDialog.text, "Address doesn't belong to the wallet")

            hardwareWallet.walletAddress = otherAddress
            appWindow.currentWallet = hardwareWallet
            compare(addressLine.text, otherAddress)
            verify(!signSection.enabled && verifySection.enabled)
            verify(!messageButton.enabled && !fileButton.enabled)
            verify(unavailableMessage.visible)

            appWindow.currentWallet = undefined
            walletManager.closeWallet()
        }

        function test_view_only_signing_disabled() {
            var wallet = walletManager.createWallet(moneroTestRoot + "/sign-full-wallet", "", "English", NetworkType.MAINNET, 1)
            compare(wallet.status, 0, wallet.errorString)
            var viewOnlyPath = moneroTestRoot + "/sign-view-only-wallet"
            verify(wallet.createViewOnly(viewOnlyPath, ""))
            appWindow.currentWallet = undefined

            var viewOnlyWallet = walletManager.openWallet(viewOnlyPath, "", NetworkType.MAINNET, 1)
            compare(viewOnlyWallet.status, 0, viewOnlyWallet.errorString)
            compare(viewOnlyWallet.viewOnly, true)
            appWindow.currentWallet = viewOnlyWallet

            var addressLine = findChild(signView, "signingAddressLine")
            var signSection = findChild(signView, "signSection")
            var verifySection = findChild(signView, "verifySection")
            var unavailableMessage = findChild(signView, "signingUnavailableMessage")
            var messageLine = findChild(signView, "signMessageLine")
            var messageButton = findChild(signView, "signMessageButton")
            var fileLine = findChild(signView, "signFileLine")
            var fileButton = findChild(signView, "signFileButton")
            compare(addressLine.text, viewOnlyWallet.address(0, 0))
            verify(!signSection.enabled && verifySection.enabled)
            verify(unavailableMessage.visible)
            messageLine.text = "view-only cannot sign"
            fileLine.text = moneroTestRoot + "/signed-file"
            verify(!messageButton.enabled && !fileButton.enabled)

            appWindow.currentWallet = undefined
            walletManager.closeWallet()
        }
    }
}
