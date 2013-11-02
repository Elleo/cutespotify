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
import Ubuntu.Components 0.1
import QtSpotify 1.0
import "UIConstants.js" as UI

Page {
    id: albumPage

    property variant album
    anchors.rightMargin: UI.MARGIN_XLARGE
    anchors.leftMargin: UI.MARGIN_XLARGE

    SpotifyAlbumBrowse {
        id: browse

        property int trackCount: browse.tracks.length;
    }

/*    TrackMenu {
        id: menu
        deleteVisible: false
        albumVisible: false
    }

    AlbumMenu {
        id: albumMenu
        playVisible: false
        artistVisible: !browse.hasMultipleArtists
    }
*/
    Column {
        id: header
        width: parent.width
        anchors.top: parent.top

        Selector {
            id: selector
            title: album ? album.name : ""
            titleFontFamily: UI.FONT_FAMILY_LIGHT
            titleFontWeight: Font.Light
            titleFontSize: UI.FONT_LARGE
            selectedIndex: 0
            model: ListModel {
                ListElement { name: "Tracks" }
                ListElement { name: "Review" }
            }
        }

        Separator {
            width: parent.width
        }
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

    Component {
        id: reviewComponent
        Label {
            width: parent ? parent.width : 0
            height: paintedHeight + UI.MARGIN_XLARGE * 2
            text: modelData
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            font.pixelSize: UI.FONT_LSMALL
            verticalAlignment: Text.AlignVCenter
        }
    }

    Item {
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: UI.MARGIN_XLARGE
        anchors.rightMargin: -UI.MARGIN_XLARGE
        anchors.leftMargin: -UI.MARGIN_XLARGE
        clip: true

        ListView {
            id: tracks
            anchors.fill: parent
            anchors.rightMargin: UI.MARGIN_XLARGE
            anchors.leftMargin: UI.MARGIN_XLARGE

            cacheBuffer: 3000
            model: browse.tracks
            header: AlbumHeader {
                artistName: album ? album.artist : ""
                trackCount: browse.trackCount > 0 ? (browse.trackCount + (browse.trackCount > 1 ? " songs" : " song")) : ""
                timing: browse.totalDuration > 0 ? spotifySession.formatDuration(browse.totalDuration) : ""
                year: browse.trackCount > 0 && album.year > 0 ? album.year : ""
                coverId: album.coverId
                onMoreClicked: { albumMenu.albumBrowse = browse; albumMenu.open() }
            }

            Component.onCompleted: positionViewAtBeginning()

            Connections {
                target: selector
                onSelectedIndexChanged: tracks.updateResults()
            }

            Connections {
                target: browse
                onTracksChanged: tracks.updateResults()
            }

            function updateResults() {
                tracks.model = 0
                tracks.delegate = null
                if (selector.selectedIndex === 0) {
                    tracks.model = browse.tracks
                    tracks.delegate = browse.hasMultipleArtists ? compilationDelegate : albumDelegate
                } else if (selector.selectedIndex == 1) {
                    tracks.delegate = reviewComponent
                    tracks.model = browse.review
                }
                tracks.positionViewAtBeginning()
            }
        }

        Scrollbar { flickableItem: tracks }
    }

    ActivityIndicator {
        id: busy
        running: browse.busy
        visible: running
        anchors.centerIn: parent
    }
}
