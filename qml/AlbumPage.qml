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
    id: albumPage

    property variant album
    orientationLock: PageOrientation.LockPortrait
    anchors.rightMargin: UI.MARGIN_XLARGE
    anchors.leftMargin: UI.MARGIN_XLARGE

    onStatusChanged: if (status == PageStatus.Active) browse.album = albumPage.album

    SpotifyAlbumBrowse {
        id: browse
    }

    TrackMenu {
        id: menu
        deleteVisible: false
        albumVisible: false
    }

    AlbumMenu {
        id: albumMenu
        playVisible: false
        artistVisible: !browse.hasMultipleArtists
    }

    Component {
        id: albumDelegate
        AlbumTrackDelegate {
            name: modelData.name
            duration: modelData.duration
            highlighted: modelData.isCurrentPlayingTrack
            starred: modelData.isStarred
            available: modelData.isAvailable
            onClicked: modelData.play()
            onPressAndHold: { menu.track = modelData; menu.open(); }
        }
    }

    Component {
        id: compilationDelegate
        TrackDelegate {
            name: modelData.name
            artistAndAlbum: modelData.artists
            duration: modelData.duration
            highlighted: modelData.isCurrentPlayingTrack
            starred: modelData.isStarred
            available: modelData.isAvailable
            onClicked: modelData.play()
            onPressAndHold: { menu.track = modelData; menu.open(); }
        }
    }

    ListView {
        id: tracks
        anchors.fill: parent

        model: browse.tracks
        header: AlbumHeader {
            albumName: album ? album.name : ""
            artistName: album ? album.artist : ""
            trackCount: tracks.count > 0 ? (tracks.count + (tracks.count > 1 ? " songs" : " song")) : ""
            timing: browse.totalDuration > 0 ? spotifySession.formatDuration(browse.totalDuration) : ""
            year: tracks.count > 0 && album.year > 0 ? album.year : ""
            coverId: album.coverId
            onMoreClicked: { albumMenu.albumBrowse = browse; albumMenu.open() }
        }

        onCountChanged: {
            delegate = browse.hasMultipleArtists ? compilationDelegate : albumDelegate
        }
    }

    ScrollDecorator { flickableItem: tracks }
}
