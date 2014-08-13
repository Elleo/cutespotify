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
import "UIConstants.js" as UI

Page {
    id: albumPage

    property string name
    property string coverId
    property string artist
    property string albumYear
    property variant browse
    property int trackCount: browse ? browse.tracks.length : 0

    anchors.rightMargin: UI.MARGIN_XLARGE
    anchors.leftMargin: UI.MARGIN_XLARGE

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
        anchors.topMargin: 80

        Label {
            height: UI.LIST_TILE_SIZE * 1.5
            font.family: UI.FONT_FAMILY_BOLD
            font.weight: Font.Bold
            font.pixelSize: UI.LIST_TILE_SIZE
            color: Theme.primaryColor
            text: name
        }


        ComboBox {
            id: selector
            currentIndex: 0
            menu: ContextMenu {
                MenuItem { text: "Tracks"; }
                MenuItem { text: "Review"; }
            }
            onCurrentIndexChanged: {
                tracks.updateResults();
            }
        }

        Separator {
            width: parent.width
            height: 2
            color: Theme.primaryColor
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
            isPlaying: modelData.isCurrentPlayingTrack
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
        clip: true

        SilicaListView {
            id: tracks
            anchors.fill: parent
            anchors.rightMargin: UI.MARGIN_XLARGE
            anchors.leftMargin: UI.MARGIN_XLARGE

            cacheBuffer: 3000
            model: browse.tracks
            header: AlbumHeader {
                artistName: artist
                trackCount: albumPage.trackCount > 0 ? (albumPage.trackCount + (albumPage.trackCount > 1 ? " songs" : " song")) : ""
                timing: browse.totalDuration > 0 ? spotifySession.formatDuration(browse.totalDuration) : ""
                year: albumPage.trackCount > 0 && albumYear > 0 ? albumYear : ""
                coverId: albumPage.coverId
                onMoreClicked: { albumMenu.albumBrowse = browse; albumMenu.open() }
            }

            Component.onCompleted: positionViewAtBeginning()

            Connections {
                target: browse
                onTracksChanged: tracks.updateResults()
            }

            function updateResults() {
                tracks.model = 0
                tracks.delegate = null
                if (selector.currentIndex === 0) {
                    tracks.model = browse.tracks
                    tracks.delegate = browse.hasMultipleArtists ? compilationDelegate : albumDelegate
                } else if (selector.currentIndex == 1) {
                    tracks.delegate = reviewComponent
                    tracks.model = browse.review
                }
                tracks.positionViewAtBeginning()
            }

            footer: Item {
                width: parent.width
                height: 100
            }

        }

    }

    BusyIndicator {
        id: busy
        running: browse.busy
        visible: running
        anchors.centerIn: parent
    }
}
