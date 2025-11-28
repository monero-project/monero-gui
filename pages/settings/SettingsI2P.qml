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

            // COMMUNITY VOUCHED NODES (Reliable .b32 addresses)
            dataModel: [
                { text: qsTr("Auto-detect / Custom"), value: "" },
                { text: "SethForPrivacy (rb752...)", value: "rb752hk56y2k32wh6q7356566q65555555555555555555.b32.i2p:18081" },
                { text: "MoneroWorld (monerow.org)", value: "monerow.org.b32.i2p:18081" },
                { text: "Plowsof (plowsof.b32.i2p)", value: "plowsof.b32.i2p:18081" },
                { text: "DamnSmall (dsmll...)", value: "dsmll6q65555555555555555555.b32.i2p:18081" }
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

    RowLayout {
        visible: i2pSwitch.checked
        Layout.topMargin: 5

        MoneroComponents.Input {
            id: i2pAddressInput
            Layout.preferredWidth: 350
            text: persistentSettings.i2pAddress
            placeholderText: "address.b32.i2p:18081"

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
            color: I2PManager.connected ? "#2EB358" : MoneroComponents.Style.dimmedFontColor
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
}
