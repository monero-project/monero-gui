import "../components" as MoneroComponents

import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2

import moneroComponents.Clipboard 1.0
import moneroComponents.Wallet 1.0

Rectangle {
    id: wizardCreateMultisig2

    property alias pageHeight: pageRoot.height
    property alias wizardNav: wizardNav
    property string viewName: "wizardCreateMultisig2"
    property string myInfo: ""

    function otherParticipantsInfo() {
        var lines = othersInfoInput.text.split("\n");
        var result = [];
        for (var i = 0; i < lines.length; i++) {
            var trimmed = lines[i].trim();
            if (trimmed.length > 0)
                result.push(trimmed);
        }
        return result;
    }

    function verify() {
        return otherParticipantsInfo().length === (wizardController.multisigTotal - 1);
    }

    function onPageCompleted(previousView) {
        wizardCreateMultisig2.myInfo = wizardController.m_wallet.getMultisigInfo();
        othersInfoInput.text = "";
    }

    color: "transparent"

    Clipboard {
        id: clipboard
    }

    ColumnLayout {
        id: pageRoot

        Layout.alignment: Qt.AlignHCenter
        width: parent.width - 100
        Layout.fillWidth: true
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: wizardController.wizardSubViewTopMargin
            Layout.maximumWidth: wizardController.wizardSubViewWidth
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            WizardHeader {
                title: qsTr("Exchange multisig info") + translationManager.emptyString
                subtitle: qsTr("Send your info string below to every other participant, and paste each of theirs into the box underneath, one per line, then click Finish. Do this over a communication channel you trust (in person, an encrypted chat, etc).") + translationManager.emptyString
            }

            MoneroComponents.TextPlain {
                Layout.fillWidth: true
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 15
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("Your multisig info (%1 of %2):").arg(1).arg(wizardController.multisigTotal) + translationManager.emptyString
            }

            Rectangle {
                color: "transparent"
                radius: 4
                Layout.preferredHeight: 90
                Layout.fillWidth: true
                border.width: 1
                border.color: MoneroComponents.Style.inputBorderColorInActive

                MoneroComponents.InputMulti {
                    id: myInfoDisplay

                    width: parent.width
                    height: parent.height
                    readOnly: true
                    text: wizardCreateMultisig2.myInfo
                    wrapMode: TextInput.Wrap
                    color: MoneroComponents.Style.defaultFontColor
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 13
                    selectByMouse: true
                }
            }

            MoneroComponents.StandardButton {
                small: true
                primary: false
                text: qsTr("Copy to clipboard") + translationManager.emptyString
                onClicked: {
                    clipboard.setText(wizardCreateMultisig2.myInfo);
                    appWindow.showStatusMessage(qsTr("Multisig info copied to clipboard"), 3);
                }
            }

            MoneroComponents.TextPlain {
                Layout.fillWidth: true
                Layout.topMargin: 10
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 15
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("Paste the other %1 participants' info strings below (one per line):").arg(wizardController.multisigTotal - 1) + translationManager.emptyString
            }

            Rectangle {
                color: "transparent"
                radius: 4
                Layout.preferredHeight: 120
                Layout.fillWidth: true
                border.width: 1
                border.color: othersInfoInput.activeFocus ? MoneroComponents.Style.inputBorderColorActive : MoneroComponents.Style.inputBorderColorInActive

                MoneroComponents.InputMulti {
                    id: othersInfoInput

                    width: parent.width
                    height: parent.height
                    wrapMode: TextInput.Wrap
                    color: MoneroComponents.Style.defaultFontColor
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 13
                    selectByMouse: true
                }
            }

            WizardNav {
                id: wizardNav

                progressSteps: 2
                progress: 1
                btnNextText: qsTr("Finish") + translationManager.emptyString
                btnNext.enabled: wizardCreateMultisig2.verify()
                onPrevClicked: {
                    wizardStateView.state = "wizardCreateMultisig1";
                }
                onNextClicked: {
                    btnNext.enabled = false;
                    wizardController.finishMultisigSetup(wizardCreateMultisig2.otherParticipantsInfo(), function(extraInfo) {
                        if (extraInfo && extraInfo.length > 0)
                            appWindow.showStatusMessage(qsTr("Wallet saved. More key exchange rounds are needed; open this wallet and go to Advanced > Multisig to continue with the other participants."), 10);
                        else
                            appWindow.showStatusMessage(qsTr("Multisig wallet ready."), 5);
                        wizardController.useMoneroClicked();
                    }, function(errorString) {
                        btnNext.enabled = true;
                        appWindow.showStatusMessage(qsTr("Failed to finish multisig setup: ") + errorString, 5);
                    });
                }
            }
        }
    }
}
