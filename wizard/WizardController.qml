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

import QtQml 2.0
import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import QtQuick.Dialogs 1.2
import moneroComponents.Wallet 1.0

import "../js/Wizard.js" as Wizard
import "../js/Windows.js" as Windows
import "../js/Utils.js" as Utils
import "../components" as MoneroComponents
import "../components/effects/" as MoneroEffects
import "../pages"

Rectangle {
    id: wizardController
    anchors.fill: parent

    signal useMoneroClicked()
    signal walletCreatedFromDevice(bool success)

    function restart() {
        wizardStateView.state = "wizardHome"
        wizardController.walletOptionsName = defaultAccountName;
        wizardController.walletOptionsLocation = '';
        wizardController.walletOptionsPassword = '';
        wizardController.walletOptionsSeed = '';
        wizardController.walletOptionsRecoverAddress = ''
        wizardController.walletOptionsRecoverViewkey = ''
        wizardController.walletOptionsRecoverSpendkey = ''
        wizardController.walletOptionsBackup = '';
        wizardController.walletRestoreMode = 'seed';
        wizardController.walletOptionsRestoreHeight = 0;
        wizardController.walletOptionsIsRecovering = false;
        wizardController.walletOptionsIsRecoveringFromDevice = false;
        wizardController.walletOptionsDeviceName = '';
        wizardController.walletOptionsDeviceIsRestore = false;
        wizardController.tmpWalletFilename = '';
        wizardController.walletRestoreMode = 'seed'
        wizardController.walletOptionsSubaddressLookahead = '';
        wizardController.remoteNodes = {};
        disconnect();
    }

    property var m_wallet;
    property alias wizardState: wizardStateView.state
    property alias wizardStatePrevious: wizardStateView.previousView
    property int wizardSubViewWidth: 780
    property int wizardSubViewTopMargin: persistentSettings.customDecorations ? 90 : 32
    property bool skipModeSelection: false

    // wallet variables
    property string walletOptionsName: ''
    property string walletOptionsLocation: ''
    property string walletOptionsPassword: ''
    property string walletOptionsSeed: ''
    property string walletOptionsRecoverAddress: ''
    property string walletOptionsRecoverViewkey: ''
    property string walletOptionsRecoverSpendkey: ''
    property string walletOptionsBackup: ''
    property int    walletOptionsRestoreHeight: 0
    property string walletOptionsBootstrapAddress: persistentSettings.bootstrapNodeAddress
    property bool   walletOptionsRestoringFromDevice: false
    property bool   walletOptionsIsRecovering: false
    property bool   walletOptionsIsRecoveringFromDevice: false
    property string walletOptionsSubaddressLookahead: ''
    property string walletOptionsDeviceName: ''
    property bool   walletOptionsDeviceIsRestore: false
    property string tmpWalletFilename: ''
    property var remoteNodes: ''

    // language settings, updated via sidebar
    property string language_locale: 'en_US'
    property string language_wallet: 'English'
    property string language_language: 'English (US)'

    // recovery made (restore wallet)
    property string walletRestoreMode: 'seed'  // seed, keys, qr

    // flickable margin
    property int flickableHeightMargin: 200

    property int layoutScale: {
        if(isMobile){
            return 0;
        } else if(appWindow.width < 800){
            return 1;
        } else {
            return 2;
        }
    }


    Rectangle {
        id: wizardStateView
        property Item currentView
        property Item previousView
        property WizardLanguage wizardLanguageView: WizardLanguage { }
        property WizardHome wizardHomeView: WizardHome { }
        property WizardCreateWallet1 wizardCreateWallet1View: WizardCreateWallet1 { }
        property WizardCreateWallet2 wizardCreateWallet2View: WizardCreateWallet2 { }
        property WizardCreateWallet3 wizardCreateWallet3View: WizardCreateWallet3 { }
        property WizardCreateWallet4 wizardCreateWallet4View: WizardCreateWallet4 { }
        property WizardRestoreWallet1 wizardRestoreWallet1View: WizardRestoreWallet1 { }
        property WizardRestoreWallet2 wizardRestoreWallet2View: WizardRestoreWallet2 { }
        property WizardRestoreWallet3 wizardRestoreWallet3View: WizardRestoreWallet3 { }
        property WizardRestoreWallet4 wizardRestoreWallet4View: WizardRestoreWallet4 { }
        property WizardCreateDevice1 wizardCreateDevice1View: WizardCreateDevice1 { }
        property WizardOpenWallet1 wizardOpenWallet1View: WizardOpenWallet1 { }
        property WizardModeSelection wizardModeSelectionView: WizardModeSelection { }
        property WizardModeRemoteNodeWarning wizardModeRemoteNodeWarningView: WizardModeRemoteNodeWarning { }
        property WizardModeBootstrap wizardModeBootstrapView: WizardModeBootstrap {}
        anchors.fill: parent

        signal previousClicked;

        color: "transparent"
        state: ''

        onPreviousClicked: {
            if (previousView && previousView.viewName != null){
                state = previousView.viewName;
            } else {
                state = "wizardHome";
            }
        }

        onCurrentViewChanged: {
            if (previousView) {
               if (typeof previousView.onPageClosed === "function") {
                   previousView.onPageClosed();
               }

               // Combined with NumberAnimation to fade out views
               previousView.opacity = 0;
            }

            if (currentView) {
                stackView.replace(currentView)
                // Calls when view is opened
                if (typeof currentView.onPageCompleted === "function") {
                    currentView.onPageCompleted(previousView);
                }

                // Combined with NumberAnimation to fade in views
                currentView.opacity = 1;
            }

            previousView = currentView;
        }

        states: [
            State {
                name: "wizardLanguage"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardLanguageView }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardLanguageView.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardHome"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardHomeView }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardHomeView.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardCreateWallet1"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardCreateWallet1View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardCreateWallet1View.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardCreateWallet2"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardCreateWallet2View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardCreateWallet2View.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardCreateWallet3"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardCreateWallet3View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardCreateWallet3View.height + wizardController.flickableHeightMargin + 400 }
            }, State {
                name: "wizardCreateWallet4"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardCreateWallet4View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardCreateWallet4View.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardRestoreWallet1"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardRestoreWallet1View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardRestoreWallet1View.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardRestoreWallet2"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardRestoreWallet2View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardRestoreWallet2View.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardRestoreWallet3"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardRestoreWallet3View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardRestoreWallet3View.childrenRect.height + wizardController.flickableHeightMargin + 400 }
            }, State {
                name: "wizardRestoreWallet4"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardRestoreWallet4View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardRestoreWallet4View.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardCreateDevice1"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardCreateDevice1View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardCreateDevice1View.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardOpenWallet1"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardOpenWallet1View }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardOpenWallet1View.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardModeSelection"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardModeSelectionView }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardModeSelectionView.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardModeRemoteNodeWarning"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardModeRemoteNodeWarningView }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardModeRemoteNodeWarningView.childrenRect.height + wizardController.flickableHeightMargin }
            }, State {
                name: "wizardModeBootstrap"
                PropertyChanges { target: wizardStateView; currentView: wizardStateView.wizardModeBootstrapView }
                PropertyChanges { target: wizardFlickable; contentHeight: wizardStateView.wizardModeBootstrapView.childrenRect.height + wizardController.flickableHeightMargin }
            }
        ]

        MoneroEffects.GradientBackground {
            anchors.fill: parent
            fallBackColor: MoneroComponents.Style.middlePanelBackgroundColor
            initialStartColor: MoneroComponents.Style.wizardBackgroundGradientStart
            initialStopColor: MoneroComponents.Style.middlePanelBackgroundGradientStop
            blackColorStart: MoneroComponents.Style._b_wizardBackgroundGradientStart
            blackColorStop: MoneroComponents.Style._b_middlePanelBackgroundGradientStop
            whiteColorStart: MoneroComponents.Style._w_wizardBackgroundGradientStart
            whiteColorStop: MoneroComponents.Style._w_middlePanelBackgroundGradientStop
            start: Qt.point(0, 0)
            end: Qt.point(height, width)
        }

        Flickable {
            id: wizardFlickable
            anchors.fill: parent
            clip: true

            ScrollBar.vertical: ScrollBar {
                parent: wizardFlickable.parent
                anchors.left: parent.right
                anchors.leftMargin: 3
                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.bottom: parent.bottom
            }

            onFlickingChanged: {
                releaseFocus();
            }

            StackView {
                id: stackView
                initialItem: wizardStateView.wizardLanguageView
                anchors.fill: parent
                clip: true

                delegate: StackViewDelegate {
                    pushTransition: StackViewTransition {
                         PropertyAnimation {
                             target: enterItem
                             property: "x"
                             from: target.width
                             to: 0
                             duration: 300
                             easing.type: Easing.OutCubic
                         }
                         PropertyAnimation {
                             target: exitItem
                             property: "x"
                             from: 0
                             to: 0 - target.width
                             duration: 300
                             easing.type: Easing.OutCubic
                         }
                    }
                }
            }
        }
	}

    //Open Wallet from file
    FileDialog {
        id: fileDialog
        title: qsTr("Please choose a file") + translationManager.emptyString
        folder: "file://" + moneroAccountsDir
        nameFilters: [ "Wallet files (*.keys)"]
        sidebarVisible: false

        onAccepted: {
            wizardController.openWalletFile(fileDialog.fileUrl);
        }
        onRejected: {
            console.log("Canceled")
            appWindow.viewState = "wizard";
        }
    }

    function createWallet() {
        // Creates wallet in a temp. location

        // Always delete the wallet object before creating new - we could be stepping back from recovering wallet
        if (typeof wizardController.m_wallet !== 'undefined') {
            walletManager.closeWallet()
            console.log("deleting wallet")
        }

        var tmp_wallet_filename = oshelper.temporaryFilename();
        console.log("Creating temporary wallet", tmp_wallet_filename)
        var nettype = appWindow.persistentSettings.nettype;
        var kdfRounds = appWindow.persistentSettings.kdfRounds;
        var wallet = walletManager.createWallet(tmp_wallet_filename, "", wizardController.language_wallet, nettype, kdfRounds)

        wizardController.walletOptionsSeed = wallet.seed

        // saving wallet in "global" object
        // @TODO: wallet should have a property pointing to the file where it stored or loaded from
        wizardController.m_wallet = wallet;
        wizardController.tmpWalletFilename = tmp_wallet_filename
    }

    function writeWallet() {
        // Save wallet files in user specified location
        var new_wallet_filename = Wizard.createWalletPath(
            isIOS,
            wizardController.walletOptionsLocation,
            wizardController.walletOptionsName);

        if(isIOS) {
            console.log("saving in ios: " + moneroAccountsDir + new_wallet_filename)
            wizardController.m_wallet.store(moneroAccountsDir + new_wallet_filename);
        } else {
            console.log("saving in wizard: " + new_wallet_filename)
            wizardController.m_wallet.store(new_wallet_filename);
        }

        // make sure temporary wallet files are deleted
        console.log("Removing temporary wallet: " + wizardController.tmpWalletFilename)
        oshelper.removeTemporaryWallet(wizardController.tmpWalletFilename)

        // protecting wallet with password
        wizardController.m_wallet.setPassword(wizardController.walletOptionsPassword);

        // Store password in session to be able to use password protected functions (e.g show seed)
        appWindow.walletPassword = walletOptionsPassword

        // save to persistent settings
        persistentSettings.language = wizardController.language_language
        persistentSettings.locale   = wizardController.language_locale

        persistentSettings.account_name = wizardController.walletOptionsName
        persistentSettings.wallet_path = new_wallet_filename
        persistentSettings.restore_height = (isNaN(walletOptionsRestoreHeight))? 0 : walletOptionsRestoreHeight

        persistentSettings.allow_background_mining = false
        persistentSettings.is_recovering = (wizardController.walletOptionsIsRecovering === undefined) ? false : wizardController.walletOptionsIsRecovering
        persistentSettings.is_recovering_from_device = (wizardController.walletOptionsIsRecoveringFromDevice === undefined) ? false : wizardController.walletOptionsIsRecoveringFromDevice
    }

    function recoveryWallet() {
        var nettype = persistentSettings.nettype;
        var kdfRounds = persistentSettings.kdfRounds;
        var restoreHeight = wizardController.walletOptionsRestoreHeight;
        var tmp_wallet_filename = oshelper.temporaryFilename()
        console.log("Creating temporary wallet", tmp_wallet_filename)

        // delete the temporary wallet object before creating new
        if (typeof wizardController.m_wallet !== 'undefined') {
            walletManager.closeWallet()
            console.log("deleting temporary wallet")
        }
        var wallet = ''
        // From seed or keys
        if(wizardController.walletRestoreMode === 'seed')
            wallet = walletManager.recoveryWallet(tmp_wallet_filename, wizardController.walletOptionsSeed, nettype, restoreHeight, kdfRounds)
        else
            wallet = walletManager.createWalletFromKeys(tmp_wallet_filename, wizardController.language_wallet, nettype,
                                                            wizardController.walletOptionsRecoverAddress, wizardController.walletOptionsRecoverViewkey,
                                                            wizardController.walletOptionsRecoverSpendkey, restoreHeight, kdfRounds)

        var success = wallet.status === Wallet.Status_Ok;
        if (success) {
            wizardController.m_wallet = wallet;
            wizardController.walletOptionsIsRecovering = true;
            wizardController.tmpWalletFilename = tmp_wallet_filename
        } else {
            console.log(wallet.errorString)
            appWindow.showStatusMessage(qsTr(wallet.errorString), 5);
            walletManager.closeWallet();
        }
        return success;
    }

    function disconnect(){
        walletManager.walletCreated.disconnect(onWalletCreated);
        walletManager.walletPassphraseNeeded.disconnect(onWalletPassphraseNeeded);
        walletManager.deviceButtonRequest.disconnect(onDeviceButtonRequest);
        walletManager.deviceButtonPressed.disconnect(onDeviceButtonPressed);
    }

    function connect(){
        walletManager.walletCreated.connect(onWalletCreated);
        walletManager.walletPassphraseNeeded.connect(onWalletPassphraseNeeded);
        walletManager.deviceButtonRequest.connect(onDeviceButtonRequest);
        walletManager.deviceButtonPressed.connect(onDeviceButtonPressed);
    }

    function deviceAttentionSplash(){
        appWindow.showProcessingSplash(qsTr("Please proceed to the device..."));
    }

    function creatingWalletDeviceSplash(){
        appWindow.showProcessingSplash(qsTr("Creating wallet from device..."));
    }

    function createWalletFromDevice() {
        // TODO: create wallet in temporary filename and a) move it to the path specified by user after the final
        // page submitted or b) delete it when program closed before reaching final page

        // Always delete the wallet object before creating new - we could be stepping back from recovering wallet
        if (typeof wizardController.m_wallet !== 'undefined') {
            walletManager.closeWallet()
            console.log("deleting wallet")
        }

        tmpWalletFilename = oshelper.temporaryFilename();
        console.log("Creating temporary wallet", tmpWalletFilename)
        var nettype = persistentSettings.nettype;
        var restoreHeight = wizardController.walletOptionsRestoreHeight;
        var subaddressLookahead = wizardController.walletOptionsSubaddressLookahead;
        var deviceName = wizardController.walletOptionsDeviceName;

        connect();
        walletManager.createWalletFromDeviceAsync(tmpWalletFilename, "", nettype, deviceName, restoreHeight, subaddressLookahead);
        creatingWalletDeviceSplash();
    }

    function onWalletCreated(wallet) {
        splash.close()

        var success = wallet.status === Wallet.Status_Ok;
        if (success) {
            wizardController.m_wallet = wallet;
            wizardController.walletOptionsIsRecoveringFromDevice = true;
            if (!wizardController.walletOptionsDeviceIsRestore) {
                // User creates a hardware wallet for the first time. Use a recent block height from API.
                wizardController.walletOptionsRestoreHeight = wizardController.m_wallet.walletCreationHeight;
            }
        } else {
            console.log(wallet.errorString)
            wizardController.tmpWalletFilename = '';
            appWindow.showStatusMessage(qsTr(wallet.errorString), 5);
            walletManager.closeWallet();
        }

        disconnect();
        walletCreatedFromDevice(success);
    }

    function onWalletPassphraseNeeded(){
        splash.close()

        console.log(">>> wallet passphrase needed: ");
        passphraseDialog.onAcceptedCallback = function() {
            walletManager.onPassphraseEntered(passphraseDialog.passphrase);
            creatingWalletDeviceSplash();
        }
        passphraseDialog.onRejectedCallback = function() {
            walletManager.onPassphraseEntered("", true);
            creatingWalletDeviceSplash();
        }
        passphraseDialog.open()
    }

    function onDeviceButtonRequest(code){
        deviceAttentionSplash();
    }

    function onDeviceButtonPressed(){
        creatingWalletDeviceSplash();
    }

    function openWallet(){
        if (typeof wizardController.m_wallet !== 'undefined' && wizardController.m_wallet != null) {
            walletManager.closeWallet()
        }

        fileDialog.open();
    }

    function openWalletFile(fn) {
        persistentSettings.restore_height = 0;
        persistentSettings.is_recovering = false;
        persistentSettings.is_recovering_from_device = false;

        appWindow.restoreHeight = 0;
        appWindow.walletPassword = "";

        if(typeof fn == 'object')
            persistentSettings.wallet_path = walletManager.urlToLocalPath(fn);
        else
            persistentSettings.wallet_path = fn;

        if(isIOS)
            persistentSettings.wallet_path = persistentSettings.wallet_path.replace(moneroAccountsDir, "");

        console.log(moneroAccountsDir);
        console.log(fn);
        console.log(persistentSettings.wallet_path);

        passwordDialog.onAcceptedCallback = function() {
            walletPassword = passwordDialog.password;
            appWindow.initialize();
        }
        passwordDialog.onRejectedCallback = function() {
            console.log("Canceled");
            appWindow.viewState = "wizard";
        }

        passwordDialog.open(appWindow.usefulName(appWindow.walletPath()));
    }

    function fetchRemoteNodes(cb, cb_err){
        // Fetch remote nodes, parse JSON, store in result `wizardController.remoteNodes`, call setAutNode(), call callback
        var url = appWindow.remoteNodeService + 'api/nodes.json';
        console.log("HTTP request: " + url);

        var xhr = new XMLHttpRequest();
        xhr.timeout = 3500;

        // Unfortunately we cannot spoof User-Agent since it is hardcoded in Qt
        //xhr.setRequestHeader("User-Agent", "-");

        xhr.onreadystatechange = function() {
            var msg;
            if (xhr.readyState != 4) {
                return;
            } else if(xhr.status != 200){
                msg = "Error fetching remote nodes; status code was not 200";
                console.log(msg);
                if(typeof cb_err === 'function')
                    return cb_err(msg);
            } else {
                var body = xhr.responseText;
                if(typeof body === 'undefined' || body === ''){
                    msg = "Error fetching remote nodes; response body was empty";
                    console.log(msg);
                    if(typeof cb_err === 'function')
                        return cb_err(msg);
                }

                var data = JSON.parse(body);
                wizardController.remoteNodes = data;
                console.log("node list updated");
                setAutoNode();
                return cb();
            }
        }

        xhr.open('GET', url, true);
        xhr.send(null);
    }

    function setAutoNode(){
        var node;
        var nodes;
        var nodeObject = wizardController.remoteNodes;
        var region = persistentSettings.remoteNodeRegion;

        if(typeof region !== 'undefined' && region !== ""){
            if(nodeObject.hasOwnProperty(region) && nodeObject[region].length > 0){
                nodes = nodeObject[region];
            } else {
                console.log("No suitable nodes found for region " + region + ". Defaulting to random node.");
            }
        }

        if(typeof nodes === 'undefined'){
            nodes = [];
            Object.keys(nodeObject).forEach(function(obj, i){
                nodes = nodes.concat(nodeObject[obj]);
            });
        }

        // 18089 has precedence
        var filteredNodes = Utils.filterNodes(nodes, "18089");
        if(filteredNodes.length > 0){
            node = Utils.randomChoice(filteredNodes);
            console.log('Choosing remote node \''+ node +'\' from a list of ' + filteredNodes.length);
        } else if(nodes.length > 0){
            node = Utils.randomChoice(nodes);
            console.log('Choosing remote node \''+ node +'\' from a list of ' + nodes.length);
        } else {
            console.log("No suitable nodes found.")
            return ''
        }

        if(appWindow.walletMode === 0)
            persistentSettings.remoteNodeAddress = node;
        else if(appWindow.walletMode === 1)
            persistentSettings.bootstrapNodeAddress = node;
    }

    Component.onCompleted: {
        //
    }
}
