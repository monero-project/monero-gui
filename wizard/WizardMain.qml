// Copyright (c) 2014-2018, The Monero Project
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
import Qt.labs.settings 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

import "../components"

ColumnLayout {
    anchors.fill: parent
    Layout.fillHeight: true
    id: wizard
    property alias nextButton : nextButton
    property var settings : ({})
    property int currentPage: 0
    property int wizardLeftMargin: (!isMobile) ?  150 : 25 * scaleRatio
    property int wizardRightMargin: (!isMobile) ? 150 : 25 * scaleRatio
    property int wizardBottomMargin: (isMobile) ? 150 : 25 * scaleRatio
    property int wizardTopMargin: (isMobile) ? 15 * scaleRatio : 50
    // Storing wallet in Settings object doesn't work in qt 5.8 on android
    property var m_wallet;

    property var paths: {
     //   "create_wallet" : [welcomePage, optionsPage, createWalletPage, passwordPage, donationPage, finishPage ],
     //   "recovery_wallet" : [welcomePage, optionsPage, recoveryWalletPage, passwordPage, donationPage, finishPage ],
        // disable donation page
        "create_wallet" : [welcomePage, optionsPage, createWalletPage, passwordPage, daemonSettingsPage, finishPage ],
        "recovery_wallet" : [welcomePage, optionsPage, recoveryWalletPage, passwordPage, daemonSettingsPage, finishPage ],
        "create_view_only_wallet" : [ createViewOnlyWalletPage, passwordPage ],
        "create_wallet_from_device" : [welcomePage, optionsPage, createWalletFromDevicePage, passwordPage, daemonSettingsPage, finishPage ],

    }
    property string currentPath: "create_wallet"
    property var pages: paths[currentPath]

    signal wizardRestarted();
    signal useMoneroClicked()
    signal openWalletFromFileClicked()
//    border.color: "#DBDBDB"
//    border.width: 1
//    color: "#FFFFFF"

    function restart(){
        wizard.currentPage = 0;
        wizard.settings = ({})
        wizard.currentPath = "create_wallet"
        wizard.pages = paths[currentPath]
        wizardRestarted();

        //hide all pages except first
        for (var i = 1; i < wizard.pages.length; i++){
            wizard.pages[i].opacity = 0;
        }
        //Show first pages
        wizard.pages[0].opacity = 1;

    }

    function switchPage(next) {

        // Android focus workaround
        releaseFocus();

        // save settings for current page;
        if (next && typeof pages[currentPage].onPageClosed !== 'undefined') {
            if (pages[currentPage].onPageClosed(settings) !== true) {
                print ("Can't go to the next page");
                return;
            };

        }
        console.log("switchpage: currentPage: ", currentPage);

        // Update prev/next button positions for mobile/desktop
        prevButton.anchors.verticalCenter = (!isMobile) ? wizard.verticalCenter : undefined
        prevButton.anchors.bottom = (isMobile) ? wizard.bottom : undefined
        nextButton.anchors.verticalCenter = (!isMobile) ? wizard.verticalCenter : undefined
        nextButton.anchors.bottom = (isMobile) ? wizard.bottom : undefined

        if (currentPage > 0 || currentPage < pages.length - 1) {
            pages[currentPage].opacity = 0
            var step_value = next ? 1 : -1
            currentPage += step_value
            pages[currentPage].opacity = 1;

            var nextButtonVisible = currentPage > 1 && currentPage < pages.length - 1
            nextButton.visible = nextButtonVisible

            if (typeof pages[currentPage].onPageOpened !== 'undefined') {
                pages[currentPage].onPageOpened(settings,next)
            }
        }
    }



    function openCreateWalletPage() {
        wizardRestarted();
        print ("show create wallet page");
        currentPath = "create_wallet"
        pages = paths[currentPath]
        createWalletPage.createWallet(settings)
        wizard.nextButton.visible = true
        // goto next page
        switchPage(true);
    }

    function openRecoveryWalletPage() {
        wizardRestarted();
        print ("show recovery wallet page");
        currentPath = "recovery_wallet"
        pages = paths[currentPath]
        // Create temporary wallet
        createWalletPage.createWallet(settings)
        wizard.nextButton.visible = true
        // goto next page
        switchPage(true);
    }

    function openOpenWalletPage() {
        console.log("open wallet from file page");
        if (typeof m_wallet !== 'undefined' && m_wallet != null) {
            walletManager.closeWallet()
        }
        optionsPage.onPageClosed(settings)
        wizard.openWalletFromFileClicked();
    }

    function openCreateViewOnlyWalletPage(){
        pages[currentPage].opacity = 0
        currentPath = "create_view_only_wallet"
        pages = paths[currentPath]
        currentPage = pages.indexOf(createViewOnlyWalletPage)
        createViewOnlyWalletPage.opacity = 1
        nextButton.visible = true
        rootItem.state = "wizard";
    }

    function openCreateWalletFromDevicePage() {
        wizardRestarted();
        print ("show create wallet from device page");
        currentPath = "create_wallet_from_device"
        pages = paths[currentPath]
        wizard.nextButton.visible = true
        // goto next page
        switchPage(true);
    }

    function createWalletPath(folder_path,account_name){

        // Remove trailing slash - (default on windows and mac)
        if (folder_path.substring(folder_path.length -1) === "/"){
            folder_path = folder_path.substring(0,folder_path.length -1)
        }

        // Store releative path on ios.
        if(isIOS)
            folder_path = "";

        return folder_path + "/" + account_name + "/" + account_name
    }

    function walletPathValid(path){
        if(isIOS)
            path = moneroAccountsDir + path;
        if (walletManager.walletExists(path)) {
            walletErrorDialog.text = qsTr("A wallet with same name already exists. Please change wallet name") + translationManager.emptyString;
            walletErrorDialog.open();
            return false;
        }

        return true;
    }

    function isAscii(str){
        for (var i = 0; i < str.length; i++) {
            if (str.charCodeAt(i) > 127)
                return false;
        }
        return true;
    }

    //! actually writes the wallet
    function applySettings() {
        // Save wallet files in user specified location
        var new_wallet_filename = createWalletPath(settings.wallet_path,settings.account_name)
        if(isIOS) {
            console.log("saving in ios: "+ moneroAccountsDir + new_wallet_filename)
            m_wallet.store(moneroAccountsDir + new_wallet_filename);
        } else {
            console.log("saving in wizard: "+ new_wallet_filename)
            m_wallet.store(new_wallet_filename);
        }



        // make sure temporary wallet files are deleted
        console.log("Removing temporary wallet: "+ settings.tmp_wallet_filename)
        oshelper.removeTemporaryWallet(settings.tmp_wallet_filename)

        // protecting wallet with password
        m_wallet.setPassword(settings.wallet_password);

        // Store password in session to be able to use password protected functions (e.g show seed)
        appWindow.walletPassword = settings.wallet_password

        // saving wallet_filename;
        settings['wallet_filename'] = new_wallet_filename;

        // persist settings
        appWindow.persistentSettings.language = settings.language
        appWindow.persistentSettings.locale   = settings.locale
        appWindow.persistentSettings.account_name = settings.account_name
        appWindow.persistentSettings.wallet_path = new_wallet_filename
        appWindow.persistentSettings.allow_background_mining = false //settings.allow_background_mining
        appWindow.persistentSettings.auto_donations_enabled = false //settings.auto_donations_enabled
        appWindow.persistentSettings.auto_donations_amount = false //settings.auto_donations_amount
        appWindow.persistentSettings.restore_height = (isNaN(settings.restore_height))? 0 : settings.restore_height
        appWindow.persistentSettings.is_recovering = (settings.is_recovering === undefined)? false : settings.is_recovering
        appWindow.persistentSettings.is_recovering_from_device = (settings.is_recovering_from_device === undefined)? false : settings.is_recovering_from_device
    }

    // reading settings from persistent storage
    Component.onCompleted: {
        settings['allow_background_mining'] = appWindow.persistentSettings.allow_background_mining
        settings['auto_donations_enabled'] = appWindow.persistentSettings.auto_donations_enabled
        settings['auto_donations_amount'] = appWindow.persistentSettings.auto_donations_amount
    }

    MessageDialog {
        id: walletErrorDialog
        title: "Error"
        onAccepted: {
        }
    }

    WizardWelcome {
        id: welcomePage
//        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin

    }

    WizardOptions {
        id: optionsPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
        onCreateWalletClicked: wizard.openCreateWalletPage()
        onRecoveryWalletClicked: wizard.openRecoveryWalletPage()
        onOpenWalletClicked: wizard.openOpenWalletPage();
        onCreateWalletFromDeviceClicked: wizard.openCreateWalletFromDevicePage()
    }

    WizardCreateWallet {
        id: createWalletPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardCreateViewOnlyWallet {
        id: createViewOnlyWalletPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardRecoveryWallet {
        id: recoveryWalletPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardCreateWalletFromDevice {
        id: createWalletFromDevicePage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardPassword {
        id: passwordPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardDaemonSettings {
        id: daemonSettingsPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardDonation {
        id: donationPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    WizardFinish {
        id: finishPage
        Layout.bottomMargin: wizardBottomMargin
        Layout.topMargin: wizardTopMargin
    }

    Rectangle {
        id: prevButton
        anchors.verticalCenter: wizard.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: isMobile ?  20 :  50
        anchors.bottomMargin: isMobile ?  20 * scaleRatio :  50
        visible: parent.currentPage > 0

        width: 50 * scaleRatio; height: 50 * scaleRatio
        radius: 25
        color: prevArea.containsMouse ? "#FF4304" : "#FF6C3C"

        Image {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -3
            source: "qrc:///images/prevPage.png"
        }

        MouseArea {
            id: prevArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: wizard.switchPage(false)
        }
    }

    Rectangle {
        id: nextButton
        anchors.verticalCenter: wizard.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: isMobile ?  20 * scaleRatio :  50
        anchors.bottomMargin: isMobile ?  20 * scaleRatio :  50
        visible: currentPage > 1 && currentPage < pages.length - 1
        width: 50 * scaleRatio; height: 50 * scaleRatio
        radius: 25
        color: enabled ? nextArea.containsMouse ? "#FF4304" : "#FF6C3C" : "#DBDBDB"


        Image {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 3
            source: "qrc:///images/nextPage.png"
        }

        MouseArea {
            id: nextArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: wizard.switchPage(true)
        }
    }

    StandardButton {
        id: sendButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins:  (isMobile) ? 20 * scaleRatio : 50 * scaleRatio
        text: qsTr("USE MONERO") + translationManager.emptyString
        visible: parent.paths[currentPath][currentPage] === finishPage
        onClicked: {
            wizard.applySettings();
            wizard.useMoneroClicked();
        }
    }

    StandardButton {
       id: createViewOnlyWalletButton
       anchors.right: parent.right
       anchors.bottom: parent.bottom
       anchors.margins: (isMobile) ? 20 * scaleRatio : 50
       text: qsTr("Create wallet") + translationManager.emptyString
       visible: currentPath === "create_view_only_wallet" &&  parent.paths[currentPath][currentPage] === passwordPage
       enabled: passwordPage.passwordsMatch
       onClicked: {
           if (currentWallet.createViewOnly(settings['view_only_wallet_path'],passwordPage.password)) {
               console.log("view only wallet created in ",settings['view_only_wallet_path']);
               informationPopup.title  = qsTr("Success") + translationManager.emptyString;
               informationPopup.text = qsTr('The view only wallet has been created. You can open it by closing this current wallet, clicking the "Open wallet from file" option, and selecting the view wallet in: \n%1')
                                        .arg(settings['view_only_wallet_path']);
               informationPopup.open()
               informationPopup.onCloseCallback = null
               rootItem.state = "normal"
               wizard.restart();

           } else {
               informationPopup.title  = qsTr("Error") + translationManager.emptyString;
               informationPopup.text = currentWallet.errorString;
               informationPopup.open()
           }

       }
   }

   StandardButton {
       id: abortViewOnlyButton
       anchors.right: createViewOnlyWalletButton.left
       anchors.bottom: parent.bottom
       anchors.margins:  (isMobile) ? 20 * scaleRatio : 50
       text: qsTr("Abort") + translationManager.emptyString
       visible: currentPath === "create_view_only_wallet" &&  parent.paths[currentPath][currentPage] === passwordPage
       onClicked: {
           wizard.restart();
           rootItem.state = "normal"
       }
   }




}
