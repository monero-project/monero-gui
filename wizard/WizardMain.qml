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
import "../components"

Rectangle {
    id: wizard
    property alias nextButton : nextButton
    property var settings : ({})
    property int currentPage: 0
    property var pages: [welcomePage, optionsPage, createWalletPage, passwordPage, /*configurePage,*/ donationPage, finishPage ]

    signal useMoneroClicked()
    border.color: "#DBDBDB"
    border.width: 1
    color: "#FFFFFF"

    function switchPage(next) {

        // save settings for current page;
        if (typeof pages[currentPage].saveSettings !== 'undefined') {
            pages[currentPage].saveSettings(settings);
        }

        if(next === false) {
            if(currentPage > 0) {
                pages[currentPage].opacity = 0
                pages[--currentPage].opacity = 1
            }
        } else {
            if(currentPage < pages.length - 1) {
                pages[currentPage].opacity = 0
                pages[++currentPage].opacity = 1
            }
        }

        // disable "next" button until passwords match
        if (pages[currentPage] === passwordPage) {
            nextButton.enabled = passwordPage.passwordValid;
        } else if (pages[currentPage] === finishPage) {
            // display settings summary
            finishPage.updateSettingsSummary();
            nextButton.visible = false
        } else {
            nextButton.visible = true
            nextButton.enabled = true
        }
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
        onCreateWalletClicked: wizard.switchPage(true)
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
        text: qsTr("USE MONERO")
        shadowReleasedColor: "#FF4304"
        shadowPressedColor: "#B32D00"
        releasedColor: "#FF6C3C"
        pressedColor: "#FF4304"
        visible: parent.pages[currentPage] === finishPage
        onClicked: wizard.useMoneroClicked()
    }
}
