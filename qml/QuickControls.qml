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
import "UIConstants.js" as UI

SilicaFlickable {

    width: parent.width
    height: 100
    visible: !player.showFullControls

    Rectangle {
        id: smallPlayer
        anchors.fill: parent
        color: "#BA000000"

        MouseArea {
            id: opener
            anchors.fill: parent
            onClicked: player.showFullControls = !player.showFullControls
        }

        Item {
            id: quickControls
            anchors.fill: parent
            anchors.rightMargin: UI.MARGIN_XLARGE

            SpotifyImage {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                id: cover
                spotifyId: spotifySession.currentTrack ? spotifySession.currentTrack.albumCoverId : ""
                width: 100
                height: width
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 1
                anchors.right: controls.left
                anchors.left: cover.right
                anchors.leftMargin: UI.MARGIN_XLARGE - 1
                Label {
                    font.family: UI.FONT_FAMILY
                    font.weight: Font.Bold
                    font.pixelSize: UI.FONT_DEFAULT
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: UI.COLOR_INVERTED_FOREGROUND
                    elide: Text.ElideRight
                    text: spotifySession.currentTrack ? spotifySession.currentTrack.name : ""
                }
                Label {
                    font.family: UI.FONT_FAMILY_LIGHT
                    font.weight: Font.Light
                    font.pixelSize: UI.FONT_LSMALL
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: UI.COLOR_INVERTED_FOREGROUND
                    elide: Text.ElideRight
                    text: spotifySession.currentTrack ? spotifySession.currentTrack.artists : ""
                }
                Label {
                    font.family: UI.FONT_FAMILY_LIGHT
                    font.weight: Font.Light
                    font.pixelSize: UI.FONT_LSMALL
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: UI.COLOR_INVERTED_FOREGROUND
                    elide: Text.ElideRight
                    text: spotifySession.currentTrack ? spotifySession.currentTrack.album : ""
                }
            }

            Row {
                id: controls
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: -UI.MARGIN_XLARGE
                spacing: -10

                Item {
                    width: 80; height: 100
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        id: favIcon
                        anchors.centerIn: parent
                        opacity: enabled ? (starArea.pressed ? 0.4 : 1.0) : 0.2
                        source: spotifySession.currentTrack ? (spotifySession.currentTrack.isStarred ? ("image://theme/icon-m-favorite-selected")
                                                                                                     : ("image://theme/icon-m-favorite"))
                                                            : ""
                        enabled: !spotifySession.offlineMode
                    }

                    MouseArea {
                        id: starArea
                        anchors.fill: parent
                        anchors.margins: -15
                        onClicked: spotifySession.currentTrack.isStarred = !spotifySession.currentTrack.isStarred
                   }
                }

                Item {
                    width: 80; height: 100
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        anchors.centerIn: parent
                        source: "image://theme/icon-m-previous-song"
                        opacity: previous.pressed ? 0.4 : 1.0
                    }
                    MouseArea {
                        id: previous
                        anchors.fill: parent
                        onClicked: spotifySession.playPrevious()
                    }
                }

                Item {
                    width: 80; height: 100
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        anchors.centerIn: parent
                        source: spotifySession.isPlaying ? "image://theme/icon-m-pause"
                                                         : "image://theme/icon-m-play"
                        opacity: play.pressed ? 0.4 : 1.0
                    }
                    MouseArea {
                        id: play
                        anchors.fill: parent
                        onClicked: spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
                    }
                }

                Item {
                    width: 80; height: 100
                    anchors.verticalCenter: parent.verticalCenter
                    Image {
                        anchors.centerIn: parent
                        source: "image://theme/icon-m-next-song"
                        opacity: next.pressed ? 0.4 : 1.0
                    }
                    MouseArea {
                        id: next
                        anchors.fill: parent
                        onClicked: spotifySession.playNext()
                    }
                }
            }
        }
    }

    PushUpMenu {
        MenuItem {
            text: "Shuffle"
            onClicked: shuffleSwitch.checked = !shuffleSwitch.checked
            Switch {
                id: shuffleSwitch
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onCheckedChanged: spotifySession.shuffle = checked
                Component.onCompleted: checked = spotifySession.shuffle;
            }
        }

        MenuItem {
            text: "Repeat songs"
            onClicked: repeatSwitch.checked = !repeatSwitch.checked
            Switch {
                id: repeatSwitch
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onCheckedChanged: spotifySession.repeat = checked
                Component.onCompleted: checked = spotifySession.repeat;
           }
        }
    }

}
