import QtQuick 2.9
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0

import "../js/Wizard.js" as Wizard
import "../js/Utils.js" as Utils
import "../components" as MoneroComponents

GridLayout {
    id: seedGrid
    Layout.alignment: Qt.AlignHCenter
    flow: GridLayout.TopToBottom
    columns: wizardController.layoutScale == 1 ? 5 :  wizardController.layoutScale == 2 ? 4 :  wizardController.layoutScale == 3 ? 3 : 2
    rows: wizardController.layoutScale == 1 ? 5 :wizardController.layoutScale == 2 ? 7 : wizardController.layoutScale == 3 ? 9 : 13
    columnSpacing: wizardController.layoutScale == 1 ? 25 : 18
    rowSpacing: 0

    Component.onCompleted: {
        var seed = wizardController.walletOptionsSeed.split(" ");
        var component = Qt.createComponent("SeedListItem.qml");
        for(var i = 0; i < seed.length; i++) {
            component.createObject(seedGrid, {wordNumber: i, word: seed[i]});
        }
    }
}
