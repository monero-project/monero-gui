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
    property bool walletRestoreMode: false

    function parseWalletRestoreUri(data) {
        var prefix = ""
        if (data.indexOf("monero-wallet:") === 0)
            prefix = "monero-wallet:"
        else if (data.indexOf("monero_wallet:") === 0)
            prefix = "monero_wallet:"
        else
            return null

        var queryOffset = data.indexOf("?")
        var address = data.substring(prefix.length, queryOffset < 0 ? data.length : queryOffset)
        if (!walletManager.addressValid(address, appWindow.persistentSettings.nettype))
            return null

        var params = {}
        if (queryOffset >= 0) {
            var items = data.substring(queryOffset + 1).split("&")
            for (var index = 0; index < items.length; ++index) {
                var separator = items[index].indexOf("=")
                if (separator < 0)
                    continue
                var name = decodeURIComponent(items[index].substring(0, separator))
                var value = decodeURIComponent(items[index].substring(separator + 1))
                if (name === "view_key")
                    params.secret_view_key = value
                else if (name === "spend_key")
                    params.secret_spend_key = value
                else if (name === "height")
                    params.restore_height = value
            }
        }
        return { "address": address, "extra_parameters": params }
    }

    states: [
        State {
            name: "Capture"
            StateChangeScript {
                script: {
		    root.visible = true
                    camera.captureMode = Camera.CaptureStillImage
                    camera.cameraState = Camera.ActiveState
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
                    camera.cameraState = Camera.UnloadedState
                    root.walletRestoreMode = false
                }
            }
        }
    ]

    Camera {
        id: camera
        objectName: "qrCameraQML"
        captureMode: Camera.CaptureStillImage
        cameraState: Camera.UnloadedState

        focus {
            focusMode: Camera.FocusContinuous
        }
    }
    QRCodeScanner {
        id : finder
        objectName: "QrFinder"
        onDecoded : {
            var walletRestore = root.walletRestoreMode ? root.parseWalletRestoreUri(data) : null
            if (walletRestore !== null) {
                root.qrcode_decoded(walletRestore.address, "", "", "", "", walletRestore.extra_parameters)
                root.state = "Stopped"
                return
            }
            const parsed = walletManager.parse_uri_to_object(data);
            if (!parsed.error) {
                root.qrcode_decoded(parsed.address, parsed.payment_id, parsed.amount, parsed.tx_description, parsed.recipient_name, parsed.extra_parameters);
                root.state = "Stopped";
            } else if (walletManager.addressValid(data, appWindow.persistentSettings.nettype)) {
                root.qrcode_decoded(data, "", "", "", "", null);
                root.state = "Stopped";
            } else {
                onNotifyError(parsed.error);
            }
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
