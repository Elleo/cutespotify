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

ContextMenu {
    id: trackMenu

    property variant track: null
    property bool deleteVisible: false
    property bool albumVisible: true
    property bool markSeenVisible: false

    MenuItem {
        id: seenItem
        onClicked: { track.seen = !track.seen }
        visible: trackMenu.markSeenVisible && !spotifySession.offlineMode;
    }
    // TODO implement QUEUEING
//    MenuItem {
//        text: qsTr("Add to queue");
//        onClicked: { track.enqueue() }
//    }
    MenuItem {
        id: starItem
        onClicked: { track.isStarred = !track.isStarred }
        visible: !spotifySession.offlineMode
    }
    MenuItem {
        text: qsTr("Album");
        visible: trackMenu.albumVisible && !spotifySession.offlineMode
        onClicked: {
            pageStack.push(Qt.resolvedUrl("AlbumPage.qml"), { "album": track.albumObject })
        }
    }
    MenuItem {
        text: qsTr("Artist");
        visible: !spotifySession.offlineMode
        onClicked: {
            pageStack.push(Qt.resolvedUrl("ArtistPage.qml"), { "artist": track.artistObject })
        }
    }
    MenuItem {
        text: qsTr("Add to playlist");
        visible: !spotifySession.offlineMode
        onClicked: {
            pageStack.push(Qt.resolvedUrl("PlaylistSelectionDialog.qml"), {"track": trackMenu.track})
        }
    }
    MenuItem {
        text: qsTr("Delete");
        visible: trackMenu.deleteVisible && !spotifySession.offlineMode;
        onClicked: deleteTrack()
    }


    onActiveChanged: {
        if (active && track) {
            starItem.text = track.isStarred ? qsTr("Unstar") : qsTr("Star");
            seenItem.text = qsTr("Mark as ") + (track.seen ? qsTr("unseen") : qsTr("seen"));
        }
    }
}
