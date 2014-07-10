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

Page {

    Connections {
        target: spotifySession
        onConnectionStatusChanged: {
            if (spotifySession.connectionStatus == SpotifySession.LoggedIn) {
                pageStack.clear();
                pageStack.push(mainPage);
            }
        }
    }

    SilicaFlickable {

        anchors.fill: parent

        PullDownMenu {
            visible: spotifySession.connectionStatus == SpotifySession.LoggedOut

            MenuItem {
                text: "Clear cache and offline song storage"
                onClicked: {
                    spotifySession.clearCache();
                }
            }
        }

        Column {
            id: content
            spacing: Theme.paddingLarge
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingLarge
            anchors.rightMargin: Theme.paddingLarge

            Image {
                id: logo
                source: "qrc:/qml/images/cutespotify-logo.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Column {
                id: fields
                visible: !spotifySession.pendingConnectionRequest && spotifySession.connectionStatus == SpotifySession.LoggedOut
                spacing: Theme.paddingLarge
                anchors.left: parent.left
                anchors.right: parent.right

                TextField {
                    id: username
                    placeholderText: qsTr("Username")
                    label: qsTr("Username")
                    width: parent.width
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText

                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-next"
                    EnterKey.onClicked: password.forceActiveFocus()
                }

                TextField {
                    id: password
                    placeholderText: qsTr("Password")
                    label: qsTr("Password")
                    echoMode: TextInput.Password
                    width: parent.width
                    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText

                    EnterKey.enabled: text.length > 0
                    EnterKey.iconSource: (username.text.length > 0 && termsCheck.checked) ? "image://theme/icon-m-enter-accept" : "image://theme/icon-m-enter-close"
                    EnterKey.onClicked: {
                        if (username.text.length > 0 && termsCheck.checked) {
                            spotifySession.login(username.text, password.text);
                            password.text = ""
                        }
                        focus = false
                    }
                }

                Column {
                    width: parent.width
                    TextSwitch {
                        id: termsCheck
                        text: qsTr("Accept")
                    }

                    Label {
                        anchors {
                            left: parent.left
                            leftMargin: Theme.paddingLarge * 2
                            right: parent.right
                        }
                        onLinkActivated: Qt.openUrlExternally(link)
                        textFormat: Text.RichText
                        wrapMode: Text.WordWrap
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: "<style>a:link { color: " + Theme.highlightColor +"; }</style>I have read and accepted the Spotify® <a href='http://www.spotify.com/legal/end-user-agreement/'>Terms and Conditions of Use</a> and <a href='http://www.spotify.com/legal/mobile-terms-and-conditions/'>Mobile Terms of Use</a>."
                    }
                }

                Button {
                    id: button
                    anchors.horizontalCenter: parent.horizontalCenter

                    text: qsTr("Log in")
                    enabled: username.text.length > 0 && password.text.length > 0 && termsCheck.checked

                    onClicked: {
                        spotifySession.login(username.text, password.text);
                        password.text = ""
                    }
                }

                Item {
                    height: Theme.paddingLarge
                    width: 1
                }

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    onLinkActivated: Qt.openUrlExternally(link)
                    horizontalAlignment: Text.AlignHCenter
                    textFormat: Text.RichText
                    text: "<style>a:link { color: " + Theme.highlightColor +"; }</style>Need a Spotify® Premium account?<br>Get one at <a href='http://www.spotify.com'>www.spotify.com</a>."
                }
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                visible: !fields.visible
                spacing: Theme.paddingLarge * 3

                Label {
                    id: loggingText
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: qsTr("Logging in")

                    Connections {
                        target:  spotifySession
                        onLoggingIn: loggingText.text = qsTr("Logging in")
                        onLoggingOut: loggingText.text = qsTr("Logging out")
                    }
                }

                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: parent.visible
                }
            }
        }
    }
}
