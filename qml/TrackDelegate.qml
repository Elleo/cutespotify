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

BackgroundItem {
    id: listItem

    property alias name: mainText.text
    property alias artistAndAlbum: subText.text
    property alias duration: timing.text
    property string coverId: ""
    property bool starred: false
    property bool available: true
    property bool showIndex: false

    property color titleColor: Theme.primaryColor

    property color subtitleColor: Theme.secondaryColor

    property real backgroundOpacity: 0.0


    height: Theme.itemSizeSmall
    width: parent.width

    Loader {
        id: indexText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: listItem.showIndex ? 48 : 0
        sourceComponent: listItem.showIndex ? indexTextComponent : null
    }

    Component {
        id: indexTextComponent
        Label {
            text: (index + 1) + ". "
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignRight
            visible: listItem.showIndex
        }
    }

    Loader {
        id: coverContainer
        width: listItem.coverId.length > 0 ? 64 : 0; height: width
        anchors.left: indexText.right
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: listItem.coverId.length > 0 ? coverContainerComponent : null
    }

    Component {
        id: coverContainerComponent
        Rectangle {
            color: Theme.secondaryColor //"#C9C9C9"
            opacity: listItem.available ? 1.0 : 0.2

            SpotifyImage {
                id: coverImage
                anchors.fill: parent
                spotifyId: listItem.coverId
            }
        }
    }

    Column {
        anchors.left: coverContainer.right
        anchors.leftMargin: listItem.coverId.length > 0 ? Theme.paddingLarge : 0
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        opacity: listItem.available ? 1.0 : 0.3

        Item {
            height: mainText.height
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: listItem.coverId.length > 0 ? 0 : Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge

            Label {
                id: mainText
                anchors.left: parent.left
                anchors.right: iconItem.left
                anchors.rightMargin: iconItem.visible ? Theme.paddingLarge : 0
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
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
            anchors.leftMargin: listItem.coverId.length > 0 ? 0 : Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge
            Label {
                id: subText
                anchors.left: parent.left
                anchors.right: timing.left
                anchors.rightMargin: Theme.paddingLarge
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Light
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                elide: Text.ElideRight
                clip: true
                visible: text != ""
            }
            Label {
                id: timing
                font.weight: Font.Light
                font.pixelSize: Theme.fontSizeSmall
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                anchors.right: parent.right
                visible: text != ""
            }
        }
    }
}
