// Copyright (c) 2014-2018, The Monero Project
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

import QtQuick 2.9
import QtMultimedia 5.4
import QtQuick.Dialogs 1.2
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

    states: [
        State {
            name: "Capture"
            StateChangeScript {
                script: {
		    root.visible = true
                    camera.captureMode = Camera.CaptureStillImage
                    camera.start()
                    finder.enabled = true
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
        captureMode: Camera.CaptureStillImage

        focus {
            focusMode: Camera.FocusContinuous
        }
    }
    QRCodeScanner {
        id : finder
        objectName: "QrFinder"
        onDecoded : {
            root.qrcode_decoded(address, payment_id, amount, tx_description, recipient_name, extra_parameters)
            root.state = "Stopped"
	}
        onNotifyError : {
            if( warning )
                messageDialog.icon = StandardIcon.Critical
            else {
                messageDialog.icon = StandardIcon.Warning
                root.state = "Stopped"
            }
            messageDialog.text = error
            messageDialog.visible = true
        }
    }

    VideoOutput {
        id: viewfinder
        visible: root.state == "Capture"

        x: 0
        y: 0
        z: parent.z+1
        width: parent.width
        height: parent.height

        source: camera
        autoOrientation: true

        MouseArea {
            anchors.fill: parent
            propagateComposedEvents: true
            onPressAndHold: {
                if (camera.lockStatus == Camera.locked)camera.unlock()
                camera.searchAndLock()
            }
            onDoubleClicked: {
                root.state = "Stopped"
            }
        }
    }

    MessageDialog {
        id: messageDialog
        title: qsTr("QrCode Scanned")  + translationManager.emptyString
        onAccepted: {
            root.state = "Stopped"
        }
    }

    Component.onCompleted: {
        if( QtMultimedia.availableCameras.length == 0) {
            console.log("No camera available. Disable qrScannerEnabled");
            appWindow.qrScannerEnabled = false;
        }
    }
}
