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

MyMenu {
    id: trackMenu

    property variant albumBrowse: null
    property bool playVisible: true
    property bool artistVisible: true
    property variant playlists: spotifySession.user ? spotifySession.user.playlists : null

    layoutContentHeight: layout.height

    NotificationBanner {
        id: banner
    }

    MySelectionDialog {
        id: selectionDialog

        titleText: "Playlists"
        parent: trackMenu.parent
        model: ListModel { }
        Button {
            text: "Add"
            onClicked: {
                var playlistItem = model.get(selectionDialog.selectedIndex);
                if (playlistItem.object) {
                    banner.text = "Album added to " + playlistItem.name;
                    playlistItem.object.addAlbum(albumBrowse);
                } else {
                    if (spotifySession.user.createPlaylistFromAlbum(albumBrowse)) {
                        banner.text = "Album added to new playlist";
                    } else {
                        banner.text = "Could not add album to new playlist";
                    }
                }
                banner.show();
            }
        }
    }

    MyMenuLayout {
        id:layout

        MyMenuItem {
            text: "Play";
            visible: playVisible
            onClicked: { albumBrowse.play() }
        }
        MyMenuItem {
            text: "Add to queue";
            onClicked: { albumBrowse.enqueue() }
        }
        MyMenuItem {
            id: starItem
            onClicked: {
                var newstar = !albumBrowse.isStarred ;
                albumBrowse.isStarred = newstar;
                if (newstar)
                    banner.text = "Album starred";
                else
                    banner.text = "Album unstarred";
                banner.show();
            }
        }
        MyMenuItem {
            text: "Artist";
            onClicked: {
                pageStack.push(Qt.resolvedUrl("ArtistPage.qml"), { artist: albumBrowse.tracks[0].artistObject })
            }
            visible: artistVisible
        }
        MyMenuItem {
            text: "Add to playlist";
            onClicked: { selectionDialog.selectedIndex = -1; selectionDialog.open(); }
        }
    }

    onPlaylistsChanged: {
        selectionDialog.model.clear();

        if (playlists === null)
            return;

        for (var i in trackMenu.playlists) {
            if (trackMenu.playlists[i].type == SpotifyPlaylist.Playlist && spotifySession.user.canModifyPlaylist(trackMenu.playlists[i]))
                selectionDialog.model.append({"name": trackMenu.playlists[i].name, "object": trackMenu.playlists[i] })
        }
        selectionDialog.model.append({"name": "New playlist" });
    }

    onStatusChanged: {
        if (status == DialogStatus.Opening && albumBrowse) {
            starItem.text = albumBrowse.isStarred ? "Unstar" : "Star";
        }
    }
}
