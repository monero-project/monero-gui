import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import "../../components" as MoneroComponents
import "../../js/Utils.js" as Utils

ColumnLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 20

    // ----------------------------------------------------
    // Section 1: Network Privacy
    // ----------------------------------------------------
    MoneroComponents.LabelSubheader {
        text: qsTr("I2P Privacy & Routing") + translationManager.emptyString
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: MoneroComponents.Style.dividerColor
        opacity: 0.5
    }

    // Master Switch
    MoneroComponents.StandardSwitch {
        id: i2pSwitch
        text: qsTr("Enable I2P Network") + translationManager.emptyString
        checked: I2PManager.enabled
        onClicked: {
            I2PManager.enabled = checked;
            if (checked) {
                I2PManager.setProxyForI2p();
            }
        }
    }

    Text {
        text: qsTr("Routing your wallet traffic through I2P hides your IP address from the remote node. This is the highest level of network privacy available.") + translationManager.emptyString
        font.family: MoneroComponents.Style.fontRegular.name
        font.pixelSize: 14
        color: MoneroComponents.Style.dimmedFontColor
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    // ----------------------------------------------------
    // Section 2: Remote Node Selection
    // ----------------------------------------------------
    RowLayout {
        visible: i2pSwitch.checked
        Layout.topMargin: 10
        spacing: 20

        MoneroComponents.Label {
            text: qsTr("Remote I2P Node") + translationManager.emptyString
            fontSize: 14
        }

        MoneroComponents.StandardDropdown {
            id: nodeDropdown
            Layout.preferredWidth: 350

            // STYLE: Orange Outline & Text
            colorBorder: MoneroComponents.Style.orange
            textColor: MoneroComponents.Style.orange

            // COMMUNITY NODES (Using column1 for display)
            dataModel: [
                { column1: qsTr("Auto-detect / Custom"), value: "" },
                { column1: "SethForPrivacy", value: "rb752hk56y2k32wh6q7356566q65555555555555555555.b32.i2p:18081" },
                { column1: "MoneroWorld", value: "monerow.org.b32.i2p:18081" },
                { column1: "Plowsof", value: "plowsof.b32.i2p:18081" },
                { column1: "DamnSmall", value: "dsmll6q65555555555555555555.b32.i2p:18081" }
            ]

            onChanged: {
                var selected = dataModel[currentIndex];
                if (selected.value !== "") {
                    i2pAddressInput.text = selected.value;
                    persistentSettings.i2pAddress = selected.value;
                }
            }
        }
    }

    // Manual Address Override
    RowLayout {
        visible: i2pSwitch.checked
        Layout.topMargin: 5

        MoneroComponents.Input {
            id: i2pAddressInput
            Layout.preferredWidth: 350
            text: persistentSettings.i2pAddress
            placeholderText: "address.b32.i2p:18081"

            // STYLE: Digital Monospaced Font in Orange
            font.family: MoneroComponents.Style.fontMonoRegular.name
            color: MoneroComponents.Style.orange

            onEditingFinished: {
                if(text !== "") persistentSettings.i2pAddress = text
            }
        }
    }

    // ----------------------------------------------------
    // Section 3: Embedded Router Management
    // ----------------------------------------------------
    MoneroComponents.LabelSubheader {
        Layout.topMargin: 30
        text: qsTr("Embedded I2P Router") + translationManager.emptyString
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: MoneroComponents.Style.dividerColor
        opacity: 0.5
    }

    Text {
        text: qsTr("Run a local I2P router to support the network and ensure self-sovereignty.") + translationManager.emptyString
        font.family: MoneroComponents.Style.fontRegular.name
        font.pixelSize: 14
        color: MoneroComponents.Style.dimmedFontColor
        wrapMode: Text.WordWrap
        Layout.fillWidth: true
    }

    RowLayout {
        spacing: 10
        MoneroComponents.Label {
            text: qsTr("Router Status:") + translationManager.emptyString
            fontSize: 14
        }

        Text {
            text: I2PManager.status
            font.family: MoneroComponents.Style.fontBold.name
            font.pixelSize: 14
            color: I2PManager.connected ? MoneroComponents.Style.green : MoneroComponents.Style.dimmedFontColor
        }
    }

    RowLayout {
        spacing: 20
        Layout.topMargin: 10

        MoneroComponents.StandardButton {
            text: qsTr("Start Router") + translationManager.emptyString
            enabled: !I2PManager.connected
            onClicked: I2PManager.startCreateNode()
        }

        MoneroComponents.StandardButton {
            text: qsTr("Stop Router") + translationManager.emptyString
            enabled: I2PManager.connected
            onClicked: I2PManager.cancelCreateNode()
        }
    }

    // Status Polling
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: I2PManager.refreshStatus()
    }

    // Progress Dialog
    Popup {
        id: i2pProgressModal
        modal: true
        focus: true
        anchors.centerIn: parent
        width: 400
        height: 200
        visible: false

        background: Rectangle {
            color: MoneroComponents.Style.middlePanelBackgroundColor
            border.color: MoneroComponents.Style.appWindowBorderColor
            radius: 4
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            MoneroComponents.Label {
                text: qsTr("Starting I2P Router...")
                fontSize: 18
                fontBold: true
            }

            BusyIndicator {
                running: true
                Layout.alignment: Qt.AlignHCenter
            }

            MoneroComponents.StandardButton {
                text: qsTr("Cancel")
                onClicked: {
                    I2PManager.cancelCreateNode();
                    i2pProgressModal.close();
                }
            }
        }
    }

    Connections {
        target: I2PManager
        function onNodeCreationStarted() { i2pProgressModal.open(); }
        function onNodeCreationFinished(success, message) { i2pProgressModal.close(); if (!success) console.log("I2P Error: " + message); }
    }
}
