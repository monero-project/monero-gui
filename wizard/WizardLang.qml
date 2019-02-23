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

import QtQuick 2.7
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.XmlListModel 2.0
import QtQuick.Controls 2.0

import "../js/Wizard.js" as Wizard
import "../components" as MoneroComponents

Rectangle {
    id: langScreen
    color: "transparent"
    anchors.fill: parent
    property int layoutScale: {
        if(isMobile){
            return 0;
        } else if(appWindow.width < 800){
            return 1;
        } else {
            return 2;
        }
    }

    Image {
        anchors.fill: parent
        source: "../images/middlePanelBg.jpg"
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.topMargin: persistentSettings.customDecorations ? 90 * scaleRatio : 32 * scaleRatio
        width: parent.width - 100 * scaleRatio
        anchors.horizontalCenter: parent.horizontalCenter;

        TextArea {
            text: qsTr("Language settings") + translationManager.emptyString
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            color: MoneroComponents.Style.defaultFontColor
            font.pixelSize: {
                if(langScreen.layoutScale === 2 ){
                    return 34 * scaleRatio;
                } else {
                    return 28 * scaleRatio;
                }
            }

            selectionColor: MoneroComponents.Style.dimmedFontColor
            selectedTextColor: MoneroComponents.Style.defaultFontColor

            selectByMouse: true
            wrapMode: Text.WordWrap
            textMargin: 0
            leftPadding: 0
            topPadding: 0
            bottomPadding: 0
            readOnly: true
        }

        TextArea {
            Layout.fillWidth: true
            visible: parent.subtitle !== ""

            color: MoneroComponents.Style.dimmedFontColor
            text: qsTr("Change the language of the Monero GUI.") + translationManager.emptyString

            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: {
                if(langScreen.layoutScale === 2 ){
                    return 16 * scaleRatio;
                } else {
                    return 14 * scaleRatio;
                }
            }

            selectionColor: MoneroComponents.Style.dimmedFontColor
            selectedTextColor: MoneroComponents.Style.defaultFontColor

            selectByMouse: true
            wrapMode: Text.WordWrap
            textMargin: 0
            leftPadding: 0
            topPadding: 0
            readOnly: true
        }

        Flow {
            id: flow
            height: 800 * scaleRatio
            Layout.fillWidth: true
            Layout.topMargin: 20 * scaleRatio

            spacing: 5 * scaleRatio

            Repeater {
                model: langModel
                delegate: Rectangle {
                    id: item
                    color: "transparent"
                    width: {
                        var minimumWidth = img.width + langRect.width;
                        if(minimumWidth < 200 * scaleRatio) return 200 * scaleRatio;
                        return minimumWidth;
                    }

                    height: 48 * scaleRatio

                    Rectangle {
                        id: img
                        anchors.top: parent.top
                        color: "transparent"
                        width: 32 * scaleRatio
                        height: parent.height

                        Image {
                            source: flag
                            mipmap: true
                            smooth: true
                            width: 32 * scaleRatio
                            height: 32 * scaleRatio
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    Rectangle {
                        id: langRect
                        anchors.top: parent.top
                        anchors.left: img.right
                        color: "transparent"
                        height: parent.height
                        width: langText.width + 22 * scaleRatio

                        Text {
                            id: langText
                            font.bold: true
                            font.pixelSize: 14 * scaleRatio
                            color: MoneroComponents.Style.defaultFontColor
                            text: display_name
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

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

                            appWindow.showStatusMessage(qsTr("Language changed."), 3);
                            appWindow.toggleLanguageView();
                        }
                        hoverEnabled: true
                        onEntered: {
                            parent.opacity = 0.75
                        }
                        onExited: {
                            parent.opacity = 1
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 32 * scaleRatio
            spacing: 20 * scaleRatio

            MoneroComponents.StandardButton {
                small: true
                text: qsTr("Close") + translationManager.emptyString

                onClicked: {
                    appWindow.toggleLanguageView();
                }
            }
        }

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
}
