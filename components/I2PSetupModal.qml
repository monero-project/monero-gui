import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15 // For DropShadow and GaussianBlur

Popup {
    id: root
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose // User must wait or hit cancel explicitly

    // Center in parent window
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: 480
    height: 320

    // Transparent background for custom rounded aesthetic
    background: Item {
        id: bgItem

        // The "Card" background
        Rectangle {
            id: mainRect
            anchors.fill: parent
            radius: 16
            color: "#1D1D1D" // Monero Dark Grey
            border.color: "#333333"
            border.width: 1
            clip: true

            // Subtle gradient for premium feel
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#242424" }
                GradientStop { position: 1.0; color: "#1a1a1a" }
            }
        }

        // Shadow for depth
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 8
            radius: 24
            samples: 17
            color: "#80000000"
        }
    }

    // We use a StackLayout to switch between "Progress" and "Password Input"
    StackLayout {
        id: layoutStack
        anchors.fill: parent
        anchors.margins: 30
        currentIndex: 0

        // --- VIEW 1: PROGRESS & STATUS ---
        ColumnLayout {
            spacing: 20

            // Icon (Placeholder for a FontAwesome icon or Image)
            Label {
                text: "⚙️" // Replace with nice SVG icon
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Setting up I2P Node"
                color: "white"
                font.pixelSize: 22
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            // Custom Progress Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                color: "#333333"
                radius: 3

                Rectangle {
                    width: parent.width * 0.3 // Indeterminate animation
                    height: parent.height
                    radius: 3
                    color: "#F26822" // Monero Orange

                    SequentialAnimation on x {
                        loops: Animation.Infinite
                        running: root.visible && layoutStack.currentIndex === 0
                        NumberAnimation { from: 0; to: parent.width - width; duration: 1000; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: parent.width - width; to: 0; duration: 1000; easing.type: Easing.InOutQuad }
                    }
                }
            }

            // Dynamic Status Text from Script
            Label {
                text: i2pController.statusMessage
                color: "#AAAAAA"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        // --- VIEW 2: PASSWORD PROMPT ---
        ColumnLayout {
            spacing: 15

            Label {
                text: "🔒"
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: "Permission Required"
                color: "white"
                font.pixelSize: 20
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                text: promptText // Property defined below
                color: "#CCCCCC"
                font.pixelSize: 14
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            // Custom Input Field
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                color: "#111111"
                radius: 8
                border.color: passwordField.activeFocus ? "#F26822" : "#444444"

                TextInput {
                    id: passwordField
                    anchors.fill: parent
                    anchors.margins: 10
                    color: "white"
                    font.pixelSize: 16
                    verticalAlignment: Text.AlignVCenter
                    echoMode: TextInput.Password
                    passwordCharacter: "•"

                    // Submit on Enter key
                    onAccepted: {
                        layoutStack.currentIndex = 0 // Go back to progress
                        i2pController.sendPassword(text)
                        text = "" // Clear for security
                    }
                }
            }

            Button {
                text: "Authorize"
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                background: Rectangle {
                    color: parent.down ? "#D95B1C" : "#F26822"
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    layoutStack.currentIndex = 0
                    i2pController.sendPassword(passwordField.text)
                    passwordField.text = ""
                }
            }
        }
    }

    // Internal Logic
    property string promptText: ""

    Connections {
        target: i2pController // The C++ class instance

        function onPasswordRequested(prompt) {
            root.promptText = prompt
            layoutStack.currentIndex = 1 // Switch to password view
            passwordField.forceActiveFocus()
        }

        function onSetupFinished(success) {
            // Small delay to let user see "Complete" before closing
            if(success) {
                 // Ideally change icon to Checkmark here
                 closeTimer.start()
            } else {
                 // Show error state
            }
        }
    }

    Timer {
        id: closeTimer
        interval: 2000
        onTriggered: root.close()
    }
}
