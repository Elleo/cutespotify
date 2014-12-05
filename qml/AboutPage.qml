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

Page {
    id: genericDialog

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentCol.height

        VerticalScrollDecorator {}

        Column {
            id: contentCol

            anchors {
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("About")
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/qml/images/cutespotify-logo.png"
            }

            Label {
                width: parent.width
                text: qsTr("Version %1".arg(APP_VERSION))
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                text: qsTr("Based on MeeSpot by Yoann Lopes")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label {
                width: parent.width
                text: qsTr("Copyright \u00a9 2011-2014 Yoann Lopes, Michael Sheldon, Lukas Vogel")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            Label {
                width: parent.width
                text: qsTr("Thanks to:\nInitial Developer Yoann Lopes\nInitial Porter to Sailfish Michael Sheldon\nMorpog for the Icon\njunnuvi for bluuetooth key handling\nAll helping persons on #sailfishos irc, coderus, Sfiet_Konstantin, Basil_s and everyone else.")
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            Button {
                id: issueButton
                width: parent.width * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Issue tracker")
                onClicked: {
                    Qt.openUrlExternally("https://github.com/lukedirtwalker/cutespotify/issues")
                }
            }

            Button {
                id: mailButton
                width: parent.width * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("e-Mail developer")
                onClicked: {
                    Qt.openUrlExternally("mailto:lukedirtwalkerdev@gmail.com?subject=[CuteSpotify]")
                }
            }

            Button {
                width: parent.width * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Donate")
                onClicked: {
                    Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=NDUQLWV667B5Q")
                }
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
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.right: parent.right
                    height: parent.height
                    wrapMode: Text.WordWrap
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Theme.fontSizeTiny
                    color: Theme.secondaryColor
                    text: "This product uses SPOTIFY CORE but is not endorsed, certified or otherwise approved in any way by Spotify. Spotify is the registered trade mark of the Spotify Group."
                }
            }

            Button {
                id: licenseButton
                width: parent.width * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("License")
                onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))
            }
        }
    }
}
