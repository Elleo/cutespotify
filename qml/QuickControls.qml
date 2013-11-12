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
import Ubuntu.Layouts 0.1
import "UIConstants.js" as UI

Rectangle {
    id: smallPlayer
    width: parent.width
    height: appWindow.showSidebar ? appWindow.height : units.gu(8)
    color: "black"

    MouseArea {
        id: opener
        anchors.fill: parent

        //TODO create a new full player (maybe as a Page element?)
        //onClicked: player.showFullControls = !player.showFullControls
    }

    Image {
        id: background
        anchors.fill: parent
        source: player.openRequested ? "images/player-quickcontrols-back-open.png" : "images/player-quickcontrols-back-closed.png"
        opacity: opener.pressed ? 0.5 : 1.0
    }

    Image {
        id: arrowIcon
        anchors.centerIn: parent
        source: player.openRequested ? "image://theme/icon-m-toolbar-up-selected" : "image://theme/icon-m-toolbar-down-selected"
        opacity: player.openRequested ? 1.0 : 0.0
    }

    /* This doesn't work either currently. Layouts elements cannot be nested yet
      I reported a bug here: https://bugs.launchpad.net/ubuntu-ui-toolkit/+bug/1247457
    Layouts {
        anchors.fill: parent
<<<<<<< HEAD

        layouts: [
            ConditionalLayout {
                name: "phone"
                when: appWindow.showSidebar

                Item {
                    anchors.fill: parent
                    anchors.rightMargin: UI.MARGIN_XLARGE
                    anchors.leftMargin: UI.MARGIN_XLARGE

                    ItemLayout {
                        id: coverLayout1
                        item: "controls"

                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left

                        width: units.gu(7)
                        height: width
                    }

                    ItemLayout {
                        id: trackinfoLayout1
                        item: "trackinfo"

                        anchors {
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: 1
                            right: controlsLayout1.left
                            left: coverLayout1.right
                            leftMargin: UI.MARGIN_XLARGE - 1
                        }
                    }

                    ItemLayout {
                        id: controlsLayout1
                        item: "controls"

                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: -UI.MARGIN_XLARGE
                        }
                    }
                }
            },
            ConditionalLayout {
                name: "desktop"
                when: appWindow.showSidebar

                Item {
                    anchors.fill: parent

                   ItemLayout {
                        id: coverLayout2
                        item: "coverimage"

                        anchors.right: parent.right
                        anchors.left: parent.left

                        anchors.bottom: parent.bottom

                        height: width
                    }

                    ItemLayout {
                        id: trackinfoLayout2
                        item: "trackinfo"

                        anchors.bottom: controlsLayout2.top
                        anchors.right: parent.right
                        anchors.left: parent.left

                        height: units.gu(5)
                    }

                    ItemLayout {
                        id: controlsLayout2
                        item: "controls"

                        height: units.gu(8)

                        anchors.bottom: coverLayout2.top
                        anchors.right: parent.right
                        anchors.left: parent.left
                    }
                }
            }
        ]
=======
        anchors.rightMargin: UI.MARGIN_XLARGE
        opacity: player.openRequested ? 0.0 : 1.0
>>>>>>> c6fc2c9a98d1917554d6e332d6084ec16724ebfe

        SpotifyImage {
            Layouts.item: "coverimage"
            spotifyId: spotifySession.currentTrack ? spotifySession.currentTrack.albumCoverId : ""
<<<<<<< HEAD
=======
            width: units.gu(8)
            height: width
>>>>>>> c6fc2c9a98d1917554d6e332d6084ec16724ebfe
        }

        Column {
            Layouts.item: "trackinfo"

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
            Layouts.item: "controls"

            spacing: -10

            Item {
                width: units.gu(7); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qml/images/previous.png"
                    opacity: previous.pressed ? 0.4 : 1.0
                }
                MouseArea {
                    id: previous
                    anchors.fill: parent
                    onClicked: spotifySession.playPrevious()
                }
            }

            Item {
                width: units.gu(7); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.centerIn: parent
                    source: spotifySession.isPlaying ? "qrc:/qml/images/pause.png"
                                                     : "qrc:/qml/images/play.png"
                    opacity: play.pressed ? 0.4 : 1.0
                }
                MouseArea {
                    id: play
                    anchors.fill: parent
                    onClicked: spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
                }
            }

            Item {
                width: units.gu(7); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qml/images/next.png"
                    opacity: next.pressed ? 0.4 : 1.0
                }
                MouseArea {
                    id: next
                    anchors.fill: parent
                    onClicked: spotifySession.playNext()
                }
            }
        }
    }*/

    // Alternate version using duplicated code...
    // Phonelayout
    Item {
        anchors.fill: parent
        visible: !appWindow.showSidebar
        SpotifyImage {
            id: cover1
            spotifyId: spotifySession.currentTrack ? spotifySession.currentTrack.albumCoverId : ""

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: height
        }

        Column {
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 1
                right: controls1.left
                left: cover1.right
                leftMargin: UI.MARGIN_XLARGE - 1
            }

            height: units.gu(5)

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
            id: controls1
            width: units.gu(20)

            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                top: parent.top
                bottom: parent.bottom
                rightMargin: -UI.MARGIN_XLARGE
            }

            spacing: -10

            Item {
                width: units.gu(5); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    id: favIcon
                    anchors.centerIn: parent
                    opacity: enabled ? (starArea.pressed ? 0.4 : 1.0) : 0.2
                    source: spotifySession.currentTrack ? (spotifySession.currentTrack.isStarred ? ("qrc:/qml/images/star.png")
                                                                                                 : ("qrc:/qml/images/emptystar.png"))
                                                        : ("qrc:/qml/images/emptystar.png")
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
                width: units.gu(5); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qml/images/previous.png"
                    opacity: previous.pressed ? 0.4 : 1.0
                }
                MouseArea {
                    id: previous
                    anchors.fill: parent
                    onClicked: spotifySession.playPrevious()
                }
            }

            Item {
                width: units.gu(5); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.centerIn: parent
                    source: spotifySession.isPlaying ? "qrc:/qml/images/pause.png"
                                                     : "qrc:/qml/images/play.png"
                    opacity: play.pressed ? 0.4 : 1.0
                }
                MouseArea {
                    id: play
                    anchors.fill: parent
                    onClicked: spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
                }
            }

            Item {
                width: units.gu(5); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qml/images/next.png"
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

    // Alternate version using duplicated code...
    // Desktop layout
    Item {
        anchors.fill: parent
        visible: appWindow.showSidebar
        SpotifyImage {
            id: cover2
            spotifyId: spotifySession.currentTrack ? spotifySession.currentTrack.albumCoverId : ""

            anchors {
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            height: width
        }

        Rectangle {
            color: Qt.rgba(1,1,1,0.5)

            anchors {
                bottomMargin: units.gu(5)
                bottom: controls2.top
                right: parent.right
                left: parent.left
            }

            height: units.gu(15)

            Column {
                anchors {
                    margins: units.gu(2)
                    fill: parent
                }

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
        }

        Row {
            id: controls2
            height: units.gu(10)

            anchors {
                leftMargin: units.gu(8)
                rightMargin: units.gu(8)
                bottom: cover2.top
                right: parent.right
                left: parent.left
            }

            spacing: -10

            Item {
                width: units.gu(7); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qml/images/previous.png"
                    opacity: previous2.pressed ? 0.4 : 1.0
                }
                MouseArea {
                    id: previous2
                    anchors.fill: parent
                    onClicked: spotifySession.playPrevious()
                }
            }

            Item {
                width: units.gu(7); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.centerIn: parent
                    source: spotifySession.isPlaying ? "qrc:/qml/images/pause.png"
                                                     : "qrc:/qml/images/play.png"
                    opacity: play2.pressed ? 0.4 : 1.0
                }
                MouseArea {
                    id: play2
                    anchors.fill: parent
                    onClicked: spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
                }
            }

            Item {
                width: units.gu(7); height: units.gu(7)
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qml/images/next.png"
                    opacity: next2.pressed ? 0.4 : 1.0
                }
                MouseArea {
                    id: next2
                    anchors.fill: parent
                    onClicked: spotifySession.playNext()
                }
            }
        }

        // Small border at the side
        Rectangle {
            width: 1
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            color: "gray"
        }
    }
}
