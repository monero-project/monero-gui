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
import moneroComponents.NetworkType 1.0

import "../js/Wizard.js" as Wizard
import "../js/Utils.js" as Utils
import "../components" as MoneroComponents

ColumnLayout {
    Layout.fillWidth: true
    spacing: 0

    WizardSummaryItem {
        Layout.fillWidth: true
        header: qsTr("Wallet name") + translationManager.emptyString
        value: wizardController.walletOptionsName
    }

    WizardSummaryItem {
        Layout.fillWidth: true
        header: qsTr("Wallet path") + translationManager.emptyString
        value: wizardController.walletOptionsLocation
    }

    WizardSummaryItem {
        Layout.fillWidth: true
        header: qsTr("Mnemonic seed language") + translationManager.emptyString
        value: persistentSettings.language_wallet
        visible: wizardStateView.state === "wizardCreateWallet5" && !wizardController.walletOptionsIsRecoveringFromDevice
    }

    WizardSummaryItem {
        Layout.fillWidth: true
        header: qsTr("Restore height") + translationManager.emptyString
        value: wizardController.walletOptionsRestoreHeight
        visible: wizardStateView.state === "wizardRestoreWallet4" || wizardController.walletOptionsIsRecoveringFromDevice
    }

    WizardSummaryItem {
        visible: persistentSettings.useRemoteNode && remoteNodesModel.currentRemoteNode().address !== "" && appWindow.walletMode == 2
        Layout.fillWidth: true
        header: qsTr("Daemon address") + translationManager.emptyString
        value: remoteNodesModel.currentRemoteNode().address
    }

    WizardSummaryItem {
        visible: !persistentSettings.useRemoteNode && persistentSettings.bootstrapNodeAddress !== "" && appWindow.walletMode == 2
        Layout.fillWidth: true
        header: qsTr("Bootstrap address") + translationManager.emptyString
        value: persistentSettings.bootstrapNodeAddress
    }

    WizardSummaryItem {
        Layout.fillWidth: true
        header: qsTr("Network Type") + translationManager.emptyString
        value: Utils.netTypeToString()
    }
}
