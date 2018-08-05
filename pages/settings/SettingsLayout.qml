import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import "../../js/Utils.js" as Utils
import "../../js/Windows.js" as Windows
import "../../components" as MoneroComponents

Rectangle {
    color: "transparent"
    height: 1400
    Layout.fillWidth: true

    ColumnLayout {
        id: settingsUI
        property int itemHeight: 60 * scaleRatio
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: (isMobile)? 17 : 20
        anchors.topMargin: 0
        spacing: 0

        MoneroComponents.CheckBox {
            visible: !isMobile
            id: customDecorationsCheckBox
            checked: persistentSettings.customDecorations
            onClicked: Windows.setCustomWindowDecorations(checked)
            text: qsTr("Custom decorations") + translationManager.emptyString
        }

        MoneroComponents.TextBlock {
            visible: isMobile
            font.pixelSize: 14
            textFormat: Text.RichText
            Layout.fillWidth: true
            text: qsTr("No Layout options exist yet in mobile mode.") + translationManager.emptyString;
        }
    }

    Component.onCompleted: {
        console.log('SettingsLayout loaded');
    }
}

