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
import com.nokia.meego 1.0
import QtSpotify 1.0
import "UIConstants.js" as UI

Page {
    id: mainPage
    tools: player.state == "open" ? null : mainTools
    orientationLock: PageOrientation.LockPortrait

    property alias tabs: tabGroup
    property alias searchTabAlias: searchTab
    property alias playlistSelection: playlistSelectionDialog

    NotificationBanner {
        id: errorBanner
    }

    MySelectionDialog {
        id: playlistSelectionDialog

        property variant track: null

        titleText: "Playlists"
        onAccepted: {
            var playlistItem = model.get(playlistSelectionDialog.selectedIndex);
            if (playlistItem.object) {
                errorBanner.text = "Track added to " + playlistItem.name;
                playlistItem.object.add(track);
            } else {
                if (spotifySession.user.createPlaylistFromTrack(track)) {
                    errorBanner.text = "Track added to new playlist";
                } else {
                    errorBanner.text = "Could not add track to new playlist";
                }
            }
            errorBanner.show();
        }
    }

    property variant playlists: spotifySession.user ? spotifySession.user.playlists : null
    Connections {
        target: spotifySession.user
        onPlaylistsNameChanged: updatePlaylistDialog()
    }

    onPlaylistsChanged: updatePlaylistDialog()

    function updatePlaylistDialog() {
        playlistSelectionDialog.model.clear();

        if (playlists === null)
            return;

        for (var i in mainPage.playlists) {
            if (mainPage.playlists[i].type == SpotifyPlaylist.Playlist && spotifySession.user.canModifyPlaylist(mainPage.playlists[i]))
                playlistSelectionDialog.model.append({"name": mainPage.playlists[i].name, "object": mainPage.playlists[i] })
        }

        playlistSelectionDialog.model.append({"name": "New playlist" });
    }

    Connections {
        target: spotifySession
        onConnectionErrorChanged: {
            if (spotifySession.connectionError != SpotifySession.Ok) {
                errorBanner.text = spotifySession.connectionErrorMessage;
                errorBanner.show();
            }
        }
        onOfflineErrorMessageChanged: {
            errorBanner.text = spotifySession.offlineErrorMessage;
            errorBanner.show();
        }
        onPlayTokenLost: {
            if (spotifySession.isPlaying) {
                errorBanner.text = "Playback has been paused because your account is used somewhere else";
                errorBanner.show();
            }
        }
    }

    Connections {
        target: lastfm
        onErrorChanged: {
            errorBanner.text = "Last.fm: " + lastfm.error;
            errorBanner.show();
        }
    }

    TabGroup {
        id: tabGroup
        enabled: !currentTab.busy
        y: player.hidden ? 0 : screen.currentOrientation == Screen.Portrait ? UI.HEADER_DEFAULT_HEIGHT_PORTRAIT
                                                                            : UI.HEADER_DEFAULT_HEIGHT_LANDSCAPE
        height: parent.height - y
        Behavior on y { NumberAnimation { easing.type: Easing.OutQuart; duration: 500 } }

        currentTab: playlistsTab

        PageStack {
            id: playlistsTab
            Component.onCompleted: push(Qt.resolvedUrl("PlaylistPage.qml"))
        }
        PageStack {
            id: searchTab
        }
        PageStack {
            id: toplistTab
        }
        PageStack {
            id: settingsTab
        }

        Connections {
            target: spotifySession
            onUserChanged: {
                if (spotifySession.isLoggedIn)
                    tabGroup.currentTab = playlistsTab
            }
        }
    }

    Player {
        id: player
    }

    property Item mainTools : ToolBarLayout {
        ToolIcon {
            iconId: enabled ? "toolbar-back" : "toolbar-back-dimmed"
            onClicked: { tabGroup.currentTab.pop(); }
            enabled: tabGroup.currentTab.depth > 1 && !tabGroup.currentTab.busy
        }

        ButtonRow {
            TabButton {
                tab: playlistsTab
                iconSource: theme.inverted ? "image://theme/icon-m-toolbar-list-white"
                                          : "image://theme/icon-m-toolbar-list"

                property bool isCurrentTab: false

                onPressedChanged: {
                    if (pressed)
                        isCurrentTab = (tabGroup.currentTab == playlistsTab);
                }

                onClicked: {
                    if (isCurrentTab && playlistsTab.depth > 1)
                        playlistsTab.pop(null);
                }
            }
            TabButton {
                tab: searchTab
                iconSource: theme.inverted ? "image://theme/icon-m-toolbar-search-white"
                                           : "image://theme/icon-m-toolbar-search"

                property bool isCurrentTab: false

                onPressedChanged: {
                    if (pressed)
                        isCurrentTab = (tabGroup.currentTab == searchTab);
                }

                onClicked: {
                    mainPage.checkSearchPage();
                    if (isCurrentTab && searchTab.depth > 1)
                        searchTab.pop(null);
                }
            }
            TabButton {
                tab: toplistTab
                iconSource: theme.inverted ? "image://theme/icon-m-toolbar-home-white"
                                           : "image://theme/icon-m-toolbar-home"

                property bool isCurrentTab: false

                onPressedChanged: {
                    if (pressed)
                        isCurrentTab = (tabGroup.currentTab == toplistTab);
                }

                onClicked: {
                    if (toplistTab.depth === 0)
                        toplistTab.push(Qt.resolvedUrl("ToplistPage.qml"))
                    else if (isCurrentTab && toplistTab.depth > 1)
                        toplistTab.pop(null);
                }
            }
            TabButton {
                tab: settingsTab
                iconSource: theme.inverted ? "image://theme/icon-m-toolbar-settings-white"
                                           : "image://theme/icon-m-toolbar-settings"
                onClicked: { if (settingsTab.depth === 0) settingsTab.push(Qt.resolvedUrl("SettingsPage.qml")) }
            }
        }
    }

    function checkSearchPage() {
        if (searchTab.depth === 0) searchTab.push(Qt.resolvedUrl("SearchPage.qml"))
    }

}
