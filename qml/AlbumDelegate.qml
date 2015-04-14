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

ListItem {
    id: listItem

    property variant listModel
    property string name: model.name
    property string artist: model.artist
    property string albumCover: model.coverId
    property int year: model.year
    property bool available: model.isAvailable
    property bool showIndex: false

    contentHeight: Theme.itemSizeSmall
    width: parent.width

    onClicked: { pageStack.push(Qt.resolvedUrl("AlbumPage.qml"),
                                { "browse": listModel.albumBrowse(index),
                                    "name": name, "coverId": albumCover,
                                    "artist": artist, "albumYear": year}) }

    menu: Component {
        id: albumMenu
        AlbumMenu {
            albumBrowse: listModel.albumBrowse(index)
        }
    }

    Label {
        id: indexText
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingSmall
        anchors.verticalCenter: parent.verticalCenter
        width: listItem.showIndex ? Theme.iconSizeMedium * 0.75 : 0
        text: (index + 1) + "."
        font.pixelSize: Theme.fontSizeSmall
        horizontalAlignment: Text.AlignRight
        color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
        visible: listItem.showIndex
    }

    Rectangle {
        id: coverContainer
        width: Theme.iconSizeMedium; height: width
        anchors.left: indexText.right
        anchors.leftMargin: indexText.visible ? Theme.paddingSmall : Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.secondaryHighlightColor
        opacity: listItem.available ? 1.0 : 0.3

        SpotifyImage {
            id: cover
            spotifyId: albumCover
            anchors.fill: parent
        }
    }

    Column {
        anchors.left: coverContainer.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        opacity: listItem.available ? 1.0 : 0.3

        Label {
            id: mainText
            text: name
            anchors.left: parent.left
            anchors.right: parent.right
            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
        }

        Label {
            id: subText
            text: artist
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: Theme.fontSizeSmall
            color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            truncationMode: TruncationMode.Fade
            visible: text != ""
        }
    }
}
