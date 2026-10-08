import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls

import "../js/Wizard.js" as Wizard
import "../js/Utils.js" as Utils
import "../components" as MoneroComponents

GridLayout {
    id: seedGrid
    property int columnCount: wizardController.layoutScale == 1 ? 5 : wizardController.layoutScale == 2 ? 4 : wizardController.layoutScale == 3 ? 3 : 2
    Layout.alignment: Qt.AlignHCenter
    flow: GridLayout.TopToBottom
    columns: columnCount
    rows: Math.ceil(wizardController.walletOptionsSeed.split(/\s+/).length / columnCount)
    columnSpacing: wizardController.layoutScale == 1 ? 25 : 18
    rowSpacing: 0

    Component.onCompleted: {
        var seed = wizardController.walletOptionsSeed.split(/\s+/);
        var component = Qt.createComponent("SeedListItem.qml");
        for(var i = 0; i < seed.length; i++) {
            component.createObject(seedGrid, {wordNumber: i, word: seed[i]});
        }
    }
}
