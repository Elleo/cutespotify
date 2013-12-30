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
import "Utilities.js" as Utilities

Page {
    anchors.rightMargin: UI.MARGIN_XLARGE
    anchors.leftMargin: UI.MARGIN_XLARGE
    enabled: !spotifySession.offlineMode

    Component.onCompleted: {
        toplist.updateResults()
    }

    Connections {
        target: spotifySession
        onOfflineModeChanged: {
            if (spotifySession.offlineMode)
                pageStack.pop(null);
            else
                toplist.updateResults()
        }
        onConnectionStatusChanged: {
            if (spotifySession.connectionStatus != SpotifySession.LoggedIn)
                pageStack.pop(null);
        }
    }

    Rectangle {
        anchors.fill: parent
        visible: spotifySession.offlineMode
        color: "#DDFFFFFF"
        z: 500

        Label {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Not available in offline mode"
            font.pixelSize: UI.FONT_XLARGE
            font.family: UI.FONT_FAMILY_LIGHT
            font.weight: Font.Light
            wrapMode: Text.WordWrap
            width: parent.width - UI.MARGIN_XLARGE * 2
            horizontalAlignment: Text.AlignHCenter
        }
    }

    SpotifyToplist {
        id: toplist
    }

/*    TrackMenu {
        id: menu
        deleteVisible: false
    }

    AlbumMenu {
        id: albumMenu
        playVisible: true
        artistVisible: true
        albumBrowse: SpotifyAlbumBrowse {
            id: menuAlbumBrowse
            onTracksChanged: albumMenu.open()
        }
    }
*/
    Column {
        id: whatsNew
        width: parent.width
        spacing: UI.MARGIN_XLARGE
        anchors.top: parent.top
        anchors.topMargin: 60

        ViewHeader {
            text: "New releases"
        }

        SpotifySearch {
            id: searchNew
            query: "tag:new"
            Component.onCompleted: search()
        }

        ListView {
            id: newAlbumsView
            width: parent.width
            height: 112
            orientation: ListView.Horizontal
            model: searchNew.albums
            clip: true
            snapMode: ListView.SnapToItem
            cacheBuffer: 3000
            pressDelay: 50

            Component.onCompleted: positionViewAtBeginning()

            delegate: SpotifyImage {
                spotifyId: modelData.coverId
                height: newAlbumsView.height
                width: height
                clip: true
                opacity: newAlbumMouse.pressed ? 0.3 : 1.0

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: newAlbumName.height + 2
                    color: "#BA000000"

                    Column {
                        id: newAlbumName
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.right: parent.right
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: -3
                        Label {
                            text: modelData.name
                            font.pixelSize: UI.FONT_XSMALL
                            font.bold: true
                            width: parent.width
                            elide: Text.ElideRight
                            color: Theme.primaryColor
                            verticalAlignment: Text.AlignVCenter
                        }
                        Label {
                            text: modelData.artist
                            font.pixelSize: UI.FONT_XXSMALL
                            font.bold: true
                            width: parent.width
                            color: Theme.primaryColor
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                MouseArea {
                    id: newAlbumMouse
                    anchors.fill: parent
                    onClicked: { pageStack.push(Qt.resolvedUrl("AlbumPage.qml"), { album: modelData }) }
                    onPressAndHold: {
                        menuAlbumBrowse.album = modelData;
                        if (menuAlbumBrowse.totalDuration > 0)
                            albumMenu.open()
                    }
                }
            }
        }
    }

    Column {
        id: header
        width: parent.width
        anchors.top: whatsNew.bottom
        anchors.topMargin: 60

        Separator {
            width: parent.width
        }

        Label {
            height: UI.LIST_TILE_SIZE * 1.5
            font.family: UI.FONT_FAMILY_BOLD
            font.weight: Font.Bold
            font.pixelSize: UI.LIST_TILE_SIZE
            color: Theme.primaryColor
            text: "Top lists"
        }

        ComboBox {
            id: selector
            currentIndex: 0
            menu: ContextMenu {
                MenuItem { text: "Tracks"; }
                MenuItem { text: "Albums"; }
                MenuItem { text: "Artists"; }
            }
            onCurrentIndexChanged: {
                results.updateResults();
            }
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
        anchors.topMargin: UI.MARGIN_XLARGE
        clip: true

        SilicaListView {
            id: results
            anchors.fill: parent
            anchors.rightMargin: UI.MARGIN_XLARGE
            anchors.leftMargin: UI.MARGIN_XLARGE
            cacheBuffer: 8000

            Component {
                id: trackComponent
                TrackDelegate {
                    name: modelData.name
                    artistAndAlbum: modelData.artists + " | " + modelData.album
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
                    artist: modelData.artist
                    albumCover: modelData.coverId
                    showIndex: true
                    onClicked: { pageStack.push(Qt.resolvedUrl("AlbumPage.qml"), { album: modelData }) }
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
                    showIndex: true
                    onClicked: { pageStack.push(Qt.resolvedUrl("ArtistPage.qml"), { artist: modelData }) }
                }
            }

            Connections {
                target: toplist
                onResultsChanged: results.updateResults()
            }

            function updateResults() {
                results.model = 0
                results.delegate = null
                if (selector.currentIndex === 0) {
                    results.delegate = trackComponent
                    results.model = toplist.tracks
                } else if (selector.currentIndex == 1) {
                    results.delegate = albumComponent
                    results.model = toplist.albums
                } else if (selector.currentIndex == 2) {
                    results.delegate = artistComponent
                    results.model = toplist.artists
                }
            }

            footer: Item {
                width: parent.width
                height: 100
            }

        }

    }

    BusyIndicator {
        anchors.centerIn: parent
        visible: toplist.busy && results.count === 0
        running: visible
    }
}
