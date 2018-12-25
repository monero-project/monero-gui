// Copyright (c) 2014-2015, The Monero Project
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

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import moneroComponents.Clipboard 1.0
import moneroComponents.PendingTransaction 1.0
import moneroComponents.Wallet 1.0

import "." as MoneroComponents


Rectangle{
    Clipboard { id: clipboard }

    width: label1.width > label2.width ? label1.width : label2.width
    height: label1.height + label2.height
    color: "transparent"

    property string copyValue: ""
    property string hashValue: ""
    property alias labelHeader: label1.text
    property alias labelValue: label2.text
    property alias labelHeaderIcon: icon
    property alias labelHeaderIconImageSource: icon.imageSource

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2 * scaleRatio

        RowLayout {
            Layout.fillWidth: true

            Text {
                id: label1
                font.family: MoneroComponents.Style.fontRegular.name
                font.pixelSize: 14 * scaleRatio
                text: labelHeader
                color: MoneroComponents.Style.dimmedFontColor
            }

            MoneroComponents.IconButton {
                id: icon
                visible: imageSource !== ""
                Layout.leftMargin: 8 * scaleRatio
                width: image.width
                height: image.height

                onClicked: {
                        editDescription(hashValue);
                }
            }
        }

        Text {
            id: label2
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14 * scaleRatio
            text: labelValue
            color: MoneroComponents.Style.dimmedFontColor

            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onEntered: {
                    label1.color = MoneroComponents.Style.defaultFontColor;
                    label2.color = MoneroComponents.Style.defaultFontColor;
                }

                onExited: {
                    label1.color = MoneroComponents.Style.dimmedFontColor;
                    label2.color = MoneroComponents.Style.dimmedFontColor;
                }

                onClicked: {
                    if(copyValue){
                        console.log("Copied to clipboard");
                        clipboard.setText(copyValue);
                        appWindow.showStatusMessage(qsTr("Copied to clipboard"),3)
                    }
                }
            }
        }
    }

    function editDescription(_hash){
        inputDialog.labelText = qsTr("Set description:") + translationManager.emptyString;
        inputDialog.onAcceptedCallback = function() {
            appWindow.currentWallet.setUserNote(_hash, inputDialog.inputText);
            appWindow.showStatusMessage(qsTr("Updated description."),3);
            middlePanel.historyView.update();
        }
        inputDialog.onRejectedCallback = null;
        inputDialog.open()
    }
}
