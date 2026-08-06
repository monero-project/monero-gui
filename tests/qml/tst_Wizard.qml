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
import moneroComponents.Settings 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0

import "../../components" as MoneroComponents
import "../../wizard"

Item {
    id: appWindow
    width: 1000
    height: 800

    property alias persistentSettings: persistentSettings
    property alias portableSettings: diskPortableSettings
    property alias wizard: wizardController
    property string accountsDir: moneroAccountsDir
    property int walletMode: persistentSettings.walletMode
    property bool ctrlPressed: false
    property bool themeTransition: false
    property var currentWallet
    property string walletPassword: ""
    property int restoreHeight: 0
    property string lastWalletOpenError: ""
    property bool walletCreated: false
    property bool walletOpenRequested: false
    property bool qrScannerEnabled: false
    property bool hideBalanceForced: false
    property bool active: true
    property string testSettingsPath: moneroTestRoot + "/settings.ini"
    property string portableTestSettingsPath: moneroTestRoot + "/monero-storage/settings.ini"
    property string portableMarkerTestPath: moneroTestRoot + "/monero-storage/.portable"

    function updateBalance() {}

    function showStatusMessage() {}

    function releaseFocus() {}

    function changeWalletMode(mode) {
        persistentSettings.walletMode = mode
    }

    function openWallet() {
        passwordDialog.open(persistentSettings.wallet_path)
    }

    QtObject {
        id: persistentSettings
        property int walletMode: 2
        property int nettype: NetworkType.MAINNET
        property int kdfRounds: 1
        property string language_wallet: "English"
        property bool customDecorations: false
        property string bootstrapNodeAddress: ""
        property string blockchainDataDir: ""
        property string language: "English (US)"
        property string account_name: ""
        property string wallet_path: ""
        property int restore_height: 0
        property bool allow_background_mining: false
        property bool is_recovering: false
        property bool is_recovering_from_device: false
        property bool portable: false
        property bool pruneBlockchain: false
        property bool useRemoteNode: false
        function setPortable() { return true }
        function setWritable() { return true }
        function sync() {}
    }

    QtObject {
        id: logger
        function resetLogFilePath() {}
    }

    PortableSettings {
        id: diskPortableSettings
        unportableFileName: appWindow.testSettingsPath
    }

    QtObject {
        id: daemonManager
        function checkLmdbExists() { return false }
    }

    ListModel {
        id: remoteNodesModel
        property int selected: 0
        function currentRemoteNode() { return { "address": "" } }
        function applyRemoteNode() {}
        function removeSelectNextIfNeeded() {}
    }

    QtObject {
        id: splash
        function close() {}
    }

    QtObject {
        id: leftPanel
        property bool enabled: true
    }

    QtObject {
        id: middlePanel
        property bool enabled: true
    }

    QtObject {
        id: titleBar
        property string state: ""
    }

    QtObject {
        id: rootItem
        property string state: "wizard"
    }

    QtObject {
        id: devicePassphraseDialog
        property var onAcceptedCallback
        property var onWalletEntryCallback
        property var onRejectedCallback
        function open() {}
    }

    WalletManager {
        id: walletManager
    }

    MoneroComponents.PasswordDialog {
        id: passwordDialog
        anchors.fill: parent

        onAccepted: {
            appWindow.walletPassword = password
            appWindow.lastWalletOpenError = ""
            var wallet = walletManager.openWallet(
                persistentSettings.wallet_path, password,
                persistentSettings.nettype, persistentSettings.kdfRounds)
            if (wallet.status === Wallet.Status_Ok) {
                appWindow.currentWallet = wallet
                appWindow.walletOpenRequested = true
            } else {
                var error = wallet.errorString
                appWindow.lastWalletOpenError = error
                walletManager.closeWallet()
                appWindow.currentWallet = undefined
                showError(error)
            }
        }
    }

    WizardController {
        id: wizardController
        anchors.fill: parent
        onUseMoneroClicked: {
            appWindow.walletCreated = true
            appWindow.openWallet()
        }
    }

    TestCase {
        name: "Wizard"
        when: windowShown

        function walletPath(walletName) {
            return appWindow.accountsDir + "/" + walletName + "/" + walletName
        }

        function showWizardHome() {
            wizardController.wizardState = "wizardHome"
            tryCompare(wizardController, "wizardState", "wizardHome")
        }

        function goToCreatePasswordPage(walletName) {
            showWizardHome()
            wizardController.wizardStateView.wizardHomeView.createWalletButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet1")

            var createWallet1 = wizardController.wizardStateView.wizardCreateWallet1View
            createWallet1.walletInput.walletName.text = walletName
            verify(createWallet1.wizardNav.btnNext.enabled)
            createWallet1.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet2")

            // The first click hides five seed words; the second confirms them. Holding
            // Ctrl is the Wizard's built-in way to skip manual seed entry in automated
            // and accessibility-driven flows.
            appWindow.ctrlPressed = true
            var createWallet2 = wizardController.wizardStateView.wizardCreateWallet2View
            createWallet2.wizardNav.btnNext.doClick()
            compare(createWallet2.state, "verify")
            createWallet2.wizardNav.btnNext.doClick()
            appWindow.ctrlPressed = false
            tryCompare(wizardController, "wizardState", "wizardCreateWallet3")

            return wizardController.wizardStateView.wizardCreateWallet3View
        }

        function createWalletThroughWizard(walletName, password) {
            var createWallet3 = goToCreatePasswordPage(walletName)

            createWallet3.pwField = password
            createWallet3.pwConfirmField = password
            verify(createWallet3.wizardNav.btnNext.enabled)
            createWallet3.wizardNav.btnNext.doClick()

            if (appWindow.walletMode >= 2) {
                tryCompare(wizardController, "wizardState", "wizardCreateWallet4")
                wizardController.wizardStateView.wizardCreateWallet4View.wizardNav.btnNext.doClick()
            }
            tryCompare(wizardController, "wizardState", "wizardCreateWallet5")

            var seed = wizardController.walletOptionsSeed
            appWindow.walletCreated = false
            appWindow.walletOpenRequested = false
            wizardController.wizardStateView.wizardCreateWallet5View.wizardNav.btnNext.doClick()
            tryCompare(appWindow, "walletCreated", true, 30000)
            compare(walletManager.localPathToUrl(persistentSettings.wallet_path),
                    walletManager.localPathToUrl(walletPath(walletName)))
            var address = acceptWalletPassword(password)
            closeOpenedWallet()

            return {
                "address": address,
                "password": password,
                "path": persistentSettings.wallet_path,
                "seed": seed
            }
        }

        function acceptWalletPassword(password) {
            tryCompare(passwordDialog, "visible", true)
            passwordDialog.password = password
            passwordDialog.acceptButton.doClick()
            tryCompare(appWindow, "walletOpenRequested", true)
            compare(appWindow.currentWallet.status, Wallet.Status_Ok,
                    appWindow.currentWallet.errorString)
            var address = appWindow.currentWallet.address(0, 0)
            verify(address.length > 0)
            return address
        }

        function openRecentWallet(walletName, password) {
            persistentSettings.wallet_path = ""
            appWindow.walletOpenRequested = false
            appWindow.lastWalletOpenError = ""
            showWizardHome()
            var wizardHome = wizardController.wizardStateView.wizardHomeView
            wizardHome.openWalletButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardOpenWallet1")

            var openWalletView = wizardController.wizardStateView.wizardOpenWallet1View
            tryVerify(function() { return openWalletView.walletCount > 0 })
            verify(waitForPolish(openWalletView))
            var recentWallet = null
            for (var i = 0; i < openWalletView.recentWallets.count; ++i) {
                var candidate = openWalletView.recentWallets.itemAt(i)
                if (candidate.walletFileName === walletName) {
                    recentWallet = candidate
                    break
                }
            }
            verify(recentWallet !== null, "Recent wallet not found: " + walletName)
            recentWallet.forceActiveFocus()
            verify(recentWallet.activeFocus)
            keyClick(Qt.Key_Return)
            verify(persistentSettings.wallet_path.length > 0)
            tryCompare(passwordDialog, "visible", true)

            passwordDialog.password = password
            passwordDialog.acceptButton.doClick()
            return persistentSettings.wallet_path
        }

        function closeOpenedWallet() {
            if (typeof appWindow.currentWallet !== "undefined") {
                walletManager.closeWallet()
                appWindow.currentWallet = undefined
            }
        }

        function init() {
            failOnWarning(/.?/)
            appWindow.ctrlPressed = false
            appWindow.walletCreated = false
            appWindow.walletOpenRequested = false
            appWindow.currentWallet = undefined
            persistentSettings.wallet_path = ""
            wizardController.restart()
            showWizardHome()
        }

        function cleanup() {
            appWindow.ctrlPressed = false
            closeOpenedWallet()
            if (passwordDialog.visible)
                passwordDialog.onCancel()
            wizardController.restart()
            showWizardHome()
        }

        function test_portable_mode_through_wizard() {
            verify(!diskPortableSettings.portable)
            verify(settingsTestHelper.writeSetting(
                appWindow.testSettingsPath, "language", "English (US)"))
            verify(settingsTestHelper.writeSetting(
                appWindow.testSettingsPath, "walletMode", 2))
            verify(settingsTestHelper.writeSetting(
                appWindow.portableTestSettingsPath, "obsolete", "must be removed"))

            var wizardHome = wizardController.wizardStateView.wizardHomeView
            wizardHome.changeWalletModeButton.doClick()
            tryCompare(wizardController, "wizardState", "wizardModeSelection")

            var modeSelection = wizardController.wizardStateView.wizardModeSelectionView
            modeSelection.portableModeButton.menuClicked()
            compare(modeSelection.portable, true)
            modeSelection.advancedModeButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardHome")

            verify(diskPortableSettings.portable)
            verify(settingsTestHelper.fileExists(appWindow.portableMarkerTestPath))
            compare(settingsTestHelper.readSetting(
                        appWindow.portableTestSettingsPath, "language"), "English (US)")
            compare(Number(settingsTestHelper.readSetting(
                        appWindow.portableTestSettingsPath, "walletMode")), 2)
            verify(!settingsTestHelper.containsSetting(
                appWindow.portableTestSettingsPath, "obsolete"))

            verify(settingsTestHelper.writeSetting(
                appWindow.testSettingsPath, "obsolete", "must be removed"))

            wizardHome = wizardController.wizardStateView.wizardHomeView
            wizardHome.changeWalletModeButton.doClick()
            tryCompare(wizardController, "wizardState", "wizardModeSelection")

            modeSelection = wizardController.wizardStateView.wizardModeSelectionView
            modeSelection.portableModeButton.menuClicked()
            compare(modeSelection.portable, false)
            modeSelection.advancedModeButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardHome")

            verify(!diskPortableSettings.portable)
            compare(settingsTestHelper.readSetting(
                        appWindow.testSettingsPath, "language"), "English (US)")
            compare(Number(settingsTestHelper.readSetting(
                        appWindow.testSettingsPath, "walletMode")), 2)
            verify(!settingsTestHelper.containsSetting(
                appWindow.testSettingsPath, "obsolete"))
            verify(!settingsTestHelper.fileExists(appWindow.portableMarkerTestPath))
            verify(settingsTestHelper.fileExists(appWindow.portableTestSettingsPath))
        }

        function test_create_password_wallet_and_open_it() {
            var createdWallet = createWalletThroughWizard(
                "wizard-password-test", "correct horse battery staple")
            var selectedWalletPath = openRecentWallet(
                "wizard-password-test", "definitely not the wallet password")
            compare(selectedWalletPath, createdWallet.path)
            verify(!appWindow.walletOpenRequested)
            verify(typeof appWindow.currentWallet === "undefined")
            verify(appWindow.lastWalletOpenError.length > 0)
            tryCompare(passwordDialog, "visible", true)

            passwordDialog.password = createdWallet.password
            passwordDialog.acceptButton.doClick()
            tryCompare(appWindow, "walletOpenRequested", true)
            compare(appWindow.currentWallet.status, Wallet.Status_Ok,
                    appWindow.currentWallet.errorString)
            compare(appWindow.currentWallet.path, selectedWalletPath)
            compare(appWindow.currentWallet.address(0, 0), createdWallet.address)
            closeOpenedWallet()
        }

        function test_existing_wallet_is_not_overwritten() {
            var walletName = "existing-wallet-test"
            var createdWallet = createWalletThroughWizard(walletName, "original password")

            showWizardHome()
            wizardController.wizardStateView.wizardHomeView.createWalletButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet1")

            var createWallet1 = wizardController.wizardStateView.wizardCreateWallet1View
            createWallet1.walletInput.walletName.text = walletName
            verify(createWallet1.walletInput.walletName.error)
            verify(createWallet1.walletInput.errorMessageWalletName.text.length > 0)
            verify(!createWallet1.wizardNav.btnNext.enabled)

            wizardController.restart()
            var selectedWalletPath = openRecentWallet(walletName, createdWallet.password)
            compare(selectedWalletPath, createdWallet.path)
            tryCompare(appWindow, "walletOpenRequested", true)
            compare(appWindow.currentWallet.status, Wallet.Status_Ok,
                    appWindow.currentWallet.errorString)
            compare(appWindow.currentWallet.address(0, 0), createdWallet.address)
            closeOpenedWallet()
        }

        function test_invalid_wallet_location_disables_next() {
            showWizardHome()
            wizardController.wizardStateView.wizardHomeView.createWalletButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet1")

            var createWallet1 = wizardController.wizardStateView.wizardCreateWallet1View
            createWallet1.walletInput.walletName.text = "invalid-location-test"
            createWallet1.walletInput.walletLocation.text =
                    appWindow.accountsDir + "-missing-" + Date.now()
            verify(createWallet1.walletInput.walletLocation.error)
            verify(createWallet1.walletInput.errorMessageWalletLocation.text.length > 0)
            verify(!createWallet1.wizardNav.btnNext.enabled)
            compare(wizardController.wizardState, "wizardCreateWallet1")
        }

        function test_password_confirmation_must_match() {
            var createWallet3 = goToCreatePasswordPage("password-mismatch-test")
            createWallet3.pwField = "one password"
            createWallet3.pwConfirmField = "a different password"
            verify(!createWallet3.wizardNav.btnNext.enabled)
            compare(wizardController.wizardState, "wizardCreateWallet3")

            createWallet3.pwConfirmField = createWallet3.pwField
            verify(createWallet3.wizardNav.btnNext.enabled)

            createWallet3.wizardNav.btnPrev.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet2")
            var createWallet2 = wizardController.wizardStateView.wizardCreateWallet2View
            createWallet2.wizardNav.btnPrev.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet1")
            var createWallet1 = wizardController.wizardStateView.wizardCreateWallet1View
            createWallet1.wizardNav.btnPrev.doClick()
            tryCompare(wizardController, "wizardState", "wizardHome")
        }

        function test_seed_confirmation_accepts_hidden_words() {
            showWizardHome()
            wizardController.wizardStateView.wizardHomeView.createWalletButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet1")

            var createWallet1 = wizardController.wizardStateView.wizardCreateWallet1View
            createWallet1.walletInput.walletName.text = "seed-confirmation-test"
            verify(createWallet1.wizardNav.btnNext.enabled)
            createWallet1.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet2")

            var createWallet2 = wizardController.wizardStateView.wizardCreateWallet2View
            createWallet2.wizardNav.btnNext.doClick()
            compare(createWallet2.state, "verify")
            verify(!createWallet2.wizardNav.btnNext.enabled)

            for (var i = 0; i < createWallet2.hiddenWords.length; ++i) {
                var wordIndex = createWallet2.hiddenWords[i]
                var seedItem = createWallet2.seedListGrid.children[wordIndex]
                verify(seedItem.lineEdit.visible)
                if (i === 0) {
                    seedItem.lineEdit.text = "incorrect"
                    verify(!seedItem.icon.wordsMatch)
                    verify(!createWallet2.wizardNav.btnNext.enabled)
                    compare(createWallet2.state, "verify")
                    seedItem.lineEdit.text = ""
                }
                var word = createWallet2.seedArray[wordIndex]
                seedItem.lineEdit.text = word
                tryCompare(seedItem.icon, "wordsMatch", true)
            }

            verify(createWallet2.wizardNav.btnNext.enabled)
            createWallet2.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet3")
        }

        function test_seed_round_trip_restores_primary_address() {
            var createdWallet = createWalletThroughWizard(
                "seed-source-test", "source password")

            var selectedSourcePath = openRecentWallet(
                "seed-source-test", createdWallet.password)
            compare(selectedSourcePath, createdWallet.path)
            tryCompare(appWindow, "walletOpenRequested", true)
            compare(appWindow.currentWallet.status, Wallet.Status_Ok,
                    appWindow.currentWallet.errorString)
            var sourcePrimaryAddress = appWindow.currentWallet.address(0, 0)
            compare(sourcePrimaryAddress, createdWallet.address)
            closeOpenedWallet()

            showWizardHome()
            wizardController.wizardStateView.wizardHomeView.restoreWalletButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet1")

            var restoreWallet1 = wizardController.wizardStateView.wizardRestoreWallet1View
            restoreWallet1.walletInput.walletName.text = "seed-restored-test"
            restoreWallet1.seedInput.text = createdWallet.seed
            restoreWallet1.restoreHeight.text = "0"
            verify(restoreWallet1.wizardNav.btnNext.enabled)
            restoreWallet1.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet2")

            var restoreWallet2 = wizardController.wizardStateView.wizardRestoreWallet2View
            var restoredPassword = "restored password"
            restoreWallet2.pwField = restoredPassword
            restoreWallet2.pwConfirmField = restoreWallet2.pwField
            verify(restoreWallet2.wizardNav.btnNext.enabled)
            restoreWallet2.wizardNav.btnNext.doClick()

            if (appWindow.walletMode >= 2) {
                tryCompare(wizardController, "wizardState", "wizardRestoreWallet3")
                wizardController.wizardStateView.wizardRestoreWallet3View.wizardNav.btnNext.doClick()
            }
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet4")

            var restoreWallet4 = wizardController.wizardStateView.wizardRestoreWallet4View
            appWindow.walletCreated = false
            appWindow.walletOpenRequested = false
            restoreWallet4.wizardNav.btnNext.doClick()
            tryCompare(appWindow, "walletCreated", true, 30000)
            var restoredWalletPath = persistentSettings.wallet_path
            var restoredDirectAddress = acceptWalletPassword(restoredPassword)
            compare(restoredDirectAddress, sourcePrimaryAddress)
            closeOpenedWallet()

            var selectedRestoredPath = openRecentWallet(
                "seed-restored-test", restoredPassword)
            compare(selectedRestoredPath, restoredWalletPath)
            tryCompare(appWindow, "walletOpenRequested", true)
            compare(appWindow.currentWallet.status, Wallet.Status_Ok,
                    appWindow.currentWallet.errorString)
            compare(appWindow.currentWallet.address(0, 0), restoredDirectAddress)
            compare(appWindow.currentWallet.address(0, 0), sourcePrimaryAddress)
            closeOpenedWallet()
        }
    }
}
