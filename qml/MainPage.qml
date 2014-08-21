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
import Ubuntu.Components 0.1;
import QtSpotify 1.0
import "UIConstants.js" as UI

Page {
    id: mainPage
    anchors.fill: parent

    property alias tabs: tabGroup
    property alias searchTabAlias: searchTab
    property alias playlistSelection: playlistSelectionDialog

    Component.onCompleted: {
        player.visible = true;
    }

    NotificationBanner {
        id: errorBanner
    }

    MySelectionDialog {
        id: playlistSelectionDialog

        property variant track: null

        titleText: "Playlists"

        Button {

            text: "Add"

            onClicked: {
                var playlistItem = model.get(playlistSelectionDialog.selectedIndex);
                if (playlistItem.object) {
                    errorBanner.text = "Track added to " + playlistItem.name;
                    playlistItem.object.add(track);
                } else {
                    if (spotifySession.user.createPlaylistFromTrack(track)) {
                         errorBanner.text = "Track added to new playlist";
                    } else {
                        errorBanner.text = "Could not add track to new playlist";
                    }
                }
                errorBanner.show();
            }
        }
    }

    property variant playlists: spotifySession.user ? spotifySession.user.playlistsFlat : null
    Connections {
        target: spotifySession.user
        onPlaylistsNameChanged: updatePlaylistDialog()
    }

    onPlaylistsChanged: updatePlaylistDialog()

    function updatePlaylistDialog() {
        playlistSelectionDialog.model.clear();

        if (playlists === null)
            return;

        playlistSelectionDialog.model.append({"name": "New playlist" });

        for (var i in mainPage.playlists) {
            if (mainPage.playlists[i].type === SpotifyPlaylist.Playlist && spotifySession.user.canModifyPlaylist(mainPage.playlists[i]))
                playlistSelectionDialog.model.append({"name": mainPage.playlists[i].name, "object": mainPage.playlists[i] })
        }
    }

    Connections {
        target: spotifySession
        onConnectionErrorChanged: {
            if (spotifySession.connectionError !== SpotifySession.Ok) {
                errorBanner.text = spotifySession.connectionErrorMessage;
                errorBanner.show();
            }
        }
        onOfflineErrorMessageChanged: {
            errorBanner.text = spotifySession.offlineErrorMessage;
            errorBanner.show();
        }
        onPlayTokenLost: {
            if (spotifySession.isPlaying) {
                errorBanner.text = "Playback has been paused because your account is used somewhere else";
                errorBanner.show();
            }
        }
    }

    Tabs {
        id: tabGroup

        Tab { 
            id: playlistsTab
            title: "Playlists"
            page: PlaylistPage { }
        }
        Tab {
            id: searchTab
            title: "Search"
            page: SearchPage { }
        }
        Tab {
            id: toplistTab
            title: "Top"
            page: ToplistPage { }
        }
        Tab {
            title: "Settings"
            id: settingsTab
            page: SettingsPage { }
        }

    }

    function checkSearchPage() {
        if (searchTab.depth === 0) searchTab.push(Qt.resolvedUrl("SearchPage.qml"))
    }

}
