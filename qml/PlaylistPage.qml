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

Page {
    id: playlistPage

    Connections {
        target: spotifySession
        onConnectionStatusChanged: {
            if (spotifySession.connectionStatus == SpotifySession.LoggedOut ||
                    spotifySession.connectionStatus == SpotifySession.Undefined) {
                pageStack.clear();
                pageStack.push(loginPage);
            }
        }
    }

    /*    PlaylistMenu {
        id: menu
    }

    PlaylistNameSheet {
        id: newPlaylistSheet
        title: "Playlist name"
        onAccepted: { spotifySession.user.createPlaylist(newPlaylistSheet.playlistName); }
    }
*/

    SilicaListView {
        id: playlists
        anchors.fill: parent
        clip: true
        pressDelay: 0

        cacheBuffer: 3000
        model: spotifySession.user ? spotifySession.user.playlists : 0

        PullDownMenu {
            MenuItem {
                text: "Settings"
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: "Top"
                onClicked: pageStack.push(Qt.resolvedUrl("ToplistPage.qml"))
            }
            MenuItem {
                text: "Search"
                onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
            }
        }

        header: PageHeader {
            id: header
            title: qsTr("Playlists")
        }


        VerticalScrollDecorator {}

        delegate: PlaylistDelegate {
            id: playlistDelegate
            title: !modelData.isLoaded ? "Loading..." : (modelData.type === SpotifyPlaylist.Playlist || modelData.type === SpotifyPlaylist.Folder ? modelData.name
                                                                                                                                                  : (modelData.type === SpotifyPlaylist.Starred ? "Starred"
                                                                                                                                                                                                : "Inbox"))
            subtitle: if (!modelData.isLoaded) {
                          "";
                      } else {
                          if (modelData.type === SpotifyPlaylist.Folder) {
                              modelData.playlistCount + " playlist" + (modelData.playlistCount > 1 ? "s" : "")
                          } else {
                              modelData.trackCount + " song" + (modelData.trackCount > 1 ? "s" : "")
                                      + ((spotifySession.user ? spotifySession.user.ownsPlaylist(modelData) : false) ? "" : " | by " + modelData.owner)
                          }
                      }
            extraText: modelData.type === SpotifyPlaylist.Folder || !modelData.isLoaded ? "" : spotifySession.formatDuration(modelData.totalDuration)
            offlineStatus: modelData.offlineStatus
            availableOffline: modelData.availableOffline
            downloadProgress: modelData.offlineDownloadProgress
            unseens: modelData.unseenCount
            enabled: opacity == 1.0
            opacity: (!spotifySession.offlineMode || modelData.availableOffline || modelData.type === SpotifyPlaylist.Folder) && modelData.isLoaded ? 1.0 : 0.3

            onClicked: {
                if (modelData.trackCount > 0)
                    pageStack.push(Qt.resolvedUrl("TracklistPage.qml"), {"playlist": modelData })
                else if (modelData.type === SpotifyPlaylist.Folder)
                    pageStack.push(Qt.resolvedUrl("FolderPage.qml"), {"folder": modelData })
            }
            onPressAndHold: { menu.playlist = modelData; menu.open(); }
        }

        // TODO add a way to create a new playlist
    }
}
