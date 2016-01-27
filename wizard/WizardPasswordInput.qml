// WizardPasswordInput.qml

import QtQuick 2.0

Item {
    property alias password: password.text
    signal changed(string password)


    TextInput {
        id : password
        anchors.fill: parent
        horizontalAlignment: TextInput.AlignHCenter
        verticalAlignment: TextInput.AlignVCenter
        font.family: "Arial"
        font.pixelSize: 32
        renderType: Text.NativeRendering
        color: "#35B05A"
        passwordCharacter: "•"
        echoMode: TextInput.Password
        focus: true
        Keys.onReleased: {
            changed(text)
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "#DBDBDB"
    }
}
