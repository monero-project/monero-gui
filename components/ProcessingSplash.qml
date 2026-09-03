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

import QtQuick 2.9
import QtQuick.Window 2.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.1

import "../components" as MoneroComponents

Rectangle {
    id: root
    color: MoneroComponents.Style.blackTheme ? "black" : "white"
    visible: false
    radius: 10
    border.color: MoneroComponents.Style.blackTheme ? Qt.rgba(255, 255, 255, 0.25) : Qt.rgba(0, 0, 0, 0.25)
    border.width: 1
    z: 11
    property alias messageText: messageTitle.text
    property alias subMessageText: messageSub.text

    // Optional Retry / Cancel row, shown instead of leaving the user
    // stuck on a splash they can't dismiss.  To use it, set
    // retryCallback and cancelCallback, set showActionButtons, then
    // call show().  Leaving retryCallback null hides Retry.
    property bool showActionButtons: false
    property var retryCallback: null
    property var cancelCallback: null

    width: 100
    height: 50

    focus: visible && showActionButtons
    Keys.onPressed: {
        if (!root.showActionButtons) return;
        if (event.key === Qt.Key_Escape) {
            root.fireCancel();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (cancelButton.activeFocus || !retryButton.visible) {
                root.fireCancel();
            } else {
                root.fireRetry();
            }
            event.accepted = true;
        }
    }

    function show() {
        root.visible = true;
        if (root.showActionButtons) {
            if (retryButton.visible) {
                retryButton.forceActiveFocus();
            } else {
                cancelButton.forceActiveFocus();
            }
        }
    }

    function close() {
        root.visible = false;
        root.showActionButtons = false;
        root.retryCallback = null;
        root.cancelCallback = null;
    }

    function fireRetry() {
        var cb = root.retryCallback;
        root.close();
        if (cb) cb();
    }

    function fireCancel() {
        var cb = root.cancelCallback;
        root.close();
        if (cb) cb();
    }

    ColumnLayout {
        id: rootLayout

        // Anchor to the splash sides so a wrapping sub-message stays
        // inside the box; anchors.centerIn leaves the layout width
        // unconstrained and long messages spill outside.
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 30
        anchors.rightMargin: 30

        spacing: 21

        Item {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.preferredHeight: 80

            Image {
                id: imgLogo
                width: 60
                height: 60
                anchors.centerIn: parent
                source: "qrc:///images/monero-vector.svg"
                mipmap: true
            }

            BusyIndicator {
                // Nothing is in progress while the action row waits for
                // the user, so the spinner stops.
                running: parent.visible && !root.showActionButtons
                anchors.centerIn: imgLogo
                style: BusyIndicatorStyle {
                    indicator: Image {
                        visible: control.running
                        source: "qrc:///images/busy-indicator.png"
                        RotationAnimator on rotation {
                            running: control.running
                            loops: Animation.Infinite
                            duration: 1000
                            from: 0
                            to: 360
                        }
                    }
                }
            }
        }


        MoneroComponents.TextPlain {
            id: messageTitle
            text: qsTr("Please wait...") + translationManager.emptyString
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true
            themeTransition: false
            color: MoneroComponents.Style.defaultFontColor
        }

        MoneroComponents.TextPlain {
            id: messageSub
            text: ""
            visible: text.length > 0
            font.pixelSize: 15
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            themeTransition: false
            color: MoneroComponents.Style.dimmedFontColor
        }

        RowLayout {
            id: actionRow
            visible: root.showActionButtons
            spacing: 16
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4

            MoneroComponents.StandardButton {
                id: cancelButton
                primary: !retryButton.visible
                small: false
                text: qsTr("Cancel") + translationManager.emptyString
                onClicked: root.fireCancel()
                KeyNavigation.tab: retryButton.visible ? retryButton : cancelButton
                KeyNavigation.backtab: retryButton.visible ? retryButton : cancelButton
            }

            MoneroComponents.StandardButton {
                id: retryButton
                visible: root.retryCallback !== null
                primary: true
                small: false
                text: qsTr("Try again") + translationManager.emptyString
                onClicked: root.fireRetry()
                KeyNavigation.tab: cancelButton
                KeyNavigation.backtab: cancelButton
            }
        }
    }
}
