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
    id: tracklistPage
    property variant playlist

    // TODO this property should once come from the model and shouldn't need
    // to be set manually
    property bool offlineSwitchVisible: true

    Component.onCompleted: tracksModel.filter = ""

    /*    TrackMenu {
        id: menu
        deleteVisible: playlist && spotifySession.user ? (playlist.type != SpotifyPlaylist.Starred && spotifySession.user.canModifyPlaylist(playlist))
                                                       : false
        markSeenVisible: playlist && playlist.type == SpotifyPlaylist.Inbox
    }*/

    Component {
        id: trackDelegate
        TrackDelegate {
            listModel: tracksModel.trackList
            name: searchField.text.length > 0 ? Theme.highlightText(trackName, searchField.text, Theme.highlightColor) : trackName
            artistAndAlbum: (searchField.text.length > 0 ? Theme.highlightText(artists, searchField.text, Theme.secondaryHighlightColor) : artists)
                            + " | "
                            + (searchField.text.length > 0 ? Theme.highlightText(album, searchField.text, Theme.secondaryHighlightColor) : album)
            enabled: !spotifySession.offlineMode || available
            onClicked: {
                if(isCurrentPlayingTrack && !spotifySession.isPlaying)
                        spotifySession.resume()
                else
                    tracksModel.trackList.playTrack(tracksModel.getSourceIndex(index))
            }
        }
    }

    Component {
        id: inboxDelegate
        InboxTrackDelegate {
            name: searchField.text.length > 0 ? Theme.highlightText(tackName, searchField.text, Theme.highlightColor) : trackName
            artistAndAlbum: (searchField.text.length > 0 ? Theme.highlightText(artists, searchField.text, Theme.secondaryHighlightColor) : artists)
                                                + " | "
                                                + (searchField.text.length > 0 ? Theme.highlightText(album, searchField.text, Theme.secondaryHighlightColor) : album)
            creatorAndDate: (searchField.text.length > 0 ? Theme.highlightText(creator, searchField.text, Theme.highlightColor) : creator)
                            + " | " + Qt.formatDateTime(creationDate)
            duration: tackDuration
            isPlaying: isCurrentPlayingTrack
            starred: isStarred
            available: isAvailable
            enabled: !spotifySession.offlineMode || available
            onClicked: {
                if(isCurrentPlayingTrack) {
                    if(!spotifySession.isPlaying)
                        spotifySession.resume()
                } else
                    tracksModel.trackList.playTrack(tracksModel.getSourceIndex(index))
            }
            seen: model.seen
            //            onPressAndHold: { menu.track = modelData; menu.open(); }
        }
    }

    onPlaylistChanged: {
        tracks.delegate = playlist.type == SpotifyPlaylist.Inbox ? inboxDelegate : trackDelegate
        tracks.positionViewAtBeginning();
    }

    Column {
        id: headerContainer
        width: tracks.width

        PageHeader {
            id: header
            title: (playlist.type == SpotifyPlaylist.Playlist ? playlist.name
                                                              : (playlist.type == SpotifyPlaylist.Starred ? "Starred"
                                                                                                          : "Inbox"))
        }

        TextSwitch {
            id: offlineSwitch
            width: parent.width

            text: qsTr("Available offline")
            property bool completed: false;
            onCheckedChanged: {
                if(completed) {
                    console.log("Offline changed");
                    playlist.availableOffline = !playlist.availableOffline;
                }
            }
            busy: playlist.offlineStatus === SpotifyPlaylist.Downloading
            checked: playlist.availableOffline
            Component.onCompleted: {
                completed = true;
            }
            visible: tracklistPage.offlineSwitchVisible
            enabled: visible
        }

        SearchField {
            id: searchField
            width: parent.width

            placeholderText: qsTr("Search tracks")
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            onTextChanged: tracksModel.filter = text.trim()

            EnterKey.iconSource: "image://theme/icon-m-enter-close"
            EnterKey.onClicked: {focus = false}
        }
    }

    SilicaListView {
        id: tracks
        anchors.fill: parent

        Component.onCompleted: tracks.positionViewAtBeginning();

        VerticalScrollDecorator {}

        clip: true
        pressDelay: 0
        cacheBuffer: 3000
        highlightMoveDuration: 1

        currentIndex: -1

        model: tracksModel

        header: Item {
            id: headerItemPlace
            width: headerContainer.width
            height: headerContainer.height
            Component.onCompleted: headerContainer.parent = headerItemPlace
        }
    }

    Connections {
        target: playlist
        onPlaylistDestroyed: {
            playlistsTab.pop(null);
        }
    }

    TrackListFilterModel {
        id: tracksModel
        trackList: playlist.tracks()

        Component.onCompleted: {
            init()
        }
    }
}
