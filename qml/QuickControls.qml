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

    contentHeight: height
    flickableDirection: Flickable.VerticalFlick

    opacity: Qt.inputMethod.visible || !open ? 0.0 : 1.0
    Behavior on opacity { FadeAnimation {duration: 300}}

    onOpenChanged: {
        if(!open && spotifySession.isPlaying && !appWindow.showFullControls)
            spotifySession.pause()
    }

    // overwrite default behavior to prevent weird behaviour when rotating.
    Behavior on y { }

    Item {
        anchors.fill: parent

        MouseArea {
            id: opener
            anchors.fill: parent
            onClicked: appWindow.showFullControls = !appWindow.showFullControls
        }

        Row {
            id: quickControlsItem
            width: parent.width
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            height: parent.height
            spacing: Theme.paddingLarge

            SpotifyImage {
                id: cover
                width: controlsFlickable.height
                height: width
                spotifyId: spotifySession.currentTrack ? spotifySession.currentTrack.albumCoverId : ""
            }

            Column {
                id: trackInfo
                width: parent.width - cover.width - Theme.paddingLarge
                height: parent.height
                spacing: -Theme.paddingSmall
                Label {
                    width: parent.width
                    truncationMode: TruncationMode.Fade
                    text: spotifySession.currentTrack ? spotifySession.currentTrack.name : ""
                }
                Label {
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                    truncationMode: TruncationMode.Fade
                    color: Theme.secondaryColor
                    text: spotifySession.currentTrack ? spotifySession.currentTrack.artists : ""
                }

                Row {
                    id: controls
                    width: parent.width
                    property real itemWidth: width / 4

                    IconButton {
                        width: controls.itemWidth
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: spotifySession.currentTrack ? (spotifySession.currentTrack.isStarred ? ("image://theme/icon-m-favorite-selected")
                                                                                                          : ("image://theme/icon-m-favorite"))
                                                                 : ""
                        enabled: !spotifySession.offlineMode
                        onClicked: spotifySession.currentTrack.isStarred = !spotifySession.currentTrack.isStarred
                    }

                    IconButton {
                        width: controls.itemWidth
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-previous-song"
                        onClicked: spotifySession.playPrevious()
                    }

                    IconButton {
                        width: controls.itemWidth
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: spotifySession.isPlaying ? "image://theme/icon-m-pause"
                                                              : "image://theme/icon-m-play"
                        onClicked: spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
                    }

                    IconButton {
                        width: controls.itemWidth
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-next-song"
                        onClicked: spotifySession.playNext()
                    }
                }
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
