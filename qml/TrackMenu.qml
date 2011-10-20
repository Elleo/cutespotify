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
import com.meego 1.0
import QtSpotify 1.0

MyMenu {
    id: trackMenu


    property variant track: null
    property bool deleteVisible: false
    property bool albumVisible: true
    property bool markSeenVisible: false

    property variant playlists: spotifySession.user ? spotifySession.user.playlists : null

    layoutContentHeight: layout.height

    NotificationBanner {
        id: banner
    }

    SelectionDialog {
        id: selectionDialog

        property alias dialogModel: playlistsModel

        ListModel {
            id: playlistsModel
        }

        titleText: "Playlists"
        parent: trackMenu.parent
        model: playlistsModel
        onAccepted: {
            var playlistItem = model.get(selectionDialog.selectedIndex);
            if (playlistItem.object) {
                banner.text = "Track added to " + playlistItem.name;
                playlistItem.object.add(track);
            } else {
                if (spotifySession.user.createPlaylistFromTrack(track)) {
                    banner.text = "Track added to new playlist";
                } else {
                    banner.text = "Could not add track to new playlist";
                }
            }
            banner.show();
        }
    }

    QueryDialog {
        id: confirmDeleteDialog
        parent: trackMenu.parent
        titleText: "Delete track?"
        message: track ? track.name : ""
        acceptButtonText: "Yes"
        rejectButtonText: "No"
        onAccepted: { track.removeFromPlaylist() }
    }

    MyMenuLayout {
        id:layout

        MyMenuItem {
            id: seenItem
            onClicked: { track.seen = !track.seen }
            visible: trackMenu.markSeenVisible && !spotifySession.offlineMode;
        }
        MyMenuItem {
            text: "Add to queue";
            onClicked: { track.enqueue() }
        }
        MyMenuItem {
            id: starItem
            onClicked: { track.isStarred = !track.isStarred }
            visible: !spotifySession.offlineMode
        }
        MyMenuItem {
            text: "Album";
            visible: trackMenu.albumVisible && !spotifySession.offlineMode
            onClicked: {
                mainPage.tabs.currentTab.push(Qt.resolvedUrl("AlbumPage.qml"), { album: track.albumObject })
            }
        }
        MyMenuItem {
            text: "Artist";
            visible: !spotifySession.offlineMode
            onClicked: {
                mainPage.tabs.currentTab.push(Qt.resolvedUrl("ArtistPage.qml"), { artist: track.artistObject })
            }
        }
        MyMenuItem {
            text: "Add to playlist";
            visible: !spotifySession.offlineMode
            onClicked: { selectionDialog.selectedIndex = -1; selectionDialog.open(); }
        }
        MyMenuItem {
            text: "Delete";
            visible: trackMenu.deleteVisible && !spotifySession.offlineMode;
            onClicked: { confirmDeleteDialog.open(); }
        }
    }

    onPlaylistsChanged: {
        selectionDialog.dialogModel.clear();

        if (playlists === null)
            return;

        for (var i in trackMenu.playlists) {
            if (trackMenu.playlists[i].type == SpotifyPlaylist.Playlist && spotifySession.user.canModifyPlaylist(trackMenu.playlists[i]))
                selectionDialog.dialogModel.append({"name": trackMenu.playlists[i].name, "object": trackMenu.playlists[i] })
        }
        selectionDialog.dialogModel.append({"name": "New playlist" });

        selectionDialog.model = 0;
        selectionDialog.model = selectionDialog.dialogModel;
    }

    onStatusChanged: {
        if (status == DialogStatus.Opening && track) {
            starItem.text = track.isStarred ? "Unstar" : "Star";
            seenItem.text = "Mark as " + (track.seen ? "unseen" : "seen");
        }
    }
}
