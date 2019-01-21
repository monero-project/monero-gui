import QtQuick 2.7
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

    property int    minWidth: 900 * scaleRatio
    property int    qrCodeSize: 220 * scaleRatio
    property bool   enableTracking: false
    property string trackingError: ""  // setting this will show a message @ tracking table
    property alias  merchantHeight: mainLayout.height
    property string addressLabel: ""
    property var    hiddenAmounts: []

    function onPageCompleted() {
        appWindow.titlebarToggleOrange();
        appWindow.hideMenu();

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
        appWindow.titlebarToggleOrange();

        // reset component objects
        timer.running = false
        root.enableTracking = false
        trackingModel.clear()

        appWindow.showMenu();
    }

    Image {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 300 * scaleRatio
        source: "../../images/merchant/bg.png"
        smooth: false
    }

    ColumnLayout {
        id: mainLayout
        visible: parent.width >= root.minWidth
        spacing: 0

        // emulates max-width + center for container
        property int maxWidth: 1200 * scaleRatio
        property int defaultMargin: 50 * scaleRatio
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
            height: 220 * scaleRatio
            anchors.left: parent.left
            anchors.right: parent.right

            Rectangle {
                id: tracker
                anchors.left: parent.left
                anchors.top: parent.top
                height: 220 * scaleRatio
                width: (parent.width - qrImg.width) - 50 * scaleRatio
                radius: 5

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    RowLayout {
                        spacing: 0
                        height: 56 * scaleRatio

                        RowLayout {
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: 260 * scaleRatio
                            Layout.preferredHeight: parent.height
                            Layout.fillHeight: true
                            spacing: 8 * scaleRatio

                            Item {
                                Layout.preferredWidth: 10 * scaleRatio
                            }

                            Text {
                                font.pixelSize: 16 * scaleRatio
                                font.bold: true
                                color: "#767676"
                                text: qsTr("Sales")
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
                        Layout.preferredHeight: 1 * scaleRatio
                        color: "#d9d9d9"
                    }

                    MerchantTrackingList {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 400 * scaleRatio
                        model: trackingModel
                        message: {
                            if(!root.enableTracking){
                                return qsTr(
                                        "<style>p{font-size:14px;}</style>" +
                                        "<p>This page will automatically scan the blockchain and the tx pool " +
                                        "for incoming transactions using the QR code.</p>" +
                                        "<p>It's up to you whether to accept unconfirmed transactions or not. It is likely they'll be " +
                                        "confirmed in short order, but there is still a possibility they might not, so for larger " +
                                        "values you may want to wait for one or more confirmation(s).</p>"
                                    );
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
                    anchors.margins: 1 * scaleRatio

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
            Layout.preferredHeight: 40 * scaleRatio
            anchors.left: parent.left
            anchors.right: parent.right

            Item {
                width: (parent.width - qrImg.width) - (50 * scaleRatio)
                height: 32 * scaleRatio

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12 * scaleRatio
                    font.bold: false
                    color: "white"
                    text: "<style type='text/css'>a {text-decoration: none; color: #FF6C3C; font-size: 12px;}</style>Currently selected address: " + addressLabel + " <a href='#'>(Change)</a>"
                    textFormat: Text.RichText

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
                width: 220 * scaleRatio
                height: 32 * scaleRatio

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 12 * scaleRatio
                    font.bold: false
                    color: "white"
                    text: qsTr("(right-click, save as)")
                }
            }
        }

        Item {
            Layout.preferredHeight: 120 * scaleRatio
            Layout.topMargin: 20 * scaleRatio
            Layout.fillWidth: true

            Rectangle {
                id: payment_url_container
                anchors.left: parent.left
                anchors.top: parent.top
                implicitHeight: 120 * scaleRatio
                width: (parent.width - qrImg.width) - (50 * scaleRatio)
                radius: 5

                ColumnLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    RowLayout {
                        spacing: 0
                        height: 56 * scaleRatio

                        RowLayout {
                            Layout.alignment: Qt.AlignLeft
                            Layout.preferredWidth: 260 * scaleRatio
                            Layout.preferredHeight: parent.height
                            Layout.fillHeight: true
                            spacing: 8

                            Item {
                                Layout.preferredWidth: 10 * scaleRatio
                            }

                            Text {
                                font.pixelSize: 14 * scaleRatio
                                font.bold: true
                                color: "#767676"
                                text: qsTr("Payment URL")
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        // @TODO: PaymentURL explanation
//                        Rectangle {
//                            // help box
//                            Layout.alignment: Qt.AlignLeft
//                            Layout.preferredWidth: 40 * scaleRatio
//                            Layout.fillHeight: true
//                            color: "transparent"

//                            Text {
//                                anchors.verticalCenter: parent.verticalCenter
//                                anchors.right: parent.right
//                                anchors.rightMargin: 20 * scaleRatio
//                                font.pixelSize: 16 * scaleRatio
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

                    Text {
                        property string _color: "#767676"
                        Layout.fillWidth: true
                        Layout.margins: 20 * scaleRatio
                        Layout.topMargin: 10 * scaleRatio

                        wrapMode: Text.WrapAnywhere
                        elide: Text.ElideRight

                        font.pixelSize: 12 * scaleRatio
                        font.bold: true
                        color: _color
                        text: TxUtils.makeQRCodeString(appWindow.current_address, amountToReceive.text)

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
                width: 220 * scaleRatio
                height: 32 * scaleRatio

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Text {
                        font.pixelSize: 14 * scaleRatio
                        font.bold: false
                        color: "white"
                        text: qsTr("Amount to receive") + " (XMR)"
                    }

                    Image {
                        height: 28 * scaleRatio
                        width: 220 * scaleRatio
                        source: "../../images/merchant/input_box.png"

                        TextField {
                            id: amountToReceive
                            topPadding: 0
                            leftPadding: 10 * scaleRatio

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: 3 * scaleRatio
                            font.pixelSize: 16 * scaleRatio
                            font.bold: true
                            horizontalAlignment: TextInput.AlignLeft
                            verticalAlignment: TextInput.AlignVCenter
                            selectByMouse: true
                            color: "#424242"
                            selectionColor: "#3f3fe3"
                            selectedTextColor: "white"

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
                        height: 2 * scaleRatio
                        width: 220 * scaleRatio
                    }

                    Text {
                        // @TODO: When we have XMR/USD rate avi. in the future.
                        visible: false
                        font.pixelSize: 14 * scaleRatio
                        font.bold: false
                        color: "white"
                        text: qsTr("Amount to receive") + " (USD)"
                        opacity: 0.2
                    }

                    Image {
                        visible: false
                        height: 28 * scaleRatio
                        width: 220 * scaleRatio
                        source: "../../images/merchant/input_box.png"
                        opacity: 0.2
                    }
                }
            }
        }

        Item {
            Layout.topMargin: 32 * scaleRatio
            Layout.preferredHeight: 40 * scaleRatio
            anchors.left: parent.left
            anchors.right: parent.right

            ColumnLayout {
                spacing: 16 * scaleRatio

                MerchantCheckbox {
                    id: trackingCheckbox
                    checked: root.enableTracking
                    text: qsTr("Enable sales tracker")

                    onChanged: {
                        root.enableTracking = this.checked;
                    }
                }

                Text {
                    id: content
                    font.pixelSize: 14 * scaleRatio
                    font.bold: false
                    color: "white"
                    text: qsTr("Leave this page")

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: appWindow.showPageRequest("Receive")
                    }
                }
            }
        }
    }

    Rectangle {
        // Shows when the window is too small
        visible: parent.width < root.minWidth
        anchors.top: parent.top
        anchors.topMargin: 100 * scaleRatio;
        anchors.horizontalCenter: parent.horizontalCenter
        height: 120 * scaleRatio
        width: 400 * scaleRatio
        radius: 5

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 14 * scaleRatio
            font.bold: true
            color: MoneroComponents.Style.moneroGrey
            text: qsTr("The merchant page requires a larger window")
        }
    }

    function update() {
        const max_tracking = 3;

        if (!appWindow.currentWallet || !root.enableTracking) {
            root.trackingError = "";
            trackingModel.clear();
            return
        }

        if (appWindow.currentWallet.connected() == Wallet.ConnectionStatus_Disconnected) {
            root.trackingError = qsTr("WARNING: no connection to daemon");
            trackingModel.clear();
            return
        }

        var model = appWindow.currentWallet.historyModel
        var count = model.rowCount()
        var totalAmount = 0
        var nTransactions = 0
        var blockchainHeight = null
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
                var amount = model.data(idx, TransactionHistoryModel.TransactionAtomicAmountRole);
                totalAmount = walletManager.addi(totalAmount, amount)
                nTransactions += 1

                var txid = model.data(idx, TransactionHistoryModel.TransactionHashRole);
                var blockHeight = model.data(idx, TransactionHistoryModel.TransactionBlockHeightRole);

                var in_txpool = false;
                var confirmations = 0;
                var displayAmount = 0;

                if (blockHeight == 0) {
                    in_txpool = true;
                } else {
                    if (blockchainHeight == null)
                        blockchainHeight = appWindow.currentWallet.blockChainHeight()
                    confirmations = blockchainHeight - blockHeight - 1
                    displayAmount = model.data(idx, TransactionHistoryModel.TransactionDisplayAmountRole);
                }

                txs.push({
                    "amount": displayAmount,
                    "confirmations": confirmations,
                    "blockheight": blockHeight,
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
                "blockheight": tx.blockheight,
                "confirmations": tx.confirmations,
                "blockheight": tx.blockHeight,
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
