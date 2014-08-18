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

Row {
    id: albumHeader
    property alias albumCount: albumCountText.text
    property alias singleCount: singleCountText.text
    property alias compilationCount: compilationsText.text
    property alias appearsOnCount: appearsOnText.text
    property alias artistPictureId: coverImage.spotifyId

    property bool busy: false

    width: parent.width
    height: width * 0.3
    spacing: Theme.paddingLarge
    anchors.left: parent.left
    anchors.leftMargin: Theme.paddingLarge

    SpotifyImage {
        id: coverImage
        height: parent.height - 2 * Theme.paddingLarge
        width: height
        fillMode: Image.PreserveAspectCrop
        defaultImage: "image://theme/icon-m-person"
        clip: true
        visible: albumCount.length > 0 || singleCount.length > 0 || compilationCount.length > 0
    }

    Column {
        id: desc
        width: parent.width - coverImage.width - Theme.paddingLarge

        Label {
            id: albumCountText
            width: parent.width
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Fade
            visible: text.length > 0
        }
        Label {
            id: singleCountText
            width: parent.width
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Fade
            visible: text.length > 0
        }
        Label {
            id: compilationsText
            width: parent.width
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Fade
            visible: text.length > 0
        }
        Label {
            id: appearsOnText
            width: parent.width
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: TruncationMode.Fade
            visible: text.length > 0
        }
    }
}
