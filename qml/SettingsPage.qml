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

import QtQuick 2.4
import Ubuntu.Components 1.3;
import Ubuntu.Components.Popups 1.3;
import QtSpotify 1.0
import "UIConstants.js" as UI

Page {
    id: settingsPage
    anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
    anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)

    ListView {
        id: settingsFlickable
        anchors.fill: parent
        anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)

        model: 1
        delegate: Column {
            id: settingsContainer
            width: parent.width
            spacing: units.gu(UI.MARGIN_XLARGE)

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                Column {
                    width: parent.width

                    Item {
                        width: parent.width
                        height: units.gu(UI.LIST_ITEM_HEIGHT) * 1.5

                        Label {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: UI.FONT_FAMILY_BOLD
                            font.weight: Font.Bold
                            font.pixelSize: units.gu(UI.LIST_TILE_SIZE)
                            color: UI.LIST_TITLE_COLOR
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
                        height: units.gu(UI.LIST_ITEM_HEIGHT) * 1.5

                        Label {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: UI.FONT_FAMILY_BOLD
                            font.weight: Font.Bold
                            font.pixelSize: units.gu(UI.LIST_TILE_SIZE)
                            color: UI.LIST_TITLE_COLOR
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



                    Item {
                        width: parent.width
                        height: units.gu(UI.LIST_ITEM_HEIGHT) * 1.5

                        Label {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: UI.FONT_FAMILY_BOLD
                            font.weight: Font.Bold
                            font.pixelSize: units.gu(UI.LIST_TILE_SIZE)
                            color: UI.LIST_TITLE_COLOR
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
                        font.pixelSize: units.gu(UI.LIST_SUBTILE_SIZE)
                        font.weight: Font.Light
                        color: UI.LIST_SUBTITLE_COLOR
                        text: "When offline, only the playlists you've made available for offline listening will be playable."
                    }

                    Item {
                        width: parent.width
                        height: units.gu(UI.MARGIN_XLARGE) * 2
                    }
                }

                Column {
                    width: parent.width

                    Label {
                        height: units.gu(UI.LIST_TILE_SIZE) * 1.5
                        font.family: UI.FONT_FAMILY_BOLD
                        font.weight: Font.Bold
                        font.pixelSize: units.gu(UI.LIST_TILE_SIZE)
                        color: UI.LIST_TITLE_COLOR
                        text: "Stream"
                    }

                    OptionSelector {
                        model: ListModel {
                            ListElement { name: "Low quality"; description: "96kbps"; value: SpotifySession.LowQuality }
                            ListElement { name: "Normal quality"; description: "160kbps"; value: SpotifySession.HighQuality }
                            ListElement { name: "High quality"; description: "320kbps"; value: SpotifySession.UltraQuality }
                        }
                        delegate: OptionSelectorDelegate { text: name; subText: description;}
                        selectedIndex: spotifySession.streamingQuality === SpotifySession.LowQuality ? 0
                                                                                                    : spotifySession.streamingQuality === SpotifySession.HighQuality ? 1 : 2
                        onSelectedIndexChanged: spotifySession.streamingQuality = model.get(selectedIndex).value
                    }

                    Item {
                        width: parent.width
                        height: units.gu(UI.MARGIN_XLARGE) * 2
                    }

                }

                Column {
                    width: parent.width

                    Label {
                        height: units.gu(UI.LIST_TILE_SIZE) * 1.5
                        font.family: UI.FONT_FAMILY_BOLD
                        font.weight: Font.Bold
                        font.pixelSize: units.gu(UI.LIST_TILE_SIZE)
                        color: UI.LIST_TITLE_COLOR
                        text: "Offline Sync"
                    }

                    OptionSelector {
                        model: ListModel {
                            ListElement { name: "Low quality"; description: "96kbps"; value: SpotifySession.LowQuality }
                            ListElement { name: "Normal quality"; description: "160kbps"; value: SpotifySession.HighQuality }
                            ListElement { name: "High quality"; description: "320kbps"; value: SpotifySession.UltraQuality }
                        }
                        delegate: OptionSelectorDelegate { text: name; subText: description;}
                        selectedIndex: spotifySession.syncQuality === SpotifySession.LowQuality ? 0
                                                                                               : spotifySession.syncQuality === SpotifySession.HighQuality ? 1 : 2
                        onSelectedIndexChanged: spotifySession.syncQuality = model.get(selectedIndex).value
                    }

                    Item {
                        width: parent.width
                        height: units.gu(UI.MARGIN_XLARGE) * 2
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(UI.LIST_ITEM_HEIGHT) * 1.5

                    Label {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: UI.FONT_FAMILY_BOLD
                        font.weight: Font.Bold
                        font.pixelSize: units.gu(UI.LIST_TILE_SIZE)
                        color: UI.LIST_TITLE_COLOR
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
                    height: units.gu(UI.MARGIN_XLARGE) * 2

                    Separator {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(UI.MARGIN_XLARGE) * 2

                    Separator {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(UI.MARGIN_XLARGE) * 2

                    Separator {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(UI.MARGIN_XLARGE)
                }

                Button {
                    id: buttonAbout
                    text: "About"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(UI.PADDING_XXLARGE)
                    anchors.rightMargin: units.gu(UI.PADDING_XXLARGE)

                    onClicked: {
                        PopupUtils.open(aboutDialogC)
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(UI.MARGIN_XLARGE)
                }

                Button {
                    id: button
                    text: "Log out " + (spotifySession.user ? spotifySession.user.canonicalName : "")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: units.gu(UI.PADDING_XXLARGE)
                    anchors.rightMargin: units.gu(UI.PADDING_XXLARGE)

                    onClicked: {
                        spotifySession.logout(false);
                        lastfm.forgetUser();
                    }
                }

                Item {
                    width: parent.width
                    height: units.gu(UI.MARGIN_XLARGE) * 2
                }
            }
            Item {
                width: parent.width
                height: units.gu(10)
            }
        }

    }

    Component {
        id: aboutDialogC
        AboutDialog {
            id: aboutDialog
        }
    }

    Scrollbar { flickableItem: settingsFlickable }
}
