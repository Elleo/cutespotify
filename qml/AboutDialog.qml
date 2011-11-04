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


import QtQuick 1.1
import com.meego 1.0
import "UIConstants.js" as UI

Dialog {
    id: genericDialog

    property string titleText: "About MeeSpot"

    property Style platformStyle: SelectionDialogStyle {}

    //private
    property bool __drawFooterLine: false

    title: Item {
        id: header
        height: genericDialog.platformStyle.titleBarHeight

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        Item {
            id: labelField

            anchors.fill:  parent

            Item {
                id: labelWrapper
                anchors.left: labelField.left
                anchors.right: labelField.left

                anchors.bottom:  parent.bottom
                anchors.bottomMargin: genericDialog.platformStyle.titleBarLineMargin

                //anchors.verticalCenter: labelField.verticalCenter

                height: titleLabel.height

                Label {
                    id: titleLabel
                    x: genericDialog.platformStyle.titleBarIndent
                    font.family: UI.FONT_FAMILY
                    font.pixelSize: UI.FONT_XLARGE
                    text: genericDialog.titleText
                }

            }
        }

        Rectangle {
            id: headerLine

            anchors.left: parent.left
            anchors.right: parent.right

            anchors.bottom:  header.bottom

            height: 1

            color: "#4D4D4D"
        }

    }

    content: Column {
        width: parent.width

        Item {
            width: parent.width
            height: 38
        }

        Label {
            text: "Version 1.2.0"
            font.pixelSize: UI.FONT_LSMALL
        }

        Label {
            text: "Copyright \u00a9 2011 Yoann Lopes"
            font.pixelSize: UI.FONT_LSMALL
        }

        Label {
            text: "Contact: yoann.lopes@gmail.com"
            font.pixelSize: UI.FONT_LSMALL
        }

        Item {
            width: parent.width
            height: 38
        }

        Item {
            id: contentField
            width: parent.width
            height: spotifyCoreLogo.height

            Image {
                id: spotifyCoreLogo
                source: "images/spotify-core-logo-128x128.png"
            }

            Label {
                anchors.verticalCenter: spotifyCoreLogo.verticalCenter
                anchors.left: spotifyCoreLogo.right
                anchors.leftMargin: UI.MARGIN_XLARGE
                anchors.right: parent.right
                height: parent.height
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                font.family: UI.FONT_FAMILY
                font.pixelSize: UI.FONT_XSMALL
                color: UI.LIST_SUBTITLE_COLOR_INVERTED
                text: "This product uses SPOTIFY CORE but is not endorsed, certified or otherwise approved in any way by Spotify. Spotify is the registered trade mark of the Spotify Group."
            }
        }
    }

    buttons: Item {
        id: buttonColFiller
        width: parent.width
        height: childrenRect.height

        anchors.top: parent.top

        Button {
            id: acceptButton
            text: "Close"
            onClicked: accept()
            __dialogButton: true
            platformStyle: ButtonStyle {inverted: true}
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 38
        }
    }

}
