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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.2

import "../../js/Utils.js" as Utils
import "../../components" as MoneroComponents


Rectangle {
    property alias consoleArea: consoleArea
    color: "transparent"
    Layout.fillWidth: true
    property alias logHeight: settingsLog.height

    ColumnLayout {
        id: settingsLog
        property int itemHeight: 60
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 10

//        Rectangle {
//            // divider
//            Layout.preferredHeight: 1
//            Layout.fillWidth: true
//            Layout.bottomMargin: 8
//            color: MoneroComponents.Style.dividerColor
//            opacity: MoneroComponents.Style.dividerOpacity
//        }

        MoneroComponents.TextPlain {
            Layout.bottomMargin: 2
            color: MoneroComponents.Style.defaultFontColor
            font.pixelSize: 18
            font.family: MoneroComponents.Style.fontRegular.name
            text: qsTr("Log level") + translationManager.emptyString
        }

        ColumnLayout {
            spacing: 10
            Layout.fillWidth: true
            id: logColumn
            z: parent.z + 1

            ListModel {
                 id: logLevel
                 ListElement { column1: "0"; name: "none"; }
                 ListElement { column1: "1"; }
                 ListElement { column1: "2"; }
                 ListElement { column1: "3"; }
                 ListElement { column1: "4"; }
                 ListElement { column1: "custom"; }
            }

            MoneroComponents.StandardDropdown {
                id: logLevelDropdown
                dataModel: logLevel
                itemTopMargin: 2
                currentIndex: appWindow.persistentSettings.logLevel;
                onChanged: {
                    if (currentIndex == 5) {
                        console.log("log categories changed: ", logCategories.text);
                        walletManager.setLogCategories(logCategories.text);
                    }
                    else {
                        console.log("log level changed: ",currentIndex);
                        walletManager.setLogLevel(currentIndex);
                    }
                    appWindow.persistentSettings.logLevel = currentIndex;
                }
                Layout.fillWidth: true
                Layout.preferredWidth: logColumn.width
                z: parent.z + 1
            }

            MoneroComponents.LineEdit {
                id: logCategories
                visible: logLevelDropdown.currentIndex === 5
                Layout.fillWidth: true
                Layout.preferredWidth: logColumn.width
                text: appWindow.persistentSettings.logCategories
                placeholderText: "(e.g. *:WARNING,net.p2p:DEBUG)"
                placeholderFontSize: 14
                fontSize: 14
                enabled: logLevelDropdown.currentIndex === 5
                onEditingFinished: {
                    if(enabled) {
                        console.log("log categories changed: ", text);
                        walletManager.setLogCategories(text);
                        appWindow.persistentSettings.logCategories = text;
                    }
                }
            }
        }

        MoneroComponents.TextPlain {
            Layout.topMargin: 10
            Layout.bottomMargin: 2
            color: MoneroComponents.Style.defaultFontColor
            font.pixelSize: 18
            font.family: MoneroComponents.Style.fontRegular.name
            text: qsTr("Daemon log") + translationManager.emptyString
            themeTransition: false
            onColorChanged: {
                var flickableContentYBefore = flickable.contentY
                var daemonLogText = consoleArea.text
                consoleArea.clear();
                if (MoneroComponents.Style.blackTheme) {
                    consoleArea.append(daemonLogText.replace(/#000000/g, '#ffffff').replace(/#008000/g, '#00ff00'));
                } else {
                    consoleArea.append(daemonLogText.replace(/#ffffff/g, '#000000').replace(/#00ff00/g, '#008000'));
                }
                flickable.contentY = flickableContentYBefore
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredHeight: 240

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: MoneroComponents.Style.inputBorderColorInActive
                border.width: 1
                radius: 4
            }

            Flickable {
                id: flickable
                anchors.fill: parent
                boundsBehavior: isMac ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

                TextArea.flickable: TextArea {
                    id : consoleArea
                    color: MoneroComponents.Style.defaultFontColor
                    selectionColor: MoneroComponents.Style.textSelectionColor
                    textFormat: TextEdit.RichText
                    selectByMouse: true
                    selectByKeyboard: true
                    font.family: MoneroComponents.Style.fontRegular.name
                    font.pixelSize: 14
                    wrapMode: TextEdit.Wrap
                    readOnly: true
                    function logCommand(msg){
                        msg = log_color(msg, MoneroComponents.Style.blackTheme ? "lime" : "green");
                        consoleArea.append(msg);
                    }
                    function logMessage(msg){
                        msg = msg.trim();
                        var color = MoneroComponents.Style.defaultFontColor;
                        if(msg.toLowerCase().indexOf('error') >= 0){
                            color = MoneroComponents.Style.errorColor;
                        } else if (msg.toLowerCase().indexOf('warning') >= 0){
                            color = "#fa6800"
                        }

                        // format multi-lines
                        if(msg.split("\n").length >= 2){
                            msg = msg.split("\n").join('<br>');
                        }

                        log(msg, color);
                    }
                    function log_color(msg, color){
                        return "<span style='color: " + color +  ";' >" + msg + "</span>";
                    }
                    function log(msg, color){
                        var timestamp = Utils.formatDate(new Date(), {
                            weekday: undefined,
                            month: "numeric",
                            timeZoneName: undefined
                        });

                        var _timestamp = log_color("[" + timestamp + "]", MoneroComponents.Style.defaultFontColor);
                        var _msg = log_color(msg, color);
                        consoleArea.append(_timestamp + " " + _msg);

                        // scroll to bottom
                        //if(flickable.contentHeight > content.height){
                        //    flickable.contentY = flickable.contentHeight;
                        //}
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    onActiveChanged: if (!active && !isMac) active = true
                    policy: isMac ? ScrollBar.AsNeeded : ScrollBar.AlwaysOn
                }
            }
        }

        MoneroComponents.LineEdit {
            id: sendCommandText
            Layout.fillWidth: true
            inputPaddingTop: 0
            inputPaddingBottom: 0
            property var lastCommands: []
            property int currentCommandIndex
            enabled: !persistentSettings.useRemoteNode
            fontBold: false
            fontSize: 16
            placeholderText: qsTr("Type a command (e.g '%1' or '%2') and press Enter").arg("help").arg("status") + translationManager.emptyString
            placeholderFontSize: 16
            Keys.onUpPressed: {
                if (currentCommandIndex != 0) {
                    sendCommandText.text = lastCommands[currentCommandIndex - 1]
                    currentCommandIndex = currentCommandIndex - 1
                }
            }
            Keys.onDownPressed: {
                if (currentCommandIndex == lastCommands.length - 1) {
                    currentCommandIndex = lastCommands.length;
                    return text = "";
                }
                if (currentCommandIndex != lastCommands.length) {
                    sendCommandText.text = lastCommands[currentCommandIndex + 1]
                    currentCommandIndex = currentCommandIndex + 1
                }
            }
            onAccepted: {
                if(text.length > 0) {
                    consoleArea.logCommand(">>> " + text)
                    daemonManager.sendCommandAsync(text.split(" "), currentWallet.nettype, persistentSettings.blockchainDataDir, function(result) {
                        if (!result) {
                            appWindow.showStatusMessage(qsTr("Failed to send command"), 3);
                        }
                    });
                }
                lastCommands.push(text);
                currentCommandIndex = lastCommands.length;
                text = ""
            }
        }
    }

    Component.onCompleted: {
        if(typeof daemonManager != "undefined")
            daemonManager.daemonConsoleUpdated.connect(onDaemonConsoleUpdated)
    }
}
