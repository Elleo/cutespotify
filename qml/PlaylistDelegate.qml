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

Item {
    id: listItem

    signal clicked
    signal pressAndHold
    property alias pressed: mouseArea.pressed
    property alias title: mainText.text
    property alias subtitle: subText.text
    property alias extraText: timing.text
    property alias icon: iconImage.source
    property int offlineStatus: 0
    property bool availableOffline: false
    property int downloadProgress: 0
    property int unseens: 0

    property int titleSize: units.gu(UI.LIST_TILE_SIZE)
    property string titleFont: UI.FONT_FAMILY_BOLD
    property color titleColor: UI.LIST_TITLE_COLOR

    property int subtitleSize: units.gu(UI.LIST_SUBTILE_SIZE)
    property string subtitleFont: UI.FONT_FAMILY_LIGHT
    property color subtitleColor: UI.LIST_SUBTITLE_COLOR

    height: units.gu(UI.LIST_ITEM_HEIGHT)
    width: parent.width - units.gu(UI.MARGIN_XLARGE)

    SequentialAnimation {
        id: backAnimation
        property bool animEnded: false
        running: mouseArea.pressed

        ScriptAction { script: backAnimation.animEnded = false }
        PauseAnimation { duration: 200 }
        ParallelAnimation {
            NumberAnimation { target: background; property: "opacity"; to: 0.4; duration: 300 }
            ColorAnimation { target: mainText; property: "color"; to: "#DDDDDD"; duration: 300 }
            ColorAnimation { target: subText; property: "color"; to: "#DDDDDD"; duration: 300 }
            ColorAnimation { target: timing; property: "color"; to: "#DDDDDD"; duration: 300 }
            NumberAnimation { target: iconItem; property: "opacity"; to: 0.2; duration: 300 }
            NumberAnimation { target: unseenBox; property: "opacity"; to: 0.2; duration: 300 }
            NumberAnimation { target: offlineStatusIcon; property: "opacity"; to: 0.2; duration: 300 }
            NumberAnimation { target: downloadBar; property: "opacity"; to: 0.2; duration: 300 }
        }
        PauseAnimation { duration: 100 }
        ScriptAction { script: { backAnimation.animEnded = true; listItem.pressAndHold(); } }
        onRunningChanged: {
            if (!running) {
                iconItem.opacity = 1.0
                unseenBox.opacity = 1.0
                offlineStatusIcon.opacity = 1.0
                downloadBar.opacity = 1.0
                mainText.color = listItem.titleColor
                subText.color = listItem.subtitleColor
                timing.color = listItem.subtitleColor
            }
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        // Fill page porders
        anchors.leftMargin: -units.gu(UI.MARGIN_XLARGE)
        anchors.rightMargin: -units.gu(UI.MARGIN_XLARGE)
        opacity: mouseArea.pressed ? 1.0 : 0.0
        color: "#15000000"
    }

    Row {
        anchors.fill: parent
        spacing: units.gu(UI.LIST_ITEM_SPACING)

        Item {
            id: iconItem
            anchors.verticalCenter: parent.verticalCenter
            visible: iconImage.source !== "" ? true : false
            width: 40
            height: 40

            Image {
                id: iconImage
                anchors.centerIn: parent
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - (iconItem.visible ? iconItem.width + units.gu(UI.LIST_ITEM_SPACING) : 0)

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: mainText.height

                Label {
                    id: mainText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    font.family: listItem.titleFont
                    font.weight: Font.Bold
                    font.pixelSize: listItem.titleSize
                    color: listItem.titleColor
                    elide: Text.ElideRight
                }

                Loader {
                    id: unseenBox
                    anchors.verticalCenter: parent.verticalCenter
                    x: mainText.paintedWidth + units.gu(UI.MARGIN_XLARGE)
                    sourceComponent: listItem.unseens > 0  ? unseensComponent : null
                }

                Component {
                    id: unseensComponent
                    BorderImage {
                        source: "images/icon-m-common-green.png"
                        visible: listItem.unseens > 0
                        width: unseenText.width > 14 ? unseenText.width + 14 : 28
                        border.left: 10
                        border.right: 10
                        border.top: 10
                        border.bottom: 10

                        Label {
                            id: unseenText
                            anchors.centerIn: parent
                            font.family: listItem.titleFont
                            font.pixelSize: listItem.subtitleSize
                            color: UI.LIST_TITLE_COLOR_INVERTED
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: listItem.unseens
                        }
                    }
                }
            }

            Item {
                height: subText.height
                anchors.left: parent.left
                anchors.right: parent.right

                Label {
                    id: offlineStatusIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    height: visible ? 24 : 0; width: height
                    verticalAlignment: Text.AlignVCenter
                    color: UI.SPOTIFY_COLOR
                    font.bold: true
                    font.pixelSize: 32
                    text: "\u2022"
                    visible: listItem.availableOffline
                }

                Item {
                    anchors.left: offlineStatusIcon.right
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: subText.height
                    visible: listItem.offlineStatus == SpotifyPlaylist.Yes || listItem.offlineStatus == SpotifyPlaylist.No || spotifySession.offlineMode

                    Label {
                        id: subText
                        font.family: listItem.subtitleFont
                        font.pixelSize: listItem.subtitleSize
                        font.weight: Font.Light
                        color: listItem.subtitleColor
                        anchors.left: parent.left
                        anchors.right: timing.left
                        anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
                        elide: Text.ElideRight
                        visible: text != ""
                    }

                    Label {
                        id: timing
                        font.family: listItem.subtitleFont
                        font.weight: Font.Light
                        font.pixelSize: listItem.subtitleSize
                        color: listItem.subtitleColor
                        anchors.right: parent.right
                        visible: text != ""
                    }
                }

                Loader {
                    id: downloadBar
                    anchors.left: offlineStatusIcon.right
                    anchors.right: parent.right
                    anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 3
                    sourceComponent: listItem.offlineStatus == SpotifyPlaylist.Downloading ? downloadBarComponent : null
                }

                Component {
                    id: downloadBarComponent
                    ProgressBar {
                        visible: listItem.offlineStatus == SpotifyPlaylist.Downloading
                        height: units.gu(1.5)
                        minimumValue: 0
                        maximumValue: 100
                        value: listItem.downloadProgress
                    }
                }

                Loader {
                    id: waitingText
                    anchors.left: offlineStatusIcon.right
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: listItem.offlineStatus == SpotifyPlaylist.Waiting && !spotifySession.offlineMode ? waitingTextComponent : null
                }

                Component {
                    id: waitingTextComponent
                    Label {
                        visible: listItem.offlineStatus == SpotifyPlaylist.Waiting && !spotifySession.offlineMode
                        font.family: listItem.subtitleFont
                        font.pixelSize: listItem.subtitleSize
                        font.weight: Font.Light
                        color: listItem.subtitleColor
                        text: "Waiting for sync"
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent
        onClicked: {
            if (!backAnimation.animEnded)
                listItem.clicked();
        }
    }
}
