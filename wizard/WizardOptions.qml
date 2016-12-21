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

import QtQuick 2.2
import QtQml 2.2
import QtQuick.Layouts 1.1
import "../components"

Item {
    id: page
    signal createWalletClicked()
    signal recoveryWalletClicked()
    signal openWalletClicked()
    opacity: 0
    visible: false
    property var buttonSize: 190

    function saveDaemonAddress() {
        wizard.settings["daemon_address"] = daemonAddress.text
        wizard.settings["testnet"] = testNet.checked
    }

    QtObject {
        id: d
        readonly property string daemonAddressTestnet : "localhost:38081"
        readonly property string daemonAddressMainnet : "localhost:18081"
    }

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.InQuad }
    }

    onOpacityChanged: visible = opacity !== 0

    Column {
        id: headerColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 74
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 24

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 28
            //renderType: Text.NativeRendering
            color: "#3F3F3F"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Welcome to Monero!") + translationManager.emptyString
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            font.family: "Arial"
            font.pixelSize: 18
            //renderType: Text.NativeRendering
            color: "#4A4646"
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Please select one of the following options:") + translationManager.emptyString
        }
    }

    Row {
        id: selectPath
        anchors.verticalCenterOffset: 35
        anchors.centerIn: parent
        spacing: 40


        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30

            Rectangle {
                width: page.buttonSize; height: page.buttonSize
                radius: page.buttonSize
                color: createWalletArea.containsMouse ? "#DBDBDB" : "#FFFFFF"


                Image {
                    width:page.buttonSize -30
                    height:page.buttonSize -30
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    verticalAlignment: Image.AlignTop
                    anchors.centerIn: parent
                    source: "qrc:///images/createWallet.png"
                }

                MouseArea {
                    id: createWalletArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        page.saveDaemonAddress()
                        page.createWalletClicked()
                    }
                }
            }

            Text {
                font.family: "Arial"
                font.pixelSize: 16
                color: "#4A4949"
                horizontalAlignment: Text.AlignHCenter
                width:page.buttonSize
                wrapMode: Text.WordWrap
                text: qsTr("Create a new wallet") + translationManager.emptyString
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30

            Rectangle {
                width: page.buttonSize; height: page.buttonSize
                radius: page.buttonSize
                color: recoverWalletArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

                Image {
                    width:page.buttonSize -30
                    height:page.buttonSize -30
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                    source: "qrc:///images/recoverWallet.png"
                }

                MouseArea {
                    id: recoverWalletArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        page.saveDaemonAddress()
                        page.recoveryWalletClicked()
                    }
                }
            }

            Text {
                font.family: "Arial"
                font.pixelSize: 16
                color: "#4A4949"
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Restore wallet from 25 word mnemonic seed") + translationManager.emptyString
                width:page.buttonSize
                wrapMode: Text.WordWrap
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 30

            Rectangle {
                width: page.buttonSize; height: page.buttonSize
                radius: page.buttonSize
                color: openWalletArea.containsMouse ? "#DBDBDB" : "#FFFFFF"

                Image {
                    width:page.buttonSize -30
                    height:page.buttonSize -30
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                    source: "qrc:///images/openAccount.png"
                }

                MouseArea {
                    id: openWalletArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        page.saveDaemonAddress()
                        page.openWalletClicked()
                    }
                }
            }

            Text {
                font.family: "Arial"
                font.pixelSize: 16
                color: "#4A4949"
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Open a wallet from file") + translationManager.emptyString
                width:page.buttonSize
                wrapMode: Text.WordWrap
            }
        }



    }



        ColumnLayout {
            anchors.top: selectPath.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 35

            spacing: 5
            Layout.fillWidth: true

            Rectangle {
                Layout.alignment: Qt.AlignCenter
                width: 200
                height: 1
                color: "gray"
            }

            Text {
                Layout.alignment: Qt.AlignCenter
                font.family: "Arial"
                font.pixelSize: 16

                color: "#4A4646"
                wrapMode: Text.Wrap
                text: qsTr("Custom daemon address (optional)")
                                  + translationManager.emptyString
            }

            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignCenter

                LineEdit {
                    id: daemonAddress
                    Layout.alignment: Qt.AlignCenter
                    width: 200
                    fontSize: 14
                    text: testNet.checked ? d.daemonAddressTestnet : d.daemonAddressMainnet
                }

                CheckBox {
                    id: testNet
                    Layout.alignment: Qt.AlignCenter
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Testnet") + translationManager.emptyString
                    background: "#F0EEEE"
                    fontColor: "#4A4646"
                    fontSize: 16
                    checkedIcon: "../images/checkedVioletIcon.png"
                    uncheckedIcon: "../images/uncheckedIcon.png"
                    checked: false
                }
            }
        }

}

