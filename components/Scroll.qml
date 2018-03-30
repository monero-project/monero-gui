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

import QtQuick 2.0

Item {
    id: scrollItem
    property var flickable
    width: 15
    z: 1

    function flickableContentYChanged() {
        if(flickable === undefined)
            return

        var t = flickable.height - scroll.height
        scroll.y = (flickable.contentY / (flickable.contentHeight - flickable.height)) * t
    }

    MouseArea {
        id: scrollArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {
        id: scroll

        width: 4
        height: {
            var t = (flickable.height * flickable.height) / flickable.contentHeight
            return t < 20 ? 20 : t
        }
        y: 0; x: 0
        color: "#DBDBDB"
        opacity: flickable.moving || handleArea.pressed || scrollArea.containsMouse ? 0.5 : 0
        visible: flickable.contentHeight > flickable.height

        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.InQuad }
        }

        MouseArea {
            id: handleArea
            anchors.fill: parent
            drag.target: scroll
            drag.axis: Drag.YAxis
            drag.minimumY: 0
            drag.maximumY: flickable.height - height
            propagateComposedEvents: true

            onPositionChanged: {
                if(!pressed) return
                var dy = scroll.y / (flickable.height - scroll.height)
                flickable.contentY = (flickable.contentHeight - flickable.height) * dy
            }
        }
    }
}
