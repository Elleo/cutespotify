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
import "UIConstants.js" as UI

BackgroundItem {
    id: listItem

    property alias title: mainText.text
    property alias subtitle: subText.text
    property alias extraText: timing.text
    property string iconSource: modelData.collaborative ? "image://theme/icon-m-music" : staticIcon
    property int offlineStatus: 0
    property bool availableOffline: false
    property int downloadProgress: 0
    property int unseens: 0

    height: Theme.itemSizeMedium
    width: parent.width

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingLarge
        spacing: Theme.paddingMedium

        SpotifyImage {
            id: iconImage
            anchors.verticalCenter: parent.verticalCenter
            visible: iconSource !== "" ? true : false
            width: Theme.iconSizeMedium
            height: Theme.iconSizeMedium
            spotifyId: modelData.hasImageId ? modelData.imageId : ""
            defaultImage: iconSource + (listItem.highlighted ? ("?" + Theme.highlightColor) : "")
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - (iconImage.visible ? iconImage.width + Theme.paddingMedium : 0)

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: mainText.height

                Label {
                    id: mainText
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    elide: Text.ElideRight
                }

                Loader {
                    id: unseenBox
                    anchors.verticalCenter: parent.verticalCenter
                    x: mainText.paintedWidth + UI.MARGIN_XLARGE
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
                            font.pixelSize: Theme.fontSizeSmall
                            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
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
                    color: Theme.highlightColor
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
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Light
                        color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        anchors.left: parent.left
                        anchors.right: timing.left
                        anchors.rightMargin: UI.MARGIN_XLARGE
                        elide: Text.ElideRight
                        visible: text != ""
                    }

                    Label {
                        id: timing
                        font.weight: Font.Light
                        font.pixelSize: Theme.fontSizeSmall
                        color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        anchors.right: parent.right
                        visible: text != ""
                    }
                }

                Loader {
                    id: downloadBar
                    anchors.left: offlineStatusIcon.right
                    anchors.right: parent.right
                    anchors.rightMargin: UI.MARGIN_XLARGE
                    anchors.leftMargin: -65
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -25
                    sourceComponent: listItem.offlineStatus == SpotifyPlaylist.Downloading ? downloadBarComponent : null
                }

                Component {
                    id: downloadBarComponent
                    ProgressBar {
                        visible: listItem.offlineStatus == SpotifyPlaylist.Downloading
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
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.Light
                        color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        text: "Waiting for sync"
                    }
                }
            }
        }
    }

    property string staticIcon

    function updateIcon() {
        if (modelData.type === SpotifyPlaylist.Playlist)
            staticIcon = "image://theme/icon-m-sounds";
        else if (modelData.type === SpotifyPlaylist.Starred)
            staticIcon = "image://theme/icon-m-favorite-selected";
        else if (modelData.type === SpotifyPlaylist.Inbox)
            staticIcon = "image://theme/icon-m-mail";
        else if (modelData.type === SpotifyPlaylist.Folder)
            staticIcon = "image://theme/icon-m-folder";
    }

    Component.onCompleted: updateIcon()
}
