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
    id: fcPage
    showNavigationIndicator: false
    backNavigation: false
    allowedOrientations: Orientation.All

    Component.onCompleted: {
        flipable.width=Math.min(width, height)
        flipable.height=flipable.width
    }

    property bool albumRequested: false
    property bool artistRequested: false

    Connections {
        target: spotifySession
        onCurrentTrackChanged: {
            //    if (infoDialog.status != DialogStatus.Closed)
            //        infoDialog.reject()
        }
    }

    // TODO
    //    Connections {
    //        target: player
    //        onInOpenPositionChanged: {
    //            if (!player.inOpenPosition) {
    //                if (albumRequested) {
    //                    albumRequested = false;
    //                    mainPage.tabs.currentTab.push(Qt.resolvedUrl("AlbumPage.qml"), { album: spotifySession.currentTrack.albumObject })
    //                }
    //                if (artistRequested) {
    //                    artistRequested = false;
    //                    mainPage.tabs.currentTab.push(Qt.resolvedUrl("ArtistPage.qml"), { artist: spotifySession.currentTrack.artistObject })
    //                }
    //            }
    //        }
    //    }

    /*    SelectionDialog {
    id: infoDialog
    parent: player.parent
    titleText: "Browse"
    model: ListModel {
        ListElement { name: "Album" }
        ListElement { name: "Artist" }
    }
    onAccepted: {
        player.openRequested = false;
        if (model.get(infoDialog.selectedIndex).name == "Album") {
            albumRequested = true;
        } else {
            artistRequested = true;
        }
    }

*/
    Flipable {
        id: flipable
        property bool flipped: false

        transform: Rotation {
            id: rotation
            origin.x: flipable.width/2
            origin.y: flipable.height/2
            axis.x: 0; axis.y: 1; axis.z: 0
            angle: 0
        }

        states: State {
            name: "back"
            PropertyChanges { target: rotation; angle: 180 }
            when: flipable.flipped
        }

        transitions: Transition {
            NumberAnimation { target: rotation; property: "angle"; duration: 350 }
        }

        front: Item {
            anchors.fill: parent
            z: flipable.flipped ? -1 : 1

            SilicaListView {
                id: coverList
                anchors.fill: parent
                boundsBehavior: Flickable.StopAtBounds
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                cacheBuffer: width * 2
                highlightMoveDuration: 0
                clip: true
                pressDelay: 90

                highlightFollowsCurrentItem: true

                currentIndex: -1
                onMovingChanged: {
                    if (!moving)
                        spotifySession.playQueue.selectTrack(currentIndex)
                }

                Connections {
                    target: spotifySession.playQueue
                    onTracksChanged: {
                        coverList.currentIndex = coverList.model.currentPlayIndex
                    }
                }

                model: spotifySession.playQueue.tracks()
                delegate: Item {
                    width: coverList.width
                    height: coverList.height
                    SpotifyImage {
                        width: Math.min(coverList.width, coverList.height)
                        height: width
                        anchors.horizontalCenter: parent.horizontalCenter
                        spotifyId: albumCoverId + (imageMouseArea.pressed ? "?" + Theme.highlightColor : "")
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        smooth: true

                        MouseArea {
                            id: imageMouseArea
                            anchors.fill: parent
                            onClicked: flipable.flipped = true
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: detailsColumn.height + Theme.paddingLarge
                color: Qt.darker(Theme.secondaryHighlightColor, 2)
                opacity: fcPage.isPortrait ? 0.9 : 0

                Column {
                    id: detailsColumn
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.paddingSmall


                    Label {
                        width: parent.width
                        truncationMode: TruncationMode.Fade
                        opacity: details.opacity
                        text: spotifySession.currentTrack ? spotifySession.currentTrack.name : ""
                    }

                    Item {
                        id: details
                        width: parent.width
                        height: column.height
                        opacity: moreMouseArea.pressed ? Theme.highlightBackgroundOpacity : 1.0

                        Column {
                            id: column
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: moreIcon.left
                            anchors.rightMargin: Theme.paddingLarge
                            Label {
                                width: parent.width
                                font.pixelSize: Theme.fontSizeSmall
                                truncationMode: TruncationMode.Fade
                                anchors.left: parent.left
                                anchors.right: parent.right
                                text: spotifySession.currentTrack ? spotifySession.currentTrack.artists : ""
                            }
                            Label {
                                width: parent.width
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.secondaryColor
                                truncationMode: TruncationMode.Fade
                                anchors.left: parent.left
                                anchors.right: parent.right
                                text: spotifySession.currentTrack ? spotifySession.currentTrack.album : ""
                            }
                        }

                        Image {
                            id: moreIcon
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            source: "image://theme/icon-m-about"
                            visible: !spotifySession.offlineMode
                        }
                    }
                }

                MouseArea {
                    // TODO
                    id: moreMouseArea
                    anchors.fill: parent
                    onClicked: { infoDialog.selectedIndex = -1; infoDialog.open(); }
                    enabled: moreIcon.visible
                }
            }
        }

        back: Item {
            anchors.fill: parent
            clip: true
            z: flipable.flipped ? 1 : -1

            PageHeader {
                id: queueHeader
                title: qsTr("Play queue")

                MouseArea {
                    id: queueHeaderMouse
                    anchors.fill: parent
                    onClicked: flipable.flipped = false
                }
            }

            SilicaListView {
                id: queueList
                anchors.top: queueHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                cacheBuffer: 80
                clip: true

                currentIndex: -1

                VerticalScrollDecorator {}

                model: spotifySession.playQueue.tracks()
                delegate: TrackDelegate {
                    property bool isExplicit: spotifySession.playQueue.isExplicitTrack(index)
                    name: trackName
                    //backgroundOpacity: isExplicit ? 0.6 : 0.0
                    // TODO those colors are no longer used.. / the opacity above neither
                    //titleColor: isExplicit ? ("#c6a83f") : (UI.LIST_TITLE_COLOR)
                    //subtitleColor: isExplicit ? ("#a79144") : (UI.LIST_SUBTITLE_COLOR)
                    artistAndAlbum: artists + " | " + album
                    duration: duration
                    isPlaying: isCurrentPlayingTrack
                    onClicked: {
                        if (!isCurrentPlayingTrack)
                            spotifySession.playQueue.selectTrack(index)
                        else
                            flipable.flipped = false
                    }

                }

                Connections {
                    target: spotifySession
                    onCurrentTrackChanged: queueList.positionViewAtIndex(queueList.model.currentPlayIndex, ListView.Center)
                }
            }
        }
    }

    PanelBackground {

        anchors.bottom: parent.bottom
        anchors.left: fcPage.isPortrait ? parent.left : flipable.right
        anchors.right: parent.right
        height: fcPage.isPortrait ? parent.height - flipable.height : parent.height
        width: fcPage.isPortrait ? parent.width : parent.width - flipable.width

        Column {
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            anchors.topMargin: Theme.paddingLarge
            width: parent.width
            spacing: Theme.paddingSmall
            anchors.top: parent.top
            opacity: fcPage.isPortrait ? 0 : 1

            Label {
                width: parent.width
                truncationMode: TruncationMode.Fade
                text: spotifySession.currentTrack ? spotifySession.currentTrack.name : ""
            }
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                text: spotifySession.currentTrack ? spotifySession.currentTrack.artists : ""
            }
            Label {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.secondaryColor
                truncationMode: TruncationMode.Fade
                text: spotifySession.currentTrack ? spotifySession.currentTrack.album : ""
            }
        }


        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: Theme.paddingLarge
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.paddingLarge
            spacing: Theme.paddingLarge

            Row {
                id: controls
                width: parent.width
                property real itemWidth: width / 3
                IconButton {
                    width: controls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-previous"
                    onClicked: spotifySession.playPrevious()
                }

                IconButton {
                    width: controls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: spotifySession.isPlaying ? "image://theme/icon-l-pause"
                                                          : "image://theme/icon-l-play"
                    onClicked: spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
                }

                IconButton {
                    width: controls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-next"
                    onClicked: spotifySession.playNext()
                }
            }

            Slider {
                id: slider
                width: parent.width

                enabled: spotifySession.currentTrack ? true : false

                handleVisible: false
                valueText: value > 3599 ? Format.formatDuration(value, Formatter.DurationLong) :
                                          Format.formatDuration(value, Formatter.DurationShort)

                minimumValue: 0
                onReleased: spotifySession.seek(slider.value * 1000)

                Connections {
                    target: spotifySession
                    onCurrentTrackPositionChanged: {
                        if (!slider.pressed)
                            slider.value = spotifySession.currentTrackPosition / 1000;
                    }
                    onCurrentTrackChanged: {
                        if(spotifySession.currentTrack)
                            slider.maximumValue = spotifySession.currentTrack.durationMs / 1000
                    }
                }
            }

            Row {
                id: moreControls
                width: parent.width
                property real itemWidth : width / 5

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-add"
                    enabled: !spotifySession.offlineMode
                    onClicked: {
                        //                        TODO mainPage.playlistSelection.track = spotifySession.currentTrack;
                        //                        mainPage.playlistSelection.selectedIndex = -1;
                        //                        mainPage.playlistSelection.open();
                    }
                }

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: spotifySession.currentTrack ? (spotifySession.currentTrack.isStarred ? ("image://theme/icon-m-favorite-selected")
                                                                                                      : ("image://theme/icon-m-favorite"))
                                                             : ("image://theme/icon-m-favorite-selected")
                    enabled: !spotifySession.offlineMode
                    onClicked: spotifySession.currentTrack.isStarred = !spotifySession.currentTrack.isStarred
                }

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: spotifySession.shuffle ? ("image://theme/icon-m-shuffle?" + Theme.highlightColor) : ("image://theme/icon-m-shuffle")
                    onClicked: spotifySession.shuffle = !spotifySession.shuffle
                }

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: spotifySession.repeat ? "image://theme/icon-m-repeat?" + Theme.highlightColor
                                                          : spotifySession.repeatOne ? "image://icon/icon-m-repeat-once?" + Theme.highlightColor : ("image://theme/icon-m-repeat")
                    onClicked: {
                        if (spotifySession.repeat) {
                            spotifySession.repeat = false;
                            spotifySession.repeatOne = true;
                        } else if (spotifySession.repeatOne) {
                            spotifySession.repeatOne = false;
                        } else {
                            spotifySession.repeat = true;
                        }
                    }
                }

                IconButton {
                    width: moreControls.itemWidth
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: "image://theme/icon-m-down"
                    onClicked: {
                        appWindow.showFullControls = !appWindow.showFullControls
                    }
                }
            }
        }
    }
}
