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
import QtQml 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import "pages"

Rectangle {
    id: root

    property Item currentView
    property bool basicMode : false
    property string balanceText
    property string unlockedBalanceText

    property Transfer transferView: Transfer { }
    property Receive receiveView: Receive { }
    property History historyView: History { }
    property Settings settingsView: Settings { }


    signal paymentClicked(string address, string paymentId, double amount, int mixinCount, int priority)
    signal generatePaymentIdInvoked()

    color: "#F0EEEE"

    onCurrentViewChanged: {
        if (currentView) {
            stackView.replace(currentView)

            // Component.onCompleted is called before wallet is initilized
            if (typeof currentView.onPageCompleted === "function") {
                currentView.onPageCompleted();
            }
        }
    }


    //   XXX: just for memo, to be removed
    //    states: [
    //        State {
    //            name: "Dashboard"
    //            PropertyChanges { target: loader; source: "pages/Dashboard.qml" }
    //        }, State {
    //            name: "History"
    //            PropertyChanges { target: loader; source: "pages/History.qml" }
    //        }, State {
    //            name: "Transfer"
    //            PropertyChanges { target: loader; source: "pages/Transfer.qml" }
    //        }, State {
    //           name: "Receive"
    //           PropertyChanges { target: loader; source: "pages/Receive.qml" }
    //        }, State {
    //            name: "AddressBook"
    //            PropertyChanges { target: loader; source: "pages/AddressBook.qml" }
    //        }, State {
    //            name: "Settings"
    //            PropertyChanges { target: loader; source: "pages/Settings.qml" }
    //        }, State {
    //            name: "Mining"
    //            PropertyChanges { target: loader; source: "pages/Mining.qml" }
    //        }
    //    ]

        states: [
            State {
                name: "Dashboard"
                PropertyChanges {  }
            }, State {
                name: "History"
                PropertyChanges { target: root; currentView: historyView }
                PropertyChanges { target: historyView; model: appWindow.currentWallet.historyModel }
            }, State {
                name: "Transfer"
                PropertyChanges { target: root; currentView: transferView }
            }, State {
               name: "Receive"
               PropertyChanges { target: root; currentView: receiveView }
            }, State {
                name: "AddressBook"
                PropertyChanges { /*TODO*/ }
            }, State {
                name: "Settings"
               PropertyChanges { target: root; currentView: settingsView }
            }, State {
                name: "Mining"
                PropertyChanges { /*TODO*/ }
            }
        ]

    // color stripe at the top
    Row {
        id: styledRow
        height: 4
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right


        Rectangle { height: 4; width: parent.width / 5; color: "#FFE00A" }
        Rectangle { height: 4; width: parent.width / 5; color: "#6B0072" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF6C3C" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FFD781" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF4F41" }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 2
        anchors.topMargin: 30
        spacing: 0


        // BasicPanel header
        Rectangle {
            id: header
            anchors.leftMargin: 1
            anchors.rightMargin: 1
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: "#FFFFFF"
            visible: basicMode

            Image {
                id: logo
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -5
                anchors.left: parent.left
                anchors.leftMargin: 20
                source: "images/moneroLogo2.png"
            }

            Grid {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: 256
                columns: 3

                Text {

                    width: 116
                    height: 20
                    font.family: "Arial"
                    font.pixelSize: 12
                    font.letterSpacing: -1
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    color: "#535353"
                    text: qsTr("Balance:")
                }

                Text {
                    id: balanceText
                    width: 110
                    height: 20
                    font.family: "Arial"
                    font.pixelSize: 18
                    font.letterSpacing: -1
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    color: "#000000"
                    text: root.balanceText
                }

                Item {
                    height: 20
                    width: 20

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        source: "images/lockIcon.png"
                    }
                }

                Text {
                    width: 116
                    height: 20
                    font.family: "Arial"
                    font.pixelSize: 12
                    font.letterSpacing: -1
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    color: "#535353"
                    text: qsTr("Unlocked Balance:")
                }

                Text {
                    id: availableBalanceText
                    width: 110
                    height: 20
                    font.family: "Arial"
                    font.pixelSize: 14
                    font.letterSpacing: -1
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignBottom
                    color: "#000000"
                    text: root.unlockedBalanceText
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: "#DBDBDB"
            }
        }

        // Views container
        StackView {
            id: stackView
            initialItem: transferView
            anchors.topMargin: 30
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.top: styledRow.bottom
            anchors.margins: 4
            clip: true // otherwise animation will affect left panel
        }
    }
    // border
    Rectangle {
        anchors.top: styledRow.bottom
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 1
        color: "#DBDBDB"
    }

    Rectangle {
        anchors.top: styledRow.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: 1
        color: "#DBDBDB"
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#DBDBDB"

    }


    // indicates disabled state
    Desaturate {
        anchors.fill: parent
        source: parent
        desaturation: root.enabled ? 0.0 : 1.0
    }


    /* connect "payment" click */
    Connections {
        ignoreUnknownSignals: false
        target: transferView
        onPaymentClicked : {
            console.log("MiddlePanel: paymentClicked")
            paymentClicked(address, paymentId, amount, mixinCount, priority)
        }
    }
}
