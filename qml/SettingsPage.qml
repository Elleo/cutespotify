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
    id: settingsPage
    allowedOrientations: Orientation.All

    SilicaFlickable {
        id: settingsFlickable

        anchors.fill: parent

        contentHeight: settingsContainer.height

        VerticalScrollDecorator {}

        PullDownMenu {
            MenuItem {
                id: button
                text: qsTr("Log out ") + (spotifySession.user ? spotifySession.user.canonicalName : "")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    var logoutDialog = pageStack.push(
                                Qt.resolvedUrl("LogoutDialog.qml"),
                                {"userName": (spotifySession.user ? spotifySession.user.canonicalName : "")})
                    logoutDialog.accepted.connect(function() {
                        spotifySession.logout(false)
                    })
                }
            }

            MenuItem {
                text: qsTr("About")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
        }

        Column {
            id: settingsContainer
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Playback")
            }

            TextSwitch {
                id: volumeNormalizeSwitch
                checked: spotifySession.volumeNormalize
                text: qsTr("Normalize Volume")
                onClicked: spotifySession.volumeNormalize = checked
            }

            SectionHeader {
                text: qsTr("Stream")
            }

            ComboBox {
                menu: ContextMenu {
                    MenuItem { text: "Low quality (96kbps)"; onClicked: spotifySession.streamingQuality = SpotifySession.LowQuality }
                    MenuItem { text: "Normal quality (160kbps)"; onClicked: spotifySession.streamingQuality = SpotifySession.HighQuality }
                    MenuItem { text: "High quality (320kbps)"; onClicked: spotifySession.streamingQuality = SpotifySession.UltraQuality }
                }
                currentIndex: spotifySession.streamingQuality === SpotifySession.LowQuality ? 0
                                                                                            : spotifySession.streamingQuality === SpotifySession.HighQuality ? 1 : 2
            }

            SectionHeader {
                text: qsTr("Offline Sync")
            }

            ComboBox {
                menu: ContextMenu {
                    MenuItem { text: "Low quality (96kbps)"; onClicked: spotifySession.syncQuality = SpotifySession.LowQuality }
                    MenuItem { text: "Normal quality (160kbps)"; onClicked: spotifySession.syncQuality = SpotifySession.HighQuality }
                    MenuItem { text: "High quality (320kbps)"; onClicked: spotifySession.syncQuality = SpotifySession.UltraQuality }
                }
                currentIndex: spotifySession.syncQuality === SpotifySession.LowQuality ? 0
                                                                                       : spotifySession.syncQuality === SpotifySession.HighQuality ? 1 : 2
            }

            SectionHeader {
                text: qsTr("Connectivity")
            }

            TextSwitch {
                id: offlineSwitch
                checked: spotifySession.offlineMode
                text: qsTr("Offline mode")
                onClicked: spotifySession.setOfflineMode(checked)
            }

            TextSwitch {
                id: privateSwitch
                checked: spotifySession.privateSession
                text: qsTr("Private session")
                onClicked: spotifySession.setPrivateSession(checked)
            }

            TextSwitch {
                id: syncSwitch
                checked: spotifySession.syncOverMobile
                text: qsTr("Sync over 2G/3G")
                onClicked: spotifySession.setSyncOverMobile(checked)
            }

            TextSwitch {
                id: scrobbleSwitch

                height: implicitHeight + (lastFMContextMenu._open ? lastFMContextMenu.height : 0)

                checked: spotifySession.scrobble
                text: qsTr("Scrobble to Last.fm")
                onClicked: {
                    if(checked && !spotifySession.lfmLoggedIn) {
                        pageStack.push(Qt.resolvedUrl("LastFMDialog.qml"))
                    }
                    spotifySession.scrobble = checked
                }
                onPressAndHold: {
                    lastFMContextMenu.show(scrobbleSwitch)
                }
            }
        }

        ContextMenu {
            id: lastFMContextMenu
            MenuItem {
                text: spotifySession.lfmLoggedIn ?
                          qsTr("Log out of Last.fm") :
                          qsTr("Log in to Last.fm")
                onClicked: {
                    if(spotifySession.lfmLoggedIn) {
                        spotifySession.lfmLogin("", "");
                    } else {
                        pageStack.push(Qt.resolvedUrl("LastFMDialog.qml"))
                    }
                }
            }
        }
    }
}
