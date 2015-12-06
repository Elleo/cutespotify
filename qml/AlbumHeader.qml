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
import "UIConstants.js" as UI

Column {
    id: albumHeader
    signal moreClicked
    property alias artistName: artistText.text
    property alias trackCount: trackCountText.text
    property alias timing: timingText.text
    property alias year: yearText.text
    property alias coverId: cover.spotifyId

    width: parent ? parent.width : 0
    spacing: units.gu(UI.MARGIN_XLARGE)

    Item {
        width: parent.width
        height: 160

        SpotifyImage {
            id: cover
            height: parent.height
            width: height
            anchors.left: parent.left
        }

        Column {
            id: desc
            anchors.left: cover.right
            anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)
            anchors.right: parent.right

            Label {
                id: artistText
                height: 35
                width: parent.width
                font.family: UI.FONT_FAMILY_BOLD
                font.weight: Font.Bold
                font.pixelSize: units.gu(UI.FONT_LSMALL)
                elide: Text.ElideRight
                verticalAlignment: Text.AlignTop
            }

            Label {
                id: trackCountText
                width: parent.width
                font.family: UI.FONT_FAMILY
                font.pixelSize: units.gu(UI.FONT_SMALL)
                elide: Text.ElideRight
            }
            Label {
                id: timingText
                width: parent.width
                font.family: UI.FONT_FAMILY
                font.pixelSize: units.gu(UI.FONT_SMALL)
                elide: Text.ElideRight
            }
            Label {
                id: yearText
                width: parent.width
                font.family: UI.FONT_FAMILY
                font.pixelSize: units.gu(UI.FONT_SMALL)
                elide: Text.ElideRight
            }
        }

        Image {
            id: moreIcon
            source: "image://theme/icon-s-music-video-description"
            opacity: moreButton.pressed ? 0.4 : 1.0
            visible: trackCount.length > 0
            anchors.left: cover.right
            anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)
            anchors.bottom: cover.bottom
            anchors.bottomMargin: 4

            MouseArea {
                id: moreButton
                anchors.fill: parent
                anchors.margins: -15
                onClicked: { albumHeader.moreClicked(); }
            }
        }
    }

    Separator {
        anchors.left: parent.left
        anchors.right: parent.right
    }
}
