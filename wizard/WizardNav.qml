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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

RowLayout {
    id: menuNav
    property alias progressEnabled: wizardProgress.visible
    property var btnPrevKeyNavigationBackTab: btnNext
    property var btnNextKeyNavigationTab: btnPrev
    property int progressSteps: 0
    property int progress: 0
    property bool autoTransition: true
    property alias btnPrev: btnPrev
    property alias btnNext: btnNext
    property alias wizardProgress: wizardProgress
    property string btnPrevText: qsTr("Previous") + translationManager.emptyString
    property string btnNextText: qsTr("Next") + translationManager.emptyString
    Layout.topMargin: 0
    Layout.preferredHeight: 70
    Layout.preferredWidth: parent.width

    signal nextClicked;
    signal prevClicked;

    // internal signals
    signal m_nextClicked;
    signal m_prevClicked;

    onM_prevClicked: {
        if (autoTransition) wizardController.wizardStackView.backTransition = true;
    }

    onM_nextClicked: {
        if (autoTransition) wizardController.wizardStackView.backTransition = false;
    }

    Rectangle {
        Layout.preferredHeight: parent.height
        color: "transparent"

        MoneroComponents.StandardButton {
            id: btnPrev
            width: appWindow.width <= 506 ? 45 : appWindow.width <= 660 ? 120 : 180
            small: true
            primary: false
            text: appWindow.width <= 506 ? "<" : menuNav.btnPrevText

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                menuNav.m_prevClicked();
                menuNav.prevClicked();
                focus = false;
            }
            Accessible.role: Accessible.Button
            Accessible.name: text
            KeyNavigation.up: btnPrevKeyNavigationBackTab
            KeyNavigation.backtab: btnPrevKeyNavigationBackTab
            KeyNavigation.down: wizardProgress.visible ? wizardProgress
                                                       : btnNext.visible && btnNext.enabled ? btnNext
                                                                                            : btnNextKeyNavigationTab
            KeyNavigation.tab: wizardProgress.visible ? wizardProgress
                                                      : btnNext.visible && btnNext.enabled ? btnNext
                                                                                           : btnNextKeyNavigationTab
        }
    }

    Rectangle {
        // progress dots
        Layout.preferredHeight: parent.height
        Layout.fillWidth: true
        color: "transparent"

        PageIndicator {
            id: wizardProgress
            currentIndex: menuNav.progress
            count: menuNav.progressSteps
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: 25
            delegate: Rectangle {
                implicitWidth: 10
                implicitHeight: 10
                radius: 10
                // @TODO: Qt 5.10+ replace === with <=
                color: index === menuNav.progress ? MoneroComponents.Style.defaultFontColor : MoneroComponents.Style.progressBarBackgroundColor
            }
            Accessible.role: Accessible.Indicator
            Accessible.name: qsTr("Step (%1) of (%2)").arg(currentIndex + 1).arg(count) + translationManager.emptyString
            KeyNavigation.up: btnPrev
            KeyNavigation.backtab: btnPrev
            KeyNavigation.down: btnNext
            KeyNavigation.tab: btnNext

            Rectangle {
                anchors.fill: parent
                color: wizardProgress.focus ? MoneroComponents.Style.titleBarButtonHoverColor : "transparent"
            }
        }
    }

    Rectangle {
        Layout.preferredHeight: parent.height
        color: "transparent"

        MoneroComponents.StandardButton {
            id: btnNext
            width: appWindow.width <= 506 ? 45 : appWindow.width <= 660 ? 120 : 180
            small: true
            text: appWindow.width <= 506 ? ">" : menuNav.btnNextText

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            onClicked: {
                menuNav.m_nextClicked();
                menuNav.nextClicked();
                focus = false;
            }
            Accessible.role: Accessible.Button
            Accessible.name: text
            KeyNavigation.up: wizardProgress.visible ? wizardProgress : btnPrev
            KeyNavigation.backtab: wizardProgress.visible ? wizardProgress : btnPrev
            KeyNavigation.down: btnNextKeyNavigationTab
            KeyNavigation.tab: btnNextKeyNavigationTab
        }
    }
}
