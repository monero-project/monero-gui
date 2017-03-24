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

import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick 2.2
import QtQuick.Layouts 1.1

RowLayout {
    Layout.preferredWidth: 200
    function getSelected() {
        return remoteNodeList.get(remoteNodeDropdown.currentIndex).url;
    }

    ListModel {
         id: remoteNodeList
         ListElement { column1: "node.xmrbackb.one" ; column2: ""; url: "node.xmrbackb.one:18081" }
         ListElement { column1: "node.moneroworld.com" ; column2: ""; url: "node.moneroworld.com:18081" }
     }

    StandardDropdown {
        Layout.fillWidth: true
        id: remoteNodeDropdown
        shadowReleasedColor: (parent.enabled)? "#FF4304" : "#c1c1bf"
        shadowPressedColor: "#B32D00"
        releasedColor: (parent.enabled)? "#FF6C3C" : "#c1c1bf"
        pressedColor: "#FF4304"
        dataModel: remoteNodeList
        z: 1
    }
}
