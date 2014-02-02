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

ApplicationWindow {
    id: appWindow
    property string themeColor

    cover: CoverBackground {

        SpotifyImage {
            id: coverImage
            anchors.top: parent.top
            width: parent.width
            height: width
            visible: spotifySession.currentTrack ? true : false
            spotifyId: spotifySession.currentTrack ? spotifySession.currentTrack.albumCoverId : ""
        }

        Image {
            anchors.centerIn: parent
            source: "qrc:/qml/images/cutespotify.png"
            visible: spotifySession.currentTrack ? false : true
            opacity: 0.5
        }

        Column {
            anchors.top: coverImage.bottom
            anchors.topMargin: 5
            anchors.leftMargin: 5
            anchors.rightMargin: 5
            visible: spotifySession.currentTrack ? true : false
            width: parent.width

            Label {
                elide: Text.ElideRight
                width: parent.width - 20
                font.pixelSize: 20
                anchors.horizontalCenter: parent.horizontalCenter
                text: spotifySession.currentTrack ? spotifySession.currentTrack.name : ""
            }

            Label {
                elide: Text.ElideRight
                width: parent.width - 20
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
                text: spotifySession.currentTrack ? spotifySession.currentTrack.artists : ""
            }
        }

        CoverActionList {
            id: coverAction

            CoverAction {
                iconSource: spotifySession.currentTrack ? (spotifySession.isPlaying ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play") : ""
                onTriggered: {
                    spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
                }
            }

            CoverAction {
                iconSource: spotifySession.currentTrack ? "image://theme/icon-cover-next-song" : ""
                onTriggered: {
                    spotifySession.playNext()
                }
            }

        }
    }

    Rectangle {
        id: errorRect
        color: Theme.highlightColor
        width: parent.width
        height: 32
        visible: false

        Label {
            id: errorBanner
            color: "black"
            font.pixelSize: 20
            anchors.centerIn: parent
            text: ""
        }

        NumberAnimation on opacity {
            id: errorRectFadeOut
            from: 1
            to: 0
            duration: 10000
        }
    }

    Rectangle {
            id: volBack
            visible: false
            anchors.top: parent.top
            width: parent.width
            height: 32
            color: Theme.secondaryColor
            NumberAnimation on opacity {
                id: volBackFadeOut
                from: 1
                to: 0
                duration: 2000
            }
    }

    Rectangle {
            id: vol
            visible: false
            anchors.top: parent.top
            anchors.left: parent.left
            width: (spotifySession.volume / 100) * parent.width
            height: 32
            color: Theme.highlightColor
            NumberAnimation on opacity {
                id: volFadeOut
                from: 1
                to: 0
                duration: 2000
            }
    }

    Connections {
        target: spotifySession
        onVolumeChanged: {
            volBack.visible = true;
            volBackFadeOut.stop();
            volBackFadeOut.start();
            vol.visible = true;
            volFadeOut.stop();
            volFadeOut.start();
        }
    }

    Connections {
        target: spotifySession
        onConnectionErrorChanged: {
            if (spotifySession.connectionError != SpotifySession.Ok) {
                errorBanner.text = spotifySession.connectionErrorMessage;
                errorRect.visible = true;
                errorRectFadeOut.stop();
                errorRectFadeOut.start();
                console.log(spotifySession.connectionErrorMessage);
            }
        }
    }

    Connections {
        target: spotifySession
        onLfmLoginError: {
            errorBanner.text = "Last.fm login failed, please check username and password";
            errorRect.visible = true;
            errorRectFadeOut.stop();
            errorRectFadeOut.start();
        }
    }

    Player {
        id: player
        visible: spotifySession.currentTrack ? true : false
    }

    Component {
        id: mainPage
        // MainPage {
        PlaylistPage {
            id: mainPageItem
            //onToolsChanged: appWindow.pageStack.toolBar.setTools(mainPageItem.tools, "replace")
        }
    }

    Component {
        id: loginPage
        LoginPage { }
    }

    Component.onCompleted: {
        spotifySession.isLoggedIn ? pageStack.push(mainPage) : pageStack.push(loginPage)
        themeColor = "color2"
        if (!spotifySession.isOnline && (!spotifySession.user || !spotifySession.offlineMode))
            openConnection();
    }

    function openConnection() {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", "http://m.google.com"); //force opening a connection
        xhr.send();
    }

    Connections {
        target: spotifySession
        onIsOnlineChanged: {
            if (!spotifySession.isOnline && (!spotifySession.user || !spotifySession.offlineMode))
                openConnection();
        }
        onOfflineModeChanged: {
            if (!spotifySession.isOnline && (!spotifySession.user || !spotifySession.offlineMode))
                openConnection();
        }
        onPendingConnectionRequestChanged: {
            if (!spotifySession.pendingConnectionRequest && spotifySession.isLoggedIn) {
                pageStack.clear() // Remove login page from stack
                pageStack.push(mainPage)
            } else if (spotifySession.pendingConnectionRequest && spotifySession.isLoggedIn) {
                pageStack.clear()
                pageStack.push(loginPage)
            }
        }
    }
}
