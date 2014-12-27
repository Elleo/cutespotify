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
import Sailfish.Media 1.0
import org.nemomobile.policy 1.0

ApplicationWindow {
    id: appWindow

    allowedOrientations: Orientation.All

    bottomMargin: quickControls.visibleSize

    property bool grabKeys: keysResource.acquired

    cover: Qt.resolvedUrl("CoverPage.qml")

    property bool showFullControls: false
    onShowFullControlsChanged: {
        if(showFullControls) {
            quickControls.open = false
            pageStack.push(fullControls, undefined, PageStackAction.Immediate)
        } else {
            pageStack.pop()
            if(spotifySession.currentTrack && !quickControls.open)
                quickControls.open = true
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

    QuickControls {
        id: quickControls
    }

    FullControls {
        id: fullControls
    }

    Component {
        id: mainPage
        PlaylistPage {  }
    }

    Component {
        id: loginPage
        LoginPage { }
    }

    Component.onCompleted: {
        spotifySession.isLoggedIn ? pageStack.push(mainPage) : pageStack.push(loginPage)
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
        onConnectionErrorChanged: {
            if (spotifySession.connectionError != SpotifySession.Ok) {
                errorBanner.text = spotifySession.connectionErrorMessage;
                errorRect.visible = true;
                errorRectFadeOut.stop();
                errorRectFadeOut.start();
                console.log(spotifySession.connectionErrorMessage);
            }
        }
        onLfmLoginError: {
            errorBanner.text = "Last.fm login failed, please check username and password";
            errorRect.visible = true;
            errorRectFadeOut.stop();
            errorRectFadeOut.start();
        }
        onIsPlayingChanged: {
            if(spotifySession.isPlaying && !quickControls.open && !showFullControls)
                quickControls.open = true;
        }
        onCurrentTrackChanged: {
            if(!spotifySession.currentTrack) {
                showFullControls = false;
                quickControls.open = false;
            }
        }
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_AudioRepeat
        onPressed: {
            spotifySession.repeat = !spotifySession.repeat;
        }
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_AudioRandomPlay
        onPressed: spotifySession.shuffle = !spotifySession.shuffle
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaTogglePlayPause
        onPressed: spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
    }
    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaPlay
        onPressed: spotifySession.resume()
    }
    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaPause
        onPressed: spotifySession.pause()
    }
    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaStop
        onPressed: spotifySession.stop();
    }
    MediaKey {
        enabled: grabKeys
        key: Qt.Key_MediaNext
        onPressed: spotifySession.playNext()
    }
    MediaKey {
        enabled: true
        key: Qt.Key_MediaPrevious
        onPressed: spotifySession.playPrevious()
    }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_AudioForward
        onPressed: spotifySession.seek(Math.max(0, spotifySession.currentTrackPosition + 500))
        onRepeat: spotifySession.seek(Math.max(0, spotifySession.currentTrackPosition + 1000))
        onReleased: nextTimer.stop()
    }
    Timer { id: nextTimer; interval: 500; onTriggered: spotifySession.playNext() }

    MediaKey {
        enabled: grabKeys
        key: Qt.Key_AudioRewind
        onPressed: spotifySession.seek(Math.max(0, spotifySession.currentTrackPosition - 500))
        onRepeat: spotifySession.seek(Math.max(0, spotifySession.currentTrackPosition - 1000))
        onReleased: previousTimer.stop()
    }
    Timer { id: previousTimer; interval: 500; onTriggered: spotifySession.playPrevious() }

    Permissions {
        enabled: true
        applicationClass: "player"

        Resource {
            id: keysResource
            type: Resource.HeadsetButtons
            optional: true
        }
    }
}
