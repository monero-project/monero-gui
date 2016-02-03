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

import QtQuick 2.2
import QtQuick.Window 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import "components"
import "wizard"

ApplicationWindow {
    id: appWindow
    objectName: "appWindow"
    property var currentItem
    property bool whatIsEnable: false
    property bool ctrlPressed: false
    property bool rightPanelExpanded: true
    property bool osx: false

    function altKeyReleased() { ctrlPressed = false; }
    function showPageRequest(page) {
        middlePanel.state = page
        leftPanel.selectItem(page)
    }
    function sequencePressed(obj, seq) {
        if(seq === undefined)
            return
        if(seq === "Ctrl") {
            ctrlPressed = true
            return
        }

        if(seq === "Ctrl+D") middlePanel.state = "Dashboard"
        else if(seq === "Ctrl+H") middlePanel.state = "History"
        else if(seq === "Ctrl+T") middlePanel.state = "Transfer"
        else if(seq === "Ctrl+B") middlePanel.state = "AddressBook"
        else if(seq === "Ctrl+M") middlePanel.state = "Mining"
        else if(seq === "Ctrl+S") middlePanel.state = "Settings"
        else if(seq === "Ctrl+Tab" || seq === "Alt+Tab") {
            if(middlePanel.state === "Dashboard") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "Settings"
            else if(middlePanel.state === "Settings") middlePanel.state = "Dashboard"
        } else if(seq === "Ctrl+Shift+Backtab" || seq === "Alt+Shift+Backtab") {
            if(middlePanel.state === "Dashboard") middlePanel.state = "Settings"
            else if(middlePanel.state === "Settings") middlePanel.state = "Mining"
            else if(middlePanel.state === "Mining") middlePanel.state = "AddressBook"
            else if(middlePanel.state === "AddressBook") middlePanel.state = "History"
            else if(middlePanel.state === "History") middlePanel.state = "Transfer"
            else if(middlePanel.state === "Transfer") middlePanel.state = "Dashboard"
        }

        leftPanel.selectItem(middlePanel.state)
    }

    function sequenceReleased(obj, seq) {
        if(seq === "Ctrl")
            ctrlPressed = false
    }

    function mousePressed(obj, mouseX, mouseY) {
        if(obj.objectName === "appWindow")
            obj = rootItem

        var tmp = rootItem.mapFromItem(obj, mouseX, mouseY)
        if(tmp !== undefined) {
            mouseX = tmp.x
            mouseY = tmp.y
        }

        if(currentItem !== undefined) {
            var tmp_x = rootItem.mapToItem(currentItem, mouseX, mouseY).x
            var tmp_y = rootItem.mapToItem(currentItem, mouseX, mouseY).y

            if(!currentItem.containsPoint(tmp_x, tmp_y)) {
                currentItem.hide()
                currentItem = undefined
            }
        }
    }

    function mouseReleased(obj, mouseX, mouseY) {

    }

    visible: true
    width: rightPanelExpanded ? 1269 : 1269 - 300
    height: 800
    color: "#FFFFFF"
    flags: Qt.FramelessWindowHint | Qt.WindowSystemMenuHint | Qt.Window | Qt.WindowMinimizeButtonHint
    onWidthChanged: x -= 0

    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
    }

    Item {
        id: rootItem
        anchors.fill: parent
        clip: true

        state: "wizard"
        states: [
            State {
                name: "wizard"
                PropertyChanges { target: leftPanel; visible: false }
                PropertyChanges { target: rightPanel; visible: false }
                PropertyChanges { target: middlePanel; visible: false }
                PropertyChanges { target: titleBar; basicButtonVisible: false }
                PropertyChanges { target: wizard; visible: true }
                PropertyChanges { target: appWindow; width: 930; }
                PropertyChanges { target: appWindow; height: 595; }
                PropertyChanges { target: resizeArea; visible: false }
                PropertyChanges { target: titleBar; maximizeButtonVisible: false }
                PropertyChanges { target: frameArea; blocked: true }
                PropertyChanges { target: titleBar; y: 0 }
                PropertyChanges { target: titleBar; title: "Program setup wizard" }
            }, State {
                name: "normal"
                PropertyChanges { target: leftPanel; visible: true }
                PropertyChanges { target: rightPanel; visible: true }
                PropertyChanges { target: middlePanel; visible: true }
                PropertyChanges { target: titleBar; basicButtonVisible: true }
                PropertyChanges { target: wizard; visible: false }
                PropertyChanges { target: appWindow; width: rightPanelExpanded ? 1269 : 1269 - 300; }
                PropertyChanges { target: appWindow; height: 800; }
                PropertyChanges { target: resizeArea; visible: true }
                PropertyChanges { target: titleBar; maximizeButtonVisible: true }
                PropertyChanges { target: frameArea; blocked: false }
                PropertyChanges { target: titleBar; y: -titleBar.height }
                PropertyChanges { target: titleBar; title: "Monero  -  Donations" }
            }
        ]

        LeftPanel {
            id: leftPanel
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: parent.height
            onDashboardClicked: middlePanel.state = "Dashboard"
            onHistoryClicked: middlePanel.state = "History"
            onTransferClicked: middlePanel.state = "Transfer"
            onAddressBookClicked: middlePanel.state = "AddressBook"
            onMiningClicked: middlePanel.state = "Minning"
            onSettingsClicked: middlePanel.state = "Settings"
        }

        RightPanel {
            id: rightPanel
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height
            width: appWindow.rightPanelExpanded ? 300 : 0
            visible: appWindow.rightPanelExpanded
        }

        MiddlePanel {
            id: middlePanel
            anchors.bottom: parent.bottom
            anchors.left: leftPanel.right
            anchors.right: rightPanel.left
            height: parent.height
            state: "Dashboard"
        }

        TipItem {
            id: tipItem
            text: "send to the same destination"
            visible: false
        }

        BasicPanel {
            id: basicPanel
            x: 0
            anchors.bottom: parent.bottom
            visible: false
        }

        MouseArea {
            id: frameArea
            property bool blocked: false
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            z: 1
            hoverEnabled: true
            onEntered: if(!blocked) titleBar.y = 0
            onExited: if(!blocked) titleBar.y = -titleBar.height
            propagateComposedEvents: true
            onPressed: mouse.accepted = false
            onReleased: mouse.accepted = false
            onMouseXChanged: titleBar.mouseX = mouseX
            onContainsMouseChanged: titleBar.containsMouse = containsMouse
        }

        SequentialAnimation {
            id: goToBasicAnimation
            PropertyAction {
                target: appWindow
                properties: "visibility"
                value: Window.Windowed
            }
            PropertyAction {
                target: titleBar
                properties: "maximizeButtonVisible"
                value: false
            }
            PropertyAction {
                target: frameArea
                properties: "blocked"
                value: true
            }
            PropertyAction {
                target: resizeArea
                properties: "visible"
                value: false
            }
            NumberAnimation {
                target: appWindow
                properties: "height"
                to: 30
                easing.type: Easing.InCubic
                duration: 200
            }
            NumberAnimation {
                target: appWindow
                properties: "width"
                to: 470
                easing.type: Easing.InCubic
                duration: 200
            }
            PropertyAction {
                targets: [leftPanel, middlePanel, rightPanel]
                properties: "visible"
                value: false
            }
            PropertyAction {
                target: basicPanel
                properties: "visible"
                value: true
            }
            NumberAnimation {
                target: appWindow
                properties: "height"
                to: basicPanel.height
                easing.type: Easing.InCubic
                duration: 200
            }

            onStopped: {
                middlePanel.visible = false
                rightPanel.visible = false
                leftPanel.visible = false
            }
        }

        SequentialAnimation {
            id: goToProAnimation
            NumberAnimation {
                target: appWindow
                properties: "height"
                to: 30
                easing.type: Easing.InCubic
                duration: 200
            }
            PropertyAction {
                target: basicPanel
                properties: "visible"
                value: false
            }
            PropertyAction {
                targets: [leftPanel, middlePanel, rightPanel, resizeArea]
                properties: "visible"
                value: true
            }
            NumberAnimation {
                target: appWindow
                properties: "width"
                to: rightPanelExpanded ? 1269 : 1269 - 300
                easing.type: Easing.InCubic
                duration: 200
            }
            NumberAnimation {
                target: appWindow
                properties: "height"
                to: 800
                easing.type: Easing.InCubic
                duration: 200
            }
            PropertyAction {
                target: frameArea
                properties: "blocked"
                value: false
            }
            PropertyAction {
                target: titleBar
                properties: "maximizeButtonVisible"
                value: true
            }
        }

        WizardMain {
            id: wizard
            anchors.fill: parent
            onUseMoneroClicked: rootItem.state = "normal"
        }

        property int maxWidth: leftPanel.width + 655 + rightPanel.width
        property int maxHeight: 700
        MouseArea {
            id: resizeArea
            hoverEnabled: true
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 30
            width: 30

            Rectangle {
                anchors.fill: parent
                color: parent.containsMouse || parent.pressed ? "#111111" : "transparent"
            }

            Image {
                anchors.centerIn: parent
                source: parent.containsMouse || parent.pressed ? "images/resizeHovered.png" :
                                                                 "images/resize.png"
            }

            property var previousPosition
            onPressed: {
                previousPosition = globalCursor.getPosition()
            }

            onPositionChanged: {
                if(!pressed) return
                var pos = globalCursor.getPosition()
                //var delta = previousPosition - pos
                var dx = previousPosition.x - pos.x
                var dy = previousPosition.y - pos.y

                if(appWindow.width - dx > parent.maxWidth)
                    appWindow.width -= dx
                else appWindow.width = parent.maxWidth

                if(appWindow.height - dy > parent.maxHeight)
                    appWindow.height -= dy
                else appWindow.height = parent.maxHeight
                previousPosition = pos
            }
        }

        TitleBar {
            id: titleBar
            anchors.left: parent.left
            anchors.right: parent.right
            onGoToBasicVersion: {
                if(yes) goToBasicAnimation.start()
                else goToProAnimation.start()
            }

            MouseArea {
                property var previousPosition
                anchors.fill: parent
                propagateComposedEvents: true
                onPressed: previousPosition = globalCursor.getPosition()
                onPositionChanged: {
                    if (pressedButtons == Qt.LeftButton) {
                        var pos = globalCursor.getPosition()
                        var dx = pos.x - previousPosition.x
                        var dy = pos.y - previousPosition.y

                        appWindow.x += dx
                        appWindow.y += dy
                        previousPosition = pos
                    }
                }
            }
        }
    }
}
