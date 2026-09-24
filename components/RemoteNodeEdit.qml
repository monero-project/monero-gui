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

import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick 2.9
import QtQuick.Layouts 1.1

import "../js/Utils.js" as Utils
import "../components" as MoneroComponents

GridLayout {
    columns: 2
    columnSpacing: 32
    id: root
    property alias daemonAddrText: daemonAddr.text
    property alias daemonPortText: daemonPort.text
    property alias daemonAddrLabelText: daemonAddr.labelText
    property alias daemonPortLabelText: daemonPort.labelText

    property string initialAddress: ""
    property var initialHostPort: initialAddress.match(/^(.*?)(?:\:?(\d*))$/)

    // TODO: LEGACY; remove these placeHolder variables when
    // the wizards get redesigned to the black-theme
    property string placeholderFontFamily: MoneroComponents.Style.fontRegular.name
    property bool placeholderFontBold: false
    property int placeholderFontSize: 15
    property string placeholderColor: MoneroComponents.Style.defaultFontColor
    property real placeholderOpacity: 0.35
    property int labelFontSize: 14

    property string lineEditBackgroundColor: "transparent"
    property string lineEditFontColor: MoneroComponents.Style.defaultFontColor
    property bool lineEditFontBold: false
    property int lineEditFontSize: 15

    // Author: David M. Syzdek https://github.com/syzdek https://gist.github.com/syzdek/6086792
    readonly property var ipv6Regex: /^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe08:(:[0-9a-fA-F]{1,4}){2,2}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$/

    signal editingFinished()
    signal textChanged()

    onActiveFocusChanged: activeFocus && daemonAddr.forceActiveFocus()

    function isValid() {
        var parsed = root.parseAddress(daemonAddr.text);
        var host = parsed.host.trim();
        if (host.length === 0) {
            return false;
        }
        if (parsed.port !== "") {
            var portNumber = parseInt(parsed.port, 10);
            return portNumber >= 1 && portNumber <= 65535;
        }
        return daemonPort.acceptableInput;
    }

    function getAddress() {
        if (!isValid()) {
            return "";
        }

        var parsed = root.parseAddress(daemonAddr.text);
        var host = parsed.host.trim();
        var port = parsed.port !== "" ? parsed.port : daemonPort.text.trim();
        return host + ":" + port;
    }

    function parseAddress(input) {
        input = input.trim();

        // strip URI scheme, e.g. "https://" (scheme is optional for "//host:port")
        input = input.replace(/^(?:[a-zA-Z][a-zA-Z0-9+.-]*:)?\/\//, "");

        // strip any path, query or fragment
        var pathIndex = input.search(/[\/\?#]/);
        if (pathIndex !== -1) {
            input = input.substring(0, pathIndex);
        }

        var port = "";

        if (input.indexOf("[") === 0) {
            // bracketed IPv6, e.g. "[::1]:18081", "[::ffff:1.2.3.4]" or "[fe80::1%eth0]:18081"
            var bracketMatch = input.match(/^(\[[^\]]+\])(?::(\d+))?$/);
            if (bracketMatch) {
                input = bracketMatch[1];
                port = bracketMatch[2] || "";
            }
        } else if (ipv6Regex.test(input)) {
            // bare IPv6, e.g. "::1" -> "[::1]"
            input = "[" + input + "]";
        } else {
            // hostname or IPv4, optionally followed by a port
            var hostPortMatch = input.match(/^([^:]+):(\d+)$/);
            if (hostPortMatch) {
                input = hostPortMatch[1];
                port = hostPortMatch[2];
            }
        }

        return { host: input, port: port };
    }

    MoneroComponents.LineEdit {
        id: daemonAddr
        Layout.fillWidth: true
        Layout.minimumWidth: 220
        placeholderText: qsTr("Remote Node Hostname / IP") + translationManager.emptyString
        placeholderFontFamily: root.placeholderFontFamily
        placeholderFontBold: root.placeholderFontBold
        placeholderFontSize: root.placeholderFontSize
        placeholderColor: root.placeholderColor
        placeholderOpacity: root.placeholderOpacity
        labelFontSize: root.labelFontSize
        backgroundColor: lineEditBackgroundColor
        fontColor: lineEditFontColor
        fontBold: lineEditFontBold
        fontSize: lineEditFontSize
        onEditingFinished: {
            var parsed = root.parseAddress(text);
            var portNumber = parseInt(parsed.port, 10);
            if (portNumber >= 1 && portNumber <= 65535) {
                daemonPort.text = parsed.port;
            }
            text = parsed.host;
            root.editingFinished();
        }
        onTextChanged: root.textChanged()
        text: initialHostPort[1]
    }

    MoneroComponents.LineEdit {
        id: daemonPort
        Layout.fillWidth: true
        Layout.minimumWidth: 120
        placeholderText: qsTr("Port") + translationManager.emptyString
        placeholderFontFamily: root.placeholderFontFamily
        placeholderFontBold: root.placeholderFontBold
        placeholderFontSize: root.placeholderFontSize
        placeholderColor: root.placeholderColor
        placeholderOpacity: root.placeholderOpacity
        labelFontSize: root.labelFontSize
        backgroundColor: lineEditBackgroundColor
        fontColor: lineEditFontColor
        fontBold: lineEditFontBold
        fontSize: lineEditFontSize
        validator: IntValidator{bottom: 1; top: 65535;}

        onEditingFinished: root.editingFinished()
        onTextChanged: root.textChanged()
        text: initialHostPort[2]
    }
}
