import QtQuick 2.9
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

import "." as MoneroComponents
import "effects" as MoneroEffects

MoneroComponents.Dialog {
    id: root
    title: qsTr("I2P Settings") + translationManager.emptyString
    
    property bool useBuiltInI2P: persistentSettings.useBuiltInI2P
    property string i2pAddress: persistentSettings.i2pAddress
    property int i2pPort: persistentSettings.i2pPort || 7656
    property string i2pInboundQuantity: persistentSettings.i2pInboundQuantity || "3"
    property string i2pOutboundQuantity: persistentSettings.i2pOutboundQuantity || "3"
    property bool i2pMixedMode: persistentSettings.i2pMixedMode

    ColumnLayout {
        id: mainLayout
        spacing: 20
        Layout.fillWidth: true

        MoneroComponents.WarningBox {
            Layout.bottomMargin: 8
            text: qsTr("I2P functionality is experimental. Use at your own risk.") + translationManager.emptyString
        }

        ColumnLayout {
            spacing: 8
            Layout.fillWidth: true

            MoneroComponents.RadioButton {
                id: builtinI2pButton
                Layout.fillWidth: true
                text: qsTr("Use built-in I2P") + translationManager.emptyString
                fontSize: 16
                checked: root.useBuiltInI2P
                onClicked: {
                    root.useBuiltInI2P = true;
                    externalI2pButton.checked = false;
                }
            }

            MoneroComponents.RadioButton {
                id: externalI2pButton
                Layout.fillWidth: true
                text: qsTr("Use external I2P") + translationManager.emptyString
                fontSize: 16
                checked: !root.useBuiltInI2P
                onClicked: {
                    root.useBuiltInI2P = false;
                    builtinI2pButton.checked = false;
                }
            }
        }

        GridLayout {
            visible: !root.useBuiltInI2P
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 32

            MoneroComponents.LineEdit {
                id: i2pAddressLine
                Layout.fillWidth: true
                labelText: qsTr("I2P address") + translationManager.emptyString
                placeholderText: "127.0.0.1"
                text: root.i2pAddress
                onTextChanged: root.i2pAddress = text
                enabled: !root.useBuiltInI2P
            }

            MoneroComponents.LineEdit {
                id: i2pPortLine
                Layout.fillWidth: true
                labelText: qsTr("I2P port") + translationManager.emptyString
                placeholderText: "7656"
                text: root.i2pPort
                validator: IntValidator { bottom: 1; top: 65535 }
                onTextChanged: root.i2pPort = text
                enabled: !root.useBuiltInI2P
            }
        }

        ColumnLayout {
            spacing: 20
            Layout.fillWidth: true

            MoneroComponents.CheckBox {
                id: mixedModeCheckbox
                checked: root.i2pMixedMode
                text: qsTr("Allow mixed mode (I2P/clearnet peers)") + translationManager.emptyString
                onClicked: root.i2pMixedMode = checked
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 32

                MoneroComponents.LineEdit {
                    id: inboundTunnelsLine
                    Layout.fillWidth: true
                    labelText: qsTr("Inbound tunnels") + translationManager.emptyString
                    placeholderText: "3"
                    text: root.i2pInboundQuantity
                    validator: IntValidator { bottom: 1; top: 16 }
                    onTextChanged: root.i2pInboundQuantity = text
                }

                MoneroComponents.LineEdit {
                    id: outboundTunnelsLine
                    Layout.fillWidth: true
                    labelText: qsTr("Outbound tunnels") + translationManager.emptyString
                    placeholderText: "3"
                    text: root.i2pOutboundQuantity
                    validator: IntValidator { bottom: 1; top: 16 }
                    onTextChanged: root.i2pOutboundQuantity = text
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 32

            MoneroComponents.StandardButton {
                id: cancelButton
                text: qsTr("Cancel") + translationManager.emptyString
                onClicked: root.close()
            }

            MoneroComponents.StandardButton {
                id: okButton
                text: qsTr("Save") + translationManager.emptyString
                onClicked: {
                    persistentSettings.useI2P = true;
                    persistentSettings.useBuiltInI2P = root.useBuiltInI2P;
                    persistentSettings.i2pAddress = root.i2pAddress;
                    persistentSettings.i2pPort = root.i2pPort;
                    persistentSettings.i2pInboundQuantity = root.i2pInboundQuantity;
                    persistentSettings.i2pOutboundQuantity = root.i2pOutboundQuantity;
                    persistentSettings.i2pMixedMode = root.i2pMixedMode;

                    // Notify daemon of settings change
                    if (appWindow.currentWallet) {
                        appWindow.currentWallet.refreshI2PSettings();
                    }
                    root.close();
                }
            }
        }
    }
} 