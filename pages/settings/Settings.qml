// Copyright (c) 2014-2024, The Monero Project
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

import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../../js/Windows.js" as Windows
import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents
import "../../pages"
import "."
import moneroComponents.Clipboard 1.0

ColumnLayout {
    id: settingsPage
    Layout.fillWidth: true
    Layout.preferredHeight: 900
    spacing: 0
    Clipboard { id: clipboard }
    property bool viewOnly: false
    property int settingsHeight: 900
    property alias settingsStateViewState: settingsStateView.state

    MoneroComponents.Navbar {
        id: navbarId
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: height
        Layout.bottomMargin: height

        MoneroComponents.NavbarItem {
            active: settingsStateView.state == "Wallet"
            text: qsTr("Wallet") + translationManager.emptyString
            onSelected: settingsStateView.state = "Wallet"
        }
        MoneroComponents.NavbarItem {
            active: settingsStateView.state == "UI"
            text: qsTr("Interface") + translationManager.emptyString
            onSelected: settingsStateView.state = "UI"
        }
        MoneroComponents.NavbarItem {
            active: settingsStateView.state == "Node"
            text: qsTr("Node") + translationManager.emptyString
            visible: appWindow.walletMode >= 2
            onSelected: settingsStateView.state = "Node"
        }
        MoneroComponents.NavbarItem {
            active: settingsStateView.state == "Log"
            text: qsTr("Log") + translationManager.emptyString
            onSelected: settingsStateView.state = "Log"
            visible: !isAndroid
        }
        MoneroComponents.NavbarItem {
            active: settingsStateView.state == "Info"
            text: qsTr("Info") + translationManager.emptyString
            onSelected: settingsStateView.state = "Info"
        }
    }

    Rectangle{
        id: settingsStateView
        property Item currentView
        property Item previousView
        property SettingsWallet settingsWalletView: SettingsWallet { }
        property SettingsLayout settingsLayoutView: SettingsLayout { }
        property SettingsNode settingsNodeView: SettingsNode { }
        property SettingsLog settingsLogView: SettingsLog { }
        property SettingsInfo settingsInfoView: SettingsInfo { }
        Layout.fillWidth: true
        Layout.preferredHeight: settingsHeight
        color: "transparent"
        state: "Wallet"

        onCurrentViewChanged: {
            if (previousView) {
                if (typeof previousView.onPageClosed === "function") {
                    previousView.onPageClosed();
                }
            }
            previousView = currentView
            if (currentView) {
                stackView.replace(currentView)
                if (typeof currentView.onPageCompleted === "function") {
                    currentView.onPageCompleted();
                }
            }
        }

        states: [
            State {
                name: "Wallet"
                PropertyChanges { target: settingsStateView; currentView: settingsStateView.settingsWalletView }
                PropertyChanges { target: settingsPage; settingsHeight: settingsStateView.settingsWalletView.settingsHeight + 140 }
            }, State {
                name: "UI"
                PropertyChanges { target: settingsStateView; currentView: settingsStateView.settingsLayoutView }
                PropertyChanges { target: settingsPage; settingsHeight: settingsStateView.settingsLayoutView.layoutHeight + 140 }
            }, State {
                name: "Node"
                PropertyChanges { target: settingsStateView; currentView: settingsStateView.settingsNodeView }
                PropertyChanges { target: settingsPage; settingsHeight: settingsStateView.settingsNodeView.nodeHeight + 140 }
            }, State {
                name: "Log"
                PropertyChanges { target: settingsStateView; currentView: settingsStateView.settingsLogView }
                PropertyChanges { target: settingsPage; settingsHeight: settingsStateView.settingsLogView.logHeight + 140 }
            }, State {
                name: "Info"
                PropertyChanges { target: settingsStateView; currentView: settingsStateView.settingsInfoView }
                PropertyChanges { target: settingsPage; settingsHeight: settingsStateView.settingsInfoView.infoHeight + 140 }
            }
        ]

        StackView {
            id: stackView
            initialItem: settingsStateView.settingsWalletView
            anchors.fill: parent
            clip: false // otherwise animation will affect left panel

            delegate: StackViewDelegate {
                pushTransition: StackViewTransition {
                    PropertyAnimation {
                        target: enterItem
                        property: "x"
                        from: (navbarId.currentIndex < navbarId.previousIndex ? 1 : -1) * - target.width
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    PropertyAnimation {
                        target: exitItem
                        property: "x"
                        from: 0
                        to: (navbarId.currentIndex < navbarId.previousIndex ? 1 : -1) * target.width
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    function onDaemonConsoleUpdated(message){
        // Update daemon console
        settingsStateView.settingsLogView.consoleArea.logMessage(message)
    }

    // fires on every page load
    function onPageCompleted() {
        console.log("Settings page loaded");
    }
}
