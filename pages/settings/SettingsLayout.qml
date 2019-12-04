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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import "../../js/Utils.js" as Utils
import "../../js/Windows.js" as Windows
import "../../components" as MoneroComponents

Rectangle {
    color: "transparent"
    height: 1400
    Layout.fillWidth: true

    ColumnLayout {
        id: settingsUI
        property int itemHeight: 60
        Layout.fillWidth: true
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 20
        anchors.topMargin: 0
        spacing: 6

        MoneroComponents.CheckBox {
            id: customDecorationsCheckBox
            checked: persistentSettings.customDecorations
            onClicked: Windows.setCustomWindowDecorations(checked)
            text: qsTr("Custom decorations") + translationManager.emptyString
        }

        MoneroComponents.CheckBox {
            id: hideBalanceCheckBox
            checked: persistentSettings.hideBalance
            onClicked: {
                persistentSettings.hideBalance = !persistentSettings.hideBalance
                appWindow.updateBalance();
            }
            text: qsTr("Hide balance") + translationManager.emptyString
        }

        MoneroComponents.CheckBox {
            id: themeCheckbox
            checked: !MoneroComponents.Style.blackTheme
            text: qsTr("Light theme") + translationManager.emptyString
            toggleOnClick: false
            onClicked: {
                MoneroComponents.Style.blackTheme = !MoneroComponents.Style.blackTheme;
                persistentSettings.blackTheme = MoneroComponents.Style.blackTheme;
            }
        }

        MoneroComponents.CheckBox {
            id: userInActivityCheckbox
            checked: persistentSettings.lockOnUserInActivity
            onClicked: persistentSettings.lockOnUserInActivity = !persistentSettings.lockOnUserInActivity
            text: qsTr("Lock wallet on inactivity") + translationManager.emptyString
        }

        ColumnLayout {
            visible: userInActivityCheckbox.checked
            Layout.fillWidth: true
            Layout.topMargin: 6
            Layout.leftMargin: 42
            spacing: 0

            Text {
                color: MoneroComponents.Style.defaultFontColor
                font.pixelSize: 14
                Layout.fillWidth: true
                text: {
                    var val = userInactivitySlider.value;
                    var minutes = val > 1 ? qsTr("minutes") : qsTr("minute");

                    qsTr("After ") + val + " " + minutes + translationManager.emptyString;
                }
            }

            Slider {
                id: userInactivitySlider
                from: 1
                value: persistentSettings.lockOnUserInActivityInterval
                to: 60
                leftPadding: 0
                stepSize: 1
                snapMode: Slider.SnapAlways

                background: Rectangle {
                    x: parent.leftPadding
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 4
                    width: parent.availableWidth
                    height: implicitHeight
                    radius: 2
                    color: MoneroComponents.Style.progressBarBackgroundColor

                    Rectangle {
                        width: parent.visualPosition * parent.width
                        height: parent.height
                        color: MoneroComponents.Style.green
                        radius: 2
                    }
                }

                handle: Rectangle {
                    x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 8
                    color: parent.pressed ? "#f0f0f0" : "#f6f6f6"
                    border.color: MoneroComponents.Style.grey
                }

                onMoved: persistentSettings.lockOnUserInActivityInterval = userInactivitySlider.value;
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        //! Manage pricing
        RowLayout {
            MoneroComponents.CheckBox {
                id: enableConvertCurrency
                text: qsTr("Enable displaying balance in other currencies") + translationManager.emptyString
                checked: persistentSettings.fiatPriceEnabled
                onCheckedChanged: {
                    if (!checked) {
                        console.log("Disabled price conversion");
                        persistentSettings.fiatPriceEnabled = false;
                        appWindow.fiatTimerStop();
                    }
                }
            }
        }

        GridLayout {
            visible: enableConvertCurrency.checked
            columns: 2
            Layout.fillWidth: true
            Layout.leftMargin: 36
            columnSpacing: 32

            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true

                MoneroComponents.Label {
                    Layout.fillWidth: true
                    fontSize: 14
                    text: qsTr("Price source") + translationManager.emptyString
                }

                MoneroComponents.StandardDropdown {
                    id: fiatPriceProviderDropDown
                    Layout.fillWidth: true
                    dataModel: fiatPriceProvidersModel
                    onChanged: {
                        var obj = dataModel.get(currentIndex);
                        persistentSettings.fiatPriceProvider = obj.data;

                        if(persistentSettings.fiatPriceEnabled)
                            appWindow.fiatApiRefresh();
                    }
                }
            }

            ColumnLayout {
                spacing: 10
                Layout.fillWidth: true

                MoneroComponents.Label {
                    Layout.fillWidth: true
                    fontSize: 14
                    text: qsTr("Currency") + translationManager.emptyString
                }

                MoneroComponents.StandardDropdown {
                    id: fiatPriceCurrencyDropdown
                    Layout.fillWidth: true
                    dataModel: fiatPriceCurrencyModel
                    onChanged: {
                        var obj = dataModel.get(currentIndex);
                        persistentSettings.fiatPriceCurrency = obj.data;

                        if(persistentSettings.fiatPriceEnabled)
                            appWindow.fiatApiRefresh();
                    }
                }
            }

            z: parent.z + 1
        }

        ColumnLayout {
            // Feature needs to be double enabled for security purposes (miss-clicks)
            visible: enableConvertCurrency.checked && !persistentSettings.fiatPriceEnabled
            spacing: 0
            Layout.topMargin: 5
            Layout.leftMargin: 36

            MoneroComponents.WarningBox {
                text: qsTr("Enabling price conversion exposes your IP address to the selected price source.") + translationManager.emptyString;
            }

            MoneroComponents.StandardButton {
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                small: true
                text: qsTr("Confirm and enable") + translationManager.emptyString

                onClicked: {
                    console.log("Enabled price conversion");
                    persistentSettings.fiatPriceEnabled = true;
                    appWindow.fiatApiRefresh();
                    appWindow.fiatTimerStart();
                }
            }
        }

        MoneroComponents.StandardButton {
            visible: !persistentSettings.customDecorations
            Layout.topMargin: 10
            small: true
            text: qsTr("Change language") + translationManager.emptyString

            onClicked: {
                appWindow.toggleLanguageView();
            }
        }
    }

    ListModel {
        id: fiatPriceProvidersModel
    }

    ListModel {
        id: fiatPriceCurrencyModel
        ListElement {
            data: "xmrusd"
            column1: "USD"
        }
        ListElement {
            data: "xmreur"
            column1: "EUR"
        }
    }

    Component.onCompleted: {
        // Dynamically fill fiatPrice dropdown based on `appWindow.fiatPriceAPIs`
        var apis = appWindow.fiatPriceAPIs;
        fiatPriceProvidersModel.clear();

        var i = 0;
        for (var api in apis){
            if (!apis.hasOwnProperty(api))
               continue;

            fiatPriceProvidersModel.append({"column1": Utils.capitalize(api), "data": api});

            if(api === persistentSettings.fiatPriceProvider)
                fiatPriceProviderDropDown.currentIndex = i;
            i += 1;
        }

        fiatPriceProviderDropDown.update();
        fiatPriceCurrencyDropdown.currentIndex = persistentSettings.fiatPriceCurrency === "xmrusd" ? 0 : 1;
        fiatPriceCurrencyDropdown.update();

        console.log('SettingsLayout loaded');
    }
}

