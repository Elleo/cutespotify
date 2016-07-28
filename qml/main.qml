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
import QtSpotify 1.0

MainView {
    id: appWindow
    width: units.gu(43)
    height: units.gu(68)
    property string themeColor
    applicationName: "CuteSpotify"

    property alias tabs: tabGroup
    property alias searchTabAlias: searchTab
    property alias playlistSelection: playlistSelectionDialog


    Component {
        id: loginPage
        LoginPage { }
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

    onPlaylistsChanged: updatePlaylistDialog()

    function updatePlaylistDialog() {
        playlistSelectionDialog.model.clear();

        if (playlists === null)
            return;

        playlistSelectionDialog.model.append({"name": "New playlist" });

        for (var i in playlists) {
            if (playlists[i].type === SpotifyPlaylist.Playlist && spotifySession.user.canModifyPlaylist(playlists[i]))
                playlistSelectionDialog.model.append({"name": playlists[i].name, "object": playlists[i] })
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
        onPlaylistsNameChanged: {
            updatePlaylistDialog()
        }
        onIsOnlineChanged: {
            if (!spotifySession.isOnline && (!spotifySession.user || !spotifySession.offlineMode))
                openConnection();
        }
        onOfflineModeChanged: {
            if (!spotifySession.isOnline && (!spotifySession.user || !spotifySession.offlineMode))
                openConnection();
        }
        onIsLoggedInChanged: {
            if(spotifySession.isLoggedIn) {
                pageStack.clear();
                pageStack.push(tabGroup);
                player.visible = true;
            } else {
                pageStack.clear();
                pageStack.push(loginPage)
            }
        }
    }

    PageStack {
        id: pageStack
        Component.onCompleted: spotifySession.isLoggedIn ? push(tabGroup) : push(loginPage)
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
                title: "Settings"
                id: settingsTab
                page: SettingsPage { }
            }

        }
    }

    Player {
        id: player
        visible: false
    }

    Connections {
        target: UriHandler
        onOpened: {
            spotifySession.handleUri(uris[0]);
        }
    }

    function checkSearchPage() {
        if (searchTab.depth === 0) searchTab.push(Qt.resolvedUrl("SearchPage.qml"))
    }

    Component.onCompleted: {
        themeColor = "color2"
        if (!spotifySession.isOnline && (!spotifySession.user || !spotifySession.offlineMode))
            openConnection();
    }

    function openConnection() {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "http://m.google.com"); //force opening a connection
        xhr.send();
    }
}
