import "../components" as MoneroComponents

import QtQuick 2.9
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

import moneroComponents.Clipboard 1.0
import moneroComponents.Wallet 1.0

Rectangle {
    id: root

    property alias panelHeight: mainLayout.height
    property var multisigState: ({
        "isMultisig": false,
        "isReady": false,
        "threshold": 0,
        "total": 0
    })
    property bool seedRevealed: false
    property bool hasPendingKeyImages: false
    readonly property string kexAttributeKey: "gui.multisig_pending_kex_msg"

    function refresh() {
        if (typeof appWindow.currentWallet === "undefined" || !appWindow.currentWallet)
            return;

        root.multisigState = appWindow.currentWallet.multisigInfo();
        if (root.multisigState.isMultisig && !root.multisigState.isReady)
            outboundInfoLine.text = appWindow.currentWallet.getCacheAttribute(root.kexAttributeKey);

        if (root.multisigState.isReady) {
            signerKeyLine.text = appWindow.currentWallet.publicMultisigSignerKey();
            root.hasPendingKeyImages = appWindow.currentWallet.hasMultisigPartialKeyImages();
        }

        root.seedRevealed = false;
        seedLine.text = "";
        inboundInfoInput.text = "";
    }

    function collectPastedInfo(text) {
        var lines = text.split("\n");
        var result = [];
        for (var i = 0; i < lines.length; i++) {
            var trimmed = lines[i].trim();
            if (trimmed.length > 0)
                result.push(trimmed);
        }
        return result;
    }

    function clearFields() {
        inboundInfoInput.text = "";
        importImagesInput.text = "";
        exportImagesLine.text = "";
    }

    function onPageCompleted() {
        root.refresh();
    }

    color: "transparent"

    Clipboard {
        id: clipboard
    }

    ColumnLayout {
        id: mainLayout

        Layout.fillWidth: true
        anchors.margins: 20
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 20

        MoneroComponents.Label {
            fontSize: 24
            text: qsTr("Multisig") + translationManager.emptyString
        }

        // Not a multisig wallet
        MoneroComponents.TextPlain {
            visible: !root.multisigState.isMultisig
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
            text: qsTr("This wallet is not a multisig wallet. Multisig wallets can be created using the \"Create a multisig wallet\" option on the wallet selection screen.") + translationManager.emptyString
        }

        // Multisig setup is still in progress (waiting for more kex rounds)
        ColumnLayout {
            visible: root.multisigState.isMultisig && !root.multisigState.isReady
            Layout.fillWidth: true
            spacing: 16

            MoneroComponents.WarningBox {
                Layout.fillWidth: true
                text: qsTr("Multisig setup is not finished yet. Exchange info with the other participants below to continue.") + translationManager.emptyString
            }

            MoneroComponents.LineEditMulti {
                id: outboundInfoLine

                Layout.fillWidth: true
                labelFontSize: 14
                labelText: qsTr("Your info for this round; send this to every other participant") + translationManager.emptyString
                readOnly: true
                copyButton: true
                wrapMode: Text.WrapAnywhere
            }

            MoneroComponents.LabelSubheader {
                Layout.fillWidth: true
                textFormat: Text.RichText
                text: qsTr("Paste the other participants' info strings below, one per line, then continue") + translationManager.emptyString
            }

            Rectangle {
                color: "transparent"
                radius: 4
                Layout.preferredHeight: 120
                Layout.fillWidth: true
                border.width: 1
                border.color: inboundInfoInput.activeFocus ? MoneroComponents.Style.inputBorderColorActive : MoneroComponents.Style.inputBorderColorInActive

                MoneroComponents.InputMulti {
                    id: inboundInfoInput

                    width: parent.width
                    height: parent.height
                    wrapMode: TextInput.Wrap
                    color: MoneroComponents.Style.defaultFontColor
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 13
                    selectByMouse: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight

                MoneroComponents.StandardButton {
                    small: true
                    text: qsTr("Continue setup") + translationManager.emptyString
                    enabled: root.collectPastedInfo(inboundInfoInput.text).length > 0
                    onClicked: {
                        var infos = root.collectPastedInfo(inboundInfoInput.text);
                        var extraInfo = appWindow.currentWallet.exchangeMultisigKeys(infos, false);
                        if (appWindow.currentWallet.status !== Wallet.Status_Ok) {
                            appWindow.showStatusMessage(qsTr("Failed to continue multisig setup: ") + appWindow.currentWallet.errorString, 5);
                            return;
                        }
                        appWindow.currentWallet.setCacheAttribute(root.kexAttributeKey, extraInfo || "");
                        inboundInfoInput.text = "";
                        appWindow.currentWallet.storeAsync(function(success) {
                            if (!success)
                                appWindow.showStatusMessage(qsTr("Failed to save wallet"), 5);

                            root.refresh();
                            if (root.multisigState.isReady)
                                appWindow.showStatusMessage(qsTr("Multisig wallet is now ready."), 5);
                            else
                                appWindow.showStatusMessage(qsTr("Round complete. Another exchange round is needed; repeat with the new info above."), 8);
                        }, "");
                    }
                }
            }
        }

        // Multisig finalized
        ColumnLayout {
            visible: root.multisigState.isReady
            Layout.fillWidth: true
            spacing: 20

            MoneroComponents.TextPlain {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14
                color: MoneroComponents.Style.defaultFontColor
                text: qsTr("This is a %1-of-%2 multisig wallet.").arg(root.multisigState.threshold).arg(root.multisigState.total) + translationManager.emptyString
            }

            MoneroComponents.WarningBox {
                visible: root.hasPendingKeyImages
                Layout.fillWidth: true
                text: qsTr("Some of your outputs' key images are only partially known. Your balance and ability to send may be wrong until you export and import key images with the other participants below.") + translationManager.emptyString
            }

            MoneroComponents.LineEditMulti {
                id: signerKeyLine

                Layout.fillWidth: true
                labelFontSize: 14
                labelText: qsTr("Your public multisig signer key") + translationManager.emptyString
                readOnly: true
                copyButton: true
                wrapMode: Text.WrapAnywhere
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                MoneroComponents.LabelSubheader {
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: qsTr("Multisig seed backup") + translationManager.emptyString
                }

                MoneroComponents.WarningBox {
                    Layout.fillWidth: true
                    text: qsTr("This seed alone is NOT enough to restore this wallet's spending ability. You must also redo key exchange with the same %1 other participants using a freshly restored wallet on each side.").arg(root.multisigState.total - 1) + translationManager.emptyString
                }

                MoneroComponents.StandardButton {
                    small: true
                    primary: false
                    text: root.seedRevealed ? qsTr("Hide multisig seed") + translationManager.emptyString : qsTr("Show multisig seed") + translationManager.emptyString
                    onClicked: {
                        root.seedRevealed = !root.seedRevealed;
                        seedLine.text = root.seedRevealed ? appWindow.currentWallet.getMultisigSeed("") : "";
                    }
                }

                MoneroComponents.LineEditMulti {
                    id: seedLine

                    visible: root.seedRevealed
                    Layout.fillWidth: true
                    readOnly: true
                    copyButton: true
                    wrapMode: Text.WrapAnywhere
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                MoneroComponents.LabelSubheader {
                    Layout.fillWidth: true
                    textFormat: Text.RichText
                    text: qsTr("Multisig key image sync") + translationManager.emptyString
                }

                MoneroComponents.TextPlain {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 13
                    color: MoneroComponents.Style.dimmedFontColor
                    text: qsTr("Export your key image data and share it with the other participants, and import theirs, to keep this wallet's balance accurate.") + translationManager.emptyString
                }

                MoneroComponents.LineEditMulti {
                    id: exportImagesLine

                    Layout.fillWidth: true
                    labelFontSize: 14
                    labelText: qsTr("Your exported key images; share with other participants") + translationManager.emptyString
                    readOnly: true
                    copyButton: true
                    wrapMode: Text.WrapAnywhere
                }

                RowLayout {
                    Layout.fillWidth: true

                    MoneroComponents.StandardButton {
                        small: true
                        primary: false
                        text: qsTr("Export key images") + translationManager.emptyString
                        onClicked: {
                            exportImagesLine.text = appWindow.currentWallet.exportMultisigImages();
                            if (exportImagesLine.text === "")
                                appWindow.showStatusMessage(qsTr("Failed to export multisig key images: ") + appWindow.currentWallet.errorString, 5);
                        }
                    }
                }

                MoneroComponents.LabelSubheader {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    textFormat: Text.RichText
                    text: qsTr("Paste other participants' exported key images below, one per line") + translationManager.emptyString
                }

                Rectangle {
                    color: "transparent"
                    radius: 4
                    Layout.preferredHeight: 100
                    Layout.fillWidth: true
                    border.width: 1
                    border.color: importImagesInput.activeFocus ? MoneroComponents.Style.inputBorderColorActive : MoneroComponents.Style.inputBorderColorInActive

                    MoneroComponents.InputMulti {
                        id: importImagesInput

                        width: parent.width
                        height: parent.height
                        wrapMode: TextInput.Wrap
                        color: MoneroComponents.Style.defaultFontColor
                        font.family: MoneroComponents.Style.fontRegular.name
                        font.pixelSize: 13
                        selectByMouse: true
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight

                    MoneroComponents.StandardButton {
                        small: true
                        text: qsTr("Import key images") + translationManager.emptyString
                        enabled: root.collectPastedInfo(importImagesInput.text).length > 0
                        onClicked: {
                            var images = root.collectPastedInfo(importImagesInput.text);
                            var imported = appWindow.currentWallet.importMultisigImages(images);
                            if (imported < 0) {
                                appWindow.showStatusMessage(qsTr("Failed to import multisig key images: ") + appWindow.currentWallet.errorString, 5);
                            } else {
                                importImagesInput.text = "";
                                appWindow.currentWallet.storeAsync(function(success) {
                                    if (!success) {
                                        appWindow.showStatusMessage(qsTr("Imported key images but failed to save wallet"), 5);
                                    } else {
                                        appWindow.showStatusMessage(qsTr("Imported key images from %1 participants").arg(imported), 5);
                                    }
                                    root.refresh();
                                }, "");
                            }
                        }
                    }
                }
            }
        }
    }
}
