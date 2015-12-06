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
import Ubuntu.Components 1.3
import QtSpotify 1.0
import "UIConstants.js" as UI

Page {
    id: artistPage

    property variant artist
    anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
    anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)

    title: artist ? artist.name : "Artist"


    Component.onCompleted: {
        browse.artist = artist
    }

    SpotifyArtistBrowse {
        id: browse
    }

/*    TrackMenu {
        id: menu
        deleteVisible: false
    }

    AlbumMenu {
        id: albumMenu
        playVisible: true
        artistVisible: false
        albumBrowse: SpotifyAlbumBrowse {
            id: menuAlbumBrowse
            onTracksChanged: albumMenu.open()
        }
    }
*/
    Column {
        id: header
        width: parent.width - units.gu(UI.MARGIN_XLARGE)
        anchors.top: parent.top
        anchors.topMargin: units.gu(UI.MARGIN_XLARGE)

        OptionSelector {
            id: selector
            selectedIndex: 1
            model: ListModel {
                ListElement { name: "Top hits" }
                ListElement { name: "Music" }
                ListElement { name: "Biography" }
                ListElement { name: "Related artists" }
            }
            delegate: OptionSelectorDelegate { text: name }
        }

        Separator {
            width: parent.width
        }
    }

    Item {
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: units.gu(UI.MARGIN_XLARGE)
        anchors.rightMargin: -units.gu(UI.MARGIN_XLARGE)
        anchors.leftMargin: -units.gu(UI.MARGIN_XLARGE)
        clip: true
        visible: !browse.busy

        ListView {
            id: artistView
            anchors.fill: parent
            anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
            anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)
            cacheBuffer: 3000

            Component.onCompleted: positionViewAtBeginning()

            Component {
                id: trackComponent
                TrackDelegate {
                    name: modelData.name
                    artistAndAlbum: modelData.album
                    duration: modelData.duration
                    highlighted: modelData.isCurrentPlayingTrack
                    starred: modelData.isStarred
                    coverId: modelData.albumCoverId
                    showIndex: true
                    available: modelData.isAvailable
                    onClicked: modelData.play()
                    onPressAndHold: { menu.track = modelData; menu.open(); }
                }
            }

            Component {
                id: albumComponent
                AlbumDelegate {
                    name: modelData.name
                    artist: modelData.sectionType == "Appears on" ? modelData.artist : (modelData.year > 0 ? modelData.year : "")
                    albumCover: modelData.coverId
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("AlbumPage.qml"), { album: modelData })
                    }
                    onPressAndHold: {
                        menuAlbumBrowse.album = modelData;
                        if (menuAlbumBrowse.totalDuration > 0)
                            albumMenu.open()
                    }
                }
            }

            Component {
                id: artistComponent
                ArtistDelegate {
                    name: modelData.name
                    portrait: modelData.pictureId
                    onClicked: { pageStack.push(Qt.resolvedUrl("ArtistPage.qml"), { artist: modelData }) }
                }
            }

            Component {
                id: bioComponent
                Label {
                    width: parent ? parent.width : 0
                    height: paintedHeight + units.gu(UI.MARGIN_XLARGE)
                    text: "<style type=text/css> a { text-decoration: none; color:" + color + "} </style>" + modelData
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                    font.pixelSize: units.gu(UI.FONT_LSMALL)
                }
            }

            Component {
                id: headerComponent
                ArtistHeader {
                    albumCount: browse.albumCount > 0 ? (browse.albumCount + (browse.albumCount > 1 ? " albums" : " album")) : ""
                    singleCount: browse.singleCount > 0 ? (browse.singleCount + (browse.singleCount > 1 ? " singles" : " single")) : ""
                    compilationCount: browse.compilationCount > 0 ? (browse.compilationCount + (browse.compilationCount > 1 ? " compilations" : " compilation")) : ""
                    appearsOnCount: browse.appearsOnCount > 0 ? ("Appears on " + browse.appearsOnCount + (browse.appearsOnCount > 1 ? " other albums" : " other album")) : ""
                    artistPictureId: artist.pictureId.length > 0 ? artist.pictureId : browse.pictureId
                    busy: browse.busy
                }
            }

            Component {
                id: sectionComponent
                Item {
                    width: parent.width
                    height: sectionText.height

                    Separator {
                        anchors.left: parent.left
                        anchors.right: sectionText.left
                        anchors.rightMargin: units.gu(UI.MARGIN_XLARGE) * 2
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Label {
                        id: sectionText
                        anchors.right: parent.right
                        anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: UI.FONT_FAMILY_BOLD
                        font.pixelSize: units.gu(UI.FONT_SMALL)
                        font.weight: Font.Bold
                        color: "#808080"
                        text: section
                    }
                }
            }

            section.property: "sectionType"

            Connections {
                target: selector
                onSelectedIndexChanged: artistView.updateResults()
            }

            Connections {
                target: browse
                onDataChanged: artistView.updateResults()
            }

            function updateResults() {
                artistView.model = 0
                artistView.delegate = null
                artistView.header = null
                artistView.section.delegate = null
                if (selector.selectedIndex === 0) {
                    artistView.model = browse.topTracks
                    artistView.delegate = trackComponent
                } else if (selector.selectedIndex == 1) {
                    artistView.header = headerComponent
                    artistView.section.delegate = sectionComponent
                    artistView.delegate = albumComponent
                    artistView.model = browse.albums
                } else if (selector.selectedIndex == 2) {
                    artistView.model = browse.biography
                    artistView.delegate = bioComponent
                } else if (selector.selectedIndex == 3) {
                    artistView.model = browse.similarArtists
                    artistView.delegate = artistComponent
                }
                artistView.positionViewAtBeginning()
            }

            footer: Item {
                width: parent.width
                height: units.gu(10)
            }
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 100
            visible: selector.selectedIndex == 2 && artistView.count === 0 && !browse.busy
            text: "No biography available"
            font.pixelSize: units.gu(UI.FONT_LARGE)
            font.family: UI.FONT_FAMILY_LIGHT
            font.weight: Font.Light
        }

        Scrollbar { flickableItem: artistView }
    }

    ActivityIndicator {
        id: busy
        running: browse.busy
        visible: running
        anchors.centerIn: parent
    }
}
