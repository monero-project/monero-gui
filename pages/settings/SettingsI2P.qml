import "../../components" as MoneroComponents
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import moneroComponents.I2P 1.0
import moneroComponents.Settings 1.0

ColumnLayout {
    id: root

    spacing: 20
    Layout.fillWidth: true

    // Known I2P Nodes
    MoneroComponents.TextPlain {
        color: MoneroComponents.Style.defaultFontColor
        font.family: MoneroComponents.Style.fontRegular.name
        font.pixelSize: 15
        text: qsTr("I2P Node") + translationManager.emptyString
    }

    MoneroComponents.StandardDropdown {
        id: knownNodes

        Layout.preferredWidth: 400
        Layout.fillWidth: true
        dataModel: [{
            "text": qsTr("Custom node") + translationManager.emptyString,
            "url": ""
        }, {
            "text": "core5hzivg4v5ttxbor4a3haja6dssksqsmiootlptnsrfsgwqqa.b32.i2p:18089",
            "url": "core5hzivg4v5ttxbor4a3haja6dssksqsmiootlptnsrfsgwqqa.b32.i2p:18089"
        }, {
            "text": "dsc7fyzzultm7y6pmx2avu6tze3usc7d27nkbzs5qwuujplxcmzq.b32.i2p:18089",
            "url": "dsc7fyzzultm7y6pmx2avu6tze3usc7d27nkbzs5qwuujplxcmzq.b32.i2p:18089"
        }, {
            "text": "sel36x6fibfzujwvt4hf5gxolz6kd3jpvbjqg6o3ud2xtionyl2q.b32.i2p:18089",
            "url": "sel36x6fibfzujwvt4hf5gxolz6kd3jpvbjqg6o3ud2xtionyl2q.b32.i2p:18089"
        }, {
            "text": "yht4tm2slhyue42zy5p2dn3sft2ffjjrpuy7oc2lpbhifcidml4q.b32.i2p:18089",
            "url": "yht4tm2slhyue42zy5p2dn3sft2ffjjrpuy7oc2lpbhifcidml4q.b32.i2p:18089"
        }]
        currentIndex: {
            var currentUrl = persistentSettings.i2pAddress;
            for (var i = 0; i < dataModel.length; i++) {
                if (dataModel[i].url === currentUrl)
                    return i;

            }
            return 0;
        }
        onChanged: {
            var selectedNode = dataModel[currentIndex];
            if (selectedNode && selectedNode.url && selectedNode.url.length > 0) {
                persistentSettings.i2pAddress = selectedNode.url;
                I2PManager.setProxyForI2p();
            } else if (selectedNode && !selectedNode.url) {
                // Custom node - could open a dialog here to enter custom address
                // For now, just allow manual entry via settings
                persistentSettings.i2pAddress = "";
            }
        }
    }

    // Create I2P Node Button
    MoneroComponents.StandardButton {
        id: createNodeButton

        Layout.fillWidth: true
        Layout.topMargin: 10
        text: qsTr("Create I2P Node (Recommended)") + translationManager.emptyString
        enabled: true
        onClicked: {
            // Start node creation - password will be requested via signal
            I2PManager.startCreateNode();
        }
    }

    // Connection Status
    RowLayout {
        spacing: 10
        Layout.fillWidth: true

        MoneroComponents.TextPlain {
            color: MoneroComponents.Style.defaultFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            text: qsTr("Connection status:") + translationManager.emptyString
        }

        MoneroComponents.TextPlain {
            id: statusText

            color: I2PManager.connected ? "#00A000" : "#C00000"
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            text: I2PManager.connected ? qsTr("Connected") : qsTr("Not connected") + translationManager.emptyString
        }

    }

    // Status refresh timer
    Timer {
        id: statusTimer

        interval: 5000
        running: persistentSettings.i2pEnabled
        repeat: true
        onTriggered: {
            I2PManager.refreshStatus();
        }
    }

    // Password Dialog Connections
    Connections {
        function onAccepted() {
            // When password is accepted, provide it to I2PManager
            // This is called after passwordRequested signal
            if (I2PManager && passwordDialog.password)
                I2PManager.providePassword(passwordDialog.password);

        }

        target: passwordDialog
    }

    // I2PManager Signal Connections
    Connections {
        // Password is provided when passwordRequested signal is received
        // The passwordDialog.onAccepted callback will call providePassword
        // Status text will update automatically via binding

        function onPasswordRequested(reason) {
            passwordDialog.open("", reason || qsTr("Enter your system password to set up I2P") + translationManager.emptyString, qsTr("Enter Password") + translationManager.emptyString, "", false);
        }

        function onNodeCreationStarted() {
            // Show progress modal with fun facts
            i2pProgressModal.open();
        }

        function onNodeCreationFinished(success, message) {
            // Close progress modal
            i2pProgressModal.close();
            passwordDialog.close();
            if (success) {
                informationPopup.title = qsTr("Success") + translationManager.emptyString;
                informationPopup.text = qsTr("I2P node created successfully. Connecting...") + translationManager.emptyString;
                informationPopup.icon = StandardIcon.Information;
            } else {
                informationPopup.title = qsTr("Error") + translationManager.emptyString;
                informationPopup.text = message || qsTr("Failed to set up I2P node. Please check logs or try again.") + translationManager.emptyString;
                informationPopup.icon = StandardIcon.Critical;
            }
            informationPopup.onCloseCallback = null;
            informationPopup.open();
        }

        function onStatusChanged() {
        }

        target: I2PManager
    }

    // I2P Progress Modal with Fun Facts
    Popup {
        id: i2pProgressModal

        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        anchors.centerIn: parent
        width: 500
        height: 400

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            // Title
            MoneroComponents.TextPlain {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20
                font.bold: true
                color: MoneroComponents.Style.defaultFontColor
                text: qsTr("Setting up your I2P node...") + translationManager.emptyString
            }

            // Progress Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                color: MoneroComponents.Style.appWindowBorderColor
                radius: 3

                Rectangle {
                    width: parent.width * 0.3
                    height: parent.height
                    radius: 3
                    color: MoneroComponents.Style.orange

                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        running: i2pProgressModal.visible

                        NumberAnimation {
                            from: 0
                            to: parent.parent.width - width
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }

                        NumberAnimation {
                            from: parent.parent.width - width
                            to: 0
                            duration: 1000
                            easing.type: Easing.InOutQuad
                        }

                    }

                }

            }

            // Status Message
            MoneroComponents.TextPlain {
                id: progressStatusText

                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 14
                color: MoneroComponents.Style.defaultFontColor
                text: I2PManager.status || qsTr("Initializing...") + translationManager.emptyString
            }

            // Fun Facts Carousel
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                Layout.topMargin: 20
                color: MoneroComponents.Style.backgroundDarkestColor
                radius: 4
                border.color: MoneroComponents.Style.appWindowBorderColor
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    MoneroComponents.TextPlain {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 12
                        font.bold: true
                        color: MoneroComponents.Style.orange
                        text: qsTr("Did you know?") + translationManager.emptyString
                    }

                    ListView {
                        id: funFactsList

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: funFactsModel

                        Timer {
                            id: factsTimer

                            interval: 5000
                            running: i2pProgressModal.visible
                            repeat: true
                            onTriggered: {
                                if (funFactsList.count > 0) {
                                    var nextIndex = (funFactsList.currentIndex + 1) % funFactsList.count;
                                    funFactsList.currentIndex = nextIndex;
                                }
                            }
                        }

                        delegate: MoneroComponents.TextPlain {
                            width: funFactsList.width
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 13
                            color: MoneroComponents.Style.defaultFontColor
                            wrapMode: Text.WordWrap
                            text: model.text
                        }

                    }

                }

            }

            // Cancel Button
            MoneroComponents.StandardButton {
                Layout.fillWidth: true
                Layout.topMargin: 10
                text: qsTr("Cancel") + translationManager.emptyString
                onClicked: {
                    I2PManager.cancelCreateNode();
                    i2pProgressModal.close();
                }
            }

        }

        background: Rectangle {
            color: MoneroComponents.Style.middlePanelBackgroundColor
            border.color: MoneroComponents.Style.appWindowBorderColor
            border.width: 1
            radius: 4
        }

    }

    // Fun Facts Model
    ListModel {
        id: funFactsModel

        ListElement {
            text: "Monero launched in April 2014 as a fork of the Bytecoin codebase."
        }

        ListElement {
            text: "Ring signatures and stealth addresses hide the origin and destination of every transaction in Monero."
        }

        ListElement {
            text: "Running your own node enhances your privacy and contributes to the network's decentralization."
        }

        ListElement {
            text: "I2P (Invisible Internet Project) is a decentralized anonymizing network layer for secure communication."
        }

        ListElement {
            text: "Monero uses ring signatures to mix your transaction with others, making it untraceable."
        }

        ListElement {
            text: "I2P provides end-to-end encryption and routes traffic through multiple nodes for anonymity."
        }

        ListElement {
            text: "Monero's privacy features are mandatory, not optional - every transaction is private by default."
        }

        ListElement {
            text: "I2P nodes help strengthen the network by providing more routing options and redundancy."
        }

    }

}
