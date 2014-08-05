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

BackgroundItem {
    id: listItem

    property alias name: mainText.text
    property alias artistAndAlbum: subText.text
    property alias creatorAndDate: thirdText.text
    property alias duration: timing.text
    property bool starred: false
    property bool available: true
    property bool seen: true
    property bool isPlaying: false

    height: Theme.itemSizeMedium
    width: parent.width

    Rectangle {
        id: seenMarker
        visible: !listItem.seen
        anchors.verticalCenter: parent.verticalCenter
        height: listItem.height
        width: Theme.paddingMedium
        color: Theme.highlightColor
        anchors.left: parent.left
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        spacing: -Theme.paddingSmall
        opacity: listItem.available ? 1.0 : 0.3

        Item {
            height: mainText.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingLarge

            Label {
                id: mainText
                anchors.left: parent.left
                anchors.right: iconItem.left
                anchors.rightMargin: iconItem.visible ? Theme.paddinLarge : 0
                color: (highlighted || isPlaying) ? Theme.highlightColor : Theme.primaryColor
                elide: Text.ElideRight
                clip: true
            }
            Image {
                id: iconItem
                anchors.right: parent.right
                anchors.bottom: mainText.bottom
                anchors.bottomMargin: 2
                width: Theme.iconSizeSmall; height: width
                smooth: true
                visible: listItem.starred
                source: "image://theme/icon-m-favorite-selected" + (highlighted ? "?" + Theme.highlightColor : "")
            }
        }

        Item {
            height: subText.height
            anchors.left: parent.left
            anchors.right: parent.right
            Label {
                id: subText
                anchors.left: parent.left
                anchors.right: timing.left
                anchors.rightMargin: Theme.paddinLarge
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Light
                color: (highlighted || isPlaying) ? Theme.secondaryHighlightColor : Theme.secondaryColor
                elide: Text.ElideRight
                clip: true
                visible: text != ""
            }
            Label {
                id: timing
                font.weight: Font.Light
                font.pixelSize: Theme.fontSizeSmall
                color: (highlighted || isPlaying) ? Theme.secondaryHighlightColor : Theme.secondaryColor
                anchors.right: parent.right
                visible: text != ""
            }
        }

        Label {
            id: thirdText
            anchors.left: parent.left
            anchors.right: parent.right
            verticalAlignment: Text.AlignBottom
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.Light
            color: (highlighted || isPlaying) ? Theme.secondaryHighlightColor : Theme.secondaryColor
            elide: Text.ElideRight
        }
    }
}
