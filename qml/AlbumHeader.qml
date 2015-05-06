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

Item {
    id: albumHeader
    width: parent.width
    height: Theme.itemSizeLarge * 3

    property alias albumName: header.title
    property alias artistName: artistText.text
    property alias trackCount: trackCountText.text
    property alias timing: timingText.text
    property alias year: yearText.text
    property alias coverId: coverImage.spotifyId

    Rectangle {
        width: parent.width
        height: parent.height
        color: Theme.highlightBackgroundColor
        opacity: 0.1
        visible: !backgroundImage.visible
    }

    SpotifyImage {
        id: backgroundImage
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectCrop
        spotifyId: coverId
        visible: spotifyId != ''
        opacity: status == Image.Ready ? 0.4 : 0.0
    }

    PageHeader {
        id: header
    }

    Row {
        spacing: Theme.paddingMedium
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        height: parent.height - header.height

        SpotifyImage {
            id: coverImage
            height: parent.height - Theme.paddingLarge - Theme.paddingMedium
            width: height
        }

        Column {
            id: desc
            width: parent.width - coverImage.width - Theme.paddingLarge

            Label {
                id: artistText
                width: parent.width
                truncationMode: TruncationMode.Fade
                verticalAlignment: Text.AlignTop
                color: Theme.highlightColor
            }

            Label {
                id: trackCountText
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
            }

            Label {
                id: timingText
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
            }

            Label {
                id: yearText
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                truncationMode: TruncationMode.Fade
                color: Theme.highlightColor
            }
        }
    }
}
