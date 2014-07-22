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
import QtSpotifySingleton 1.0 as SearchProvider

Page {
    enabled: !spotifySession.offlineMode

    property int searchType: 0
    property variant search: SearchProvider.SpotifySearch

    Rectangle {
        anchors.fill: parent
        visible: spotifySession.offlineMode
        color: "#DDFFFFFF"
        z: 500

        Label {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Search is not available in offline mode"
            font.pixelSize: Theme.fontSizeHuge
            font.weight: Font.Light
            wrapMode: Text.WordWrap
            width: parent.width - Theme.paddingLarge * 2
            horizontalAlignment: Text.AlignHCenter
        }
    }

    /*
    TrackMenu {
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
        id: headerContainer
        width: parent.width

        spacing: Theme.paddingMedium

        PageHeader {
            title: qsTr("Search ") + currentModeString()
        }

        SearchField {
            id: searchField
            property bool _hasHadFocus: false
            placeholderText: qsTr("Search")
            width: parent.width
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            onTextChanged: {
                search.query = text.trim()
                search.search()
            }
            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.onClicked: {_hasHadFocus = false; results.focus = true;}

//            focusOutBehavior: FocusBehavior.KeepFocus
        }
    }

    SilicaListView {
        id: results
        anchors.fill: parent
        cacheBuffer: 8000
        clip: true
        currentIndex: -1

        header: Item {
            id: headerItemPlace
            width: headerContainer.width
            height: headerContainer.height
            Component.onCompleted: headerContainer.parent = headerItemPlace
        }

        model: searchType == 0 ? search.tracks() : (searchType == 1 ? search.albums : (searchType == 2 ? search.artists : search.playlists))
        delegate: searchType == 0 ? trackComponent : (searchType == 1 ? albumComponent : (searchType == 2 ? artistComponent : playlistComponent))

        PullDownMenu {
            id: selector
            MenuItem {
                visible: searchType !== 0
                text: "Tracks"
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("SearchPage.qml"),
                                      {"search" : search, "searchType" : 0})
                }
            }
            MenuItem {
                visible: searchType !== 1
                text: "Albums"
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("SearchPage.qml"),
                                      {"search" : search, "searchType" : 1})
                }
            }
            MenuItem {
                visible: searchType !== 2
                text: "Artists"
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("SearchPage.qml"),
                                      {"search" : search, "searchType" : 2})
                }
            }
            MenuItem {
                visible: searchType !== 3
                text: "Playlists"
                onClicked: {
                    pageStack.replace(Qt.resolvedUrl("SearchPage.qml"),
                                      {"search" : search, "searchType" : 3})
                }
            }
//            MenuItem { visible: searchType !== 1; text: "Albums"; onClicked: searchType = 1;}
//            MenuItem { visible: searchType !== 2; text: "Artists"; onClicked: searchType = 2;}
//            MenuItem { visible: searchType !== 3; text: "Playlists"; onClicked: searchType = 3;}
        }

        VerticalScrollDecorator { }

        ViewPlaceholder {
            text: search.didYouMean.length > 0 ? "Did you mean" : qsTr("No %1 found").arg(currentModeString() + "s")
            enabled: results.count === 0 && search.query.length > 0 && !search.busy
        }

        Component {
            id: trackComponent
            TrackDelegate {
                name: trackName
                artistAndAlbum: artists + " | " + album
                duration: trackDuration
                highlighted: isCurrentPlayingTrack
                starred: isStarred
                available: isAvailable
                // TODO onClicked: model.play()
//                onPressAndHold: { menu.track = modelData; menu.open(); }
            }
        }
        Component {
            id: albumComponent
            AlbumDelegate {
                name: modelData.name
                artist: modelData.artist
                albumCover: modelData.coverId
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
                onClicked: { pageStack.push(Qt.resolvedUrl("ArtistPage.qml"), { artist: modelData }) }
            }
        }
        Component {
            id: playlistComponent
            PlaylistDelegate {
                title: modelData.name
                iconSource: "image://theme/icon-m-sounds"

                onClicked: {
                    console.log("qml: Loading playlist")
                    var component = Qt.createComponent("TracklistPage.qml");
                    if (component.status === Component.Ready) {
                        var playlistPage = component.createObject(pageStack, { playlist: modelData.playlist });
                        pageStack.push(playlistPage);
                    }
                }
            }
        }

//        Label {
//            id: errorMessage
//            anchors.horizontalCenter: parent.horizontalCenter
//            y: 80
//            visible: results.count === 0 && search.query.length > 0 && !search.busy
//            font.pixelSize: Theme.fontSizeLarge
//            font.weight: Font.Light
//            wrapMode: Text.WordWrap
//            width: parent.width - Theme.paddingLarge * 2
//            horizontalAlignment: Text.AlignHCenter

//            text: search.didYouMean.length > 0 ? "Did you mean" : qsTr("No %1 found").arg(currentModeString() + "s")
//        }
//        Label {
//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.top: errorMessage.bottom
//            visible: results.count === 0 && search.query.length > 0 && !search.busy && search.didYouMean.length > 0
//            font.pixelSize: Theme.fontSizeLarge
//            font.weight: Font.Light
//            wrapMode: Text.WordWrap
//            width: parent.width - Theme.paddingLarge * 2
//            horizontalAlignment: Text.AlignHCenter

//            text: "<a href='didyoumean'>" + search.didYouMean + "</a>?"

//            onLinkActivated: searchField.text = search.didYouMean
//        }

    }

    function currentModeString() {
        if(searchType === 0)
            return "track";
        if(searchType === 1)
            return "album"
        if(searchType === 2)
            return "artist"
        if(searchType === 3)
            return "playlist"
    }
}
