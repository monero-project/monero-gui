// Copyright (c) 2014-2019, The Monero Project
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

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

GridLayout {
    id: menuNav
    property alias progressEnabled: wizardProgress.visible
    property int progressSteps: 0
    property int progress: 0
    property alias btnPrev: btnPrev
    property alias btnNext: btnNext
    property string btnPrevText: qsTr("Previous") + translationManager.emptyString
    property string btnNextText: qsTr("Next") + translationManager.emptyString
    Layout.topMargin: 20 * scaleRatio
    Layout.preferredHeight: 70 * scaleRatio
    Layout.preferredWidth: parent.width
    columns: 3

    signal nextClicked;
    signal prevClicked;

    Rectangle {
        Layout.preferredHeight: parent.height
        Layout.fillWidth: true
        color: "transparent"

        MoneroComponents.StandardButton {
            id: btnPrev
            small: true
            text: menuNav.btnPrevText
            
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                menuNav.prevClicked();
            }
        }
    }

    Rectangle {
        // progress dots
        Layout.preferredHeight: parent.height
        Layout.fillWidth: true
        color: "transparent"

        RowLayout {
            id: wizardProgress
            spacing: 0
            width: 100  // default, dynamically set later
            height: 30
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        Layout.preferredHeight: parent.height
        Layout.fillWidth: true
        color: "transparent"

        MoneroComponents.StandardButton {
            id: btnNext
            small: true
            text: menuNav.btnNextText

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            onClicked: {
                menuNav.nextClicked();
            }
        }
    }

    Component.onCompleted: {
        for(var i =0; i < menuNav.progressSteps; i++) {
            var active = i < menuNav.progress ? 'true' : 'false';
            Qt.createQmlObject("WizardNavProgressDot { active: " + active + " }", wizardProgress, 'dynamicWizardNavDot');
        }

        // Set `wizardProgress` width based on amount of progress dots
        wizardProgress.width = 30 * menuNav.progressSteps;
    }
}
