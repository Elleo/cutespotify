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
import "Utilities.js" as Util

Page {
    id: tracklistPage

    property variant playlist
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
            name: searchField.text.length > 0 ? Util.highlightWord(modelData.name, searchField.text) : modelData.name
            artist: searchField.text.length > 0 ? Util.highlightWord(modelData.artists, searchField.text) : modelData.artists
            album: searchField.text.length > 0 ? Util.highlightWord(modelData.album, searchField.text) : modelData.album
            duration: modelData.duration
            highlighted: modelData.isCurrentPlayingTrack
            starred: modelData.isStarred
            available: modelData.isAvailable
            enabled: !spotifySession.offlineMode || available
            onClicked: {
                modelData.play()
            }
            onPressAndHold: { menu.track = modelData; menu.open(); }
        }
    }

    Component {
        id: inboxDelegate
        InboxTrackDelegate {
            name: searchField.text.length > 0 ? Util.highlightWord(modelData.name, searchField.text) : modelData.name
            artistAndAlbum: (searchField.text.length > 0 ? Util.highlightWord(modelData.artists, searchField.text) : modelData.artists)
                            + " | "
                            + (searchField.text.length > 0 ? Util.highlightWord(modelData.album, searchField.text) : modelData.album)
            creatorAndDate: (searchField.text.length > 0 ? Util.highlightWord(modelData.creator, searchField.text) : modelData.creator)
                            + " | " + Qt.formatDateTime(modelData.creationDate)
            duration: modelData.duration
            highlighted: modelData.isCurrentPlayingTrack
            starred: modelData.isStarred
            available: modelData.isAvailable
            enabled: !spotifySession.offlineMode || available
            onClicked: {
                modelData.play()
            }
            seen: modelData.seen
            onPressAndHold: { menu.track = modelData; menu.open(); }
        }
    }

    onPlaylistChanged: {
        tracks.delegate = playlist.type == SpotifyPlaylist.Inbox ? inboxDelegate : trackDelegate
        tracks.positionViewAtBeginning();
    }

    Item {
        // FIXME: Bug in conditional layouts. Have to add this to every page...
        anchors.leftMargin: appWindow.showSidebar ? units.gu(appWindow.sidebarWidth) : 0
        anchors.fill: parent

        ListView {

            id: tracks

            property bool showSearchField: false
            property bool _movementFromBeginning: false

            Component.onCompleted: tracks.positionViewAtBeginning();

            Timer {
                id: searchFieldTimer
                onTriggered: tracks.showSearchField = false
                interval: 5000
            }

            width: parent.width
            anchors.top: searchFieldContainer.bottom
            anchors.bottom: parent.bottom

            cacheBuffer: 3000
            highlightMoveDuration: 1
            model: playlist.tracks
            header: Item {
                anchors {
                    right: parent.right
                    left: parent.left

                    rightMargin: UI.MARGIN_XLARGE
                    leftMargin: UI.MARGIN_XLARGE
                }

                height: units.gu(10)
                Label {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: UI.FONT_FAMILY_BOLD
                    font.weight: Font.Bold
                    font.pixelSize: appWindow.showSidebar ? units.gu(4) : units.gu(2)
                    color: UI.LIST_TITLE_COLOR
                    text: (playlist.type === SpotifyPlaylist.Playlist ? playlist.name
                                                                     : (playlist.type === SpotifyPlaylist.Starred ? "Starred"
                                                                                                                 : "Inbox"))
                }
                Row {
                    spacing: units.gu(2)
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        text: "Available offline"
                    }
                    Switch {
                        onCheckedChanged: playlist.availableOffline = !playlist.availableOffline
                        checked: playlist.availableOffline
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
        }

        Connections {
            target: playlist
            onPlaylistDestroyed: {
                playlistsTab.pop(null);
            }
        }

        Rectangle {
            color: Qt.rgba(1,1,1,0.8)

            anchors {
                top: parent.top
                right: parent.right
                left: parent.left
            }

            id: searchFieldContainer
            height: 0
            clip: true

            opacity: 0

            AdvancedTextField {
                anchors {
                    fill: parent
                    margins: units.gu(1)
                }

                id: searchField
                placeholderText: "Search"
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                Keys.onReturnPressed: { tracks.focus = true }

                onTextChanged: playlist.trackFilter = Util.trim(text)

                onActiveFocusChanged: {
                    if (activeFocus)
                        searchFieldTimer.stop();
                    else if (text.length === 0)
                        searchFieldTimer.start();
                }
            }

            states: State {
                name: "visible"

                //always show search field if there is enough height
                when: searchField.text.length > 0 || searchField.activeFocus || tracks.showSearchField || appWindow.showSidebar

                PropertyChanges {
                    target: searchFieldContainer
                    height: units.gu(6)
                }

                PropertyChanges {
                    target: searchFieldContainer
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
}
