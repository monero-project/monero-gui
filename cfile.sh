#!/bin/bash
# Create the I2P UI components

# 1. Create the Modal (Popup)
echo "Creating components/I2PNodeModal.qml..."
cat > "components/I2PNodeModal.qml" << 'EOF'
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import "." as MoneroComponents

Dialog {
    id: root
    modal: true
    closePolicy: Popup.NoAutoClose
    dim: true
    title: "Securing Your Freedom"
    
    property alias passwordText: passwordField.text
    signal submitPassword()
    
    property var facts: [
        "Did you know? Monero uses ring signatures to obfuscate the origin of funds.",
        "Running your own node is the highest level of privacy you can achieve.",
        "I2P (Invisible Internet Project) creates a strictly anonymous network layer.",
        "By running this node, you are protecting yourself and the entire network.",
        "Monero is the only major cryptocurrency where every user is anonymous by default."
    ]
    
    property int currentFactIndex: 0

    Timer {
        interval: 5000 
        running: root.visible && !passwordRow.visible
        repeat: true
        onTriggered: {
            currentFactIndex = (currentFactIndex + 1) % facts.length
        }
    }

    background: Rectangle {
        color: "#1D1D1D"
        radius: 10
        border.color: "#FF6600"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        Text {
            text: "Constructing Secure Node..."
            color: "white"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.preferredWidth: 400
            Layout.preferredHeight: 100
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                width: parent.width
                text: facts[currentFactIndex]
                color: "#AAAAAA"
                font.pixelSize: 16
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: true
        }
        
        ColumnLayout {
            id: passwordRow
            visible: false 
            Layout.fillWidth: true
            
            Text {
                text: "Admin Access Required for Docker"
                color: "#FF6600"
                font.pixelSize: 14
            }
            
            TextField {
                id: passwordField
                echoMode: TextInput.Password
                placeholderText: "Enter System Password"
                Layout.fillWidth: true
                color: "white"
                background: Rectangle { color: "#333"; radius: 4 }
            }
            
            Button {
                text: "Authorize Securely"
                Layout.alignment: Qt.AlignRight
                onClicked: root.submitPassword()
            }
        }
    }
}
EOF

# 2. Create the Settings Page
echo "Creating pages/settings/SettingsI2P.qml..."
cat > "pages/settings/SettingsI2P.qml" << 'EOF'
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import "../../components" as MoneroComponents

Rectangle {
    color: "transparent"
    signal requestNodeCreation(string password)

    ColumnLayout {
        width: parent.width
        spacing: 20

        RowLayout {
            spacing: 15
            Switch {
                id: i2pToggle
                text: "Enable I2P Privacy Routing"
                checked: false
                contentItem: Text {
                    text: i2pToggle.text
                    color: i2pToggle.checked ? "#FF6600" : "#AAAAAA"
                    font.pixelSize: 18
                }
            }
            
            Rectangle {
                visible: i2pToggle.checked
                width: 100
                height: 30
                radius: 15
                color: "#2EB358"
                RowLayout {
                    anchors.centerIn: parent
                    Text { text: "✓ SECURE"; color: "white"; font.bold: true }
                }
            }
        }

        ColumnLayout {
            visible: i2pToggle.checked
            Layout.fillWidth: true
            spacing: 15

            Text {
                text: "Traffic is currently encrypted and proxied via I2P."
                color: "#888888"
                font.italic: true
            }

            RowLayout {
                Text { text: "Connection Method:"; color: "white" }
                ComboBox {
                    model: ["Automatic (Best)", "Local I2P Router", "Remote I2P Node"]
                    currentIndex: 0
                    width: 200
                }
            }

            Text { text: "Verified Trust Nodes"; color: "#FF6600"; font.bold: true }
            
            ListView {
                Layout.preferredHeight: 80
                Layout.fillWidth: true
                model: ListModel {
                    ListElement { name: "i2p-project.main.net"; status: "Online" }
                    ListElement { name: "monero-node-01.i2p"; status: "Online" }
                }
                delegate: Text { text: name + " (" + status + ")"; color: "white" }
            }

            Button {
                // visible: !i2pManager.isMobile // Commented out until C++ wiring is done
                text: "CREATE YOUR OWN NODE (DOCKER)"
                Layout.fillWidth: true
                onClicked: createNodeModal.open()
                background: Rectangle { color: "#FF6600"; radius: 5 }
                contentItem: Text { text: parent.text; color: "white"; horizontalAlignment: Text.AlignHCenter }
            }
        }
    }

    I2PNodeModal {
        id: createNodeModal
        anchors.centerIn: parent
        width: 600
        height: 300
        onSubmitPassword: requestNodeCreation(passwordText)
    }
}
EOF
echo "UI Files Created."
