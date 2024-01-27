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
        return daemonAddr.text.trim().length > 0 && daemonPort.acceptableInput
    }

    function getAddress() {
        if (!isValid()) {
            return "";
        }

        var addr = daemonAddr.text.trim();
        var port = daemonPort.text.trim();
        return addr + ":" + port;
    }

    MoneroComponents.LineEdit {
        id: daemonAddr
        Layout.preferredWidth: root.width/3
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
            text = text.replace(ipv6Regex, "[$1]");
            root.editingFinished();
        }
        onTextChanged: root.textChanged()
        text: initialHostPort[1]
    }

    MoneroComponents.LineEdit {
        id: daemonPort
        Layout.preferredWidth: root.width/3
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
