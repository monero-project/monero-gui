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

import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls
import moneroComponents.Clipboard 1.0

import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateWallet2
    
    color: "transparent"
    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property alias wizardNav: navigation
    property string viewName: "wizardCreateWallet2"
    property var seedArray: wizardController.walletOptionsSeed.split(/\s+/)
    property int seedWordCount: seedArray.length
    property var seedListGrid: ""
    property var hiddenWords: [0, 1, 2, 3, 4]

    function lastSeedItem() {
        if (!seedListGrid || !seedListGridColumn.children[0] || seedWordCount === 0) {
            return recoveryPhraseLabel;
        }
        return seedListGridColumn.children[0].children[seedWordCount - 1];
    }

    function chooseHiddenWords() {
        var selected = [];
        var count = Math.min(5, seedWordCount);
        for (var i = 0; i < count; i++) {
            var start = Math.floor(i * seedWordCount / count);
            var end = Math.floor((i + 1) * seedWordCount / count) - 1;
            selected.push(start + Math.floor(Math.random() * (end - start + 1)));
        }
        hiddenWords = selected;
    }

    function verificationComplete() {
        if (!seedListGrid || !seedListGridColumn.children[0]) {
            return false;
        }
        for (var i = 0; i < hiddenWords.length; i++) {
            if (!seedListGridColumn.children[0].children[hiddenWords[i]].icon.wordsMatch) {
                return false;
            }
        }
        return true;
    }

    Clipboard { id: clipboard }

    state: "default"
    states: [
        State {
            name: "default";
        }, State {
            name: "verify";
            when: typeof currentWallet != "undefined" && wizardStateView.state == "wizardCreateWallet2"
            PropertyChanges { target: header; title: qsTr("Verify your recovery phrase") + translationManager.emptyString }
            PropertyChanges { target: header; imageIcon: wizardController.layoutScale != 4 ? (MoneroComponents.Style.blackTheme ? "qrc:///images/verify.png" : "qrc:///images/verify-white.png") : "" }
            PropertyChanges { target: header; subtitle: qsTr("Please confirm that you have written down your recover phrase by filling in the five blank fields with the correct words. If you have not written down your recovery phrase on a piece of paper, click on the Previous button and write it down right now!") + translationManager.emptyString}
            PropertyChanges { target: createNewSeedButton; opacity: 0; enabled: false}
            PropertyChanges { target: copyToClipboardButton; opacity: 0; enabled: false}
            PropertyChanges { target: printPDFTemplate; opacity: 0; enabled: false}

            PropertyChanges { target: navigation; onPrevClicked: {
                seedListGridColumn.clearFields();
                wizardCreateWallet2.state = "default";
                pageRoot.forceActiveFocus();
            }}
            PropertyChanges { target: navigation; onNextClicked: {
                seedListGridColumn.clearFields();
                wizardStateView.state = "wizardCreateWallet3";
                wizardCreateWallet2.state = "default";
            }}
        }
    ]

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 0
        KeyNavigation.down: mobileDialog.visible ? mobileHeader : header
        KeyNavigation.tab: mobileDialog.visible ? mobileHeader : header

        ColumnLayout {
            id: mobileDialog
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            visible: wizardController.layoutScale == 4
            spacing: 60

            WizardHeader {
                id: mobileHeader
                title: qsTr("Write down your recovery phrase") + translationManager.emptyString
                Accessible.role: Accessible.StaticText
                Accessible.name: qsTr("Write down your recovery phrase") + translationManager.emptyString
                Keys.onUpPressed: displaySeedButton.forceActiveFocus()
                Keys.onBacktabPressed: displaySeedButton.forceActiveFocus()
                KeyNavigation.down: mobileImage
                KeyNavigation.tab: mobileImage
            }

            Image {
                id: mobileImage
                Layout.alignment: Qt.AlignHCenter
                fillMode: Image.PreserveAspectCrop
                source: MoneroComponents.Style.blackTheme ? "qrc:///images/write-down@2x.png" : "qrc:///images/write-down-white@2x.png"
                width: 125
                height: 125
                sourceSize.width: 125
                sourceSize.height: 125
                Accessible.role: Accessible.Graphic
                Accessible.name: qsTr("A pencil writing on a piece of paper") + translationManager.emptyString
                KeyNavigation.up: mobileHeader
                KeyNavigation.backtab: mobileHeader
                KeyNavigation.down: mobileText
                KeyNavigation.tab: mobileText

                Rectangle {
                    width: mobileImage.width
                    height: mobileImage.height
                    color: mobileImage.focus ? MoneroComponents.Style.titleBarButtonHoverColor : "transparent"
                }
            }

            Text {
                id: mobileText
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("The next page will display your recovery phrase, also known as mnemonic seed.") + " " + qsTr("These words are a backup of your wallet. Write these words down now on a piece of paper in the same order displayed. Keep this paper in a safe place and do not disclose it to anybody! Do not store these words digitally, always use a paper!") + translationManager.emptyString

                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                leftPadding: 0
                topPadding: 0
                Accessible.role: Accessible.StaticText
                Accessible.name: qsTr("The next page will display your recovery phrase, also known as mnemonic seed.") + " " + qsTr("These words are a backup of your wallet. Write these words down now on a piece of paper in the same order displayed. Keep this paper in a safe place and do not disclose it to anybody! Do not store these words digitally, always use a paper!") + translationManager.emptyString
                KeyNavigation.up: mobileImage
                KeyNavigation.backtab: mobileImage
                KeyNavigation.down: displaySeedButton
                KeyNavigation.tab: displaySeedButton

                Rectangle {
                    anchors.fill: parent
                    color: parent.focus ? MoneroComponents.Style.titleBarButtonHoverColor : "transparent"
                }
            }

            MoneroComponents.StandardButton {
                id: displaySeedButton
                Layout.alignment: Qt.AlignHCenter;
                text: qsTr("Display recovery phrase") + translationManager.emptyString
                onClicked: {
                    mobileDialog.visible = false;
                }
                Accessible.role: Accessible.Button
                Accessible.name: qsTr("The next page will display your recovery phrase, also known as mnemonic seed. ") + qsTr("These words are a backup of your wallet. Write these words down now on a piece of paper in the same order displayed. Keep this paper in a safe place and do not disclose it to anybody! Do not store these words digitally, always use a paper!") + translationManager.emptyString
                KeyNavigation.up: mobileText
                KeyNavigation.backtab: mobileText
                KeyNavigation.down: mobileHeader
                KeyNavigation.tab: mobileHeader
            }
        }

        ColumnLayout {
            id: mainPage
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            visible: !mobileDialog.visible
            spacing: 15

            WizardHeader {
                id: header
                imageIcon: wizardController.layoutScale != 4 ? (MoneroComponents.Style.blackTheme ? "qrc:///images/write-down.png" : "qrc:///images/write-down-white.png") : ""
                title: qsTr("Write down your recovery phrase") + translationManager.emptyString
                subtitleVisible: wizardController.layoutScale != 4
                subtitle: qsTr("These words are a backup of your wallet. Write these words down now on a piece of paper in the same order displayed. Keep this paper in a safe place and do not disclose it to anybody! Do not store these words digitally, always use a paper!") + translationManager.emptyString

                Accessible.role: Accessible.StaticText
                Accessible.name: title + ". " + subtitle
                Keys.onUpPressed: navigation.btnNext.enabled ? navigation.btnNext.forceActiveFocus() : navigation.wizardProgress.forceActiveFocus()
                Keys.onBacktabPressed: navigation.btnNext.enabled ? navigation.btnNext.forceActiveFocus() : navigation.wizardProgress.forceActiveFocus()
                Keys.onDownPressed: recoveryPhraseLabel.visible ? recoveryPhraseLabel.forceActiveFocus() : focusOnListGrid()
                Keys.onTabPressed: recoveryPhraseLabel.visible ? recoveryPhraseLabel.forceActiveFocus() : focusOnListGrid()

                function focusOnListGrid() {
                    if (wizardCreateWallet2.state == "verify") {
                        if (seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[0]].lineEdit.visible) {
                            return seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[0]].lineEdit.forceActiveFocus();
                        } else {
                            return seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[0]].forceActiveFocus();
                        }
                    } else {
                        return seedListGridColumn.children[0].children[0].forceActiveFocus();
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                MoneroComponents.TextPlain {
                    id: recoveryPhraseLabel
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 15
                    font.bold: false
                    wrapMode: Text.WordWrap
                    color: MoneroComponents.Style.dimmedFontColor
                    text: qsTr("Polyseed recovery phrase (%1)").arg(wizardController.walletOptionsSeedLanguage) + translationManager.emptyString
                    themeTransition: false
                    tooltip: qsTr("These words encode your private spend key in a human readable format.") + "<br>" + qsTr("It is expected that some words may be repeated.") + translationManager.emptyString
                    tooltipIconVisible: true
                    Accessible.role: Accessible.StaticText
                    Accessible.name: text + ". " + recoveryPhraseNote.text
                    KeyNavigation.up: header
                    KeyNavigation.backtab: header
                    Keys.onDownPressed: header.focusOnListGrid()
                    Keys.onTabPressed: header.focusOnListGrid()
                }

                MoneroComponents.TextPlain {
                    id: recoveryPhraseNote
                    Layout.fillWidth: true
                    font.family: recoveryPhraseLabel.font.family
                    font.pixelSize: recoveryPhraseLabel.font.pixelSize
                    wrapMode: Text.WordWrap
                    color: MoneroComponents.Style.dimmedFontColor
                    text: qsTr("Restoring this phrase requires a wallet that supports Polyseed.") + translationManager.emptyString
                    themeTransition: false
                    Accessible.ignored: true
                }
            }

            ColumnLayout {
                id: seedListGridColumn

                function clearFields() {
                    for (var i = 0; i < wizardCreateWallet2.hiddenWords.length; i++) {
                        seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[i]].wordText.visible = true;
                        seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[i]].lineEdit.text = "";
                        seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[i]].lineEdit.readOnly = false;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight

                Timer {
                    id: checkSeedListGridDestruction
                    interval: 100; running: false; repeat: true
                    onTriggered: {
                        if (!wizardCreateWallet2.seedListGrid) {
                            var newSeedListGrid = Qt.createComponent("SeedListGrid.qml");
                            wizardCreateWallet2.seedListGrid = newSeedListGrid.createObject(seedListGridColumn);
                            appWindow.showStatusMessage(qsTr("New seed generated"),3);
                            pageRoot.forceActiveFocus();
                            checkSeedListGridDestruction.stop();
                        }
                    }
                }

                MoneroComponents.StandardButton {
                    id: createNewSeedButton
                    visible: appWindow.walletMode >= 2
                    small: true
                    primary: false
                    text: qsTr("Create new seed") + translationManager.emptyString
                    onClicked: {
                        wizardController.restart(true);
                        if (!wizardController.createWallet()) {
                            wizardCreateWallet2.seedListGrid.destroy();
                            wizardStateView.state = "wizardHome";
                            return;
                        }
                        wizardCreateWallet2.seedArray = wizardController.walletOptionsSeed.split(/\s+/)
                        wizardCreateWallet2.seedListGrid.destroy();
                        checkSeedListGridDestruction.start();
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Create new seed") + translationManager.emptyString
                    KeyNavigation.up: wizardCreateWallet2.lastSeedItem()
                    KeyNavigation.backtab: wizardCreateWallet2.lastSeedItem()
                    KeyNavigation.down: copyToClipboardButton
                    KeyNavigation.tab: copyToClipboardButton
                }

                MoneroComponents.StandardButton {
                    id: copyToClipboardButton
                    visible: appWindow.walletMode >= 2
                    small: true
                    primary: false
                    text: qsTr("Copy to clipboard") + translationManager.emptyString
                    onClicked: {
                        clipboard.setText(wizardController.walletOptionsSeed);
                        appWindow.showStatusMessage(qsTr("Recovery phrase copied to clipboard"),3);
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Copy to clipboard") + translationManager.emptyString
                    KeyNavigation.up: createNewSeedButton
                    KeyNavigation.backtab: createNewSeedButton
                    KeyNavigation.down: printPDFTemplate
                    KeyNavigation.tab: printPDFTemplate
                }

                MoneroComponents.StandardButton {
                    id: printPDFTemplate
                    small: true
                    primary: false
                    text: qsTr("Print a template") + translationManager.emptyString
                    tooltip: qsTr("Print a template to write down your seed") + translationManager.emptyString
                    onClicked: {
                        oshelper.openSeedTemplate();
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Print a template to write down your seed") + translationManager.emptyString
                    KeyNavigation.up: copyToClipboardButton.visible ? copyToClipboardButton : wizardCreateWallet2.lastSeedItem()
                    KeyNavigation.backtab: copyToClipboardButton.visible ? copyToClipboardButton : wizardCreateWallet2.lastSeedItem()
                    KeyNavigation.down: navigation.btnPrev
                    KeyNavigation.tab: navigation.btnPrev
                }
            }

            WizardNav {
                id: navigation
                progressSteps: appWindow.walletMode <= 1 ? 4 : 5
                progress: 1
                onPrevClicked: {
                    wizardStateView.state = "wizardCreateWallet1";
                    mobileDialog.visible = Qt.binding(function() { return wizardController.layoutScale == 4 })
                }
                btnPrevKeyNavigationBackTab: wizardCreateWallet2.state == "default" ? printPDFTemplate
                                                                                    : wizardCreateWallet2.seedListGrid.children[hiddenWords[hiddenWords.length - 1]].lineEdit
                btnNextKeyNavigationTab: mobileDialog.visible ? mobileHeader : header
                btnNext.enabled: wizardCreateWallet2.state === "default" || appWindow.ctrlPressed || wizardCreateWallet2.verificationComplete()
                onNextClicked: {
                    wizardCreateWallet2.chooseHiddenWords();

                    wizardCreateWallet2.state = "verify";
                    for (var i = 0; i < hiddenWords.length; i++) {
                        seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[i]].wordText.visible = false;
                    }
                    seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[0]].lineEdit.forceActiveFocus();
                }
            }
        }
    }

    function onPageCompleted(previousView){
        wizardCreateWallet2.seedArray = wizardController.walletOptionsSeed.split(/\s+/)
        if (!wizardCreateWallet2.seedListGrid) {
            var component = Qt.createComponent("SeedListGrid.qml");
            wizardCreateWallet2.seedListGrid = component.createObject(seedListGridColumn);
        }
    }
}
