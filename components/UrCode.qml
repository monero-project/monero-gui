import QtQuick 2.9
import QtMultimedia 5.4
import OtsUr 0.1
import "." as MoneroComponents

Rectangle {
    id : root

    x: 0
    y: 0
    z: parent.z+1
    width: parent.width
    height: parent.height

    property bool active: false
    property bool ur: true

    visible: root.active
    focus: root.active
    color: "black"

    Image {
        id: qrCodeImage
        cache: false
        width: qrCodeImage.height
        height: Math.max(300, Math.min(parent.height - frameInfo.height - displayType.height - 240, parent.width - 40))
        anchors.centerIn: parent
        function reload() {
            var tmp = qrCodeImage.source
            qrCodeImage.source = ""
            qrCodeImage.source = tmp
        }
    }

    Rectangle {
        id: frameInfo
        visible: textFrameInfo.visible
        height: textFrameInfo.height + 5
        width: textFrameInfo.width + 20
        z: parent.z + 1
        radius: 16
        color: "#FA6800"
        anchors.centerIn: textFrameInfo
        opacity: 0.4
    }

    Text {
        id: textFrameInfo
        z: frameInfo.z + 1
        visible: textFrameInfo.text !== ""
        text: urSender.currentFrameInfo
        anchors.top: parent.top
        anchors.horizontalCenter: qrCodeImage.horizontalCenter
        anchors.margins: 30
        font.pixelSize: 22
        color: "white"
        opacity: 0.7
    }

    Rectangle {
        id: displayType
        visible: textDisplayType.text !== ""
        height: textDisplayType.height + 5
        width: textDisplayType.width + 20
        z: parent.z + 1
        radius: 16
        color: "#FA6800"
        anchors.centerIn: textDisplayType
        opacity: 0.4
    }

    Text {
        id: textDisplayType
        visible: displayType.visible
        z: displayType.z + 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: btnClose.top
        anchors.margins: 30
        text: ""
        font.pixelSize: 22
        color: "white"
        opacity: 0.7
    }

    MoneroComponents.StandardButton {
        id: btnClose
        text: qsTr("Close")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.topMargin: 20
        focus: true
        onClicked: root.close()
    }

    Connections {
        target: urSender
        function onUpdateQrCode() {
            qrCodeImage.reload()
        }
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onDoubleClicked: {
            root.close()
        }
    }

    function showQr(text) {
        urSender.sendQrCode(text)
        root.ur = false
        root.active = true
    }

    function showWalletData(address, spendKey, viewKey, mnemonic, height) {
        textDisplayType.text = qsTr("Wallet")
        urSender.sendWallet(address, spendKey, viewKey, mnemonic, height)
        root.ur = false
        root.active = true
    }

    function showTxData(address, amount, paymentId, recipient, description) {
        textDisplayType.text = qsTr("TX Data")
        urSender.sendTx(address, amount, paymentId, recipient, description)
        root.ur = false
        root.active = true
    }

    function showOutputs(outputs) {
        textDisplayType.text = qsTr("Outputs")
        urSender.sendOutputs(outputs)
        root.active = true
    }

    function showKeyImages(keyImages) {
        textDisplayType.text = qsTr("Key Images")
        urSender.sendKeyImages(keyImages)
        root.active = true
    }

    function showUnsignedTx(tx) {
        textDisplayType.text = qsTr("Unsigned TX")
        urSender.sendTxUnsigned(tx)
        root.active = true
    }

    function showSignedTx(tx) {
        textDisplayType.text = qsTr("Signed TX")
        urSender.sendTxSigned(tx)
        root.active = true
    }

    function close() {
        textDisplayType.text = ""
        urSender.sendClear()
        root.ur = true
        root.active = false
    }

    Component.onCompleted: {
        qrCodeImage.source = "image://urcode/qr"
    }
}
