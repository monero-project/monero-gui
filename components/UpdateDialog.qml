// Copyright (c) 2020-2024, The Monero Project
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
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

import moneroComponents.Downloader 1.0

import "../components" as MoneroComponents

Popup {
    id: updateDialog

    property bool active: false
    property bool allowed: true
    property string error: ""
    property string filename: ""
    property string hash: ""
    property double progress: url && downloader.total > 0 ? downloader.loaded * 100 / downloader.total : 0
    property string url: ""
    property bool valid: false
    property string version: ""

    background: Rectangle {
        border.color: MoneroComponents.Style.appWindowBorderColor
        border.width: 1
        color: MoneroComponents.Style.middlePanelBackgroundColor
    }
    closePolicy: Popup.NoAutoClose
    padding: 20
    visible: active && allowed

    function show(version, url, hash) {
        updateDialog.error = "";
        updateDialog.hash = hash;
        updateDialog.url = url;
        updateDialog.valid = false;
        updateDialog.version = version;
        updateDialog.active = true;
    }

    ColumnLayout {
        id: mainLayout
        spacing: updateDialog.padding

        Text {
            color: MoneroComponents.Style.defaultFontColor
            font.bold: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 18
            text: qsTr("New Monero version v%1 is available.").arg(updateDialog.version)
        }

        Text {
            id: errorText
            color: "red"
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 18
            text: updateDialog.error
            visible: text
        }

        Text {
            id: statusText
            color: updateDialog.valid ? MoneroComponents.Style.green : MoneroComponents.Style.defaultFontColor
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 18
            visible: !errorText.visible

            text: {
                if (!updateDialog.url) {
                    return qsTr("Please visit getmonero.org for details") + translationManager.emptyString;
                }
                if (downloader.active) {
                    return "%1 (%2%)"
                        .arg(qsTr("Downloading"))
                        .arg(updateDialog.progress.toFixed(1))
                        + translationManager.emptyString;
                }
                if (updateDialog.valid) {
                    return qsTr("Update downloaded, signature verified") + translationManager.emptyString;
                }
                return qsTr("Do you want to download and verify new version?") + translationManager.emptyString;
            }
        }

        Rectangle {
            id: progressBar
            color: MoneroComponents.Style.lightGreyFontColor
            height: 3
            Layout.fillWidth: true
            visible: updateDialog.valid || downloader.active

            Rectangle {
                color: MoneroComponents.Style.buttonBackgroundColor
                height: parent.height
                width: parent.width * updateDialog.progress / 100
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: parent.spacing

            MoneroComponents.StandardButton {
                id: cancelButton
                fontBold: false
                primary: !updateDialog.url
                text: {
                    if (!updateDialog.url) {
                        return qsTr("Ok") + translationManager.emptyString;
                    }
                    if (updateDialog.valid || downloader.active || errorText.visible) {
                        return qsTr("Cancel")  + translationManager.emptyString;
                    }
                    return qsTr("Download later") + translationManager.emptyString;
                }

                onClicked: {
                    downloader.cancel();
                    updateDialog.active = false;
                }
            }

            MoneroComponents.StandardButton {
                id: downloadButton
                KeyNavigation.tab: cancelButton
                fontBold: false
                text: (updateDialog.error ? qsTr("Retry") : qsTr("Download")) + translationManager.emptyString
                visible: updateDialog.url && !updateDialog.valid && !downloader.active

                onClicked: {
                    updateDialog.error = "";
                    updateDialog.filename = updateDialog.url.replace(/^.*\//, '');
                    const downloadingStarted = downloader.get(updateDialog.url, updateDialog.hash, function(error) {
                        if (error) {
                            console.error("Download failed", error);
                            updateDialog.error = qsTr("Download failed") + translationManager.emptyString;
                        } else {
                            updateDialog.valid = true;
                        }
                    });
                    if (!downloadingStarted) {
                        updateDialog.error = qsTr("Failed to start download") + translationManager.emptyString;
                    }
                }
            }

            MoneroComponents.StandardButton {
                id: saveButton
                KeyNavigation.tab: cancelButton
                fontBold: false
                onClicked: {
                    const fullPath = oshelper.openSaveFileDialog(
                        qsTr("Save as") + translationManager.emptyString,
                        oshelper.downloadLocation(),
                        updateDialog.filename);
                    if (!fullPath) {
                        return;
                    }
                    if (downloader.saveToFile(fullPath)) {
                        cancelButton.clicked();
                        oshelper.openContainingFolder(fullPath);
                    } else {
                        updateDialog.error = qsTr("Save operation failed") + translationManager.emptyString;
                    }
                }
                text: qsTr("Save to file") + translationManager.emptyString
                visible: updateDialog.valid
            }
        }
    }

    Downloader {
        id: downloader
        proxyAddress: persistentSettings.getProxyAddress()
    }
}
