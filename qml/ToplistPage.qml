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
    id: toplistPage
    allowedOrientations: Orientation.All
    enabled: !spotifySession.offlineMode

    SpotifyToplist {
        id: toplist
    }

    Component.onCompleted: {
        toplist.updateResults()
    }

    Connections {
        target: spotifySession
        onOfflineModeChanged: {
            if (spotifySession.offlineMode)
                pageStack.pop();
        }
    }

    SilicaListView {
        id: results
        anchors.fill: parent
        cacheBuffer: 3000

        property int _state: 0
        property string _stateString: qsTr("tracks")

        model: toplist.tracks()
        delegate: trackComponent

        PullDownMenu {
            MenuItem {
                text: qsTr("Tracks")
                onClicked: {
                    results._state = 0;
                    results._stateString = qsTr("tracks")
                    results.updateResults();
                }
                visible: results._state != 0
            }
            MenuItem {
                text: qsTr("Albums")
                onClicked: {
                    results._state = 1;
                    results._stateString = qsTr("albums")
                    results.updateResults();
                }
                visible: results._state != 1
            }
            MenuItem {
                text: qsTr("Artists")
                onClicked: {
                    results._state = 2;
                    results._stateString = qsTr("artists")
                    results.updateResults();
                }
                visible: results._state != 2
            }
        }

        VerticalScrollDecorator {}

        Component {
            id: trackComponent
            TrackDelegate {
                listModel: toplist.tracks()
                coverId: albumCoverId
                showIndex: true
            }
        }
        Component {
            id: albumComponent
            AlbumDelegate {
                listModel: toplist.albums()
                showIndex: true
            }
        }
        Component {
            id: artistComponent
            ArtistDelegate {
                listModel: toplist.artists()
                showIndex: true
            }
        }

        header: PageHeader {
            title: qsTr("Top ") + results._stateString
        }

        function updateResults() {
            results.model = 0
            results.delegate = null
            if (results._state === 0) {
                results.delegate = trackComponent
                results.model = toplist.tracks()
            } else if (results._state == 1) {
                results.delegate = albumComponent
                results.model = toplist.albums()
            } else if (results._state == 2) {
                results.delegate = artistComponent
                results.model = toplist.artists()
            }
        }

        Connections {
            target: toplist
            onResultsChanged: if(toplistPage.status === PageStatus.Active)
                                  results.updateResults()
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        visible: /*toplist.busy && */results.count == 0 // Busy is currently not working as artists give a channel error
        running: visible
    }
}
