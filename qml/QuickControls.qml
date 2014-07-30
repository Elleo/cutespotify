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

DockedPanel {
    id: controlsFlickable

    width: parent.width
    height: 150
    open: !player.hidden

    contentHeight: height
    flickableDirection: Flickable.VerticalFlick

    MouseArea {
        id: opener
        anchors.fill: parent
        onClicked: player.showFullControls = !player.showFullControls
    }

    SpotifyImage {
        id: cover
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spotifyId: spotifySession.currentTrack ? spotifySession.currentTrack.albumCoverId : ""
        width: controlsFlickable.height
        height: width
    }

    Item {
        id: quickControls
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: cover.right
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium

        Column {
            id: trackInfo
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                truncationMode: TruncationMode.Fade
                text: spotifySession.currentTrack ? spotifySession.currentTrack.name : ""
            }
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                color: Theme.secondaryColor
                text: spotifySession.currentTrack ? spotifySession.currentTrack.artists : ""
            }
        }

        Row {
            id: controls
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.top: trackInfo.bottom
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            spacing: Theme.paddingMedium

            IconButton {
                height: quickControls.height * 0.5
                width: height
                anchors.verticalCenter: parent.verticalCenter
                icon.source: spotifySession.currentTrack ? (spotifySession.currentTrack.isStarred ? ("image://theme/icon-m-favorite-selected")
                                                                                                  : ("image://theme/icon-m-favorite"))
                                                         : ""
                enabled: !spotifySession.offlineMode
                onClicked: spotifySession.currentTrack.isStarred = !spotifySession.currentTrack.isStarred
            }

            IconButton {
                height: quickControls.height * 0.5
                width: height
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "image://theme/icon-m-previous-song"
                onClicked: spotifySession.playPrevious()
            }

            IconButton {
                height: quickControls.height * 0.5
                width: height
                anchors.verticalCenter: parent.verticalCenter
                icon.source: spotifySession.isPlaying ? "image://theme/icon-m-pause"
                                                      : "image://theme/icon-m-play"
                onClicked: spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
            }

            IconButton {
                height: quickControls.height * 0.5
                width: height
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "image://theme/icon-m-next-song"
                onClicked: spotifySession.playNext()
            }
        }
    }

    PushUpMenu {
        Row {
            width: parent.width

            Switch {
                id: shuffleSwitch
                width: parent.width * 0.5
                anchors.bottom: parent.bottom
                icon.source: "image://theme/icon-m-shuffle"
                onCheckedChanged: spotifySession.shuffle = checked
                Component.onCompleted: checked = spotifySession.shuffle;
            }

            Switch {
                id: repeatSwitch
                width: parent.width * 0.5
                anchors.bottom: parent.bottom
                icon.source: "image://theme/icon-m-repeat"
                onCheckedChanged: spotifySession.repeat = checked
                Component.onCompleted: checked = spotifySession.repeat;
            }
        }
    }
}
