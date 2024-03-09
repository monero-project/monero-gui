// Copyright (c) 2021-2024, The Monero Project
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
import "../components" as MoneroComponents
import "."

ColumnLayout {
    id: root
    Layout.fillWidth: true
    Layout.preferredHeight: 900
    spacing: 0
    property int panelHeight: 900
    property alias miningView: stateView.miningView
    property alias signView: stateView.signView
    property alias prooveView: stateView.prooveView
    property alias state: stateView.state

    MoneroComponents.Navbar {
        id: navbarId
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: height
        Layout.bottomMargin: height

        MoneroComponents.NavbarItem {
            active: state == "Mining"
            text: qsTr("Mining") + translationManager.emptyString
            onSelected: state = "Mining"
            visible: !isAndroid
        }
        MoneroComponents.NavbarItem {
            active: state == "Prove"
            text: qsTr("Prove/check") + translationManager.emptyString
            onSelected: state = "Prove"
        }
        MoneroComponents.NavbarItem {
            active: state == "SharedRingDB"
            text: qsTr("Shared RingDB") + translationManager.emptyString
            onSelected: state = "SharedRingDB"
        }
        MoneroComponents.NavbarItem {
            active: state == "Sign"
            text: qsTr("Sign/verify") + translationManager.emptyString
            onSelected: state = "Sign"
        }
    }

    Rectangle{
        id: stateView
        property Item currentView
        property Item previousView
        property Mining miningView: Mining { }
        property TxKey prooveView: TxKey { }
        property SharedRingDB sharedRingDBView: SharedRingDB { }
        property Sign signView: Sign { }
        Layout.fillWidth: true
        Layout.preferredHeight: panelHeight
        color: "transparent"
        state: isAndroid ? "Prove" : "Mining"

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
                name: "Mining"
                PropertyChanges { target: stateView; currentView: stateView.miningView }
                PropertyChanges { target: root; panelHeight: stateView.miningView.miningHeight + 140 }
            }, State {
                name: "Prove"
                PropertyChanges { target: stateView; currentView: stateView.prooveView }
                PropertyChanges { target: root; panelHeight: stateView.prooveView.txkeyHeight + 140 }
            }, State {
                name: "SharedRingDB"
                PropertyChanges { target: stateView; currentView: stateView.sharedRingDBView }
                PropertyChanges { target: root; panelHeight: stateView.sharedRingDBView.panelHeight + 140 }
            }, State {
                name: "Sign"
                PropertyChanges { target: stateView; currentView: stateView.signView }
                PropertyChanges { target: root; panelHeight: stateView.signView.signHeight + 140 }
            }
        ]

        StackView {
            id: stackView
            initialItem: isAndroid ? stateView.prooveView : stateView.miningView
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

    function clearFields() {
        signView.clearFields();
        prooveView.clearFields();
    }
    
}
