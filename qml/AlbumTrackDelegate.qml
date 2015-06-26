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

ListItem {
    id: listItem

    property variant listModel
    property string name: model.trackName
    property string duration: model.trackDuration
    property bool starred: model.isStarred
    property bool available: model.isAvailable
    property bool isPlaying: model.isCurrentPlayingTrack

    onClicked: {
        if(isPlaying) {
            if(!spotifySession.isPlaying)
                spotifySession.resume()
        } else
            listModel.playTrack(index)
    }

    contentHeight: Theme.itemSizeSmall
    width: parent.width

    menu: Component {
        id: trackMenuComponent
        TrackMenu {
            track: model.rawPtr
            albumVisible: false
        }
    }

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        opacity: listItem.available ? 1.0 : 0.3

        Label {
            id: mainText
            text: listItem.name
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingLarge
            anchors.right: iconItem.left
            anchors.rightMargin: Theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            color: (highlighted || isPlaying) ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
        }

        Image {
            id: iconItem
            anchors.right: timing.left
            anchors.rightMargin: Theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -2
            width: Theme.iconSizeSmall; height: width
            smooth: true
            visible: listItem.starred
            source: "image://theme/icon-m-favorite-selected" + (highlighted ? "?" + Theme.highlightColor : "")
        }

        Label {
            id: timing
            text: listItem.duration
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeSmall
            color: (highlighted || isPlaying) ? Theme.secondaryHighlightColor : Theme.secondaryColor
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge
            visible: text != ""
        }
    }
}
