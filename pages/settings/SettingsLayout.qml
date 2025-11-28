import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2

import moneroComponents.Wallet 1.0

import "../../js/Utils.js" as Utils
import "../../js/Windows.js" as Windows
import "../../components" as MoneroComponents

Rectangle {
    color: "transparent"
    Layout.fillWidth: true
    property alias layoutHeight: settingsUI.height

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

        // ... [Existing Checkboxes for Custom Decorations, Updates, etc.] ...

        MoneroComponents.CheckBox {
            id: customDecorationsCheckBox
            checked: persistentSettings.customDecorations
            onClicked: Windows.setCustomWindowDecorations(checked)
            text: qsTr("Custom decorations") + translationManager.emptyString
        }

        MoneroComponents.CheckBox {
            id: checkForUpdatesCheckBox
            enabled: !disableCheckUpdatesFlag
            checked: persistentSettings.checkForUpdates && !disableCheckUpdatesFlag
            onClicked: persistentSettings.checkForUpdates = !persistentSettings.checkForUpdates
            text: qsTr("Check for updates periodically") + translationManager.emptyString
        }

        MoneroComponents.CheckBox {
            checked: persistentSettings.displayWalletNameInTitleBar
            onClicked: persistentSettings.displayWalletNameInTitleBar = !persistentSettings.displayWalletNameInTitleBar
            text: qsTr("Display wallet name in title bar") + translationManager.emptyString
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
            }
        }

        MoneroComponents.CheckBox {
            checked: persistentSettings.askPasswordBeforeSending
            text: qsTr("Ask for password before sending a transaction") + translationManager.emptyString
            toggleOnClick: false
            onClicked: {
                if (persistentSettings.askPasswordBeforeSending) {
                    passwordDialog.onAcceptedCallback = function() {
                        if (appWindow.walletPassword === passwordDialog.password){
                            persistentSettings.askPasswordBeforeSending = false;
                        } else {
                            passwordDialog.showError(qsTr("Wrong password"));
                        }
                    }
                    passwordDialog.onRejectedCallback = null;
                    passwordDialog.open()
                } else {
                    persistentSettings.askPasswordBeforeSending = true;
                }
            }
        }

        MoneroComponents.CheckBox {
            checked: persistentSettings.autosave
            onClicked: persistentSettings.autosave = !persistentSettings.autosave
            text: qsTr("Autosave") + translationManager.emptyString
        }

        MoneroComponents.Slider {
            Layout.fillWidth: true
            Layout.leftMargin: 35
            Layout.topMargin: 6
            visible: persistentSettings.autosave
            from: 1
            stepSize: 1
            to: 60
            value: persistentSettings.autosaveMinutes
            text: "%1 %2 %3".arg(qsTr("Every")).arg(value).arg(qsTr("minute(s)")) + translationManager.emptyString
            onMoved: persistentSettings.autosaveMinutes = value
        }

        MoneroComponents.CheckBox {
            id: userInActivityCheckbox
            checked: persistentSettings.lockOnUserInActivity
            onClicked: persistentSettings.lockOnUserInActivity = !persistentSettings.lockOnUserInActivity
            text: qsTr("Lock wallet on inactivity") + translationManager.emptyString
        }

        MoneroComponents.Slider {
            visible: userInActivityCheckbox.checked
            Layout.fillWidth: true
            Layout.topMargin: 6
            Layout.leftMargin: 35
            from: 1
            stepSize: 1
            to: 60
            value: persistentSettings.lockOnUserInActivityInterval
            text: {
                var minutes = value > 1 ? qsTr("minutes") : qsTr("minute");
                return qsTr("After ") + value + " " + minutes + translationManager.emptyString;
            }
            onMoved: persistentSettings.lockOnUserInActivityInterval = value
        }

        MoneroComponents.CheckBox {
            id: backgroundSyncCheckbox
            visible: !!currentWallet && !currentWallet.isHwBacked() && !appWindow.viewOnly
            checked: appWindow.backgroundSyncType != Wallet.BackgroundSync_Off
            text: qsTr("Sync in the background when locked") + translationManager.emptyString
            toggleOnClick: false
            onClicked: {
                if (currentWallet && appWindow) {
                    appWindow.showProcessingSplash(qsTr("Updating settings..."))
                    var newBackgroundSyncType = Wallet.BackgroundSync_Off
                    if (currentWallet.getBackgroundSyncType() === Wallet.BackgroundSync_Off)
                        newBackgroundSyncType = Wallet.BackgroundSync_ReusePassword
                    currentWallet.setupBackgroundSync(newBackgroundSyncType, appWindow.walletPassword)
                }
            }
        }

        MoneroComponents.CheckBox {
            checked: persistentSettings.askStopLocalNode
            onClicked: persistentSettings.askStopLocalNode = !persistentSettings.askStopLocalNode
            text: qsTr("Ask to stop local node during program exit") + translationManager.emptyString
        }

        // Manage pricing
        RowLayout {
            MoneroComponents.CheckBox {
                id: enableConvertCurrency
                text: qsTr("Enable displaying balance in other currencies") + translationManager.emptyString
                checked: persistentSettings.fiatPriceEnabled
                onCheckedChanged: {
                    if (!checked) {
                        console.log("Disabled price conversion");
                        persistentSettings.fiatPriceEnabled = false;
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

            MoneroComponents.StandardDropdown {
                id: fiatPriceProviderDropDown
                Layout.maximumWidth: 200
                labelText: qsTr("Price source") + translationManager.emptyString
                labelFontSize: 14
                dataModel: fiatPriceProvidersModel
                onChanged: {
                    var obj = dataModel.get(currentIndex);
                    persistentSettings.fiatPriceProvider = obj.data;

                    if(persistentSettings.fiatPriceEnabled)
                        appWindow.fiatApiRefresh();
                }
            }

            MoneroComponents.StandardDropdown {
                id: fiatPriceCurrencyDropdown
                Layout.maximumWidth: 100
                labelText: qsTr("Currency") + translationManager.emptyString
                labelFontSize: 14
                currentIndex: persistentSettings.fiatPriceCurrency === "xmrusd" ? 0 : 1
                dataModel: fiatPriceCurrencyModel
                onChanged: {
                    var obj = dataModel.get(currentIndex);
                    persistentSettings.fiatPriceCurrency = obj.data;

                    if(persistentSettings.fiatPriceEnabled)
                        appWindow.fiatApiRefresh();
                }
            }

            z: parent.z + 1
        }

        ColumnLayout {
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
                }
            }
        }

        // Connect via I2P Checkbox (Simple Mode)
        MoneroComponents.CheckBox {
            id: i2pCheckbox
            Layout.topMargin: 6
            checked: persistentSettings.i2pEnabled && persistentSettings.anonymityNetwork === 2
            text: qsTr("Route traffic through I2P") + translationManager.emptyString
            onClicked: {
                if (checked) {
                    // Enable I2P: disconnect current node, set I2P settings, reconnect
                    appWindow.enableI2pRouting();
                } else {
                    // Disable I2P: disconnect, clear I2P settings, reconnect normally
                    appWindow.disableI2pRouting();
                }
            }
        }

        MoneroComponents.CheckBox {
            id: proxyCheckbox
            Layout.topMargin: 6
            enabled: !socksProxyFlagSet
            checked: socksProxyFlagSet ? socksProxyFlag : persistentSettings.proxyEnabled
            onClicked: {
                persistentSettings.proxyEnabled = !persistentSettings.proxyEnabled;
            }
            text: qsTr("Socks5 proxy (%1%2)")
                .arg(appWindow.walletMode >= 2 ? qsTr("remote node connections, ") : "")
                .arg(qsTr("updates downloading, fetching price sources")) + translationManager.emptyString
        }

        MoneroComponents.RemoteNodeEdit {
            id: proxyEdit
            enabled: proxyCheckbox.enabled
            Layout.leftMargin: 36
            Layout.topMargin: 6
            Layout.minimumWidth: 100
            placeholderFontSize: 15
            visible: proxyCheckbox.checked

            daemonAddrLabelText: qsTr("IP address") + translationManager.emptyString
            daemonPortLabelText: qsTr("Port") + translationManager.emptyString

            initialAddress: socksProxyFlagSet ? socksProxyFlag : persistentSettings.proxyAddress
            onEditingFinished: {
                persistentSettings.proxyAddress = proxyEdit.getAddress();
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

    // ... [ListModels and Component.onCompleted] ...
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

        console.log('SettingsLayout loaded');
    }
}
