// Copyright (c) 2014-2020, The Monero Project
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
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import moneroComponents.Clipboard 1.0
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Window 2.0

import "../components" as MoneroComponents
import "effects/" as MoneroEffects

Rectangle {
    id: root
    x: parent.width/2 - root.width/2
    y: parent.height/2 - root.height/2
    z: parent.z + 1
    // TODO: implement without hardcoding sizes
    width: 580
    height: 400
    color: MoneroComponents.Style.blackTheme ? "black" : "white"
    visible: false
    radius: 10
    border.color: MoneroComponents.Style.blackTheme ? Qt.rgba(255, 255, 255, 0.25) : Qt.rgba(0, 0, 0, 0.25)
    border.width: 1    

    Clipboard { id: clipboard }

    property var transactionID;

    // same signals as Dialog has
    signal accepted()
    signal rejected()
    signal closeCallback();

    function open(txid) {
        root.transactionID = txid;
        root.visible = true;
        doneButton.forceActiveFocus();
    }

    function close() {
        root.visible = false;
        closeCallback();
    }

    ColumnLayout {
        id: mainLayout
        spacing: 10
        anchors.fill: parent
        anchors.margins: 25

        ColumnLayout{
            id: column
            Layout.topMargin: 10
            Layout.leftMargin: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
          
            MoneroComponents.Label {
                id: dialogTitle
                fontSize: 18
                fontFamily: "Arial"
                horizontalAlignment: Text.AlignHCenter
                text: {
                    if (appWindow.viewOnly){
                        return qsTr("Transaction file successfully saved!") + translationManager.emptyString;;
                    } else {
                        return  qsTr("Transaction successfully sent!") + translationManager.emptyString;
                    }
                }
            }  
        }

        Image {
            id: successImage
            Layout.alignment: Qt.AlignCenter
            width: 140
            height: 140
            source: "qrc:///images/success.png"

            SequentialAnimation{
                running: successImage.visible
                ScaleAnimator { target: successImage; from: 0.4; to: 1.3; duration: 125}
                ScaleAnimator { target: successImage; from: 1.3; to: 1; duration: 80}
            }
        }

        MoneroComponents.LineEditMulti {
            id: transactionIDLabel
            visible: !appWindow.viewOnly
            Layout.leftMargin: 25
            Layout.rightMargin: 25
            borderDisabled: true
            readOnly: true
            copyButton: true
            wrapMode: Text.Wrap
            labelText: qsTr("Transaction ID:") + translationManager.emptyString
            text: root.transactionID ? root.transactionID : "";
            fontSize: 16
        }
        
        MoneroComponents.LineEditMulti {
            id: transactionFilePath
            visible: appWindow.viewOnly
            Layout.leftMargin: 25
            borderDisabled: true
            readOnly: true
            wrapMode: Text.Wrap
            labelText: qsTr("Transaction file location:") + translationManager.emptyString
            text: walletManager.urlToLocalPath(saveTxDialog.fileUrl)
            fontSize: 16
        }

        // open folder / done buttons
        RowLayout {
            id: buttons
            spacing: 70
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            MoneroComponents.StandardButton {
                id: openFolderButton
                visible: appWindow.viewOnly
                text: qsTr("Open folder") + translationManager.emptyString;
                width: 200
                KeyNavigation.tab: doneButton
                Keys.enabled: openFolderButton.visible
                Keys.onReturnPressed: openFolderButton.onClicked
                Keys.onEnterPressed: openFolderButton.onClicked
                Keys.onEscapePressed: {
                    root.close()
                    root.rejected()
                } 
                onClicked: {
                    oshelper.openContainingFolder(walletManager.urlToLocalPath(saveTxDialog.fileUrl))
                    root.rejected()
                }
            }

            MoneroComponents.StandardButton {
                id: doneButton
                text: qsTr("Done") + translationManager.emptyString;
                width: 200
                focus: true
                KeyNavigation.tab: openFolderButton
                Keys.enabled: doneButton.visible
                Keys.onReturnPressed: doneButton.onClicked
                Keys.onEnterPressed: doneButton.onClicked
                Keys.onEscapePressed: {
                    root.close()
                    root.rejected()
                } 
                onClicked: {
                    root.close()
                    root.accepted()
                }
            }
        }
    }
}
