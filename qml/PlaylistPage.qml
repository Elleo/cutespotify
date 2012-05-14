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


import QtQuick 1.1
import com.nokia.meego 1.0
import QtSpotify 1.0
import "UIConstants.js" as UI

Page {
    id: playlistPage
    orientationLock: PageOrientation.LockPortrait
    pageStack: parent
    anchors.rightMargin: UI.MARGIN_XLARGE
    anchors.leftMargin: UI.MARGIN_XLARGE

    Connections {
        target: spotifySession
        onOfflineModeChanged: {
            if (spotifySession.offlineMode)
                pageStack.pop(null);
        }
        onConnectionStatusChanged: {
            if (spotifySession.connectionStatus != SpotifySession.LoggedIn)
                pageStack.pop(null);
        }
    }

    PlaylistMenu {
        id: menu
    }

    PlaylistNameSheet {
        id: newPlaylistSheet
        title: "Playlist name"
        onAccepted: { spotifySession.user.createPlaylist(newPlaylistSheet.playlistName); }
    }

    ListView {
        id: playlists
        anchors.fill: parent

        cacheBuffer: 3000
        model: spotifySession.user ? spotifySession.user.playlists : 0

        Component.onCompleted: positionViewAtBeginning()

        delegate: PlaylistDelegate {
            title: (modelData.type == SpotifyPlaylist.Playlist ? modelData.name
                                                               : (modelData.type == SpotifyPlaylist.Starred ? "Starred"
                                                                                                            : "Inbox"))
            subtitle: modelData.trackCount + " song" + (modelData.trackCount > 1 ? "s" : "")
                      + ((spotifySession.user ? spotifySession.user.ownsPlaylist(modelData) : false) ? "" : " | by " + modelData.owner)
            extraText: spotifySession.formatDuration(modelData.totalDuration)
            visible: modelData.isLoaded
            icon: modelData.collaborative ? "images/icon-m-collaborative-playlist.png" : staticIcon
            offlineStatus: modelData.offlineStatus
            availableOffline: modelData.availableOffline
            downloadProgress: modelData.offlineDownloadProgress
            unseens: modelData.unseenCount
            enabled: opacity == 1.0
            opacity: !spotifySession.offlineMode || modelData.availableOffline ? 1.0 : 0.3

            onClicked: {
                if (modelData.trackCount > 0) {
                    var component = Qt.createComponent("TracklistPage.qml");
                    if (component.status == Component.Ready) {
                        var playlistPage = component.createObject(pageStack, { playlist: modelData });
                        pageStack.push(playlistPage);
                    }
                }
            }
            onPressAndHold: { menu.playlist = modelData; menu.open(); }

            property string staticIcon
            Component.onCompleted: {
                if (modelData.type == SpotifyPlaylist.Playlist)
                    staticIcon = "image://theme/icon-m-music-video-all-songs";
                else if (modelData.type == SpotifyPlaylist.Starred)
                    staticIcon = "image://theme/icon-m-common-favorite-mark-inverse";
                else if (modelData.type == SpotifyPlaylist.Inbox)
                    staticIcon = "image://theme/icon-m-toolbar-directory-move-to-white-selected";
            }
        }

        header: ViewHeader {
            text: "Playlists" + (spotifySession.offlineMode ? " (Offline mode)" : "")
        }

        footer: Item {
            height: visible ? (UI.LIST_ITEM_HEIGHT + separator.height) : 0
            width: parent.width
            visible: !spotifySession.offlineMode

            Separator {
                id: separator
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
            }

            Rectangle {
                id: background
                anchors.fill: row
                // Fill page porders
                anchors.leftMargin: -UI.MARGIN_XLARGE
                anchors.rightMargin: -UI.MARGIN_XLARGE
                opacity: mouseArea.pressed ? 1.0 : 0.0
                color: "#22FFFFFF"
            }

            Row {
                id: row
                width: parent.width
                anchors.top: separator.bottom
                anchors.bottom: parent.bottom
                spacing: UI.LIST_ITEM_SPACING

                Item {
                    id: iconItem
                    anchors.verticalCenter: parent.verticalCenter
                    visible: iconImage.source !== "" ? true : false
                    width: 40
                    height: 40

                    Image {
                        id: iconImage
                        anchors.centerIn: parent
                        source: theme.inverted ? "image://theme/icon-m-input-add" : "image://theme/icon-m-common-add"
                        opacity: 0.4
                    }
                }

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: UI.FONT_FAMILY_BOLD
                    font.weight: Font.Bold
                    font.pixelSize: UI.LIST_TILE_SIZE
                    color: theme.inverted ? UI.LIST_TITLE_COLOR_INVERTED : UI.LIST_TITLE_COLOR
                    opacity: 0.4
                    text: "New playlist"
                }
            }

            MouseArea {
                id: mouseArea;
                anchors.fill: parent
                onClicked: {
                    newPlaylistSheet.playlistName = "";
                    newPlaylistSheet.open();
                }
            }
        }

        section.criteria: ViewSection.FirstCharacter
        section.property: "listSection"
        section.delegate: Separator {
            anchors.left: parent.left
            anchors.right: parent.right
            visible: section == "p"
        }
    }

    Scrollbar { listView: playlists }
}
