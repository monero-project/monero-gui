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


import QtQml 2.0
import QtQuick 2.2
import QtQuick.Controls 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import moneroComponents.Wallet 1.0

import "components" as MoneroComponents
import "./pages"
import "./pages/settings"
import "./pages/merchant"
import "components" as MoneroComponents

Rectangle {
    id: root

    property Item currentView
    property Item previousView
    property bool basicMode : isMobile
    property string balanceLabelText: qsTr("Balance") + translationManager.emptyString
    property string balanceText
    property string unlockedBalanceLabelText: qsTr("Unlocked Balance") + translationManager.emptyString
    property string unlockedBalanceText
    property int minHeight: (appWindow.height > 800) ? appWindow.height : 800 * scaleRatio
    property alias contentHeight: mainFlickable.contentHeight
    property alias flickable: mainFlickable
//    property int headerHeight: header.height

    property Transfer transferView: Transfer { }
    property Receive receiveView: Receive { }
    property Merchant merchantView: Merchant { }
    property TxKey txkeyView: TxKey { }
    property SharedRingDB sharedringdbView: SharedRingDB { }
    property History historyView: History { }
    property Sign signView: Sign { }
    property Settings settingsView: Settings { }
    property Mining miningView: Mining { }
    property AddressBook addressBookView: AddressBook { }
    property Keys keysView: Keys { }
    property Account accountView: Account { }

    signal paymentClicked(string address, string paymentId, string amount, int mixinCount, int priority, string description)
    signal sweepUnmixableClicked()
    signal generatePaymentIdInvoked()
    signal getProofClicked(string txid, string address, string message);
    signal checkProofClicked(string txid, string address, string message, string signature);

    Rectangle {
        // grey background on merchantView
        visible: currentView === merchantView
        color: MoneroComponents.Style.moneroGrey
        anchors.fill: parent
    }

    Image {
        anchors.fill: parent
        visible: currentView !== merchantView
        source: "../images/middlePanelBg.jpg"
    }

    onCurrentViewChanged: {
        if (previousView) {
            if (typeof previousView.onPageClosed === "function") {
                previousView.onPageClosed();
            }
        }
        previousView = currentView
        if (currentView) {
            stackView.replace(currentView)
            // Component.onCompleted is called before wallet is initilized
            if (typeof currentView.onPageCompleted === "function") {
                currentView.onPageCompleted();
            }
        }
    }

    function updateStatus(){
        transferView.updateStatus();
    }

    // send from AddressBook
    function sendTo(address, paymentId, description){
        root.state = "Transfer";
        transferView.sendTo(address, paymentId, description);
    }

        states: [
            State {
                name: "History"
                PropertyChanges { target: root; currentView: historyView }
                PropertyChanges { target: historyView; model: appWindow.currentWallet ? appWindow.currentWallet.historyModel : null }
                PropertyChanges { target: mainFlickable; contentHeight: historyView.tableHeight + 220 * scaleRatio }
            }, State {
                name: "Transfer"
                PropertyChanges { target: root; currentView: transferView }
                PropertyChanges { target: mainFlickable; contentHeight: 700 * scaleRatio }
            }, State {
               name: "Receive"
               PropertyChanges { target: root; currentView: receiveView }
               PropertyChanges { target: mainFlickable; contentHeight: receiveView.receiveHeight + 100 }
            }, State {
                name: "Merchant"
                PropertyChanges { target: root; currentView: merchantView }
                PropertyChanges { target: mainFlickable; contentHeight: merchantView.merchantHeight + 100 }
            }, State {
               name: "TxKey"
               PropertyChanges { target: root; currentView: txkeyView }
               PropertyChanges { target: mainFlickable; contentHeight: 1200 * scaleRatio  }
            }, State {
               name: "SharedRingDB"
               PropertyChanges { target: root; currentView: sharedringdbView }
               PropertyChanges { target: mainFlickable; contentHeight: sharedringdbView.panelHeight + 100  }
            }, State {
                name: "AddressBook"
                PropertyChanges {  target: root; currentView: addressBookView  }
                PropertyChanges { target: mainFlickable; contentHeight: minHeight }
            }, State {
                name: "Sign"
               PropertyChanges { target: root; currentView: signView }
               PropertyChanges { target: mainFlickable; contentHeight: 1000 * scaleRatio  }
            }, State {
                name: "Settings"
               PropertyChanges { target: root; currentView: settingsView }
               PropertyChanges { target: mainFlickable; contentHeight: settingsView.settingsHeight }
            }, State {
                name: "Mining"
                PropertyChanges { target: root; currentView: miningView }
                PropertyChanges { target: mainFlickable; contentHeight: 700 * scaleRatio}
            }, State {
                name: "Keys"
                PropertyChanges { target: root; currentView: keysView }
                PropertyChanges { target: mainFlickable; contentHeight: keysView.keysHeight }
            }, State {
	           name: "Account"
	           PropertyChanges { target: root; currentView: accountView }
	           PropertyChanges { target: mainFlickable; contentHeight: minHeight }
            }	
        ]

    // color stripe at the top
    Row {
        id: styledRow
        visible: currentView !== merchantView
        height: 4
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: parent.z + 1

        Rectangle { height: 4; width: parent.width / 5; color: "#FFE00A" }
        Rectangle { height: 4; width: parent.width / 5; color: "#6B0072" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF6C3C" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FFD781" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF4F41" }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: currentView !== merchantView ? 20 * scaleRatio : 0
        anchors.topMargin: appWindow.persistentSettings.customDecorations ? 50 * scaleRatio : 0
        spacing: 0

        Flickable {
            id: mainFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ScrollBar.vertical: ScrollBar {
                parent: mainFlickable.parent
                anchors.left: parent.right
                anchors.leftMargin: 3
                anchors.top: parent.top
                anchors.topMargin: 4
                anchors.bottom: parent.bottom
                anchors.bottomMargin: persistentSettings.customDecorations ? 4 : 0 
            }

            onFlickingChanged: {
                releaseFocus();
            }

            // Views container
            StackView {
                id: stackView
                initialItem: transferView
                anchors.fill:parent
                clip: true // otherwise animation will affect left panel

                delegate: StackViewDelegate {
                    pushTransition: StackViewTransition {
                        PropertyAnimation {
                            target: enterItem
                            property: "x"
                            from: 0 - target.width
                            to: 0
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                        PropertyAnimation {
                            target: exitItem
                            property: "x"
                            from: 0
                            to: target.width
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

        }// flickable
    }

    // border
    Rectangle {
        anchors.top: styledRow.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 1
        color: "#313131"
    }

    /* connect "payment" click */
    Connections {
        ignoreUnknownSignals: false
        target: transferView
        onPaymentClicked : {
            console.log("MiddlePanel: paymentClicked")
            paymentClicked(address, paymentId, amount, mixinCount, priority, description)
        }
        onSweepUnmixableClicked : {
            console.log("MiddlePanel: sweepUnmixableClicked")
            sweepUnmixableClicked()
        }
    }
}
