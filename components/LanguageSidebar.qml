// Copyright (c) 2014-2019, The Monero Project
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

import "../components" as MoneroComponents

import QtQuick 2.7
import QtQuick.XmlListModel 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.0


Drawer {
    id: sideBar

    // @TODO: Qt 5.10 introduces `opened` built-in for Drawer
    property bool isOpened: false

    onClosed: {
        isOpened = false;
    }

    onOpened: {
        isOpened = true;
    }

    width: 240 * scaleRatio
    height: parent.height - (persistentSettings.customDecorations ? 50 : 0)
    y: titleBar.height

    background: Rectangle {
        color: "#0d0d0d"
        width: parent.width
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        color: "red"

        ListView {
            clip: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            boundsBehavior: Flickable.StopAtBounds
            width: sideBar.width
            height: sideBar.height

            model: langModel

            delegate: Rectangle {
                id: item
                color: "transparent"
                width: sideBar.width
                height: 32 * scaleRatio

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16 * scaleRatio
                    font.bold: true
                    font.pixelSize: 14 * scaleRatio
                    color: MoneroComponents.Style.defaultFontColor
                    text: display_name
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: MoneroComponents.Style.dividerColor
                    opacity: MoneroComponents.Style.dividerOpacity
                    height: 1
                }

                // button gradient while checked
                Image {
                    anchors.fill: parent
                    source: "../images/menuButtonGradient.png"
                    opacity: 0.65
                    visible: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var locale_spl = locale.split("_");

                            // reload active translations
                            console.log(locale_spl[0]);
                            translationManager.setLanguage(locale_spl[0]);

                            // set wizard language settings
                            wizard.language_locale = locale;
                            wizard.language_wallet = wallet_language;
                            wizard.language_language = display_name + " (" + locale_spl[1] + ") ";
                            sideBar.close()
                        }
                        hoverEnabled: true
                        onEntered: {
                            // item.color = "#26FFFFFF"
                            parent.opacity = 1
                        }
                        onExited: {
                            // item.color = "transparent"
                            parent.opacity = 0.65
                        }
                    }
                }
            }

            ScrollIndicator.vertical: ScrollIndicator {
                // @TODO: QT 5.9 introduces `policy: ScrollBar.AlwaysOn`
                active: true
                contentItem.opacity: 0.7
                onActiveChanged: {
                    if (!active) {
                        active = true;
                    }
                }
            }
        }
    }

    //Flags model
    XmlListModel {
        id: langModel
        source: "/lang/languages.xml"
        query: "/languages/language"

        XmlRole { name: "display_name"; query: "@display_name/string()" }
        XmlRole { name: "locale"; query: "@locale/string()" }
        XmlRole { name: "wallet_language"; query: "@wallet_language/string()" }
        XmlRole { name: "flag"; query: "@flag/string()" }
        // TODO: XmlListModel is read only, we should store current language somewhere else
        // and set current language accordingly
        XmlRole { name: "isCurrent"; query: "@enabled/string()" }

        onStatusChanged: {
            if(status === XmlListModel.Ready){
                console.log("languages available: ",count);
            }
        }
    }
}
