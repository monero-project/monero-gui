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

Rectangle {
    color: "#F0EEEE"
    signal paymentClicked(string address, string paymentId, double amount, int mixinCount)
    signal generatePaymentIdInvoked()

    states: [
        State {
            name: "Dashboard"
            PropertyChanges { target: loader; source: "pages/Dashboard.qml" }
        }, State {
            name: "History"
            PropertyChanges { target: loader; source: "pages/History.qml" }
        }, State {
            name: "Transfer"
            PropertyChanges { target: loader; source: "pages/Transfer.qml" }
        }, State {
           name: "Receive"
           PropertyChanges { target: loader; source: "pages/Receive.qml" }
        }, State {
            name: "AddressBook"
            PropertyChanges { target: loader; source: "pages/AddressBook.qml" }
        }, State {
            name: "Settings"
            PropertyChanges { target: loader; source: "pages/Settings.qml" }
        }, State {
            name: "Mining"
            PropertyChanges { target: loader; source: "pages/Mining.qml" }
        }
    ]

    Row {
        id: styledRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        Rectangle { height: 4; width: parent.width / 5; color: "#FFE00A" }
        Rectangle { height: 4; width: parent.width / 5; color: "#6B0072" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF6C3C" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FFD781" }
        Rectangle { height: 4; width: parent.width / 5; color: "#FF4F41" }
    }

    Loader {
        id: loader
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: styledRow.bottom
        anchors.bottom: parent.bottom
        onLoaded: {
            console.log("Loaded " + item);
        }

    }

    /* connect "payment" click */
    Connections {
        ignoreUnknownSignals: false
        target: loader.item
        onPaymentClicked : {
            console.log("MiddlePanel: paymentClicked")
            paymentClicked(address, paymentId, amount, mixinCount)
        }
    }

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
}
