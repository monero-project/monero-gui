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
import QtGraphicalEffects 1.0
import "components"

Rectangle {
    id: panel

    property alias unlockedBalanceText: unlockedBalanceText.text
    property alias balanceText: balanceText.text
    property alias networkStatus : networkStatus
    property alias daemonProgress : daemonProgress

    signal dashboardClicked()
    signal historyClicked()
    signal transferClicked()
    signal receiveClicked()
    signal settingsClicked()
    signal addressBookClicked()
    signal miningClicked()

    function selectItem(pos) {
        menuColumn.previousButton.checked = false
        if(pos === "Dashboard") menuColumn.previousButton = dashboardButton
        else if(pos === "History") menuColumn.previousButton = historyButton
        else if(pos === "Transfer") menuColumn.previousButton = transferButton
        else if(pos === "Receive")  menuColumn.previousButton = receiveButton
        else if(pos === "AddressBook") menuColumn.previousButton = addressBookButton
        else if(pos === "Mining") menuColumn.previousButton = miningButton
        else if(pos === "Settings") menuColumn.previousButton = settingsButton

        menuColumn.previousButton.checked = true
    }

    width: 260
    color: "#FFFFFF"

    // Item with monero logo
    Item {
        id: logoItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 31
        height: logo.implicitHeight

        Image {
            id: logo
            anchors.left: parent.left
            anchors.leftMargin: 50
            source: "images/moneroLogo.png"
        }

        Image {
            anchors.left: parent.left
            anchors.verticalCenter: logo.verticalCenter
            anchors.leftMargin: 19
            source: appWindow.rightPanelExpanded ? "images/expandRightPanel.png" :
                                                   "images/collapseRightPanel.png"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: appWindow.rightPanelExpanded = !appWindow.rightPanelExpanded
        }
    }


    Column {
        id: column1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: logoItem.bottom
        anchors.topMargin: 40
        spacing: 6

        Label {
            text: qsTr("Balance") + translationManager.emptyString
            anchors.left: parent.left
            anchors.leftMargin: 50
            tipText: qsTr("Test tip 1<br/><br/>line 2") + translationManager.emptyString
        }

        Row {
            Item {
                anchors.verticalCenter: parent.verticalCenter
                height: 26
                width: 50

                Image {
                    anchors.centerIn: parent
                    source: "images/lockIcon.png"
                }
            }

            Text {
                id: balanceText
                anchors.verticalCenter: parent.verticalCenter
                font.family: "Arial"
                font.pixelSize: 26
                color: "#000000"
                text: "N/A"
            }
        }

        Item { //separator
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
        }

        Label {
            text: qsTr("Unlocked balance") + translationManager.emptyString
            anchors.left: parent.left
            anchors.leftMargin: 50
            tipText: qsTr("Test tip 2<br/><br/>line 2") + translationManager.emptyString
        }

        Text {
            id: unlockedBalanceText
            anchors.left: parent.left
            anchors.leftMargin: 50
            font.family: "Arial"
            font.pixelSize: 18
            color: "#000000"
            text: "N/A"
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: menuRect.top
        width: 1
        color: "#DBDBDB"
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 1
        color: "#DBDBDB"
    }

    Rectangle {
        id: menuRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: column1.bottom
        anchors.topMargin: 50
        color: "#1C1C1C"

        Column {
            id: menuColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            property var previousButton: transferButton

            // ------------- Dashboard tab ---------------

            /*
            MenuButton {
                id: dashboardButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Dashboard") + translationManager.emptyString
                symbol: qsTr("D") + translationManager.emptyString
                dotColor: "#FFE00A"
                checked: true
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = dashboardButton
                    panel.dashboardClicked()
                }
            }


            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: dashboardButton.checked || transferButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }
            */


            // ------------- Transfer tab ---------------
            MenuButton {
                id: transferButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Transfer") + translationManager.emptyString
                symbol: qsTr("T") + translationManager.emptyString
                dotColor: "#FF6C3C"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = transferButton
                    panel.transferClicked()
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: transferButton.checked || receiveButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }

            // ------------- Receive tab ---------------
            MenuButton {
                id: receiveButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Receive") + translationManager.emptyString
                symbol: qsTr("R") + translationManager.emptyString
                dotColor: "#AAFFBB"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = receiveButton
                    panel.receiveClicked()
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: transferButton.checked || historyButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }

            // ------------- History tab ---------------

            MenuButton {
                id: historyButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("History") + translationManager.emptyString
                symbol: qsTr("H") + translationManager.emptyString
                dotColor: "#6B0072"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = historyButton
                    panel.historyClicked()
                }
            }
            /*
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: historyButton.checked || addressBookButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }
            // ------------- AddressBook tab ---------------

            MenuButton {
                id: addressBookButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Address book") + translationManager.emptyString
                symbol: qsTr("B") + translationManager.emptyString
                dotColor: "#FF4F41"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = addressBookButton
                    panel.addressBookClicked()
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: addressBookButton.checked || miningButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }

            // ------------- Mining tab ---------------
            MenuButton {
                id: miningButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Mining") + translationManager.emptyString
                symbol: qsTr("M") + translationManager.emptyString
                dotColor: "#FFD781"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = miningButton
                    panel.miningClicked()
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                color: miningButton.checked || settingsButton.checked ? "#1C1C1C" : "#505050"
                height: 1
            }
            */
            // ------------- Settings tab ---------------
            MenuButton {
                id: settingsButton
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Settings") + translationManager.emptyString
                symbol: qsTr("S") + translationManager.emptyString
                dotColor: "#36B25C"
                onClicked: {
                    parent.previousButton.checked = false
                    parent.previousButton = settingsButton
                    panel.settingsClicked()
                }
            }

        }

        NetworkStatusItem {
            id: networkStatus
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: (daemonProgress.visible)? daemonProgress.top : parent.bottom;
            connected: false
        }

        DaemonProgress {
            id: daemonProgress
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }
    // indicate disabled state
    Desaturate {
        anchors.fill: parent
        source: parent
        desaturation: panel.enabled ? 0.0 : 1.0
    }


}
