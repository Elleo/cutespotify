/****************************************************************************
**
** Copyright (c) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Yoann Lopes (yoann.lopes@nokia.com)
**
** This file is part of the MeeSpot project.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions
** are met:
**
** Redistributions of source code must retain the above copyright notice,
** this list of conditions and the following disclaimer.
**
** Redistributions in binary form must reproduce the above copyright
** notice, this list of conditions and the following disclaimer in the
** documentation and/or other materials provided with the distribution.
**
** Neither the name of Nokia Corporation and its Subsidiary(-ies) nor the names of its
** contributors may be used to endorse or promote products derived from
** this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
** FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
** TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
** PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
** LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
** NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSpotify 1.0
import "UIConstants.js" as UI

Page {
    id: settingsPage

    SilicaListView {
        id: settingsFlickable
        anchors.fill: parent
        anchors.topMargin: 50
        anchors.rightMargin: UI.MARGIN_XLARGE
        anchors.leftMargin: UI.MARGIN_XLARGE

        model: 1
        delegate: Column {
            id: settingsContainer
            width: settingsPage.width

            Column {
                width: parent.width

                Column {
                    width: parent.width

                    Item {
                        width: parent.width
                        height: UI.LIST_ITEM_HEIGHT * 1.5

                        Label {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: UI.FONT_FAMILY_BOLD
                            font.weight: Font.Bold
                            font.pixelSize: UI.LIST_TILE_SIZE
                            color: Theme.primaryColor
                            text: "Shuffle"
                        }

                        Switch {
                            id: shuffleSwitch
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: spotifySession.shuffle = checked
                            Component.onCompleted: checked = spotifySession.shuffle;
                        }
                    }

                    Item {
                        width: parent.width
                        height: UI.LIST_ITEM_HEIGHT

                        Label {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: UI.FONT_FAMILY_BOLD
                            font.weight: Font.Bold
                            font.pixelSize: UI.LIST_TILE_SIZE
                            color: Theme.primaryColor
                            text: "Repeat songs"
                        }

                        Switch {
                            id: repeatSwitch
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: spotifySession.repeat = checked
                            Component.onCompleted: checked = spotifySession.repeat;
                        }   
                    }



 /*                   Item {
                        width: parent.width
                        height: UI.LIST_ITEM_HEIGHT

                        Label {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: UI.FONT_FAMILY_BOLD
                            font.weight: Font.Bold
                            font.pixelSize: UI.LIST_TILE_SIZE
                            color: Theme.primaryColor
                            text: "Offline mode"
                        }

                        Switch {
                            id: offlineSwitch
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: spotifySession.setOfflineMode(checked)

                            Component.onCompleted: checked = spotifySession.offlineMode;

                            Connections {
                                target: spotifySession
                                onOfflineModeChanged: offlineSwitch.checked = spotifySession.offlineMode
                            }
                        }
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.family: UI.FONT_FAMILY_LIGHT
                        font.pixelSize: UI.LIST_SUBTILE_SIZE
                        font.weight: Font.Light
                        color: Theme.secondaryColor
                        text: "When offline, only the playlists you've made available for offline listening will be playable."
                    }
*/
                    Item {
                        width: parent.width
                        height: UI.MARGIN_XLARGE * 2
                    }
                }

                Column {
                    width: parent.width

                    Label {
                        height: UI.LIST_TILE_SIZE
                        font.family: UI.FONT_FAMILY_BOLD
                        font.weight: Font.Bold
                        font.pixelSize: UI.LIST_TILE_SIZE
                        color: Theme.primaryColor
                        text: "Stream"
                    }


                    ComboBox {
                        menu: ContextMenu {
                            MenuItem { text: "Low quality (96kbps)"; onClicked: spotifySession.streamingQuality = SpotifySession.LowQuality }
                            MenuItem { text: "Normal quality (160kbps)"; onClicked: spotifySession.streamingQuality = SpotifySession.HighQuality }
                            MenuItem { text: "High quality (320kbps)"; onClicked: spotifySession.streamingQuality = SpotifySession.UltraQuality }
                        }
                        currentIndex: spotifySession.streamingQuality === SpotifySession.LowQuality ? 0
                                                                                                   : spotifySession.streamingQuality === SpotifySession.HighQuality ? 1 : 2
                    }

                    Item {
                        width: parent.width
                        height: UI.MARGIN_XLARGE * 2
                    }

                }

                Column {
                    width: parent.width

                    Label {
                        height: UI.LIST_TILE_SIZE
                        font.family: UI.FONT_FAMILY_BOLD
                        font.weight: Font.Bold
                        font.pixelSize: UI.LIST_TILE_SIZE
                        color: Theme.primaryColor
                        text: "Offline Sync"
                    }

                    ComboBox {
                        menu: ContextMenu {
                            MenuItem { text: "Low quality (96kbps)"; onClicked: spotifySession.syncQuality = SpotifySession.LowQuality }
                            MenuItem { text: "Normal quality (160kbps)"; onClicked: spotifySession.syncQuality = SpotifySession.HighQuality }
                            MenuItem { text: "High quality (320kbps)"; onClicked: spotifySession.syncQuality = SpotifySession.UltraQuality }
                        }
                        currentIndex: spotifySession.syncQuality === SpotifySession.LowQuality ? 0
                                                                                              : spotifySession.syncQuality === SpotifySession.HighQuality ? 1 : 2
                    }

                    Item {
                        width: parent.width
                        height: UI.MARGIN_XLARGE * 2
                    }
                }

                Item {
                    width: parent.width
                    height: UI.LIST_ITEM_HEIGHT

                    Label {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: UI.FONT_FAMILY_BOLD
                        font.weight: Font.Bold
                        font.pixelSize: UI.LIST_TILE_SIZE
                        color: Theme.primaryColor
                        text: "Sync over 2G/3G"
                    }

                    Switch {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: spotifySession.syncOverMobile
                        onCheckedChanged: spotifySession.setSyncOverMobile(checked)
                    }
                }

                Item {
                    width: parent.width
                    height: UI.MARGIN_XLARGE * 2
                }

                Item {
                    width: parent.width
                    height: UI.LIST_ITEM_HEIGHT

                    Label {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: UI.FONT_FAMILY_BOLD
                        font.weight: Font.Bold
                        font.pixelSize: UI.LIST_TILE_SIZE
                        color: Theme.primaryColor
                        text: "Scrobble to Last.fm"
                    }

                    Switch {
                        id: scrobbleSwitch
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: spotifySession.scrobble
                        onCheckedChanged: spotifySession.scrobble = checked
                    }
                }

                Column {
                    width: parent.width
                    visible: scrobbleSwitch.checked

                    Item {
                        width: parent.width
                        height: UI.MARGIN_XLARGE * 2
                    }

                    TextField {
                        id: lfmUser
                        visible: !spotifySession.lfmLoggedIn
                        placeholderText: "Last.fm Username"
                        width: parent.width
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                        Keys.onReturnPressed: {
                            lfmPass.forceActiveFocus();
                        }
                    }

                    TextField {
                        id: lfmPass
                        visible: !spotifySession.lfmLoggedIn
                        placeholderText: "Last.fm Password"
                        echoMode: TextInput.Password
                        width: parent.width
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                    }

                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: spotifySession.lfmLoggedIn ? "Logout of Last.fm" : "Login to Last.fm";
                        onClicked: {
                            if(spotifySession.lfmLoggedIn) {
                                spotifySession.lfmLogin("", "");
                            } else {
                                spotifySession.lfmLogin(lfmUser.text, lfmPass.text);
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: UI.MARGIN_XLARGE * 2
                }

                Button {
                    id: buttonAbout
                    text: "About"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        pageStack.push(aboutDialogC)
                    }
                }

                Item {
                    width: parent.width
                    height: UI.MARGIN_XLARGE
                }

                Button {
                    id: button
                    text: "Log out " + (spotifySession.user ? spotifySession.user.canonicalName : "")
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        spotifySession.logout(false);
                    }
                }

                Item {
                    width: parent.width
                    height: UI.MARGIN_XLARGE * 2
                }
            }
            Item {
                width: parent.width
                height: 100
            }
        }

    }

    Component {
        id: aboutDialogC
        AboutDialog {
            id: aboutDialog
        }
    }

}
