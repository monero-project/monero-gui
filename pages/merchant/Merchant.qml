import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2

import moneroComponents.Clipboard 1.0
import moneroComponents.Wallet 1.0
import moneroComponents.WalletManager 1.0
import moneroComponents.TransactionHistory 1.0
import moneroComponents.TransactionHistoryModel 1.0
import moneroComponents.Subaddress 1.0
import moneroComponents.SubaddressModel 1.0

import "../../js/Windows.js" as Windows
import "../../js/TxUtils.js" as TxUtils
import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents
import "../../pages"
import "."

Item {
    id: root
    anchors.margins: 0

    property int    minWidth: 900
    property int    minHeight: 600
    property int    qrCodeSize: 220
    property bool   enableTracking: false
    property string trackingError: ""  // setting this will show a message @ tracking table
    property alias  merchantHeight: mainLayout.height
    property string addressLabel: ""
    property var    hiddenAmounts: []

    function onPageCompleted() {
        if (appWindow.currentWallet) {
            appWindow.current_address = appWindow.currentWallet.address(appWindow.currentWallet.currentSubaddressAccount, 0)
        }
        // prepare tracking
        trackingCheckbox.checked = root.enableTracking
        root.update();
        timer.running = true;

        // set currently selected account indication
        var _addressLabel = appWindow.currentWallet.getSubaddressLabel(
            appWindow.currentWallet.currentSubaddressAccount,
            appWindow.current_subaddress_table_index);
        if(_addressLabel === ""){
            root.addressLabel = "#" + appWindow.current_subaddress_table_index;
        } else {
            root.addressLabel = _addressLabel;
        }
    }

    function onPageClosed() {
        // reset component objects
        timer.running = false
        root.enableTracking = false
        trackingModel.clear()
    }

    Image {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 300
        source: "qrc:///images/merchant/bg.png"
        smooth: false
    }

    ColumnLayout {
        id: mainLayout
        visible: parent.width >= root.minWidth && appWindow.height >= root.minHeight
        spacing: 0

        // emulates max-width + center for container
        property int maxWidth: 1200
        property int defaultMargin: 50
        property int horizontalMargin: {
            if(appWindow.width >= maxWidth){
                return ((appWindow.width - maxWidth) / 2) + defaultMargin;
            } else {
                return defaultMargin;
            }
        }

        anchors.leftMargin: horizontalMargin
        anchors.rightMargin: horizontalMargin
        anchors.margins: defaultMargin
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right

        Item {
            Layout.preferredHeight: 220
            Layout.fillWidth: true

            Rectangle {
                id: tracker
                anchors.left: parent.left
                anchors.top: parent.top
                height: 220
                width: (parent.width - qrImg.width) - 50
                radius: 5

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    RowLayout {
                        spacing: 0
                        height: 56

                        RowLayout {
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: 260
                            Layout.preferredHeight: parent.height
                            Layout.fillHeight: true
                            spacing: 8

                            Item {
                                Layout.preferredWidth: 10
                            }

                            MoneroComponents.TextPlain {
                                font.pixelSize: 16
                                font.bold: true
                                color: "#767676"
                                text: qsTr("Sales") + translationManager.emptyString
                                themeTransition: false
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: "#d9d9d9"
                    }

                    MerchantTrackingList {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 400
                        model: trackingModel
                        message: {
                            if(!root.enableTracking){
                                return "<style>p{font-size:14px;}</style> <p>%1</p> <p>%2</p>"
                                    .arg(qsTr("This page will automatically scan the blockchain and the tx pool for incoming transactions using the QR code."))
                                    .arg(qsTr("It's up to you whether to accept unconfirmed transactions or not. It is likely they'll be confirmed in short order, but there is still a possibility they might not, so for larger values you may want to wait for one or more confirmation(s)"))
                                    + translationManager.emptyString;
                            } else if(root.trackingError !== ""){
                                return root.trackingError;
                            } else if(trackingModel.count < 1){
                                return qsTr("Currently monitoring incoming transactions, none found yet.");
                            } else {
                                return ""
                            }
                        }
                        onHideAmountToggled: {
                            if(root.hiddenAmounts.indexOf(txid) < 0){
                                root.hiddenAmounts.push(txid);
                            } else {
                                root.hiddenAmounts = root.hiddenAmounts.filter(function(_txid) { return _txid !== txid });
                            }
                        }
                    }
                }
            }

            DropShadow {
                anchors.fill: source
                cached: true
                horizontalOffset: 3
                verticalOffset: 3
                radius: 8.0
                samples: 16
                color: "#20000000"
                smooth: true
                source: tracker
            }

            Rectangle {
                id: qrImg
                color: "white"

                anchors.right: parent.right
                anchors.top: parent.top

                height: root.qrCodeSize
                width: root.qrCodeSize

                Layout.maximumWidth: root.qrCodeSize
                Layout.preferredHeight: width
                radius: 5

                Image {
                    id: qrCode
                    anchors.fill: parent
                    anchors.margins: 1

                    smooth: false
                    fillMode: Image.PreserveAspectFit
                    source: "image://qrcode/" + TxUtils.makeQRCodeString(appWindow.current_address, amountToReceive.text)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onClicked: {
                            if (mouse.button == Qt.RightButton){
                                qrMenu.x = this.mouseX;
                                qrMenu.y = this.mouseY;
                                qrMenu.open()
                            }
                        }
                        onPressAndHold: qrFileDialog.open()
                    }
                }

                Menu {
                    id: qrMenu
                    title: "QrCode"

                    MenuItem {
                        text: qsTr("Save As") + translationManager.emptyString;
                        onTriggered: qrFileDialog.open()
                    }
                }
            }

            DropShadow {
                anchors.fill: source
                cached: true
                horizontalOffset: 3
                verticalOffset: 3
                radius: 8.0
                samples: 16
                color: "#30000000"
                smooth: true
                source: qrImg
            }
        }

        Item {
            Layout.preferredHeight: 40
            Layout.fillWidth: true

            Item {
                width: (parent.width - qrImg.width) - (50)
                height: 32

                MoneroComponents.TextPlain {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12
                    font.bold: false
                    color: "white"
                    text: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 12px;}</style>%1: %2 <a href='#'>(%3)</a>"
                        .arg(qsTr("Currently selected address"))
                        .arg(addressLabel)
                        .arg(qsTr("Change")) + translationManager.emptyString
                    textFormat: Text.RichText
                    themeTransition: false

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appWindow.showPageRequest("Receive")
                    }
                }
            }

            Item {
                anchors.right: parent.right
                anchors.top: parent.top
                width: 220
                height: 32

                MoneroComponents.TextPlain {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12
                    font.bold: false
                    color: "white"
                    text: qsTr("(right-click, save as)") + translationManager.emptyString
                    themeTransition: false
                }
            }
        }

        Item {
            Layout.preferredHeight: 120
            Layout.topMargin: 20
            Layout.fillWidth: true

            Rectangle {
                id: payment_url_container
                anchors.left: parent.left
                anchors.top: parent.top
                implicitHeight: 120
                width: (parent.width - qrImg.width) - (50)
                radius: 5

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    RowLayout {
                        spacing: 0
                        height: 56

                        RowLayout {
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: 260
                            Layout.preferredHeight: parent.height
                            Layout.fillHeight: true
                            spacing: 8

                            Item {
                                Layout.preferredWidth: 10
                            }

                            MoneroComponents.TextPlain {
                                font.pixelSize: 14
                                font.bold: true
                                color: "#767676"
                                text: qsTr("Payment URL") + translationManager.emptyString
                                themeTransition: false
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        // @TODO: PaymentURL explanation
//                        Rectangle {
//                            // help box
//                            Layout.alignment: Qt.AlignLeft
//                            Layout.preferredWidth: 40
//                            Layout.fillHeight: true
//                            color: "transparent"

//                            MoneroComponents.TextPlain {
//                                anchors.verticalCenter: parent.verticalCenter
//                                anchors.right: parent.right
//                                anchors.rightMargin: 20
//                                font.pixelSize: 16
//                                font.bold: true
//                                color: "#767676"
//                                text:"?"
//                            }

//                            MouseArea {
//                                anchors.fill: parent
//                                cursorShape: Qt.PointingHandCursor
//                                onClicked: {
//                                    merchantPageDialog.title  = qsTr("Payment URL") + translationManager.emptyString;
//                                    merchantPageDialog.text = qsTr("payment url explanation")
//                                    merchantPageDialog.icon = StandardIcon.Information
//                                    merchantPageDialog.open()
//                                }
//                            }
//                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1

                        color: "#d9d9d9"
                    }

                    MoneroComponents.TextPlain {
                        property string _color: "#767676"
                        Layout.fillWidth: true
                        Layout.margins: 20
                        Layout.topMargin: 10

                        wrapMode: Text.WrapAnywhere
                        elide: Text.ElideRight

                        font.pixelSize: 12
                        font.bold: true
                        color: _color
                        text: TxUtils.makeQRCodeString(appWindow.current_address, amountToReceive.text)
                        themeTransition: false

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                parent.color = MoneroComponents.Style.orange
                            }
                            onExited: {
                                parent.color = parent._color
                            }
                            onClicked: {
                                console.log("Copied to clipboard");
                                clipboard.setText(parent.text);
                                appWindow.showStatusMessage(qsTr("Copied to clipboard"), 3);
                            }
                        }
                    }
                }
            }

            DropShadow {
                anchors.fill: source
                cached: true
                horizontalOffset: 3
                verticalOffset: 3
                radius: 8.0
                samples: 16
                color: "#20000000"
                smooth: true
                source: payment_url_container
            }

            Item {
                anchors.right: parent.right
                anchors.top: parent.top
                width: 220
                height: 32

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    MoneroComponents.TextPlain {
                        font.pixelSize: 14
                        font.bold: false
                        color: "white"
                        text: qsTr("Amount to receive") + " (XMR)" + translationManager.emptyString
                        themeTransition: false
                    }

                    Image {
                        height: 28
                        width: 220
                        source: "qrc:///images/merchant/input_box.png"

                        MoneroComponents.Input {
                            id: amountToReceive
                            topPadding: 0
                            leftPadding: 10

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 3
                            font.pixelSize: 16
                            font.bold: true
                            horizontalAlignment: TextInput.AlignLeft
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            color: "#424242"
                            selectionColor: "#3f3fe3"
                            selectedTextColor: "white"
                            placeholderText: "0.00"

                            background: Rectangle {
                                color: "transparent"
                            }
                            onTextChanged: {
                                if (amountToReceive.text.indexOf('.') === 0) {
                                    amountToReceive.text = '0' + amountToReceive.text;
                                }
                            }
                            validator: RegExpValidator {
                                regExp: /^(\d{1,8})?([\.]\d{1,12})?$/
                            }
                        }
                    }

                    Item {
                        height: 2
                        width: 220
                    }

                    MoneroComponents.TextPlain {
                        // @TODO: When we have XMR/USD rate avi. in the future.
                        visible: false
                        font.pixelSize: 14
                        font.bold: false
                        color: "white"
                        text: qsTr("Amount to receive") + " (USD)"
                        opacity: 0.2
                        themeTransition: false
                    }

                    Image {
                        visible: false
                        height: 28
                        width: 220
                        source: "qrc:///images/merchant/input_box.png"
                        opacity: 0.2
                    }
                }
            }
        }

        Item {
            Layout.topMargin: 32
            Layout.preferredHeight: 40
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 16

                MerchantCheckbox {
                    id: trackingCheckbox
                    checked: root.enableTracking
                    text: qsTr("Enable sales tracker") + translationManager.emptyString

                    onChanged: {
                        root.enableTracking = this.checked;
                    }
                }

                MoneroComponents.TextPlain {
                    id: content
                    font.pixelSize: 14
                    font.bold: false
                    color: "white"
                    text: qsTr("Leave this page") + translationManager.emptyString
                    themeTransition: false

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appWindow.showPageRequest("Settings")
                    }
                }
            }
        }
    }

    Rectangle {
        // Shows when the window is too small
        visible: parent.width < root.minWidth || appWindow.height < root.minHeight
        anchors.top: parent.top
        anchors.topMargin: 100;
        anchors.horizontalCenter: parent.horizontalCenter
        height: 120
        width: 400
        radius: 5

        MoneroComponents.TextPlain {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14
            font.bold: true
            color: MoneroComponents.Style.moneroGrey
            text: qsTr("The merchant page requires a larger window") + translationManager.emptyString
            themeTransition: false
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: appWindow.showPageRequest("Settings")
        }
    }

    function update() {
        const max_tracking = 3;

        if (!appWindow.currentWallet || !root.enableTracking) {
            root.trackingError = "";
            trackingModel.clear();
            return
        }

        if (appWindow.disconnected) {
            root.trackingError = qsTr("WARNING: no connection to daemon");
            trackingModel.clear();
            return
        }

        var model = appWindow.currentWallet.historyModel
        var count = model.rowCount()
        var nTransactions = 0
        var txs = []

        // Currently selected subaddress as per Receive page
        var current_subaddress_table_index = appWindow.current_subaddress_table_index;

        for (var i = 0; i < count && txs.length < max_tracking; ++i) {
            var idx = model.index(i, 0)
            var isout = model.data(idx, TransactionHistoryModel.TransactionIsOutRole);
            var timeDate = model.data(idx, TransactionHistoryModel.TransactionDateRole);
            var timeHour = model.data(idx, TransactionHistoryModel.TransactionTimeRole);
            var timeEpoch = new Date(timeDate + "T" + timeHour) .getTime() / 1000;
            var subaddrAccount = model.data(idx, TransactionHistoryModel.TransactionSubaddrAccountRole);
            var subaddrIndex = model.data(idx, TransactionHistoryModel.TransactionSubaddrIndexRole);

            if (!isout && subaddrAccount == appWindow.currentWallet.currentSubaddressAccount && subaddrIndex == current_subaddress_table_index) {
                nTransactions += 1

                var txid = model.data(idx, TransactionHistoryModel.TransactionHashRole);
                var blockHeight = model.data(idx, TransactionHistoryModel.TransactionBlockHeightRole);

                var in_txpool = false;
                var confirmations = 0;
                var displayAmount = model.data(idx, TransactionHistoryModel.TransactionDisplayAmountRole);

                if (blockHeight === undefined) {
                    in_txpool = true;
                } else {
                    confirmations = model.data(idx, TransactionHistoryModel.TransactionConfirmationsRole);
                }

                txs.push({
                    "amount": displayAmount,
                    "confirmations": confirmations,
                    "in_txpool": in_txpool,
                    "txid": txid,
                    "time_epoch": timeEpoch,
                    "time_date": timeDate + " " + timeHour,
                    "hide_amount": root.hiddenAmounts.indexOf(txid) >= 0
                })
            }
        }

        // Update tracking status label
        if (nTransactions == 0) {
            root.trackingError = qsTr("Currently monitoring incoming transactions, none found yet.") + translationManager.emptyString
            return
        }

        trackingModel.clear();
        txs.forEach(function(tx){
            trackingModel.append({
                "amount": tx.amount,
                "confirmations": tx.confirmations,
                "in_txpool": tx.in_txpool,
                "txid": tx.txid,
                "time_epoch": tx.time_epoch,
                "time_date": tx.time_date,
                "hide_amount": tx.hide_amount
            });
        });
    }

    ListModel {
        id: trackingModel
    }

    Timer {
        id: timer
        interval: 3000; running: false; repeat: true
        onTriggered: update()
    }

    MessageDialog {
        id: merchantPageDialog
        standardButtons: StandardButton.Ok
    }

    FileDialog {
        id: qrFileDialog
        title: "Please choose a name"
        folder: shortcuts.pictures
        selectExisting: false
        nameFilters: ["Image (*.png)"]
        onAccepted: {
            if(!walletManager.saveQrCode(TxUtils.makeQRCodeString(appWindow.current_address, amountToReceive.text), walletManager.urlToLocalPath(fileUrl))) {
                console.log("Failed to save QrCode to file " + walletManager.urlToLocalPath(fileUrl) )
                receivePageDialog.title = qsTr("Save QrCode") + translationManager.emptyString;
                receivePageDialog.text = qsTr("Failed to save QrCode to ") + walletManager.urlToLocalPath(fileUrl) + translationManager.emptyString;
                receivePageDialog.icon = StandardIcon.Error
                receivePageDialog.open()
            }
        }
    }

    Clipboard { id: clipboard }
}
