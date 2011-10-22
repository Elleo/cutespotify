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
import "UIConstants.js" as UI

Page {
    id: tracklistPage
    property variant playlist
    orientationLock: PageOrientation.LockPortrait
    anchors.rightMargin: UI.MARGIN_XLARGE
    anchors.leftMargin: UI.MARGIN_XLARGE

    TrackMenu {
        id: menu
        deleteVisible: playlist && spotifySession.user ? (playlist.type != SpotifyPlaylist.Starred && spotifySession.user.canModifyPlaylist(playlist))
                                                       : false
        markSeenVisible: playlist && playlist.type == SpotifyPlaylist.Inbox
    }

    Component {
        id: trackDelegate
        TrackDelegate {
            name: modelData.name
            artistAndAlbum: modelData.artists + " | " + modelData.album
            duration: modelData.duration
            highlighted: modelData.isCurrentPlayingTrack
            starred: modelData.isStarred
            available: modelData.isAvailable
            enabled: !spotifySession.offlineMode || available
            onClicked: {
                modelData.play()
            }
            onPressAndHold: { menu.track = modelData; menu.open(); }
        }
    }

    Component {
        id: inboxDelegate
        InboxTrackDelegate {
            name: modelData.name
            artistAndAlbum: modelData.artists + " | " + modelData.album
            creatorAndDate: modelData.creator + " | " + Qt.formatDateTime(modelData.creationDate)
            duration: modelData.duration
            highlighted: modelData.isCurrentPlayingTrack
            starred: modelData.isStarred
            available: modelData.isAvailable
            enabled: !spotifySession.offlineMode || available
            onClicked: {
                modelData.play()
            }
            seen: modelData.seen
            onPressAndHold: { menu.track = modelData; menu.open(); }
        }
    }

    ListView {
        id: tracks
        anchors.fill: parent

        highlightMoveDuration: 1
        model: playlist.tracks
        header: ViewHeader {
            text: (playlist.type == SpotifyPlaylist.Playlist ? playlist.name
                                                             : (playlist.type == SpotifyPlaylist.Starred ? "Starred"
                                                                                                         : "Inbox"))
        }

        Component.onCompleted: {
            tracks.delegate = playlist.type == SpotifyPlaylist.Inbox ? inboxDelegate : trackDelegate
        }
    }

    Connections {
        target: playlist
        onPlaylistDestroyed: {
            playlistsTab.pop(null);
        }
    }

    ScrollDecorator { flickableItem: tracks }
}
