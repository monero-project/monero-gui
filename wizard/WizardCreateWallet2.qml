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
import moneroComponents.Clipboard 1.0

import "../js/Wizard.js" as Wizard
import "../js/Utils.js" as Utils
import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateWallet2
    
    color: "transparent"
    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property string viewName: "wizardCreateWallet2"
    property var seedArray: wizardController.walletOptionsSeed.split(" ")
    property var seedListGrid: ""
    property var hiddenWords: [0, 5, 10, 15, 20]

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
            PropertyChanges { target: walletCreationDate; opacity: 0; enabled: false}
            PropertyChanges { target: walletCreationDateValue; opacity: 0; enabled: false}
            PropertyChanges { target: walletRestoreHeight; opacity: 0; enabled: false}
            PropertyChanges { target: walletRestoreHeightValue; opacity: 0; enabled: false}
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

    MoneroComponents.TextPlain {
        //PDF template text
        // the translation of these strings is used to create localized PDF templates
        visible: false
        text: qsTr("Print this paper, fill it out, and keep it in a safe location. Never share your recovery phrase with anybody, especially with strangers offering technical support.") +
              qsTr("Recovery phrase (mnemonic seed)") +
              qsTr("These words are are a backup of your wallet. They are the only thing needed to access your funds and restore your Monero wallet, so keep this paper in a safe place and do not disclose it to anybody! It is strongly not recommended to store your recovery phrase digitally (in an email, online service, screenshot, photo, or any other type of computer file).") +
              qsTr("Wallet creation date") +
              qsTr("Wallet restore height") +
              qsTr("For instructions on how to restore this wallet, visit www.getmonero.org and go to Resources > User Guides > \"How to restore a wallet from mnemonic seed\". Use only Monero wallets that are trusted and recommended by the Monero community (see a list of them in www.getmonero.org/downloads).") + translationManager.emptyString
    }

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

            MoneroComponents.TextPlain {
                id: recoveryPhraseLabel
                visible: wizardController.layoutScale != 4
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 15
                font.bold: false
                textFormat: Text.RichText
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("Recovery phrase (mnemonic seed)") + ":" + translationManager.emptyString
                themeTransition: false
                tooltip: qsTr("These words encode your private spend key in a human readable format.") + "<br>" + qsTr("It is expected that some words may be repeated.") + translationManager.emptyString
                tooltipIconVisible: true
                Accessible.role: Accessible.StaticText
                Accessible.name: qsTr("Recovery phrase (mnemonic seed)") + translationManager.emptyString;
                KeyNavigation.up: header
                KeyNavigation.backtab: header
                Keys.onDownPressed: header.focusOnListGrid()
                Keys.onTabPressed: header.focusOnListGrid()
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
                        wizardController.createWallet();
                        wizardCreateWallet2.seedArray = wizardController.walletOptionsSeed.split(" ")
                        wizardCreateWallet2.seedListGrid.destroy();
                        checkSeedListGridDestruction.start();
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Create new seed") + translationManager.emptyString
                    KeyNavigation.up: (wizardCreateWallet2.seedListGrid && seedListGridColumn.children[0]) ? seedListGridColumn.children[0].children[24] : recoveryPhraseLabel
                    KeyNavigation.backtab: (wizardCreateWallet2.seedListGrid && seedListGridColumn.children[0]) ? seedListGridColumn.children[0].children[24] : recoveryPhraseLabel
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
                    KeyNavigation.down: printPDFTemplate.visible ? printPDFTemplate : walletCreationDate
                    KeyNavigation.tab: printPDFTemplate.visible ? printPDFTemplate : walletCreationDate
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
                    KeyNavigation.up: copyToClipboardButton.visible ? copyToClipboardButton : (wizardCreateWallet2.seedListGrid && seedListGridColumn.children[0]) ? seedListGridColumn.children[0].children[24] : recoveryPhraseLabel
                    KeyNavigation.backtab: copyToClipboardButton.visible ? copyToClipboardButton : (wizardCreateWallet2.seedListGrid && seedListGridColumn.children[0]) ? seedListGridColumn.children[0].children[24] : recoveryPhraseLabel
                    KeyNavigation.down: walletCreationDate
                    KeyNavigation.tab: walletCreationDate
                }
            }

            RowLayout {
                Layout.topMargin: 0
                Layout.fillWidth: true
                Layout.maximumWidth: seedListGridColumn.width
                spacing: 10

                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true

                    MoneroComponents.TextPlain {
                        id: walletCreationDate
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 15
                        font.bold: false
                        textFormat: Text.RichText
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("Creation date") + ": " + translationManager.emptyString
                        themeTransition: false
                        Accessible.role: Accessible.StaticText
                        Accessible.name: qsTr("Creation date") + " " + walletCreationDateValue.text + translationManager.emptyString
                        KeyNavigation.up: printPDFTemplate.visible ? printPDFTemplate : copyToClipboardButton
                        KeyNavigation.backtab: printPDFTemplate.visible ? printPDFTemplate : copyToClipboardButton
                        KeyNavigation.down: walletRestoreHeight
                        KeyNavigation.tab: walletRestoreHeight
                    }

                    MoneroComponents.TextPlain {
                        id: walletCreationDateValue
                        property var locale: Qt.locale()
                        property date currentDate: new Date()
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 16
                        font.bold: true
                        textFormat: Text.RichText
                        color: MoneroComponents.Style.defaultFontColor
                        text: currentDate.toLocaleDateString(locale, Locale.ShortFormat)
                    }
                }

                ColumnLayout {
                    spacing: 5
                    Layout.fillWidth: true

                    MoneroComponents.TextPlain {
                        id: walletRestoreHeight
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 15
                        font.bold: false
                        textFormat: Text.RichText
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("Restore height") + ":" + translationManager.emptyString
                        tooltip: wizardController.layoutScale != 4 ? qsTr("Enter this number when restoring the wallet to make your initial wallet synchronization faster.") : "" + translationManager.emptyString
                        tooltipIconVisible: true
                        themeTransition: false
                        Accessible.role: Accessible.StaticText
                        Accessible.name: qsTr("Restore height") + " " + Utils.roundDownToNearestThousand(wizardController.m_wallet ? wizardController.m_wallet.walletCreationHeight : 0) + translationManager.emptyString
                        KeyNavigation.up: walletCreationDate
                        KeyNavigation.backtab: walletCreationDate
                        Keys.onDownPressed: navigation.btnPrev.forceActiveFocus();
                        Keys.onTabPressed: navigation.btnPrev.forceActiveFocus();
                    }

                    MoneroComponents.TextPlain {
                        id: walletRestoreHeightValue
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 16
                        font.bold: true
                        textFormat: Text.RichText
                        color: MoneroComponents.Style.defaultFontColor
                        text: Utils.roundDownToNearestThousand(wizardController.m_wallet ? wizardController.m_wallet.walletCreationHeight : 0)
                    }
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
                btnPrevKeyNavigationBackTab: wizardCreateWallet2.state == "default" ? walletRestoreHeight
                                                                                    : seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[4]].lineEdit.visible ? seedListGridColumn.children[0].children[wizardCreateWallet2.hiddenWords[4]].lineEdit
                                                                                                                                                                                   : seedListGridColumn.children[0].children[24]
                btnNextKeyNavigationTab: mobileDialog.visible ? mobileHeader : header
                btnNext.enabled: walletCreationDate.opacity == 1 || appWindow.ctrlPressed ? true
                                                                                          : seedListGridColumn.children[0].children[hiddenWords[0]].icon.wordsMatch &&
                                                                                            seedListGridColumn.children[0].children[hiddenWords[1]].icon.wordsMatch &&
                                                                                            seedListGridColumn.children[0].children[hiddenWords[2]].icon.wordsMatch &&
                                                                                            seedListGridColumn.children[0].children[hiddenWords[3]].icon.wordsMatch &&
                                                                                            seedListGridColumn.children[0].children[hiddenWords[4]].icon.wordsMatch
                onNextClicked: {
                    //choose five random words to hide
                    for (var i = 0; i < hiddenWords.length; i++) {
                        wizardCreateWallet2.hiddenWords[i] = Math.floor(Math.random() * 5) + 5 * i
                    }

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
        wizardCreateWallet2.seedArray = wizardController.walletOptionsSeed.split(" ")
        if (!wizardCreateWallet2.seedListGrid) {
            var component = Qt.createComponent("SeedListGrid.qml");
            wizardCreateWallet2.seedListGrid = component.createObject(seedListGridColumn);
        }
    }
}
