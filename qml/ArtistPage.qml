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
    id: artistPage
    allowedOrientations: Orientation.All


    property variant artist
    property string artistName: artist ? artist.name : ""
    property string artistPicId: artist ? artist.pictureId : ""
    property variant browse: artist ? artist.browse() : null

    property string titleString: qsTr("Music")

    SilicaListView {
        id: artistView
        property int _state: 1
        anchors.fill: parent
        cacheBuffer: 3000

        PullDownMenu {
            MenuItem {
                text: qsTr("Top hits");
                onClicked: {
                    artistView._state = 0
                    artistView.updateResults()
                    titleString = text
                }
                visible: artistView._state != 0;
            }
            MenuItem {
                text: qsTr("Music");
                onClicked: {
                    artistView._state = 1
                    artistView.updateResults()
                    titleString = text
                }
                visible: artistView._state != 1;
            }
            MenuItem {
                text: qsTr("Biography");
                onClicked: {
                    artistView._state = 2
                    artistView.updateResults()
                    titleString = text
                }
                visible: artistView._state != 2;
            }
            MenuItem {
                text: qsTr("Related artists");
                onClicked: {
                    artistView._state = 3
                    artistView.updateResults()
                    titleString = text
                }
                visible: artistView._state != 3;
            }
        }

        VerticalScrollDecorator { }

        ViewPlaceholder {
            enabled: artistView._state == 2 && artistView.count === 0 && !browse.busy
            text: qsTr("No biography available")
        }

        Component {
            id: trackComponent
            TrackDelegate {
                listModel: browse.topTracks()
                coverId: albumCoverId
                showIndex: true
            }
        }

        Component {
            id: albumComponent
            AlbumDelegate {
                listModel: browse.albums()
                artist: sectionType === "Appears on" ? model.artist : (model.year > 0 ? model.year : "")
                enableArtistMenu: sectionType === "Appears on"
            }
        }

        Component {
            id: artistComponent
            ArtistDelegate {
                listModel: browse.similarArtists()
            }
        }

        Component {
            id: bioComponent
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.leftMargin: Theme.paddingLarge
                height: paintedHeight + Theme.paddingLarge
                text: "<style type=text/css> a { text-decoration: none; color:" + color + "} </style>" + modelData
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeSmall
            }
        }

        header: Column {
            width: parent.width
            PageHeader {
                title: artistName + ": " + titleString
                visible: artistView._state != 1
            }

            ArtistHeader {
                title: artistName
                albumCount: browse.albumCount > 0 ? (browse.albumCount + (browse.albumCount > 1 ? " albums" : " album")) : ""
                singleCount: browse.singleCount > 0 ? (browse.singleCount + (browse.singleCount > 1 ? " singles" : " single")) : ""
                compilationCount: browse.compilationCount > 0 ? (browse.compilationCount + (browse.compilationCount > 1 ? " compilations" : " compilation")) : ""
                appearsOnCount: browse.appearsOnCount > 0 ? ("Appears on " + browse.appearsOnCount + (browse.appearsOnCount > 1 ? " other albums" : " other album")) : ""
                artistPictureId: artistPicId.length > 0 ? artistPicId : browse.pictureId
                busy: browse.busy
                visible: artistView._state == 1
            }
        }

        section.property: "sectionType"


        Component {
            id: sectionComponent

            SectionHeader {
                text: section
            }
        }

        Connections {
            target: browse
            onDataChanged: artistView.updateResults()
        }

        function updateResults() {
            artistView.model = 0
            artistView.delegate = null
            artistView.section.delegate = null
            if (artistView._state == 0) {
                artistView.model = browse.topTracks()
                artistView.delegate = trackComponent
            } else if (artistView._state == 1) {
                artistView.section.delegate = sectionComponent
                artistView.delegate = albumComponent
                artistView.model = browse.albums()
            } else if (artistView._state == 2) {
                artistView.model = browse.biography
                artistView.delegate = bioComponent
            } else if (artistView._state == 3) {
                artistView.model = browse.similarArtists()
                artistView.delegate = artistComponent
            }
            artistView.positionViewAtBeginning()
        }
        Component.onCompleted: {
            updateResults()
            positionViewAtBeginning()
        }
    }
}
