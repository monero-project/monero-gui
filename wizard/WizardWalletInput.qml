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
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0
import FontAwesome 1.0

import "../js/Wizard.js" as Wizard
import "../components"
import "../components" as MoneroComponents

GridLayout {
    id: grid
    Layout.fillWidth: true
    property alias walletName: walletName
    property alias walletLocation: walletLocation
    property alias browseButton: browseButton
    property alias errorMessageWalletName: errorMessageWalletName
    property alias errorMessageWalletLocation: errorMessageWalletLocation
    property bool rowLayout: true
    property var walletNameKeyNavigationBackTab: browseButton
    property var browseButtonKeyNavigationTab: walletName

    columnSpacing: rowLayout ? 20 : 0
    rowSpacing: rowLayout ? 0 : 20
    columns: rowLayout ? 2 : 1

    function verify() {
        if (walletName.text !== '' && walletLocation.text !== '') {
            if (!walletName.error && !walletLocation.error) {
                return true;
            }
        }
        return false;
    }

    function reset() {
        walletName.error = !walletName.verify();
        walletLocation.error = !walletLocation.verify();
        walletLocation.text = appWindow.accountsDir;
        walletName.text = Wizard.unusedWalletName(appWindow.accountsDir, defaultAccountName, walletManager);
    }

    ColumnLayout {
        MoneroComponents.LineEdit {
            id: walletName
            Layout.preferredWidth: grid.width/5

            function verify(){
                if (walletName.text === "") {
                    errorMessageWalletName.text = qsTr("Wallet name is empty") + translationManager.emptyString;
                    return false;
                }
                if (/[\\\/]/.test(walletName.text)) {
                    errorMessageWalletName.text = qsTr("Wallet name is invalid") + translationManager.emptyString;
                    return false;
                }
                if (walletLocation.text !== "") {
                    var walletAlreadyExists = Wizard.walletPathExists(appWindow.accountsDir, walletLocation.text, walletName.text, isIOS, walletManager);
                    if (walletAlreadyExists) {
                        errorMessageWalletName.text = qsTr("Wallet already exists") + translationManager.emptyString;
                        return false;
                    }
                }
                errorMessageWalletName.text = "";
                return true;
            }

            labelText: qsTr("Wallet name") + translationManager.emptyString
            labelFontSize: 14
            fontSize: 16
            placeholderFontSize: 16
            placeholderText: ""
            errorWhenEmpty: true
            text: defaultAccountName

            onTextChanged: walletName.error = !walletName.verify();
            Component.onCompleted: walletName.error = !walletName.verify();

            Accessible.role: Accessible.EditableText
            Accessible.name: labelText + text
            KeyNavigation.up: walletNameKeyNavigationBackTab
            KeyNavigation.backtab: walletNameKeyNavigationBackTab
            KeyNavigation.down: errorMessageWalletName.text != "" ? errorMessageWalletName : appWindow.walletMode >= 2 ? walletLocation : wizardNav.btnPrev
            KeyNavigation.tab: errorMessageWalletName.text != "" ? errorMessageWalletName : appWindow.walletMode >= 2 ? walletLocation : wizardNav.btnPrev
        }

        RowLayout {
            Layout.preferredWidth: grid.width/5

            MoneroComponents.TextPlain {
                visible: errorMessageWalletName.text != ""
                font.family: FontAwesome.fontFamilySolid
                font.styleName: "Solid"
                font.pixelSize: 15
                text: FontAwesome.exclamationCircle
                color: "#FF0000"
                themeTransition: false
            }

            MoneroComponents.TextPlain {
                id: errorMessageWalletName
                textFormat: Text.PlainText
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: "#FF0000"
                themeTransition: false
                Accessible.role: Accessible.StaticText
                Accessible.name: text
                KeyNavigation.up: walletName
                KeyNavigation.backtab: walletName
                KeyNavigation.down: walletLocation
                KeyNavigation.tab: walletLocation
            }
        }
    }

    ColumnLayout {
        visible: appWindow.walletMode >= 2

        MoneroComponents.LineEdit {
            id: walletLocation
            Layout.preferredWidth: grid.width/3

            function verify() {
                if (walletLocation.text == "") {
                    errorMessageWalletLocation.text = qsTr("Wallet location is empty") + translationManager.emptyString;
                    return false;
                }
                errorMessageWalletLocation.text = "";
                return true;
            }

            labelText: qsTr("Wallet location") + translationManager.emptyString
            labelFontSize: 14
            fontSize: 16
            placeholderText: ""
            placeholderFontSize: 16
            errorWhenEmpty: true
            text: appWindow.accountsDir + "/"
            onTextChanged: {
                walletLocation.error = !walletLocation.verify();
                walletName.error = !walletName.verify();
            }
            Component.onCompleted: walletLocation.error = !walletLocation.verify();
            Accessible.role: Accessible.EditableText
            Accessible.name: labelText + text
            KeyNavigation.up: errorMessageWalletName.text != "" ? errorMessageWalletName : walletName
            KeyNavigation.backtab: errorMessageWalletName.text != "" ? errorMessageWalletName : walletName
            KeyNavigation.down: browseButton
            KeyNavigation.tab: browseButton

            MoneroComponents.InlineButton {
                id: browseButton
                fontFamily: FontAwesome.fontFamilySolid
                fontStyleName: "Solid"
                fontPixelSize: 18
                text: FontAwesome.folderOpen
                tooltip: qsTr("Browse") + translationManager.emptyString
                tooltipLeft: true
                onClicked: {
                    fileWalletDialog.folder = walletManager.localPathToUrl(walletLocation.text)
                    fileWalletDialog.open()
                    walletLocation.focus = true
                }
                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Browse") + translationManager.emptyString
                KeyNavigation.up: walletLocation
                KeyNavigation.backtab: walletLocation
                KeyNavigation.down: errorMessageWalletLocation.text != "" ? errorMessageWalletLocation : browseButtonKeyNavigationTab
                KeyNavigation.tab: errorMessageWalletLocation.text != "" ? errorMessageWalletLocation : browseButtonKeyNavigationTab
            }
        }

        RowLayout {
            Layout.preferredWidth: grid.width/3

            MoneroComponents.TextPlain {
                visible: errorMessageWalletLocation.text != ""
                font.family: FontAwesome.fontFamilySolid
                font.styleName: "Solid"
                font.pixelSize: 15
                text: FontAwesome.exclamationCircle
                color: "#FF0000"
                themeTransition: false
            }

            MoneroComponents.TextPlain {
                id: errorMessageWalletLocation
                textFormat: Text.PlainText
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: "#FF0000"
                themeTransition: false
                Accessible.role: Accessible.StaticText
                Accessible.name: text
                KeyNavigation.up: browseButton
                KeyNavigation.backtab: browseButton
                KeyNavigation.down: browseButtonKeyNavigationTab
                KeyNavigation.tab: browseButtonKeyNavigationTab
            }
        }
    }

    FileDialog {
        id: fileWalletDialog
        selectMultiple: false
        selectFolder: true
        title: qsTr("Please choose a directory")  + translationManager.emptyString
        onAccepted: {
            walletLocation.text = walletManager.urlToLocalPath(fileWalletDialog.folder);
            fileWalletDialog.visible = false;
            walletName.error = !walletName.verify();
        }
        onRejected: {
            fileWalletDialog.visible = false;
        }
    }
}
