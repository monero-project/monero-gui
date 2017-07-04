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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import "../components"
// import moneroComponents.AddressBook 1.0
// import moneroComponents.AddressBookModel 1.0

Rectangle {
    color: "#F0EEEE"
    id: root
    property var model

    Text {
        id: balanceAll
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 20
        anchors.topMargin: 20
        font.family: "Arial"
        font.pixelSize: 18
        textFormat: Text.RichText
    }

    Text {
        id: unlockedBalanceAll
        anchors.left: parent.left
        anchors.top: balanceAll.bottom
        anchors.leftMargin: 20
        anchors.topMargin: 10
        font.family: "Arial"
        font.pixelSize: 18
        textFormat: Text.RichText
    }

    RowLayout {
        id: buttonRow
        anchors.top: unlockedBalanceAll.bottom
        anchors.left: parent.left
        anchors.topMargin: 10
        anchors.leftMargin: 20
        spacing: 20

        StandardButton {
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            text: qsTr("Create new account") + translationManager.emptyString;
            onClicked: {
                inputDialog.labelText = qsTr("Set the label of the new account:") + translationManager.emptyString
                inputDialog.inputText = qsTr("(Untitled)")
                inputDialog.onAcceptedCallback = function() {
                    appWindow.currentWallet.subaddressAccount.addRow(inputDialog.inputText)
                    appWindow.currentWallet.switchSubaddressAccount(appWindow.currentWallet.numSubaddressAccounts() - 1)
                    table.currentIndex = appWindow.currentWallet.numSubaddressAccounts() - 1
                }
                inputDialog.onRejectedCallback = null;
                inputDialog.open()
            }
        }

        StandardButton {
            shadowReleasedColor: "#FF4304"
            shadowPressedColor: "#B32D00"
            releasedColor: "#FF6C3C"
            pressedColor: "#FF4304"
            text: qsTr("Rename") + translationManager.emptyString;
            onClicked: {
                inputDialog.labelText = qsTr("Set the label of the selected account:") + translationManager.emptyString
                inputDialog.inputText = appWindow.currentWallet.getSubaddressLabel(currentWallet.currentSubaddressAccount, 0)
                inputDialog.onAcceptedCallback = function() {
                    appWindow.currentWallet.subaddressAccount.setLabel(appWindow.currentWallet.currentSubaddressAccount, inputDialog.inputText)
                }
                inputDialog.onRejectedCallback = null;
                inputDialog.open()
            }
        }
    }

    Rectangle {
        id: tableRect
        anchors.left: parent.left
        anchors.top: buttonRow.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        height: parent.height - balanceAll.bottom
        color: "#FFFFFF"

        ListModel {
            id: testModel
            ListElement { address: "A17dsp"; label: "Default"; balance: "0.1"; unlockedBalance: "0.1" }
            ListElement { address: "BhFPVh"; label: "hoge hoge"; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "Bh5rw6"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BdZsW8"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BZiySC"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BYqbdA"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BYqbdA"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BYqbdA"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BYqbdA"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BYqbdA"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BYqbdA"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BYqbdA"; label: ""; balance: "0"; unlockedBalance: "0" }
            ListElement { address: "BYqbdA"; label: ""; balance: "0"; unlockedBalance: "0" }
        }

        Scroll {
            id: flickableScroll
            anchors.right: table.right
            // anchors.rightMargin: -14
            anchors.top: table.top
            anchors.bottom: table.bottom
            flickable: table
        }

        SubaddressAccountTable {
            id: table
            anchors.fill: parent
            model: root.model
            onContentYChanged: flickableScroll.flickableContentYChanged()
            onCurrentItemChanged: {
                if (appWindow.currentWallet !== undefined) {
                    appWindow.currentWallet.switchSubaddressAccount(table.currentIndex)
                    appWindow.onWalletUpdate()
                }
            }
        }
    }

    function onPageCompleted() {
        console.log("account");
        if (appWindow.currentWallet !== undefined) {
            appWindow.currentWallet.subaddressAccount.refresh();
            root.model = appWindow.currentWallet.subaddressAccountModel;
            table.currentIndex = appWindow.currentWallet.currentSubaddressAccount;
            balanceAll.text = qsTr("Total balance: ") + "<font size='+1'>" + walletManager.displayAmount(appWindow.currentWallet.balanceAll()) + "</font>"
            unlockedBalanceAll.text = qsTr("Total unlocked balance: ") + "<font size='+1'>" + walletManager.displayAmount(appWindow.currentWallet.unlockedBalanceAll()) + "</font>"
        }
    }
}
