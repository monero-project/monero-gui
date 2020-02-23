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
    color: "transparent"
    visible: false

    Clipboard { id: clipboard }

    property var icon;
    property var lastTransaction: [];

    // same signals as Dialog has
    signal accepted()
    signal rejected()
    signal closeCallback();

    // background
    MoneroEffects.GradientBackground {
        anchors.fill: parent
        fallBackColor: MoneroComponents.Style.middlePanelBackgroundColor
        initialStartColor: MoneroComponents.Style.middlePanelBackgroundGradientStart
        initialStopColor: MoneroComponents.Style.middlePanelBackgroundGradientStop
        blackColorStart: MoneroComponents.Style._b_middlePanelBackgroundGradientStart
        blackColorStop: MoneroComponents.Style._b_middlePanelBackgroundGradientStop
        whiteColorStart: MoneroComponents.Style._w_middlePanelBackgroundGradientStart
        whiteColorStop: MoneroComponents.Style._w_middlePanelBackgroundGradientStop
        start: Qt.point(0, 0)
        end: Qt.point(height, width)
    }

    // Make window draggable
    MouseArea {
        anchors.fill: parent
        property point lastMousePos: Qt.point(0, 0)
        onPressed: { lastMousePos = Qt.point(mouseX, mouseY); }
        onMouseXChanged: root.x += (mouseX - lastMousePos.x)
        onMouseYChanged: root.y += (mouseY - lastMousePos.y)
    }

    function open() {
        // Center
        root.x = parent.width/2 - root.width/2
        root.y = 100
        root.z = 11
        root.visible = true;

        doneButton.forceActiveFocus();

        //creating lastTransaction property, which will be used by View progress button to search txid in History page
        var lastTransaction = new Array (0);
        lastTransaction.push(appWindow.transactionAddress);
        lastTransaction.push(appWindow.transactionID);
        appWindow.lastTransaction = lastTransaction;
    }

    function close() {
        root.visible = false;
        closeCallback();
    }

    // TODO: implement without hardcoding sizes
    width: 580
    height: 400

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
                    text: appWindow.viewOnly ? qsTr("Transaction file successfully saved!") : qsTr("Transaction successfully sent!") + translationManager.emptyString;
                    color: MoneroComponents.Style.defaultFontColor
                }  
        }

        Image {
            id: successImage
            Layout.alignment: Qt.AlignCenter
            width: 260
            height: 135
            source: "qrc:///images/success.png"

            SequentialAnimation{
                running: successImage.visible
                ScaleAnimator { target: successImage; from: 0.4; to: 1.3; duration: 125}
                ScaleAnimator { target: successImage; from: 1.3; to: 1; duration: 80}
            }
        }

        MoneroComponents.LineEditMulti {
            id: transactionID
            visible: !appWindow.viewOnly
            Layout.leftMargin: 25
            Layout.rightMargin: 25
            borderDisabled: true
            readOnly: true
            copyButton: true
            wrapMode: Text.Wrap
            labelText: qsTr("Transaction ID:") + translationManager.emptyString
            text: appWindow.transactionID ? appWindow.transactionID : "";
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

        // view progress / open folder / done buttons
        RowLayout {
            id: buttons
            spacing: 70
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            MoneroComponents.StandardButton {
                id: viewProgressButton
                visible: !appWindow.viewOnly
                text: qsTr("View progress") + translationManager.emptyString;
                width: 200
                KeyNavigation.tab: doneButton
                Keys.enabled: viewProgressButton.visible
                Keys.onReturnPressed: viewProgressButton.onClicked
                Keys.onEnterPressed: viewProgressButton.onClicked
                Keys.onEscapePressed: {
                    root.close()
                    root.rejected()
                } 
                onClicked: {
                    doSearchInHistory(appWindow.transactionID);
                    root.close()
                    root.rejected()
                }
            }

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
                KeyNavigation.tab: appWindow.viewOnly ? openFolderButton : viewProgressButton
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

    // window borders
    Rectangle{
        width: 1
        color: MoneroComponents.Style.grey
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    Rectangle{
        width: 1
        color: MoneroComponents.Style.grey
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    Rectangle{
        height: 1
        color: MoneroComponents.Style.grey
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    Rectangle{
        height: 1
        color: MoneroComponents.Style.grey
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
    }
}
