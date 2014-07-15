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
import QtSpotify 1.0

Page {
    showNavigationIndicator: false

Column {
    id: fullControls
    width: parent.width
    spacing: UI.MARGIN_XLARGE

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
    }
*/
    Flipable {
        id: flipable
        width: parent.width
        height: width

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

        front: Rectangle {
            anchors.fill: parent
            color: "#C9C9C9"
            z: flipable.flipped ? -1 : 1

            ListView {
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
                        spotifySession.playQueue.selectTrack(model[currentIndex])
                }

                Connections {
                    target: spotifySession.playQueue
                    onTracksChanged: {
                        coverList.currentIndex = spotifySession.playQueue.currentIndex()
                    }
                }

                model: spotifySession.playQueue.tracks
                delegate: SpotifyImage {
                    width: coverList.width
                    height: width
                    spotifyId: modelData.albumCoverId
                    fillMode: Image.PreserveAspectCrop
                    clip: true
                    smooth: true
                    opacity: imageMouseArea.pressed ? 0.4 : 1.0

                    MouseArea {
                        id: imageMouseArea
                        anchors.fill: parent
                        onClicked: flipable.flipped = true
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: detailsColumn.height + UI.MARGIN_XLARGE
                color: (moreMouseArea.pressed ? "#DD" : "#BA") + ("#D7D7D7")

                Column {
                    id: detailsColumn
                    anchors.left: parent.left
                    anchors.leftMargin: UI.MARGIN_XLARGE
                    anchors.right: parent.right
                    anchors.rightMargin: UI.MARGIN_XLARGE
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8

                    Label {
                        width: parent.width
                        font.family: UI.FONT_FAMILY
                        font.weight: Font.Bold
                        font.pixelSize: UI.FONT_DEFAULT
                        color: UI.COLOR_FOREGROUND
                        elide: Text.ElideRight
                        opacity: details.opacity
                        text: spotifySession.currentTrack ? spotifySession.currentTrack.name : ""
                    }

                    Item {
                        id: details
                        width: parent.width
                        height: column.height
                        opacity: moreMouseArea.pressed ? 0.4 : 1.0
                        Column {
                            id: column
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: moreIcon.left
                            anchors.rightMargin: UI.MARGIN_XLARGE
                            Label {
                                width: parent.width
                                font.family: UI.FONT_FAMILY
                                font.pixelSize: UI.FONT_LSMALL
                                color: UI.LIST_SUBTITLE_COLOR
                                elide: Text.ElideRight
                                anchors.left: parent.left
                                anchors.right: parent.right
                                text: spotifySession.currentTrack ? spotifySession.currentTrack.artists : ""
                            }
                            Label {
                                width: parent.width
                                font.family: UI.FONT_FAMILY
                                font.pixelSize: UI.FONT_LSMALL
                                color: UI.LIST_SUBTITLE_COLOR
                                elide: Text.ElideRight
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
                        MouseArea {
                            id: moreMouseArea
                            anchors.fill: parent
                            onClicked: { infoDialog.selectedIndex = -1; infoDialog.open(); }
                            enabled: moreIcon.visible
                        }
                    }
                }
            }
        }

        back: Item {
            anchors.fill: parent
            clip: true
            z: flipable.flipped ? 1 : -1

            ViewHeader {
                id: queueHeader
                contentMargins: UI.MARGIN_XLARGE
                text: "Play queue"
                color: UI.COLOR_BACKGROUND
                contentOpacity: queueHeaderMouse.pressed ? 0.4 : 1.0

                MouseArea {
                    id: queueHeaderMouse
                    anchors.fill: parent
                    onClicked: flipable.flipped = false
                }
            }

            SilicaListView {
                id: queueList
                anchors.top: queueHeader.bottom
                anchors.topMargin: UI.MARGIN_XLARGE
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                cacheBuffer: UI.LIST_ITEM_HEIGHT
                clip: true

                VerticalScrollDecorator {}

                model: spotifySession.playQueue.tracks
                delegate: TrackDelegate {
                    property bool isExplicit: spotifySession.playQueue.isExplicitTrack(index)
                    name: modelData.name
                    backgroundOpacity: isExplicit ? 0.6 : 0.0
                    // TODO those colors are no longer used.. / the opacity above neither
                    titleColor: isExplicit ? ("#c6a83f") : (UI.LIST_TITLE_COLOR)
                    subtitleColor: isExplicit ? ("#a79144") : (UI.LIST_SUBTITLE_COLOR)
                    artistAndAlbum: modelData.artists + " | " + modelData.album
                    duration: modelData.duration
                    highlighted: index == spotifySession.playQueue.currentIndex
                    onClicked: if (!highlighted) spotifySession.playQueue.selectTrack(modelData)
                }

                Connections {
                    target: spotifySession.playQueue
                    onTracksChanged: queueList.positionViewAtIndex(spotifySession.playQueue.currentIndex, ListView.Center)
                }
            }

/*            Scrollbar {
                anchors.topMargin: -UI.MARGIN_XLARGE
                anchors.rightMargin: -UI.MARGIN_XLARGE
                flickableItem: queueList
            }*/
        }
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: UI.MARGIN_XLARGE
        anchors.right: parent.right
        anchors.rightMargin: UI.MARGIN_XLARGE
        spacing: UI.MARGIN_XLARGE

        Item {
            id: controls
            width: parent.width
            height: 128

            Image {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/icon-m-previous"
                opacity: previous.pressed ? 0.4 : 1.0

                MouseArea {
                    id: previous
                    anchors.fill: parent
                    anchors.margins: -15
                    onClicked: spotifySession.playPrevious()
                }
            }
            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                source: spotifySession.isPlaying ? "image://theme/icon-m-pause"
                                                 : "image://theme/icon-m-play"
                opacity: play.pressed ? 0.4 : 1.0

                MouseArea {
                    id: play
                    anchors.fill: parent
                    anchors.margins: -15
                    onClicked: spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
                }
            }
            Image {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                source: "image://theme/icon-m-next"
                opacity: next.pressed ? 0.4 : 1.0

                MouseArea {
                    id: next
                    anchors.fill: parent
                    anchors.margins: -15
                    onClicked: spotifySession.playNext()
                }
            }
        }

        Column {
            id: seeker
            width: parent.width
            spacing: 8

            Slider {
                id: slider
                width: parent.width
                minimumValue: 0
                maximumValue: spotifySession.currentTrack ? spotifySession.currentTrack.durationMs : 0
                //stepSize: 1000
                //valueIndicatorVisible: spotifySession.currentTrack ? true : false
                //valueIndicatorMargin : 40
                enabled: spotifySession.currentTrack ? true : false

                function formatValue(v) {
                    return spotifySession.formatDuration(v);
                }

                onPressedChanged:  {
                    if (!slider.pressed) {
                        spotifySession.seek(slider.value)
                    }
                }

                Connections {
                    target: spotifySession
                    onCurrentTrackPositionChanged: {
                        if (!slider.pressed)
                            slider.value = spotifySession.currentTrackPosition;
                    }
                }
            }

            Item {
                width: parent.width
                height: trackPos.height + 8

                Label {
                    id: trackPos
                    font.family: UI.FONT_FAMILY
                    font.pixelSize: UI.FONT_LSMALL
                    color: UI.LIST_SUBTITLE_COLOR
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    anchors.top: parent.top
                    //text: slider.valueIndicatorText
                    visible: spotifySession.currentTrack ? true : false
                }
                Label {
                    font.family: UI.FONT_FAMILY
                    font.pixelSize: UI.FONT_LSMALL
                    color: UI.LIST_SUBTITLE_COLOR
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    anchors.top: parent.top
                    text: spotifySession.currentTrack ? spotifySession.currentTrack.duration : ""
                }
            }
        }

        Row {
            width: parent.width
            height: 40

            spacing: Theme.paddingLarge

            Image {
                id: addIcon
                anchors.verticalCenter: parent.verticalCenter
                opacity: enabled ? (addArea.pressed ? 0.4 : 1.0) : 0.2
                source: "image://theme/icon-m-add"
                enabled: !spotifySession.offlineMode

                MouseArea {
                    id: addArea
                    anchors.fill: parent
                    anchors.margins: -15
                    onClicked: {
                        mainPage.playlistSelection.track = spotifySession.currentTrack;
                        mainPage.playlistSelection.selectedIndex = -1;
                        mainPage.playlistSelection.open();
                    }
                }
            }
            Image {
                id: favIcon
                anchors.verticalCenter: parent.verticalCenter
                opacity: enabled ? (starArea.pressed ? 0.4 : 1.0) : 0.2
                source: spotifySession.currentTrack ? (spotifySession.currentTrack.isStarred ? ("image://theme/icon-m-favorite-selected")
                                                                                             : ("image://theme/icon-m-favorite"))
                                                    : ("image://theme/icon-m-favorite-selected")
                enabled: !spotifySession.offlineMode

                MouseArea {
                    id: starArea
                    anchors.fill: parent
                    anchors.margins: -15
                    onClicked: spotifySession.currentTrack.isStarred = !spotifySession.currentTrack.isStarred
                }
            }
            Image {
                anchors.verticalCenter: parent.verticalCenter
                source: spotifySession.shuffle ? ("image://theme/icon-m-shuffle?" + Theme.highlightColor) : ("image://theme/icon-m-shuffle")
                opacity: shuffleArea.pressed ? 0.4 : 1.0
                MouseArea {
                    id: shuffleArea
                    anchors.fill: parent
                    anchors.margins: -15
                    onClicked: spotifySession.shuffle = !spotifySession.shuffle
                }
            }
            Image {
                anchors.verticalCenter: parent.verticalCenter
                source: spotifySession.repeat ? "image://theme/icon-m-repeat?" + Theme.highlightColor
                                             /* TODO : spotifySession.repeatOne ? "images/icon-m-toolbar-repeat-one-white-selected.png" */: ("image://theme/icon-m-repeat")
                opacity: repeatArea.pressed ? 0.4 : 1.0
                MouseArea {
                    id: repeatArea
                    anchors.fill: parent
                    anchors.margins: -15
                    onClicked: {
                        if (spotifySession.repeat) {
                            spotifySession.repeat = false;
                            // TODO spotifySession.repeatOne = true;
                        } else if (spotifySession.repeatOne) {
                            spotifySession.repeatOne = false;
                        } else {
                            spotifySession.repeat = true;
                        }
                    }
                }
            }
            IconButton {
                anchors.verticalCenter: parent.verticalCenter
//                height: Theme.iconSizeSmall
                icon.source: "image://theme/icon-m-down"
                onClicked: {
                    player.showFullControls = !player.showFullControls
                }
            }
        }
    }
}
}
