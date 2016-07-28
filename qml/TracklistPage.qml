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
import "Utilities.js" as Util

Page {
    id: tracklistPage
    property variant playlist
    anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
    anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)

    title: (playlist.type == SpotifyPlaylist.Playlist ? playlist.name
                                                      : (playlist.type == SpotifyPlaylist.Starred ? "Starred"
                                                                                                  : "Inbox"))

    Component.onCompleted: playlist.trackFilter = ""

/*    TrackMenu {
        id: menu
        deleteVisible: playlist && spotifySession.user ? (playlist.type != SpotifyPlaylist.Starred && spotifySession.user.canModifyPlaylist(playlist))
                                                       : false
        markSeenVisible: playlist && playlist.type == SpotifyPlaylist.Inbox
    }*/

    Component {
        id: trackDelegate
        TrackDelegate {
            name: searchField.text.length > 0 ? Util.highlightWord(model.trackName, searchField.text) : model.trackName
            artistAndAlbum: (searchField.text.length > 0 ? Util.highlightWord(model.artists, searchField.text) : model.artists)
                            + " | "
                            + (searchField.text.length > 0 ? Util.highlightWord(model.album, searchField.text) : model.album)
            duration: model.duration
            highlighted: model.isCurrentPlayingTrack
            starred: model.isStarred
            available: model.isAvailable
            enabled: !spotifySession.offlineMode || available
            onClicked: {
                if(isCurrentPlayingTrack && !spotifySession.isPlaying)
                    spotifySession.resume()
                else
                    tracksModel.trackList.playTrack(tracksModel.getSourceIndex(index))
            }
            onPressAndHold: { menu.track = model; menu.open(); }
        }
    }

    onPlaylistChanged: {
        tracks.positionViewAtBeginning();
    }

    Connections {
        target: playlist
        onPlaylistDestroyed: {
            pageStack.pop(null);
        }
    }

    TrackListFilterModel {
        id: tracksModel
        trackList: playlist.tracks()

        Component.onCompleted: {
            init()
        }
    }

    ListView {
        id: tracks

        property bool showSearchField: false
        property bool _movementFromBeginning: false

        Component.onCompleted: tracks.positionViewAtBeginning();

        delegate: trackDelegate

        Timer {
            id: searchFieldTimer
            onTriggered: tracks.showSearchField = false
            interval: 5000
        }

        width: parent.width
        anchors.top: searchFieldContainer.bottom
        anchors.bottom: parent.bottom

        clip: true
        highlightMoveDuration: 1
        model: tracksModel
        header: Item {
            width: parent.width
            height: units.gu(10)
            Row {
                spacing: units.gu(2)
                anchors.right: parent.right
                anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
                anchors.verticalCenter: parent.verticalCenter
                Label {
                    text: "Available offline"
                }
                Switch {
                    onCheckedChanged: playlist.availableOffline = checked
                    Component.onCompleted: {
                        checked = playlist.availableOffline
                    }
                }
            }
        }

        onMovementStarted: {
            tracks.focus = true;
            if (atYBeginning)
                _movementFromBeginning = true;
        }

        onContentYChanged: {
            if (contentY < 0 && _movementFromBeginning) {
                showSearchField = true;
                searchFieldTimer.start()
            } else {
                _movementFromBeginning = false;
            }
        }

        footer: Item {
            width: parent.width
            height: units.gu(10)
        }
    }

    Connections {
        target: playlist
        onPlaylistDestroyed: {
            playlistsTab.pop(null);
        }
    }

    Rectangle {
        id: searchFieldContainer
        anchors.top: parent.top
        width: parent.width
        height: 0
        color: UI.COLOR_BACKGROUND
        clip: true

        Column {
            id: searchColumn
            y: units.gu(UI.MARGIN_XLARGE)
            width: parent.width
            spacing: units.gu(UI.MARGIN_XLARGE)
            opacity: 0

            AdvancedTextField {
                id: searchField
                placeholderText: "Search"
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                Keys.onReturnPressed: { tracks.focus = true }

                onTextChanged: tracksModel.filter = text.trim()

                onActiveFocusChanged: {
                    if (activeFocus)
                        searchFieldTimer.stop();
                    else if (text.length === 0)
                        searchFieldTimer.start();
                }
            }

            Separator { width: parent.width }
        }

        states: State {
            name: "visible"
            when: searchField.text.length > 0 || searchField.activeFocus || tracks.showSearchField
            PropertyChanges {
                target: searchFieldContainer
                height: searchColumn.height + units.gu(UI.MARGIN_XLARGE)
            }
            PropertyChanges {
                target: searchColumn
                opacity: 1
            }
        }

        transitions: [
            Transition {
                from: "visible"; to: ""
                SequentialAnimation {
                    NumberAnimation {
                        properties: "opacity"
                        duration: 250
                    }
                    NumberAnimation {
                        properties: "height"
                        duration: 350
                    }
                }
            },
            Transition {
                from: ""; to: "visible"
                SequentialAnimation {
                    NumberAnimation {
                        properties: "height"
                        duration: 100
                    }
                    NumberAnimation {
                        properties: "opacity"
                        duration: 200
                    }
                }
            }
        ]
    }

    Scrollbar { flickableItem: tracks }
}
