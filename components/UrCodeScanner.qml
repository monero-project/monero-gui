import QtQuick 2.9
import QtQml.Models 2.2
import QtMultimedia 5.4
import QtQuick.Dialogs 1.2
import OtsUr 0.1
import "." as MoneroComponents

Rectangle {
    id : root

    x: 0
    y: 0
    z: parent.z+1
    width: parent.width
    height: parent.height

    visible: false
    color: "black"
    state: "Stopped"

    property bool active: false
    property bool ur: true
    property string errorMessage: ""

    signal canceled()
    signal qrCode(string data)
    signal wallet(MoneroWalletData walletData)
    signal txData(MoneroTxData data)
    signal unsignedTx(var tx)
    signal signedTx(var tx)
    signal keyImages(var keyImages)
    signal outputs(var outputs)

    states: [
        State {
            name: "Capture"
            when: root.active
            StateChangeScript {
                script: {
                    root.visible = true
                    for(var i = 0; i < QtMultimedia.availableCameras.length; i++)
                        if(QtMultimedia.availableCameras[i].deviceId === persistentSettings.lastUsedCamera) {
                            urCamera.deviceId = persistentSettings.lastUsedCamera
                            break
                        }
                    urCamera.captureMode = Camera.CaptureStillImage
                    urCamera.cameraState = Camera.ActiveState
                    urCamera.start()
                }
            }
        },
        State {
            name: "Stopped"
            when: !root.active
            StateChangeScript {
                script: {
                    urCamera.stop()
                    urScanner.stop()
                    root.ur = true
                    scanProgress.reset()
                    root.visible = false
                    urCamera.cameraState = Camera.UnloadedState
                }
            }
        }
    ]

    ListModel {
        id: availableCameras
        Component.onCompleted: {
            availableCameras.clear()
            for(var i = 0; i < QtMultimedia.availableCameras.length; i++) {
                var cam = QtMultimedia.availableCameras[i]
                availableCameras.append({
                                            column1: cam.displayName,
                                            column2: cam.deviceId,
                                            priority: i
                                        })
            }
        }
    }

    UrCodeScannerImpl {
        id: urScanner
        objectName: "urScanner"
        onQrDataReceived: function(data) {
            root.active = false
        }

        onUrDataReceived: function(type, data) {
            root.active = false
        }

        onUrDataFailed: function(error) {
            root.cancel()
        }
    }

    MoneroComponents.StandardButton {
        id: btnSwitchCamera
        visible: QtMultimedia.availableCameras.length === 2 // if the system has exact to cams, show a switch button
        text: qsTr("Switch Camera")
        z: viewfinder.z + 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.bottomMargin: 20
        onClicked: {
            btnSwitchCamera.visible = false
            urCamera.deviceId = urCamera.deviceId === QtMultimedia.availableCameras[0].deviceId ? QtMultimedia.availableCameras[1].deviceId : QtMultimedia.availableCameras[0].deviceId
            persistentSettings.lastUsedCamera = urCamera.deviceId
            btnSwitchCamera.visible = true
        }
    }

    StandardDropdown {
        id: cameraChooser
        visible: QtMultimedia.availableCameras.length > 2 // if the system has more then 2 cams, show a list
        z: viewfinder.z + 1
        width: 300
        height: 30
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.bottomMargin: 20
        dataModel: availableCameras
        onChanged: {
            urCamera.deviceId = QtMultimedia.availableCameras[cameraChooser.currentIndex].deviceId
            persistentSettings.lastUsedCamera = urCamera.deviceId
        }
    }

    Camera {
        id: urCamera
        objectName: "urCamera"
        captureMode: Camera.CaptureStillImage
        cameraState: Camera.UnloadedState

        focus {
            focusMode: Camera.FocusContinuous
        }
    }

    VideoOutput {
        id: viewfinder
        visible: root.active == true

        x: 0
        y: btnSwitchCamera.height + 40 // 2 x 20 (margin)
        z: parent.z+1
        width: parent.width
        height: parent.height - btnClose.height - btnSwitchCamera.height - 80 // 4 x 20 (margin)

        source: urCamera
        autoOrientation: true
        focus: visible

        MouseArea {
            anchors.fill: parent
            onPressAndHold: {
                if (camera.lockStatus === Camera.locked)camera.unlock()
                camera.searchAndLock()
            }
            onDoubleClicked: root.cancel()
        }

        Rectangle {
            id: scanTypeFrame
            height: scanType.height + 20
            width: scanType.width + 30
            z: parent.z + 1
            radius: 16
            color: "#FA6800"
            opacity: 0.4
            anchors.centerIn: scanType
        }

        Text {
            z: scanTypeFrame.z + 1
            anchors.centerIn: parent
            id: scanType
            text: ""
            font.pixelSize: 22
            color: "white"
            opacity: 0.7
        }

        Rectangle {
            id: unexpectedTypeFrame
            visible: root.errorMessage !== ""
            height: Math.max(unexpectedType.height + 20, scanTypeFrame.height)
            width: Math.max(unexpectedType.width + 30, scanTypeFrame.width)
            z: parent.z + 100
            radius: 3
            color: "black"
            anchors.centerIn: unexpectedType
        }

        Text {
            id: unexpectedType
            visible: unexpectedTypeFrame.visible
            text: root.errorMessage
            z: unexpectedTypeFrame.z + 1
            anchors.centerIn: parent
            font.pixelSize: 22
            color: "#FA6800"
        }

        Rectangle {
            id: scanProgress
            property int scannedFrames: 0
            property int totalFrames: 0
            property int progress: 0
            visible: root.ur
            height: textScanProgress.height + 10
            width: viewfinder.contentRect.width - 40
            z: viewfinder.z + 1
            radius: 20
            color: "#FA6800"
            opacity: 0.4
            anchors.horizontalCenter: viewfinder.horizontalCenter
            anchors.bottom: viewfinder.bottom
            anchors.bottomMargin: 20

            function onScannedFrames(count, total) {
                scanProgress.scannedFrames = count
                scanProgress.totalFrames = total
            }

            function onProgress(complete) {
                scanProgress.progress = Math.floor(complete * 100)
            }

            function reset() {
                scanProgress.scannedFrames = 0
                scanProgress.totalFrames = 0
                scanProgress.progress = 0
            }
        }

        Rectangle {
            id: scanProgressBar
            visible: root.ur && scanProgressBar.width > 36
            height: scanProgress.height - 8
            width: Math.floor((scanProgress.width - 8) * scanProgress.progress / 100)
            x: scanProgress.x + 4
            y: scanProgress.y + 4
            z: scanProgress.z + 1
            color: "#FA6800"
            opacity: 0.8
            radius: 16
        }

        Text {
            id: textScanProgress
            visible: root.ur
            z: scanProgress.z + 2
            anchors.centerIn: scanProgress
            text: (scanProgress.progress > 0 || scanProgress.totalFrames > 0) ? (scanProgress.progress + "% (" + scanProgress.scannedFrames + "/" + scanProgress.totalFrames + ")") : ""
            font.pixelSize: 22
            color: "white"
            opacity: 0.7
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: true
    }

    MoneroComponents.StandardButton {
        id: btnClose
        text: qsTr("Cancel")
        z: viewfinder.z + 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.topMargin: 20
        onClicked: root.cancel()
    }

    function cancel() {
        root.active = false
        root.canceled()
    }

    function scanQrCode() {
        root.ur = false
        root.active = true
        scanType.text = qsTr("Scan QR Code")
        urScanner.qr()
    }

    function scanWallet() {
        root.ur = false
        root.active = true
        scanType.text = qsTr("Scan Wallet QR Code")
        urScanner.scanWallet()
    }

    function scanTxData() {
        root.ur = false
        root.active = true
        scanType.text = qsTr("Scan Tx Data QR Code")
        urScanner.scanTxData()
    }

    function scanOutputs() {
        root.active = true
        scanType.text = qsTr("Scan Outputs UR Code")
        urScanner.scanOutputs()
    }

    function scanKeyImages() {
        root.active = true
        scanType.text = qsTr("Scan Key Images UR Code")
        urScanner.scanKeyImages()
    }

    function scanUnsignedTx() {
        root.active = true
        scanType.text = qsTr("Scan Unsigned Transaction UR Code")
        urScanner.scanUnsignedTx()
    }

    function scanSignedTx() {
        root.active = true
        scanType.text = qsTr("Scan Signed Transaction UR Code")
        urScanner.scanSignedTx()
    }

    function onUnexpectedFrame(urType){
        root.errorMessage = qsTr("Unexpected UR type: ") + urType
    }

    function onDecodedFrame(unused) {
        root.errorMessage = ""
    }

    Component.onCompleted: {
        if( QtMultimedia.availableCameras.length === 0) {
            console.warn("No camera available. Disable qrScannerEnabled")
            appWindow.qrScannerEnabled = false
            return
        }
        urScanner.outputs.connect(root.outputs)
        urScanner.keyImages.connect(root.keyImages)
        urScanner.unsignedTx.connect(root.unsignedTx)
        urScanner.signedTx.connect(root.signedTx)
        urScanner.txData.connect(root.txData)
        urScanner.wallet.connect(root.wallet)
        urScanner.qrCaptureStarted.connect(scanProgress.reset)
        urScanner.scannedFrames.connect(scanProgress.onScannedFrames)
        urScanner.estimatedCompletedPercentage.connect(scanProgress.onProgress)
        urScanner.unexpectedUrType.connect(root.onUnexpectedFrame)
        urScanner.decodedFrame.connect(root.onDecodedFrame)
    }
}
