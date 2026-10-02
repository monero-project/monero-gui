import "../components" as MoneroComponents
import "../js/Wizard.js" as Wizard

import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.2

Rectangle {
    id: wizardCreateMultisig1

    property alias pageHeight: pageRoot.height
    property alias pageRoot: pageRoot
    property alias walletInput: walletInput
    property alias wizardNav: wizardNav
    property string viewName: "wizardCreateMultisig1"

    function totalParticipants() {
        return parseInt(participantsField.text) || 0;
    }

    function threshold() {
        return parseInt(thresholdField.text) || 0;
    }

    function verify() {
        var n = totalParticipants();
        var m = threshold();
        return walletInput.verify() && passwordFields.calcStrengthAndVerify() && n >= 2 && n <= 16 && m >= 2 && m <= n;
    }

    function onPageCompleted(previousView) {
        if (previousView.viewName == "wizardHome")
            walletInput.reset();
    }

    color: "transparent"

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
            spacing: 20

            WizardHeader {
                id: createMultisigHeader

                title: qsTr("Create a multisig wallet") + translationManager.emptyString
                subtitle: qsTr("Creates a new M-of-N multisig wallet on this computer. You will need to exchange information with the other participants to finish setting it up; this can take multiple rounds and may need to happen over several sessions.") + translationManager.emptyString
            }

            WizardWalletInput {
                id: walletInput
                rowLayout: false
            }

            WizardAskPassword {
                id: passwordFields
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                spacing: 20

                MoneroComponents.LineEdit {
                    id: participantsField

                    Layout.fillWidth: true
                    labelText: qsTr("Number of participants (N)") + translationManager.emptyString
                    labelFontSize: 14
                    fontSize: 16
                    placeholderFontSize: 16
                    placeholderText: "3"
                    text: "3"

                    validator: IntValidator {
                        bottom: 2
                        top: 16
                    }
                }

                MoneroComponents.LineEdit {
                    id: thresholdField

                    Layout.fillWidth: true
                    labelText: qsTr("Required signatures (M)") + translationManager.emptyString
                    labelFontSize: 14
                    fontSize: 16
                    placeholderFontSize: 16
                    placeholderText: "2"
                    text: "2"

                    validator: IntValidator {
                        bottom: 2
                        top: 16
                    }
                }
            }

            MoneroComponents.TextPlain {
                Layout.fillWidth: true
                Layout.topMargin: -10
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 13
                wrapMode: Text.WordWrap
                color: MoneroComponents.Style.dimmedFontColor
                text: qsTr("Each of the N participants needs their own copy of this GUI software and their own wallet. This wallet must be brand new and never receive funds before multisig setup is finished.") + translationManager.emptyString
            }

            WizardNav {
                id: wizardNav

                progressSteps: 2
                progress: 0
                btnNext.enabled: wizardCreateMultisig1.verify()
                btnPrev.text: qsTr("Back to menu") + translationManager.emptyString
                onPrevClicked: {
                    wizardStateView.state = "wizardHome";
                }
                onNextClicked: {
                    wizardController.walletOptionsName = walletInput.walletName.text;
                    wizardController.walletOptionsLocation = walletInput.walletLocation.text;
                    wizardController.walletOptionsPassword = passwordFields.password;
                    wizardController.multisigTotal = wizardCreateMultisig1.totalParticipants();
                    wizardController.multisigThreshold = wizardCreateMultisig1.threshold();
                    wizardController.createMultisigWallet();
                    wizardStateView.state = "wizardCreateMultisig2";
                }
            }
        }
    }
}
