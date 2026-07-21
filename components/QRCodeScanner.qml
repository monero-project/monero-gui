// Copyright (c) 2014-2024, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick
import QtCore
import QtMultimedia
import QtQuick.Dialogs
import moneroComponents.QRCodeScanner 1.0

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

    signal qrcode_decoded(string address, string payment_id, string amount, string tx_description, string recipient_name, var extra_parameters)
    property bool sessionConfigured: false

    function showDecodeError(error, warning) {
        if (!warning)
            root.state = "Stopped"
        messageDialog.text = error
        messageDialog.visible = true
    }

    function startCamera() {
        if (mediaDevices.videoInputs.length === 0) {
            appWindow.qrScannerEnabled = false
            root.state = "Stopped"
            return
        }
        if (!sessionConfigured) {
            if (!finder.setSource(camera) || !finder.setVideoOutput(viewfinder)) {
                appWindow.qrScannerEnabled = false
                root.state = "Stopped"
                return
            }
            sessionConfigured = true
        }
        camera.start()
    }

    CameraPermission {
        id: cameraPermission
    }

    MediaDevices {
        id: mediaDevices

        onVideoInputsChanged: {
            appWindow.qrScannerEnabled = videoInputs.length > 0
            if (videoInputs.length === 0 && root.state === "Capture")
                root.state = "Stopped"
        }
    }

    states: [
        State {
            name: "Capture"
            StateChangeScript {
                script: {
                    if (cameraPermission.status !== Qt.PermissionStatus.Granted) {
                        cameraPermission.request()
                        return
                    }
                    startCamera()
                }
            }
        },
        State {
            name: "Stopped"
            StateChangeScript {
                script: {
                    camera.stop()
		    root.visible = false
                    finder.enabled = false
                }
            }
        }
    ]

    Camera {
        id: camera
        objectName: "qrCameraQML"
        cameraDevice: mediaDevices.defaultVideoInput

        onActiveChanged: {
            if (camera.active && root.state === "Capture") {
                root.visible = true
                finder.enabled = true
            } else if (!camera.active) {
                root.visible = false
                finder.enabled = false
            }
        }
        onErrorOccurred: function(error, errorString) {
            console.error("QR scanner camera error:", error, errorString)
            if (root.state === "Capture") {
                root.state = "Stopped"
                messageDialog.text = errorString
                messageDialog.visible = true
            }
        }
        focusMode: Camera.FocusModeAuto
    }

    QRCodeScanner {
        id : finder
        objectName: "QrFinder"
        onDecoded : (data) => {
            const parsed = walletManager.parse_uri_to_object(data);
            if (!parsed.error) {
                root.qrcode_decoded(parsed.address, parsed.payment_id, parsed.amount, parsed.tx_description, parsed.recipient_name, parsed.extra_parameters);
                root.state = "Stopped";
            } else if (walletManager.addressValid(data, appWindow.persistentSettings.nettype)) {
                root.qrcode_decoded(data, "", "", "", "", null);
                root.state = "Stopped";
            } else {
                root.showDecodeError(parsed.error, false)
            }
        }
        onNotifyError : (error, warning) => {
            root.showDecodeError(error, warning)
        }
    }

    VideoOutput {
        id: viewfinder
        visible: camera.active

        x: 0
        y: 0
        z: parent.z+1
        width: parent.width
        height: parent.height

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onDoubleClicked: {
                root.state = "Stopped"
            }
        }
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("QR Scanner")  + translationManager.emptyString
        onAccepted: {
            root.state = "Stopped"
        }
    }

    Connections {
        target: cameraPermission
        function onStatusChanged() {
            if (cameraPermission.status === Qt.PermissionStatus.Granted && root.state === "Capture") {
                startCamera()
            } else if (cameraPermission.status === Qt.PermissionStatus.Denied && root.state === "Capture") {
                root.state = "Stopped"
                messageDialog.text = qsTr("Camera permission was denied.") + translationManager.emptyString
                messageDialog.visible = true
            }
        }
    }

    Component.onCompleted: {
        appWindow.qrScannerEnabled = mediaDevices.videoInputs.length > 0
    }
}
