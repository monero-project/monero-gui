import "../components" as MoneroComponents;
import QtQuick 2.9
import QtQuick.Layouts 1.2
import FontAwesome 1.0

ColumnLayout {
    id: seedListItem
    property var wordNumber;
    property var word;
    property var wordSpelled: (word.split("")).join(". ")
    property var acessibleText: (wordNumber + 1) + word
    property alias wordText: wordText
    property alias lineEdit: lineEdit
    property alias icon: icon
    spacing: 0

    Layout.preferredWidth: 136
    Layout.maximumWidth: 136
    Layout.minimumWidth: 136

    Accessible.role: Accessible.StaticText
    Accessible.name: lineEdit.inputHasFocus && !lineEdit.readOnly ? qsTr("Please enter the word number") + " " + (wordNumber + 1) + "." +
                                                                    (icon.visible ? (icon.wordsMatch ? qsTr("Green check mark") + "."
                                                                                                     : qsTr("Red exclamation mark") + ".")
                                                                                  : "")
                                                                  : (wordNumber + 1) + word + ". " +
                                                                    (lineEdit.inputHasFocus && lineEdit.readOnly ? qsTr("Green check mark")
                                                                                                                 : qsTr("This word is spelled ") + " " + wordSpelled + ".") +
                                                                    translationManager.emptyString
    KeyNavigation.up: wordNumber == 0 ? (recoveryPhraseLabel.visible ? recoveryPhraseLabel : header) : parent.children[wordNumber - 1]
    KeyNavigation.backtab: wordNumber == 0 ? (recoveryPhraseLabel.visible ? recoveryPhraseLabel : header) : parent.children[wordNumber - 1]
    Keys.onUpPressed: focusOnPreviousField()
    Keys.onBacktabPressed: focusOnPreviousField()
    Keys.onDownPressed: focusOnNextField()
    Keys.onTabPressed: focusOnNextField()

    function focusOnPreviousField() {
        if (wizardCreateWallet2.state == "verify") {
            if (wordNumber < 5) {
                if (recoveryPhraseLabel.visible) {
                    return recoveryPhraseLabel.forceActiveFocus();
                } else {
                    return header.forceActiveFocus();
                }
            } else if (wordNumber >= 5 && wordNumber < 25) {
                return parent.children[wizardCreateWallet2.hiddenWords[parseInt(wordNumber / 5) - 1]].lineEdit.forceActiveFocus()
            }
        } else {
            if (wordNumber == 0) {
                if (recoveryPhraseLabel.visible) {
                    return recoveryPhraseLabel.forceActiveFocus();
                } else {
                    return header.forceActiveFocus();
                }
            } else {
                return parent.children[wordNumber - 1].forceActiveFocus()
            }
        }
    }

    function focusOnNextField() {
        if (wizardCreateWallet2.state == "verify") {
            if (wordNumber < 20) {
                return parent.children[wizardCreateWallet2.hiddenWords[parseInt(wordNumber / 5) + 1]].lineEdit.forceActiveFocus()
            } else {
                return navigation.btnPrev.forceActiveFocus()
            }
        } else {
            if (wordNumber == 24) {
                if (createNewSeedButton.visible) {
                    return createNewSeedButton.forceActiveFocus()
                } else {
                    return printPDFTemplate.forceActiveFocus()
                }
            } else {
                return parent.children[wordNumber + 1].forceActiveFocus()
            }
        }
    }

    RowLayout {
        id: wordRow
        spacing: 0

        MoneroComponents.Label {
            color: lineEdit.inputHasFocus ? MoneroComponents.Style.defaultFontColor : MoneroComponents.Style.dimmedFontColor
            fontSize: 13
            text: (wordNumber + 1)
            themeTransition: false
        }

        MoneroComponents.LineEdit {
            id: lineEdit
            property bool firstUserInput: true
            inputHeight: 29
            inputPaddingLeft: 10
            inputPaddingBottom: 2
            inputPaddingRight: 0
            borderDisabled: true
            visible: !wordText.visible
            fontSize: 16
            fontBold: true
            text: ""
            tabNavigationEnabled: false
            onTextChanged: {
                if (lineEdit.text.length == wordText.text.length) {
                    firstUserInput = false;
                }
            }
            onBacktabPressed: focusOnPreviousField()
            onTabPressed: focusOnNextField()
        }

        MoneroComponents.Label {
            id: wordText
            Layout.leftMargin: 10
            color: MoneroComponents.Style.defaultFontColor
            fontSize: seedListItem.focus ? 19 : 16
            fontBold: true
            text: word
            themeTransition: false
        }

        MoneroComponents.TextPlain {
            id: icon
            Layout.leftMargin: wordsMatch ? 10 : 0
            property bool wordsMatch: lineEdit.text === wordText.text
            property bool partialWordMatches: lineEdit.text === wordText.text.substring(0, lineEdit.text.length)
            visible: lineEdit.text.length > 0 && !lineEdit.firstUserInput || lineEdit.firstUserInput && !partialWordMatches
            font.family: FontAwesome.fontFamilySolid
            font.styleName: "Solid"
            font.pixelSize: 15
            text: wordsMatch ? FontAwesome.checkCircle : FontAwesome.exclamationCircle
            color: wordsMatch ? (MoneroComponents.Style.blackTheme ? "#00FF00" : "#008000") : "#FF0000"
            themeTransition: false
            onTextChanged: {
                if (wizardCreateWallet2.seedListGrid && wordsMatch) {
                    if (wordNumber < 20) {
                        focusOnNextField();
                    }
                    lineEdit.readOnly = true;
                }
            }
        }
    }

    Rectangle {
        id: underLine
        color: lineEdit.inputHasFocus ? MoneroComponents.Style.defaultFontColor : MoneroComponents.Style.appWindowBorderColor
        Layout.fillWidth: true
        height: 1
    }
}
