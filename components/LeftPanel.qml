// Settings page
MenuButton {
    id: settingsButton
    anchors.left: parent.left
    anchors.right: parent.right
    text: qsTr("Settings") + translationManager.emptyString
    symbol: qsTr("S") + translationManager.emptyString
    dotColor: "#FFD781"
    under: advancedButton
    onClicked: {
        parent.previousButton = settingsButton
        parent.activateItem()
        panel.settingsClicked()
    }
}

// I2P button
MenuButton {
    id: i2pButton
    anchors.left: parent.left
    anchors.right: parent.right
    text: qsTr("I2P") + translationManager.emptyString
    symbol: qsTr("I") + translationManager.emptyString
    dotColor: "#2EB358" // Green dot for I2P
    under: settingsButton
    visible: persistentSettings.i2pEnabled
    onClicked: {
        parent.previousButton = i2pButton
        parent.activateItem()
        panel.i2pClicked()
    }
} 