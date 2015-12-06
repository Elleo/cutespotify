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
import Ubuntu.Components 1.3;
import "UIConstants.js" as UI

Item {
    id: listItem

    signal clicked
    property alias pressed: mouseArea.pressed
    property alias name: mainText.text
    property alias portrait: portraitImage.spotifyId
    property bool showIndex: false

    property int titleSize: units.gu(UI.LIST_TILE_SIZE)
    property string titleFont: UI.FONT_FAMILY_BOLD
    property color titleColor: UI.LIST_TITLE_COLOR

    property int subtitleSize: units.gu(UI.LIST_SUBTILE_SIZE)
    property string subtitleFont: UI.FONT_FAMILY_LIGHT
    property color subtitleColor: UI.LIST_SUBTITLE_COLOR

    height: units.gu(UI.LIST_ITEM_HEIGHT)
    width: parent.width - units.gu(UI.MARGIN_XLARGE)

    Rectangle {
        id: background
        anchors.fill: parent
        // Fill page porders
        anchors.leftMargin: -units.gu(UI.MARGIN_XLARGE)
        anchors.rightMargin: -units.gu(UI.MARGIN_XLARGE)
        opacity: mouseArea.pressed ? 1.0 : 0.0
        color: "#15000000"
    }

    Label {
        id: indexText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: listItem.showIndex ? 48 : 0
        text: (index + 1) + ".   "
        font.family: UI.FONT_FAMILY_LIGHT
        font.pixelSize: units.gu(UI.FONT_SMALL)
        horizontalAlignment: Text.AlignRight
        visible: listItem.showIndex
    }

    Rectangle {
        id: portraitContainer
        width: 64; height: width
        anchors.left: indexText.right
        anchors.verticalCenter: parent.verticalCenter
        color: "#C9C9C9"

        SpotifyImage {
            id: portraitImage
            anchors.fill: parent
            defaultImage: "images/icon-l-contact-avatar-placeholder-black.png"
        }
    }

    Label {
        id: mainText
        anchors.left: portraitContainer.right
        anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        font.family: listItem.titleFont
        font.weight: Font.Bold
        font.pixelSize: listItem.titleSize
        color: listItem.titleColor
        elide: Text.ElideRight
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent
        onClicked: listItem.clicked()
    }
}
