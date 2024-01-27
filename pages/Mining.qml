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

import QtQml.Models 2.2
import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import "../components" as MoneroComponents
import moneroComponents.Wallet 1.0
import moneroComponents.P2PoolManager 1.0
import moneroComponents.DaemonManager 1.0

Rectangle {
    id: root
    color: "transparent"
    property alias miningHeight: mainLayout.height
    property double currentHashRate: 0
    property int threads: idealThreadCount / 2
    property alias stopMiningEnabled: stopSoloMinerButton.enabled
    property string args: ""
    ColumnLayout {
        id: mainLayout
        Layout.fillWidth: true
        anchors.margins: 20
        anchors.topMargin: 0
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        spacing: 20

        MoneroComponents.Label {
            id: soloTitleLabel
            fontSize: 24
            text: qsTr("Mining") + translationManager.emptyString
        }

        MoneroComponents.WarningBox {
            Layout.bottomMargin: 8
            id: localDaemonWarning
            text: qsTr("Mining is only available on local daemons.") + translationManager.emptyString
            visible: persistentSettings.useRemoteNode && !persistentSettings.allowRemoteNodeMining
        }

        MoneroComponents.WarningBox {
            Layout.bottomMargin: 8
            text: qsTr("Your daemon must be synchronized before you can start mining") + translationManager.emptyString
            visible: !persistentSettings.useRemoteNode && !appWindow.daemonSynced
        }

        MoneroComponents.TextPlain {
            id: soloMainLabel
            text: qsTr("Mining with your computer helps strengthen the Monero network. The more people mine, the harder it is for the network to be attacked, and every little bit helps.\n\nMining also gives you a small chance to earn some Monero. Your computer will create hashes looking for block solutions. If you find a block, you will get the associated reward. Good luck!") + "\n\n" + qsTr("P2Pool mining is a decentralized way to pool mine that pays out more frequently compared to solo mining, while also supporting the network.") + translationManager.emptyString
            wrapMode: Text.Wrap
            Layout.fillWidth: true
            font.family: MoneroComponents.Style.fontRegular.name
            font.pixelSize: 14
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.WarningBox {
            id: warningLabel
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            text: qsTr("Mining may reduce the performance of other running applications and processes.") + translationManager.emptyString
        }

        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 20
            rowSpacing: 16

            ListModel {
                id: miningModeModel

                ListElement { column1: qsTr("Solo") ; column2: ""; priority: 0}
                ListElement { column1: "P2Pool" ; column2: ""; priority: 1}
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                MoneroComponents.Label {
                    id: miningModeLabel
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("Mining mode") + translationManager.emptyString
                    fontSize: 16
                }
            }

            ColumnLayout {
                Layout.topMargin: 5
                spacing: 10

                MoneroComponents.StandardDropdown {
                    Layout.maximumWidth: 200
                    id: miningModeDropdown
                    visible: true
                    currentIndex: persistentSettings.miningModeSelected
                    dataModel: miningModeModel
                    onChanged: {
                        persistentSettings.allow_p2pool_mining = miningModeDropdown.currentIndex === 1;
                        persistentSettings.miningModeSelected = miningModeDropdown.currentIndex;
                        walletManager.stopMining();
                        p2poolManager.exit();
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                MoneroComponents.Label {
                    id: soloMinerThreadsLabel
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("CPU threads") + translationManager.emptyString
                    fontSize: 16
                    wrapMode: Text.WordWrap
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    MoneroComponents.StandardButton {
                        id: removeThreadButton
                        small: true
                        primary: false
                        text: "−"
                        enabled: threads > 1
                        onClicked: threads--
                    }

                    MoneroComponents.TextPlain {
                        Layout.bottomMargin: 1
                        Layout.minimumWidth: 45
                        color: MoneroComponents.Style.defaultFontColor
                        text: threads
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 16

                        MouseArea {
                            anchors.fill: parent
                            scrollGestureEnabled: false
                            onWheel: {
                                if (wheel.angleDelta.y > 0 && threads < idealThreadCount) {
                                    return threads++
                                } else if (wheel.angleDelta.y < 0 && threads > 1) {
                                    return threads--
                                }
                            }
                        }
                    }

                    MoneroComponents.StandardButton {
                        id: addThreadButton
                        small: true
                        primary: false
                        text: "+"
                        enabled: threads < idealThreadCount
                        onClicked: threads++
                    }
                }

                RowLayout {
                    MoneroComponents.StandardButton {
                        id: autoRecommendedThreadsButton
                        small: true
                        primary: false
                        text: qsTr("Use half (recommended)") +  translationManager.emptyString
                        enabled: startSoloMinerButton.enabled
                        onClicked: {
                                threads = idealThreadCount / 2
                                appWindow.showStatusMessage(qsTr("Set to use recommended # of threads"),3)
                        }
                    }

                    MoneroComponents.StandardButton {
                        id: autoSetMaxThreadsButton
                        small: true
                        primary: false
                        text: qsTr("Use all threads") + " (" + idealThreadCount + ")" + translationManager.emptyString
                        enabled: startSoloMinerButton.enabled
                        onClicked: {
                            threads = idealThreadCount
                            appWindow.showStatusMessage(qsTr("Set to use all threads") + translationManager.emptyString,3)
                        }
                    }
                }

                RowLayout {
                    // Disable this option until stable
                    visible: false
                    MoneroComponents.CheckBox {
                        id: ignoreBattery
                        enabled: startSoloMinerButton.enabled
                        checked: !persistentSettings.miningIgnoreBattery
                        onClicked: {persistentSettings.miningIgnoreBattery = !checked}
                        text: qsTr("Enable mining when running on battery") + translationManager.emptyString
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.minimumWidth: 140

                MoneroComponents.Label {
                    id: optionsLabel
                    color: MoneroComponents.Style.defaultFontColor
                    visible: !persistentSettings.allow_p2pool_mining
                    text: qsTr("Options") + translationManager.emptyString
                    fontSize: 16
                    wrapMode: Text.Wrap
                    Layout.preferredWidth: manageSoloMinerLabel.textWidth
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    MoneroComponents.CheckBox {
                        id: backgroundMining
                        visible: !persistentSettings.allow_p2pool_mining
                        enabled: startSoloMinerButton.enabled && !persistentSettings.allow_p2pool_mining
                        checked: persistentSettings.allow_background_mining
                        onClicked: persistentSettings.allow_background_mining = checked
                        text: qsTr("Background mining (experimental)") + translationManager.emptyString
                    }
                }
            }

            ColumnLayout {
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                MoneroComponents.Label {
                    id: manageSoloMinerLabel
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("Manage miner") + translationManager.emptyString
                    fontSize: 16
                    wrapMode: Text.Wrap
                    Layout.preferredWidth: manageSoloMinerLabel.textWidth
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                RowLayout {
                    MoneroComponents.StandardButton {
                        visible: true
                        id: startSoloMinerButton
                        small: true
                        primary: !stopSoloMinerButton.enabled
                        text: qsTr("Start mining") + translationManager.emptyString
                        onClicked: {
                            var daemonReady = appWindow.daemonSynced && appWindow.daemonRunning && !persistentSettings.useRemoteNode
                            if (persistentSettings.allowRemoteNodeMining) {
                                daemonReady = persistentSettings.useRemoteNode && appWindow.daemonSynced
                            }
                            if (daemonReady) {
                                var success;
                                if (persistentSettings.allow_p2pool_mining) {
                                    if (p2poolManager.isInstalled()) {
                                        args = daemonManager.getArgs(persistentSettings.blockchainDataDir) //updates arguments
                                        if (persistentSettings.allowRemoteNodeMining || (args.includes("--zmq-pub tcp://127.0.0.1:18083") || args.includes("--zmq-pub=tcp://127.0.0.1:18083")) && !args.includes("--no-zmq")) {
                                            startP2Pool()
                                        }
                                        else {
                                            daemonManager.stopAsync(persistentSettings.nettype, persistentSettings.blockchainDataDir, startP2PoolLocal)
                                        }
                                    }
                                    else {
                                        confirmationDialog.title = qsTr("P2Pool installation") + translationManager.emptyString;
                                        confirmationDialog.text  = qsTr("P2Pool will be installed at %1. Proceed?").arg(applicationDirectory) + translationManager.emptyString;
                                        confirmationDialog.icon = StandardIcon.Question;
                                        confirmationDialog.cancelText = qsTr("No") + translationManager.emptyString;
                                        confirmationDialog.okText = qsTr("Yes") + translationManager.emptyString;
                                        confirmationDialog.onAcceptedCallback = function() {
                                            p2poolManager.download();
                                            statusMessageText.text = "Downloading P2Pool...";
                                            statusMessage.visible = true
                                            startSoloMinerButton.enabled = false;
                                            stopSoloMinerButton.enabled = false;
                                        }
                                        confirmationDialog.open();
                                    }
                                }
                                else 
                                {
                                    success = walletManager.startMining(appWindow.currentWallet.address(0, 0), threads, persistentSettings.allow_background_mining, persistentSettings.miningIgnoreBattery)
                                    if (success) 
                                    {
                                        update()
                                    } 
                                    else 
                                    {
                                        miningError(qsTr("Couldn't start mining.<br>") + translationManager.emptyString)
                                    }
                                }
                            }
                            else {
                                miningError(qsTr("Couldn't start mining.<br>") + translationManager.emptyString)
                            }
                        }
                    }

                    MoneroComponents.StandardButton {
                        visible: true
                        id: stopSoloMinerButton
                        small: true
                        primary: stopSoloMinerButton.enabled
                        text: qsTr("Stop mining") + translationManager.emptyString
                        onClicked: {
                            walletManager.stopMining()
                            p2poolManager.exit()
                            update()
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                MoneroComponents.Label {
                    id: statusLabel
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("Status") + translationManager.emptyString
                    fontSize: 16
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                MoneroComponents.LineEditMulti {
                    id: statusText
                    Layout.minimumWidth: 300
                    text: qsTr("Not mining") + translationManager.emptyString
                    borderDisabled: true
                    readOnly: true
                    wrapMode: Text.Wrap
                    inputPaddingLeft: 0
                }
            }

            ListModel {
                id: chainModel

                ListElement { column1: qsTr("Mini") ; column2: ""; priority: 0}
                ListElement { column1: qsTr("Main") ; column2: ""; priority: 1}
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                MoneroComponents.Label {
                    id: chainLabel
                    color: MoneroComponents.Style.defaultFontColor
                    visible: persistentSettings.allow_p2pool_mining
                    text: qsTr("Chain") + translationManager.emptyString
                    fontSize: 16
                }

                MoneroComponents.Tooltip {
                    id: chainsHelpTooltip
                    text: qsTr("Use the mini chain if you have a low hashrate.") + translationManager.emptyString
                }

                MouseArea {
                    id: chainsTooltipArea
                    width: parent.width
                    height: parent.height
                    enabled: persistentSettings.allow_p2pool_mining
                    hoverEnabled: true
                    onEntered: {
                        chainsHelpTooltip.tooltipPopup.open();
                    }
                    onExited: {
                        chainsHelpTooltip.tooltipPopup.close();
                    }
                }
            }

            ColumnLayout {
                Layout.topMargin: 5
                spacing: 10

                MoneroComponents.StandardDropdown {
                    Layout.maximumWidth: 200
                    id: chainDropdown
                    visible: persistentSettings.allow_p2pool_mining
                    currentIndex: persistentSettings.chainDropdownSelected
                    dataModel: chainModel
                    onChanged: persistentSettings.chainDropdownSelected = chainDropdown.currentIndex;
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment : Qt.AlignTop | Qt.AlignLeft

                MoneroComponents.Label {
                    id: flagsLabel
                    visible: persistentSettings.allow_p2pool_mining
                    color: MoneroComponents.Style.defaultFontColor
                    text: qsTr("Flags") + translationManager.emptyString
                    fontSize: 16
                }

                MoneroComponents.Tooltip {
                    id: flagsHelpTooltip
                    text: "
                    Usage:<br>
                        --wallet             Wallet address to mine to. Subaddresses and integrated addresses are not supported!<br>
                        --host               IP address of your Monero node, default is 127.0.0.1<br>
                        --rpc-port           monerod RPC API port number, default is 18081<br>
                        --zmq-port           monerod ZMQ pub port number, default is 18083 (same port as in monerod\'s \"--zmq-pub\" command line parameter)<br>
                        --stratum            Comma-separated list of IP:port for stratum server to listen on<br>
                        --p2p                Comma-separated list of IP:port for p2p server to listen on<br>
                        --addpeers           Comma-separated list of IP:port of other p2pool nodes to connect to<br>
                        --light-mode         Don't allocate RandomX dataset, saves 2GB of RAM<br>
                        --loglevel           Verbosity of the log, integer number between 0 and 6<br>
                        --config             Name of the p2pool config file<br>
                        --data-api           Path to the p2pool JSON data (use it in tandem with an external web-server)<br>
                        --local-api          Enable /local/ path in api path for Stratum Server and built-in miner statistics<br>
                        --stratum-api        An alias for --local-api<br>
                        --no-cache           Disable p2pool.cache<br>
                        --no-color           Disable colors in console output<br>
                        --no-randomx         Disable internal RandomX hasher: p2pool will use RPC calls to monerod to check PoW hashes<br>
                        --out-peers N        Maximum number of outgoing connections for p2p server (any value between 10 and 1000)<br>
                        --in-peers N         Maximum number of incoming connections for p2p server (any value between 10 and 1000)<br>
                        --start-mining N     Start built-in miner using N threads (any value between 1 and 64)<br>
                        --help               Show this help message
                    "
                }

                MouseArea {
                    id: flagsTooltipArea
                    width: parent.width
                    height: parent.height
                    enabled: persistentSettings.allow_p2pool_mining
                    hoverEnabled: true
                    onEntered: {
                        flagsHelpTooltip.tooltipPopup.open();
                    }
                    onExited: {
                        flagsHelpTooltip.tooltipPopup.close();
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                MoneroComponents.LineEditMulti {
                    id: p2poolFlags
                    Layout.minimumWidth: 100
                    Layout.bottomMargin: 20
                    labelFontSize: 14
                    fontSize: 15
                    visible: persistentSettings.allow_p2pool_mining
                    wrapMode: Text.WrapAnywhere
                    labelText: qsTr("P2Pool startup flags") + translationManager.emptyString
                    placeholderText: qsTr("(optional)") + translationManager.emptyString
                    placeholderFontSize: 15
                    text: persistentSettings.p2poolFlags
                    addressValidation: false
                    onEditingFinished:  {
                        persistentSettings.allowRemoteNodeMining = p2poolFlags.text.includes("--host");
                        persistentSettings.p2poolFlags = p2poolFlags.text;
                    }
                }
            }
        }
    }

    function updateStatusText(p2poolHashrate) {
        if (appWindow.isMining) {
            if (persistentSettings.allow_p2pool_mining) {
                if (p2poolHashrate === 0) {
                    statusText.text = qsTr("Starting P2Pool") + translationManager.emptyString;
                }
                else {
                    statusText.text = qsTr("Mining with P2Pool, at %1 H/s").arg(p2poolHashrate) + translationManager.emptyString;
                }
            }
            else {
                var userHashRate = walletManager.miningHashRate();
                if (userHashRate === 0) {
                    statusText.text = qsTr("Mining temporarily suspended.") + translationManager.emptyString;
                }
                else {
                    var blockTime = 120;
                    var blocksPerDay = 86400 / blockTime;
                    var globalHashRate = walletManager.networkDifficulty() / blockTime;
                    var probabilityFindNextBlock = userHashRate / globalHashRate;
                    var probabilityFindBlockDay = 1 - Math.pow(1 - probabilityFindNextBlock, blocksPerDay);
                    var chanceFindBlockDay = Math.round(1 / probabilityFindBlockDay);
                    statusText.text = qsTr("Mining at %1 H/s. It gives you a 1 in %2 daily chance of finding a block.").arg(userHashRate).arg(chanceFindBlockDay) + translationManager.emptyString;
                }  
            }
        }
        else {
            statusText.text = qsTr("Not mining") + translationManager.emptyString;
        }
    }

    function onMiningStatus(isMining, hashrate) {
        var daemonReady = appWindow.daemonSynced
        if (!persistentSettings.allowRemoteNodeMining) {
            var daemonReady = !persistentSettings.useRemoteNode && daemonReady
        }
        appWindow.isMining = isMining;
        updateStatusText(hashrate)
        startSoloMinerButton.enabled = !appWindow.isMining && daemonReady
        stopSoloMinerButton.enabled = !startSoloMinerButton.enabled && daemonReady
    }

    function update() {
        persistentSettings.allow_p2pool_mining = miningModeDropdown.currentIndex === 1;
        if (persistentSettings.allow_p2pool_mining) {
            p2poolManager.getStatus();
        }
        else {
            walletManager.miningStatusAsync();
        } 
    }

    function miningError(message) {
        p2poolManager.exit()
        errorPopup.title  = qsTr("Error starting mining") + translationManager.emptyString;
        errorPopup.text = message
        if (persistentSettings.useRemoteNode && !persistentSettings.allowRemoteNodeMining)
            errorPopup.text += qsTr("Mining is only available on local daemons. Run a local daemon to be able to mine.<br>") + translationManager.emptyString
        errorPopup.icon = StandardIcon.Critical
        errorPopup.open()
    }

    MoneroComponents.StandardDialog {
        id: errorPopup
        cancelVisible: false
    }

    Timer {
        id: timer
        interval: 2000
        running: middlePanel.advancedView.state === "Mining" && middlePanel.state === "Advanced" && currentWallet !== undefined && (!persistentSettings.useRemoteNode || persistentSettings.allowRemoteNodeMining)
        repeat: true
        onTriggered: update()
    }

    function startP2PoolLocal() {
        var noSync = false;
        //these args will be deleted because DaemonManager::start will re-add them later.
        //--no-zmq must be deleted. removing '--zmq-pub=tcp...' lets us blindly add '--zmq-pub tcp...' later without risking duplication.
        var defaultArgs = ["--detach","--data-dir","--bootstrap-daemon-address","--prune-blockchain","--no-sync","--check-updates","--non-interactive","--max-concurrency","--no-zmq","--zmq-pub=tcp://127.0.0.1:18083"]
        var customDaemonArgsArray = args.split(' ');
        var flag = "";
        var allArgs = [];
        var p2poolArgs = ["--zmq-pub tcp://127.0.0.1:18083"];
        //create an array (allArgs) of ['--arg value','--arg2','--arg3']
        for (let i = 0; i < customDaemonArgsArray.length; i++) {
            if(!customDaemonArgsArray[i].startsWith("--")) {
                flag += " " + customDaemonArgsArray[i]
            } else {
                if(flag){
                    allArgs.push(flag)
                }
                flag = customDaemonArgsArray[i]
            }
        }
        allArgs.push(flag)
        //pop from allArgs if value is inside the deleteme array (defaultArgs)
allArgs = allArgs.filter( ( el ) => !defaultArgs.includes( el.split(" ")[0] ) )
        //append required p2pool flags
        for (let i = 0; i < p2poolArgs.length; i++) {
            if(!allArgs.includes(p2poolArgs[i])) {
                allArgs.push(p2poolArgs[i])
                continue
            }
        }
        var success = daemonManager.start(allArgs.join(" "), persistentSettings.nettype, persistentSettings.blockchainDataDir, persistentSettings.bootstrapNodeAddress, noSync, persistentSettings.pruneBlockchain)
        if (success) {
            startP2Pool()
        }
        else {
            miningError(qsTr("Couldn't start mining.<br>") + translationManager.emptyString)
        }
    }

    function startP2Pool() {
        var address = currentWallet.address(0, 0);
        var chain = "mini"
        if (chainDropdown.currentIndex === 1) {
            chain = "main"
        }
        var p2poolArgs = persistentSettings.p2poolFlags;
        var success = p2poolManager.start(p2poolArgs, address, chain, threads);
        if (success) 
        {
            update()
        }
        else {
            miningError(qsTr("Couldn't start mining.<br>") + translationManager.emptyString)
        }
    }

    function p2poolDownloadFailed(errorCode) {
        statusMessage.visible = false
        errorPopup.title = qsTr("P2Pool Installation Failed") + translationManager.emptyString;
        switch (errorCode) {
            case P2PoolManager.HashVerificationFailed:
                errorPopup.text = qsTr("Hash verification failed.") + translationManager.emptyString;
                break;
            case P2PoolManager.BinaryNotAvailable:
                errorPopup.text = qsTr("P2Pool download is not available.") + translationManager.emptyString;
                break;
            case P2PoolManager.ConnectionIssue:
                errorPopup.text = qsTr("P2Pool download failed due to a connection issue.") + translationManager.emptyString;
                break;
            case P2PoolManager.InstallationFailed:
                errorPopup.text = qsTr("P2Pool installation failed.") + (isWindows ? (" " + qsTr("Try starting the program with administrator privileges.")) : "")
                break;
            default:
                errorPopup.text = qsTr("Unknown error.") + translationManager.emptyString;
        }
        errorPopup.icon = StandardIcon.Critical
        errorPopup.open()
        update()
    }

    function p2poolDownloadSucceeded() {
        statusMessage.visible = false
        informationPopup.title  = qsTr("P2Pool Installation Succeeded") + translationManager.emptyString;
        informationPopup.text = qsTr("P2Pool has successfully installed.");
        informationPopup.icon = StandardIcon.Critical
        informationPopup.open()
        update()
    }

    Component.onCompleted: {
        walletManager.miningStatus.connect(onMiningStatus);
        p2poolManager.p2poolStatus.connect(onMiningStatus);
        p2poolManager.p2poolDownloadFailure.connect(p2poolDownloadFailed);
        p2poolManager.p2poolDownloadSuccess.connect(p2poolDownloadSucceeded);
    }
}
