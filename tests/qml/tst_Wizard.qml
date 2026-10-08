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
import QtCore
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
    property string lastStatusMessage: ""

    function updateBalance() {}

    function showStatusMessage(message) { lastStatusMessage = message }

    function releaseFocus() {}

    function changeWalletMode(mode) {
        persistentSettings.walletMode = mode
    }

    function openWallet() {
        passwordDialog.open(persistentSettings.wallet_path)
    }

    Settings {
        id: persistentSettings
        location: diskPortableSettings.location
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
        property bool pruneBlockchain: false
        property bool useRemoteNode: false
        Component.onCompleted: wallet_pathChanged()
    }

    QtObject {
        id: logger
        function resetLogFilePath() {}
    }

    PortableSettings {
        id: diskPortableSettings
        settings: persistentSettings
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

        // Public vectors from external/polyseed/tests/tests.c and
        // tests/unit_tests/mnemonics.cpp in the Monero submodule.
        readonly property string polyseed: "raven tail swear infant grief assist regular lamp "
                                          + "duck valid someone little harsh puppy airport language"
        readonly property string legacySeed: "cinzento luxuriante leonardo gnostico digressao cupula "
                                            + "fifa broxar iniquo louvor ovario dorsal ideologo besuntar "
                                            + "decurso rosto susto lemure unheiro pagodeiro nitroglicerina "
                                            + "eclusa mazurca bigorna gnostico"

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
            appWindow.width = 1000
            appWindow.ctrlPressed = false
            appWindow.walletCreated = false
            appWindow.walletOpenRequested = false
            appWindow.currentWallet = undefined
            appWindow.lastStatusMessage = ""
            persistentSettings.nettype = NetworkType.MAINNET
            persistentSettings.language_wallet = "English"
            persistentSettings.walletMode = 2
            persistentSettings.wallet_path = ""
            wizardController.restart()
            showWizardHome()
        }

        function cleanup() {
            appWindow.width = 1000
            appWindow.ctrlPressed = false
            closeOpenedWallet()
            if (passwordDialog.visible)
                passwordDialog.onCancel()
            wizardController.restart()
            showWizardHome()
            var createWallet2 = wizardController.wizardStateView.wizardCreateWallet2View
            createWallet2.state = "default"
            if (createWallet2.seedListGrid) {
                createWallet2.seedListGrid.destroy()
                tryVerify(function() { return !createWallet2.seedListGrid })
            }
        }

        function test_portable_mode_through_wizard() {
            verify(!diskPortableSettings.portable)
            persistentSettings.language = "English (US)"
            persistentSettings.walletMode = 2
            persistentSettings.pruneBlockchain = false
            tryVerify(function() {
                return String(persistentSettings.value("pruneBlockchain")) === "false"
            })
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
            verify(persistentSettings.pruneBlockchain)
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
            compare(settingsTestHelper.readFile(appWindow.portableMarkerTestPath), "disabled\n")
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

        function test_seed_confirmation_accepts_hidden_words_data() {
            return [
                { tag: "desktop", width: 1000, language: "English", expectedLanguage: "English", rows: 4 },
                { tag: "four-columns", width: 780, language: "English", expectedLanguage: "English", rows: 4 },
                { tag: "three-columns", width: 620, language: "English", expectedLanguage: "English", rows: 6 },
                { tag: "mobile", width: 480, language: "English", expectedLanguage: "English", rows: 8 },
                { tag: "french", width: 1000, language: "Français", expectedLanguage: "français", rows: 4 },
                { tag: "japanese", width: 1000, language: "日本語", expectedLanguage: "日本語", rows: 4 },
                { tag: "chinese", width: 1000, language: "简体中文 (中国)", expectedLanguage: "中文(简体)", rows: 4 },
                { tag: "unsupported-language", width: 1000, language: "Deutsch", expectedLanguage: "English", rows: 4 }
            ]
        }

        function test_seed_confirmation_accepts_hidden_words(data) {
            persistentSettings.language_wallet = data.language
            showWizardHome()
            wizardController.wizardStateView.wizardHomeView.createWalletButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet1")

            var createWallet1 = wizardController.wizardStateView.wizardCreateWallet1View
            createWallet1.walletInput.walletName.text = "seed-confirmation-test"
            verify(createWallet1.wizardNav.btnNext.enabled)
            createWallet1.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet2")

            var createWallet2 = wizardController.wizardStateView.wizardCreateWallet2View
            compare(wizardController.m_wallet.status, Wallet.Status_Ok,
                    wizardController.m_wallet.errorString)
            verify(wizardController.m_wallet.polyseed)
            compare(wizardController.walletOptionsSeedLanguage, data.expectedLanguage)
            compare(createWallet2.seedWordCount, 16)
            compare(createWallet2.seedListGrid.children.length, 16)
            for (var wordNumber = 0; wordNumber < 16; ++wordNumber) {
                compare(createWallet2.seedListGrid.children[wordNumber].word,
                        createWallet2.seedArray[wordNumber])
            }
            appWindow.width = data.width
            tryCompare(createWallet2.seedListGrid, "rows", data.rows)
            // Return from the mobile introduction before entering the words.
            appWindow.width = 1000
            verify(waitForPolish(createWallet2))
            createWallet2.wizardNav.btnNext.doClick()
            compare(createWallet2.state, "verify")
            verify(!createWallet2.wizardNav.btnNext.enabled)
            compare(createWallet2.hiddenWords.length, 5)

            for (var i = 0; i < createWallet2.hiddenWords.length; ++i) {
                var wordIndex = createWallet2.hiddenWords[i]
                verify(wordIndex >= 0 && wordIndex < 16)
                if (i > 0)
                    verify(wordIndex > createWallet2.hiddenWords[i - 1])
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
                if (i < createWallet2.hiddenWords.length - 1)
                    verify(!createWallet2.wizardNav.btnNext.enabled)
            }

            verify(createWallet2.wizardNav.btnNext.enabled)
            createWallet2.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet3")
        }

        function test_seed_backup_keyboard_navigation_data() {
            return [
                { tag: "simple", mode: 0 },
                { tag: "simple-bootstrap", mode: 1 },
                { tag: "advanced", mode: 2 }
            ]
        }

        function test_seed_backup_keyboard_navigation(data) {
            persistentSettings.walletMode = data.mode
            var createWallet3 = goToCreatePasswordPage("seed-navigation-test")
            createWallet3.wizardNav.btnPrev.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet2")
            var createWallet2 = wizardController.wizardStateView.wizardCreateWallet2View
            verify(waitForPolish(createWallet2))
            var printButton = createWallet2.wizardNav.btnPrevKeyNavigationBackTab
            compare(printButton.text, "Print a template")

            createWallet2.lastSeedItem().forceActiveFocus()
            keyClick(Qt.Key_Tab)
            if (data.mode >= 2) {
                var copyButton = printButton.KeyNavigation.backtab
                var newSeedButton = copyButton.KeyNavigation.backtab
                verify(newSeedButton.activeFocus)
                keyClick(Qt.Key_Tab)
                verify(copyButton.activeFocus)
                keyClick(Qt.Key_Tab)
            }
            verify(printButton.activeFocus)
            keyClick(Qt.Key_Tab)
            verify(createWallet2.wizardNav.btnPrev.activeFocus)
            keyClick(Qt.Key_Backtab)
            verify(printButton.activeFocus)
        }

        function test_regenerate_seed_updates_backup_and_confirmation() {
            var createWallet3 = goToCreatePasswordPage("regenerate-seed-test")
            createWallet3.wizardNav.btnPrev.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet2")
            var createWallet2 = wizardController.wizardStateView.wizardCreateWallet2View
            verify(waitForPolish(createWallet2))
            var previousSeed = wizardController.walletOptionsSeed
            var previousAddress = wizardController.m_wallet.address(0, 0)
            var printButton = createWallet2.wizardNav.btnPrevKeyNavigationBackTab
            var copyButton = printButton.KeyNavigation.backtab
            var newSeedButton = copyButton.KeyNavigation.backtab
            newSeedButton.doClick()
            tryCompare(appWindow, "lastStatusMessage", "New seed generated")

            verify(wizardController.walletOptionsSeed !== previousSeed)
            verify(wizardController.m_wallet.address(0, 0) !== previousAddress)
            compare(createWallet2.seedWordCount, 16)
            compare(createWallet2.seedListGrid.children.length, 16)
            for (var i = 0; i < 16; ++i) {
                compare(createWallet2.seedListGrid.children[i].word, createWallet2.seedArray[i])
            }
            createWallet2.wizardNav.btnNext.doClick()
            compare(createWallet2.state, "verify")
            verify(!createWallet2.wizardNav.btnNext.enabled)
            for (var j = 0; j < createWallet2.hiddenWords.length; ++j) {
                var wordIndex = createWallet2.hiddenWords[j]
                createWallet2.seedListGrid.children[wordIndex].lineEdit.text = createWallet2.seedArray[wordIndex]
            }
            verify(createWallet2.wizardNav.btnNext.enabled)
            createWallet2.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet3")
        }

        function test_simple_hardware_summary_back_keeps_device_flow_data() {
            return [
                { tag: "simple", mode: 0 },
                { tag: "simple-bootstrap", mode: 1 }
            ]
        }

        function test_simple_hardware_summary_back_keeps_device_flow(data) {
            persistentSettings.walletMode = data.mode
            // Resume at the password page after successful hardware wallet creation.
            wizardController.walletOptionsIsRecoveringFromDevice = true
            wizardController.wizardState = "wizardCreateWallet3"
            var createWallet3 = wizardController.wizardStateView.wizardCreateWallet3View
            createWallet3.pwField = "device wallet password"
            createWallet3.pwConfirmField = createWallet3.pwField
            createWallet3.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateWallet5")
            wizardController.wizardStateView.wizardCreateWallet5View.wizardNav.btnPrev.doClick()
            tryCompare(wizardController, "wizardState", "wizardCreateDevice1")
            verify(!wizardController.wizardStateView.wizardCreateWallet2View.seedListGrid)
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
            verify(appWindow.currentWallet.polyseed)
            compare(appWindow.currentWallet.seed, createdWallet.seed)
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
            var expectedRestoreHeight = wizardController.m_wallet.walletCreationHeight
            verify(expectedRestoreHeight > 0)
            tryCompare(appWindow, "walletCreated", true, 30000)
            var restoredWalletPath = persistentSettings.wallet_path
            var restoredDirectAddress = acceptWalletPassword(restoredPassword)
            compare(restoredDirectAddress, sourcePrimaryAddress)
            verify(appWindow.currentWallet.polyseed)
            compare(appWindow.currentWallet.seed, createdWallet.seed)
            compare(appWindow.currentWallet.walletCreationHeight, expectedRestoreHeight)
            compare(persistentSettings.restore_height, expectedRestoreHeight)
            closeOpenedWallet()

            var selectedRestoredPath = openRecentWallet(
                "seed-restored-test", restoredPassword)
            compare(selectedRestoredPath, restoredWalletPath)
            tryCompare(appWindow, "walletOpenRequested", true)
            compare(appWindow.currentWallet.status, Wallet.Status_Ok,
                    appWindow.currentWallet.errorString)
            compare(appWindow.currentWallet.address(0, 0), restoredDirectAddress)
            compare(appWindow.currentWallet.address(0, 0), sourcePrimaryAddress)
            compare(appWindow.currentWallet.walletCreationHeight, expectedRestoreHeight)
            closeOpenedWallet()
        }

        function test_offline_restore_height_data() {
            // The public Polyseed vector's birthday is 2021-12-01 22:29:06 UTC.
            // Heights follow wallet2's fork extrapolation, network adjustment,
            // and one-month safety margin when no daemon is available.
            return [
                { tag: "polyseed-mainnet", seed: polyseed, nettype: NetworkType.MAINNET, height: 0, expectedHeight: 2482480, polyseed: true },
                { tag: "polyseed-testnet", seed: polyseed, nettype: NetworkType.TESTNET, height: 0, expectedHeight: 1815190, polyseed: true },
                { tag: "polyseed-stagenet", seed: polyseed, nettype: NetworkType.STAGENET, height: 0, expectedHeight: 929592, polyseed: true },
                { tag: "override-mainnet", seed: polyseed, nettype: NetworkType.MAINNET, height: 123456, expectedHeight: 123456, polyseed: true },
                { tag: "override-testnet", seed: polyseed, nettype: NetworkType.TESTNET, height: 123456, expectedHeight: 123456, polyseed: true },
                { tag: "override-stagenet", seed: polyseed, nettype: NetworkType.STAGENET, height: 123456, expectedHeight: 123456, polyseed: true },
                { tag: "legacy-zero", seed: legacySeed, nettype: NetworkType.MAINNET, height: 0, expectedHeight: 0, polyseed: false },
                { tag: "legacy-override", seed: legacySeed, nettype: NetworkType.MAINNET, height: 123456, expectedHeight: 123456, polyseed: false },
                { tag: "legacy-24-words", seed: legacySeed.split(" ").slice(0, 24).join(" "), nettype: NetworkType.MAINNET, height: 0, expectedHeight: 0, polyseed: false }
            ]
        }

        function test_offline_restore_height(data) {
            persistentSettings.nettype = data.nettype
            // Pasted seed phrases may contain newlines, tabs, or ideographic spaces.
            wizardController.walletOptionsSeed = "  " + data.seed.replace(/ /g, "\n\t\u3000") + "  "
            wizardController.walletOptionsRestoreHeight = data.height
            verify(wizardController.recoveryWallet())
            var wallet = wizardController.m_wallet
            compare(wallet.status, Wallet.Status_Ok, wallet.errorString)
            compare(wallet.polyseed, data.polyseed)
            compare(wallet.walletCreationHeight, data.expectedHeight)
            compare(wizardController.walletOptionsRestoreHeight, data.expectedHeight)
            verify(wallet.address(0, 0).length > 0)
        }

        function test_recoverable_error_does_not_hide_seed_data() {
            return [
                { tag: "polyseed", seed: polyseed, polyseed: true },
                { tag: "legacy", seed: legacySeed, polyseed: false }
            ]
        }

        function test_recoverable_error_does_not_hide_seed(data) {
            wizardController.walletOptionsSeed = data.seed
            verify(wizardController.recoveryWallet())
            var wallet = wizardController.m_wallet
            var recoveryPhrase = wallet.seed
            compare(wallet.getTxKey("bad"), "")
            compare(wallet.status, Wallet.Status_Error)
            compare(wallet.seed, recoveryPhrase)
            wallet.getTxKey("bad")
            var error = wallet.errorString
            compare(wallet.polyseed, data.polyseed)
            compare(wallet.status, Wallet.Status_Error)
            compare(wallet.errorString, error)
        }

        function test_clearing_restore_height_uses_polyseed_birthday() {
            wizardController.wizardStateView.wizardHomeView.restoreWalletButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet1")
            var restoreWallet1 = wizardController.wizardStateView.wizardRestoreWallet1View
            restoreWallet1.walletInput.walletName.text = "cleared-height-test"
            restoreWallet1.seedInput.text = polyseed
            restoreWallet1.restoreHeightCheckbox.toggle()
            restoreWallet1.restoreHeight.text = "123456"
            restoreWallet1.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet2")
            compare(wizardController.walletOptionsRestoreHeight, 123456)
            wizardController.wizardStateView.wizardRestoreWallet2View.wizardNav.btnPrev.doClick()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet1")
            restoreWallet1.restoreHeight.text = ""
            restoreWallet1.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet2")
            compare(wizardController.walletOptionsRestoreHeight, 0)
            verify(wizardController.recoveryWallet())
            compare(wizardController.m_wallet.walletCreationHeight, 2482480)
        }

        function test_invalid_polyseed_keeps_restore_page_usable() {
            wizardController.wizardStateView.wizardHomeView.restoreWalletButton.menuClicked()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet1")
            var restoreWallet1 = wizardController.wizardStateView.wizardRestoreWallet1View
            restoreWallet1.walletInput.walletName.text = "invalid-polyseed-test"
            // Change the checksum word while keeping a valid 16-word list.
            restoreWallet1.seedInput.text = polyseed.replace("raven", "abandon")
            restoreWallet1.restoreHeight.text = "0"
            verify(restoreWallet1.wizardNav.btnNext.enabled)
            restoreWallet1.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet2")
            var restoreWallet2 = wizardController.wizardStateView.wizardRestoreWallet2View
            restoreWallet2.pwField = "restore password"
            restoreWallet2.pwConfirmField = restoreWallet2.pwField
            restoreWallet2.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet3")
            wizardController.wizardStateView.wizardRestoreWallet3View.wizardNav.btnNext.doClick()
            tryCompare(wizardController, "wizardState", "wizardRestoreWallet4")
            var restoreWallet4 = wizardController.wizardStateView.wizardRestoreWallet4View
            restoreWallet4.wizardNav.btnNext.doClick()
            verify(restoreWallet4.wizardNav.btnNext.enabled)
            verify(typeof wizardController.m_wallet === "undefined")
            verify(appWindow.lastStatusMessage.length > 0)
            verify(!appWindow.walletCreated)
            verify(!walletManager.walletExists(walletPath("invalid-polyseed-test")))
            compare(wizardController.wizardState, "wizardRestoreWallet4")
        }
    }
}
