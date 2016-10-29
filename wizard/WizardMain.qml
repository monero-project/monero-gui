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
import Qt.labs.settings 1.0

import "../components"

Rectangle {
    id: wizard
    property alias nextButton : nextButton
    property var settings : ({})
    property int currentPage: 0

    property var paths: {
     //   "create_wallet" : [welcomePage, optionsPage, createWalletPage, passwordPage, donationPage, finishPage ],
     //   "recovery_wallet" : [welcomePage, optionsPage, recoveryWalletPage, passwordPage, donationPage, finishPage ],
        // disable donation page
        "create_wallet" : [welcomePage, optionsPage, createWalletPage, passwordPage,  finishPage ],
        "recovery_wallet" : [welcomePage, optionsPage, recoveryWalletPage, passwordPage,  finishPage ],

    }
    property string currentPath: "create_wallet"
    property var pages: paths[currentPath]

    signal useMoneroClicked()
    signal openWalletFromFileClicked()
    border.color: "#DBDBDB"
    border.width: 1
    color: "#FFFFFF"

    function restart(){
        wizard.currentPage = 0;
        wizard.settings = ({})
        wizard.currentPath = "create_wallet"
        wizard.pages = paths[currentPath]

        //hide all pages except first
        for (var i = 1; i < wizard.pages.length; i++){
            wizard.pages[i].opacity = 0;
        }
        //Show first pages
        wizard.pages[0].opacity = 1;

    }

    function switchPage(next) {
        console.log("hepp")
        // save settings for current page;
        if (next && typeof pages[currentPage].onPageClosed !== 'undefined') {
            if (pages[currentPage].onPageClosed(settings) !== true) {
                print ("Can't go to the next page");
                return;
            };

        }
        print ("switchpage: currentPage: ", currentPage);

        if (currentPage > 0 || currentPage < pages.length - 1) {
            pages[currentPage].opacity = 0
            var step_value = next ? 1 : -1
            currentPage += step_value
            pages[currentPage].opacity = 1;

            var nextButtonVisible = pages[currentPage] !== optionsPage;
            nextButton.visible = nextButtonVisible;

            if (next && typeof pages[currentPage].onPageOpened !== 'undefined') {
                pages[currentPage].onPageOpened(settings)
            }



        }
    }



    function openCreateWalletPage() {
        print ("show create wallet page");
        pages[currentPage].opacity = 0;
        createWalletPage.opacity = 1
        currentPath = "create_wallet"
        pages = paths[currentPath]
        currentPage = pages.indexOf(createWalletPage)
        createWalletPage.createWallet(settings)
        wizard.nextButton.visible = true
        createWalletPage.onPageOpened(settings);


    }

    function openRecoveryWalletPage() {
        print ("show recovery wallet page");
        pages[currentPage].opacity = 0
        recoveryWalletPage.opacity = 1
        currentPath = "recovery_wallet"
        pages = paths[currentPath]
        currentPage = pages.indexOf(recoveryWalletPage)
        wizard.nextButton.visible = true
        recoveryWalletPage.onPageOpened(settings);
    }

    function openOpenWalletPage() {
        console.log("open wallet from file page");
         wizard.openWalletFromFileClicked();
    }

    //! actually writes the wallet
    function applySettings() {
        console.log("Here we apply the settings");
        // here we need to actually move wallet to the new location
        console.log(settings.wallet_full_path);


        // Remove trailing slash - (default on windows and mac)
        if (settings.wallet_path.substring(settings.wallet_path.length -1) === "/"){
            settings.wallet_path = settings.wallet_path.substring(0,settings.wallet_path.length -1)
        }

        var new_wallet_filename = settings.wallet_path + "/"
                + settings.account_name + "/"
                + settings.account_name;

        console.log("saving in wizard: "+ new_wallet_filename)
        // moving wallet files to the new destination, if user changed it
        if (new_wallet_filename !== settings.wallet_filename) {
            // using previously saved wallet;
            settings.wallet.store(new_wallet_filename);
        }

        // protecting wallet with password
        settings.wallet.setPassword(settings.wallet_password);

        // Store password in session to be able to use password protected functions (e.g show seed)
        appWindow.password = settings.wallet_password

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
        appWindow.persistentSettings.daemon_address = settings.daemon_address
        appWindow.persistentSettings.testnet = settings.testnet
        appWindow.persistentSettings.restore_height = (isNaN(settings.restore_height))? 0 : settings.restore_height
        appWindow.persistentSettings.is_recovering = (settings.is_recovering === undefined)? false : settings.is_recovering


    }

    // reading settings from persistent storage
    Component.onCompleted: {
        settings['allow_background_mining'] = appWindow.persistentSettings.allow_background_mining
        settings['auto_donations_enabled'] = appWindow.persistentSettings.auto_donations_enabled
        settings['auto_donations_amount'] = appWindow.persistentSettings.auto_donations_amount
    }


    Rectangle {
        id: nextButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 50
        visible: wizard.currentPage !== 1 && wizard.currentPage !== 6
        width: 50; height: 50
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


    WizardWelcome {
        id: welcomePage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
    }

    WizardOptions {
        id: optionsPage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
        onCreateWalletClicked: wizard.openCreateWalletPage()
        onRecoveryWalletClicked: wizard.openRecoveryWalletPage()
        onOpenWalletClicked: wizard.openOpenWalletPage();
    }

    WizardCreateWallet {
        id: createWalletPage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
    }

    WizardRecoveryWallet {
        id: recoveryWalletPage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
    }

    WizardPassword {
        id: passwordPage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
    }

    WizardDonation {
        id: donationPage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
    }

    WizardFinish {
        id: finishPage
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: nextButton.left
        anchors.left: prevButton.right
        anchors.leftMargin: 50
        anchors.rightMargin: 50
    }

    Rectangle {
        id: prevButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 50
        visible: parent.currentPage > 0

        width: 50; height: 50
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

    StandardButton {
        id: sendButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 50
        width: 110
        text: qsTr("USE MONERO") + translationManager.emptyString
        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        visible: parent.paths[currentPath][currentPage] === finishPage
        onClicked: {
            wizard.applySettings();
            wizard.useMoneroClicked();
        }
    }
}
