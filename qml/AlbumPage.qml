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
    property int trackCount: browse ? browse.trackCount : 0

    SilicaListView {
        id: tracks
        anchors.fill: parent

        PullDownMenu {
            id: pullMenu
            property int _state : 0 // 0 for tracks // 1 for review
            MenuItem {
                text: qsTr("Tracks")
                onClicked: {
                    pullMenu._state = 0
                    tracks.model = browse.tracks()
                    tracks.delegate = browse.hasMultipleArtists ? compilationDelegate : albumDelegate
                }
                visible: pullMenu._state == 1
            }
            MenuItem {
                text: qsTr("Review")
                onClicked: {
                    pullMenu._state = 1
                    tracks.delegate = reviewComponent
                    tracks.model = browse.review
                }
                visible: pullMenu._state == 0
            }
        }

        VerticalScrollDecorator { }

        ViewPlaceholder {
            enabled: browse.busy
            BusyIndicator {
                id: busy
                running: browse.busy
                visible: running
                anchors.centerIn: parent
            }
        }

        cacheBuffer: 3000
        model: browse.tracks()
        header: Column {
            width: parent.width
            PageHeader {
                title: name
            }

            AlbumHeader {
                artistName: artist
                trackCount: albumPage.trackCount > 0 ? (albumPage.trackCount + (albumPage.trackCount > 1 ? " songs" : " song")) : ""
                timing: browse.totalDuration > 0 ? spotifySession.formatDuration(browse.totalDuration) : ""
                year: albumPage.trackCount > 0 && albumYear > 0 ? albumYear : ""
                coverId: albumPage.coverId
            }
        }

        Component.onCompleted: {
            tracks.model = browse.tracks()
            tracks.delegate = browse.hasMultipleArtists ? compilationDelegate : albumDelegate
            positionViewAtBeginning()
        }

        Component {
            id: albumDelegate
            AlbumTrackDelegate {
                listModel: browse.tracks()
            }
        }

        Component {
            id: compilationDelegate
            TrackDelegate {
                listModel: browse.tracks()
                artistAndAlbum: model.artists
            }
        }

        Component {
            id: reviewComponent
            Label {
                width: parent ? parent.width : 0
                height: paintedHeight + Theme.paddingLarge * 2
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right:  parent.right
                anchors.rightMargin: Theme.paddingLarge
                text: parent ? modelData : ""
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}
