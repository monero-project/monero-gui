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

import QtQuick 6.6
import QtQuick.Controls 6.6
import QtQuick.Layouts 6.6

import FontAwesome 1.0
import "." as MoneroComponents

Popup {
    id: root
    
    width: appWindow ? Math.min(800, appWindow.width * 0.9) : 800
    height: appWindow ? Math.min(700, appWindow.height * 0.9) : 700
    x: appWindow ? (appWindow.width - width) / 2 : 0
    y: appWindow ? (appWindow.height - height) / 2 : 0
    
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    
    background: Rectangle {
        color: MoneroComponents.Style.middlePanelBackgroundColor
        border.color: MoneroComponents.Style.dimmedFontColor
        border.width: 1
        radius: 4
    }
    
    padding: 20
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 15
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            MoneroComponents.TextPlain {
                font.pixelSize: 18
                font.bold: true
                color: MoneroComponents.Style.defaultFontColor
                text: qsTr("i2p FAQ: Why is i2p Slow to Connect?") + translationManager.emptyString
                Layout.fillWidth: true
            }
            
            MoneroComponents.InlineButton {
                fontFamily: FontAwesome.fontFamilySolid
                fontStyleName: "Solid"
                fontPixelSize: 16
                text: FontAwesome.times
                tooltip: qsTr("Close") + translationManager.emptyString
                onClicked: root.close()
            }
        }
        
        // Scrollable content
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            
            ColumnLayout {
                width: root.width - 60
                spacing: 20
                
                // The "Warm-Up" Phase
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 14
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("The \"Warm-Up\" Phase: Why It's Slow") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("Unlike a standard VPN or Tor, which can connect relatively quickly, i2p requires a significant \"warm-up\" period to integrate itself into the network. When you start an i2p router, it cannot simply \"call home\" to a central server. It must autonomously build a path through the network.") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
                
                // Bootstrapping
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 14
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("Bootstrapping (The Search for Peers)") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("The router must first find other active routers (peers). If it has been offline for a while, its list of known peers might be stale. It has to \"reseed\" by fetching a new list of active peers to start the discovery process.") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
                
                // Building Tunnels
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 14
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("Building Tunnels (The 5-Minute Hurdle)") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("i2p is a packet-switched network that uses unidirectional tunnels. Your router needs to build exploratory tunnels to find the Network Database (NetDB) and then build client tunnels for your actual traffic. This involves negotiating encryption keys with multiple hops (usually nearly 12 hops for a full round trip). If your router is new to the network, other routers may reject your tunnel participation requests because they don't \"trust\" your stability yet (a metric often called \"floodfill\" or reliability scoring).") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
                
                // 5-Minute Timeout
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 14
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("The 5-Minute Timeout Setting") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("There is a specific technical parameter that might be relevant if you are seeing exactly 5 minutes of delay. The default i2p.streaming.connectTimeout is often set to 5 minutes. If your router is trying to open a stream to a destination and the tunnels aren't ready, it may spin for exactly 5 minutes before timing out or finally succeeding if a tunnel is built just in time.") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
                
                // Factors That Influence Speed
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 14
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("Factors That Influence Speed") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 15
                        rowSpacing: 8
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            font.bold: true
                            color: MoneroComponents.Style.defaultFontColor
                            text: qsTr("Cold Start:") + translationManager.emptyString
                        }
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("If the router was off for >24 hours, it effectively has to start over. Connection takes 5–15+ mins.") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            font.bold: true
                            color: MoneroComponents.Style.defaultFontColor
                            text: qsTr("Warm Start:") + translationManager.emptyString
                        }
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("If the router was only off for a few minutes, it retains active peers. Connection takes <2 mins.") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            font.bold: true
                            color: MoneroComponents.Style.defaultFontColor
                            text: qsTr("NAT/Firewall:") + translationManager.emptyString
                        }
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("If your port is not forwarded, your router is \"firewalled.\" You can still connect, but integration is much slower because you can't accept incoming connections to help build tunnels.") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            font.bold: true
                            color: MoneroComponents.Style.defaultFontColor
                            text: qsTr("Bandwidth:") + translationManager.emptyString
                        }
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("If your shared bandwidth is set too low (e.g., <30 KBps), the network may ignore you, making tunnel building very slow.") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
                
                // How to Improve It
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 14
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("How to Improve It") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            MoneroComponents.TextPlain {
                                font.family: FontAwesome.fontFamilySolid
                                font.styleName: "Solid"
                                font.pixelSize: 12
                                color: "#4CAF50"
                                text: FontAwesome.checkCircle
                            }
                            
                            MoneroComponents.TextPlain {
                                font.pixelSize: 12
                                color: MoneroComponents.Style.dimmedFontColor
                                text: qsTr("Leave it Running: The \"Golden Rule\" of i2p is uptime. The longer your router runs (24/7 is ideal), the more \"integrated\" it becomes. A router that has been running for 24 hours will be fast; a router that has been running for 5 minutes will be slow.") + translationManager.emptyString
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            MoneroComponents.TextPlain {
                                font.family: FontAwesome.fontFamilySolid
                                font.styleName: "Solid"
                                font.pixelSize: 12
                                color: "#4CAF50"
                                text: FontAwesome.checkCircle
                            }
                            
                            MoneroComponents.TextPlain {
                                font.pixelSize: 12
                                color: MoneroComponents.Style.dimmedFontColor
                                text: qsTr("Check Port Forwarding: Ensure the i2p UDP/TCP ports are forwarded in your firewall/router. A \"Firewalled\" status is the #1 cause of excessive slowness.") + translationManager.emptyString
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            MoneroComponents.TextPlain {
                                font.family: FontAwesome.fontFamilySolid
                                font.styleName: "Solid"
                                font.pixelSize: 12
                                color: "#4CAF50"
                                text: FontAwesome.checkCircle
                            }
                            
                            MoneroComponents.TextPlain {
                                font.pixelSize: 12
                                color: MoneroComponents.Style.dimmedFontColor
                                text: qsTr("Don't Restart Unnecessarily: Unlike other software where a restart fixes things, restarting i2p hurts performance because you lose your built tunnels and active peer credibility.") + translationManager.emptyString
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
                
                // Where to Find Active i2p Nodes
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 14
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("Where to Find Active i2p Nodes") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("The most reliable way to get a currently active list is to use a Monero Node Directory. These sites scan the network and list nodes that are currently online.") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("1. Monero.fail:") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        spacing: 5
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("• Go to monero.fail") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("• Uncheck \"Clear Net\" and \"Tor\" filters to see only i2p nodes") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("• You will see addresses ending in .b32.i2p") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("2. Known Trusted Nodes (For Wallets)") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("If you are looking for a \"Remote Node\" to connect your wallet to (so you don't have to download the whole blockchain), these are two widely used community nodes that maintain i2p addresses:") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        spacing: 5
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("• Feather Wallet Node: rwzulgcql2y3n6os2jhmhg6un2m33rylazfnzhf56likav47aylq.b32.i2p") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            font.family: "monospace"
                        }
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("• Trocador (Exchange Aggregator) Node: lpn5pb34rpsee3ycqtjf3vzngpibxsvzx4a3kdc3rmavgpbpclvq.b32.i2p") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            font.family: "monospace"
                        }
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 11
                        font.italic: true
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("Note: i2p addresses change less frequently than IP addresses, but if these don't work, check monero.fail for fresh ones.") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("3. Important Distinction: Wallet vs. Node") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("Connecting a Wallet (Remote Node):") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 15
                        spacing: 5
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("• You enter the .b32.i2p address into your wallet's \"Remote Node\" settings") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                        
                        MoneroComponents.TextPlain {
                            font.pixelSize: 12
                            color: MoneroComponents.Style.dimmedFontColor
                            text: qsTr("• Tip: You must have a local i2p router (like i2pd) running in the background for your wallet to route traffic to these addresses") + translationManager.emptyString
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        font.bold: true
                        color: MoneroComponents.Style.defaultFontColor
                        text: qsTr("Syncing Your Own Node (Peering):") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("If you are running monerod and want it to talk to the i2p network, you don't necessarily need a list. You can add a \"priority node\" to help it find peers faster:") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                        Layout.leftMargin: 15
                        color: MoneroComponents.Style.blackTheme ? "#2a2a2a" : "#f5f5f5"
                        border.color: MoneroComponents.Style.dimmedFontColor
                        border.width: 1
                        radius: 4
                        height: codeText.height + 10
                        
                        MoneroComponents.TextPlain {
                            id: codeText
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 5
                            font.pixelSize: 11
                            font.family: "monospace"
                            color: MoneroComponents.Style.defaultFontColor
                            text: qsTr("./monerod --add-priority-node rwzulgcql2y3n6os2jhmhg6un2m33rylazfnzhf56likav47aylq.b32.i2p") + translationManager.emptyString
                            wrapMode: Text.Wrap
                        }
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        font.bold: true
                        color: "#FFA500"
                        text: qsTr("Why is it not connecting?") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.topMargin: 10
                    }
                    
                    MoneroComponents.TextPlain {
                        font.pixelSize: 12
                        color: MoneroComponents.Style.dimmedFontColor
                        text: qsTr("If you paste an i2p address into your wallet and it fails immediately, remember the 5-minute rule we discussed. Your local i2p router needs to have built up its tunnels before it can successfully reach these remote nodes. Wait for your i2p router to show roughly 10+ active tunnels before trying to connect.") + translationManager.emptyString
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                }
            }
        }
        
        // Close button
        MoneroComponents.StandardButton {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            text: qsTr("Close") + translationManager.emptyString
            onClicked: root.close()
        }
    }
}
