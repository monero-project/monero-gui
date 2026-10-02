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
import "../js/Utils.js" as Utils
import "../components" as MoneroComponents

Rectangle {
    id: wizardCreateWallet1
    
    color: "transparent"
    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property alias walletInput: walletInput
    property alias wizardNav: wizardNav
    property alias fileEntropyCheckBox: fileEntropyCheckBox
    property alias entropyFileInput: entropyFileInput
    property alias entropyFileSelector: entropyFileInput
    property string viewName: "wizardCreateWallet1"
    property bool addEntropySuccess: false

    ColumnLayout {
        id: pageRoot
        Layout.alignment: Qt.AlignHCenter;
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter;

        spacing: 0
        KeyNavigation.down: createWalletHeader
        KeyNavigation.tab: createWalletHeader

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 20

            WizardHeader {
                id: createWalletHeader
                title: {
                    var nettype = persistentSettings.nettype;
                    return qsTr("Create a new wallet") + (nettype === 2 ? " (" + qsTr("stagenet") + ")"
                                                                        : nettype === 1 ? " (" + qsTr("testnet") + ")"
                                                                                        : "") + translationManager.emptyString
                }
                subtitle: qsTr("Creates a new wallet on this computer.") + translationManager.emptyString
                Accessible.role: Accessible.StaticText
                Accessible.name: title + subtitle
                Keys.onUpPressed: wizardNav.btnNext.enabled ? wizardNav.btnNext.forceActiveFocus() : wizardNav.wizardProgress.forceActiveFocus()
                Keys.onBacktabPressed: wizardNav.btnNext.enabled ? wizardNav.btnNext.forceActiveFocus() : wizardNav.wizardProgress.forceActiveFocus()
                Keys.onDownPressed: walletInput.walletName.forceActiveFocus();
                Keys.onTabPressed: walletInput.walletName.forceActiveFocus();
            }

            WizardWalletInput{
                id: walletInput
                rowLayout: false
                walletNameKeyNavigationBackTab: createWalletHeader
                browseButtonKeyNavigationTab: fileEntropyCheckBox
            }
            //Selecting file as extra entropy source
            MoneroComponents.CheckBox{
                id: fileEntropyCheckBox
                text: qsTr("Provide extra entropy for wallet generation by file") + translationManager.emptyString
                tooltip: qsTr("Uses data from a file to add more randomness when creating your wallet. Only the first 64 MB of the selected file will be used. This option does not provide additional security if your operating system already provides sufficient randomness.") + translationManager.emptyString
                tooltipIconVisible: true
                fontSize: walletInput.walletName.labelFontSize
                checked: false
                activeFocusOnTab: true
                onCheckedChanged: {
                    if (!checked) {
                        wizardCreateWallet1.addEntropySuccess = false
                        entropyFileInput.text = ""
                        entropyFileWarning.text = ""
                    }
                }
                KeyNavigation.up: walletInput.browseButton
                KeyNavigation.backtab: walletInput.browseButton
                KeyNavigation.down: checked ? entropyFileInput : wizardNav.btnPrev
                KeyNavigation.tab: checked ? entropyFileInput : wizardNav.btnPrev
            }

            MoneroComponents.LineEdit {
                id: entropyFileInput
                Layout.fillWidth: true
                visible: fileEntropyCheckBox.checked
                labelText: qsTr("Entropy file") + translationManager.emptyString
                labelFontSize: walletInput.walletName.labelFontSize
                fontSize: walletInput.walletName.fontSize
                placeholderText: qsTr("Choose a file") + translationManager.emptyString
                placeholderFontSize: walletInput.walletName.placeholderFontSize
                readOnly: true
                Accessible.role: Accessible.EditableText
                Accessible.name: labelText + " " + text
                KeyNavigation.up: fileEntropyCheckBox
                KeyNavigation.backtab: fileEntropyCheckBox
                KeyNavigation.down: entropyFileBrowseButton
                KeyNavigation.tab: entropyFileBrowseButton

                MoneroComponents.InlineButton {
                    id: entropyFileBrowseButton
                    fontFamily: FontAwesome.fontFamilySolid
                    fontStyleName: "Solid"
                    fontPixelSize: 18
                    text: FontAwesome.folderOpen
                    tooltip: qsTr("Browse") + translationManager.emptyString
                    tooltipLeft: true
                    onClicked: {
                        entropyFileDialog.open()
                        entropyFileInput.focus = true
                    }
                    Accessible.role: Accessible.Button
                    Accessible.name: qsTr("Browse") + translationManager.emptyString
                    KeyNavigation.up: entropyFileInput
                    KeyNavigation.backtab: entropyFileInput
                    KeyNavigation.down: wizardNav.btnPrev
                    KeyNavigation.tab: wizardNav.btnPrev
                }
            }
            //Displaying the entropy adding result
            MoneroComponents.TextPlain {
                id: entropyFileWarning
                Layout.fillWidth: true
                visible: fileEntropyCheckBox.checked && text !== ""
                textFormat: Text.PlainText
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: wizardCreateWallet1.addEntropySuccess
                       ? (MoneroComponents.Style.blackTheme ? "#00FF00" : "#008000")
                       : "#FF0000"
                themeTransition: false
                Accessible.role: Accessible.StaticText
                Accessible.name: text
            }

            WizardNav {
                id: wizardNav
                progressSteps: appWindow.walletMode <= 1 ? 4 : 5
                progress: 0
                btnNext.enabled: walletInput.verify()
                                 && (!fileEntropyCheckBox.checked || wizardCreateWallet1.addEntropySuccess)
                btnPrev.text: appWindow.width <= 506 ? "<" : qsTr("Back to menu") + translationManager.emptyString
                onPrevClicked: {
                    if (wizardStateView.wizardCreateWallet2View.seedListGrid) {
                        wizardStateView.wizardCreateWallet2View.seedListGrid.destroy();
                    }
                    wizardController.wizardStateView.wizardCreateWallet3View.pwField = "";
                    wizardController.wizardStateView.wizardCreateWallet3View.pwConfirmField = "";
                    wizardStateView.state = "wizardHome";
                }
                btnPrevKeyNavigationBackTab: entropyFileInput.visible ? entropyFileBrowseButton : fileEntropyCheckBox
                btnNextKeyNavigationTab: createWalletHeader
                onNextClicked: {
                    wizardController.walletOptionsName = walletInput.walletName.text;
                    wizardController.walletOptionsLocation = walletInput.walletLocation.text;
                    wizardStateView.state = "wizardCreateWallet2";
                    wizardStateView.wizardCreateWallet2View.pageRoot.forceActiveFocus();
                }
            }
        }
    }

    FileDialog {
        id: entropyFileDialog
        title: qsTr("Please choose a file as extra entropy source") + translationManager.emptyString
        folder: shortcuts.home
        nameFilters: [qsTr("All files (*)") + translationManager.emptyString]
        selectExisting: true
        selectFolder: false
        selectMultiple: false

        onAccepted: {
            var path = walletManager.urlToLocalPath(entropyFileDialog.fileUrl)
            wizardCreateWallet1.addEntropySuccess = false
            entropyFileInput.text = ""

            if (oshelper.addExtraEntropyFromFile(path)) {
                entropyFileInput.text = path
                //regenerate the seed using new entropy
                wizardStateView.wizardCreateWallet2View.regenerateSeed()
                wizardCreateWallet1.addEntropySuccess = true
                entropyFileWarning.text = qsTr("Extra entropy was added successfully") + translationManager.emptyString
            } else {
                entropyFileWarning.text = qsTr("The selected file could not be opened for reading") + translationManager.emptyString
            }
        }
    }

    function onPageCompleted(previousView){
        if(previousView.viewName == "wizardHome"){
            walletInput.reset();
            fileEntropyCheckBox.checked = false;
            entropyFileInput.text = "";
            entropyFileWarning.text = "";
            wizardCreateWallet1.addEntropySuccess = false;
        }
    }
}
