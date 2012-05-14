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
    id: settingsPage
    orientationLock: PageOrientation.LockPortrait
    anchors.rightMargin: UI.MARGIN_XLARGE
    anchors.leftMargin: UI.MARGIN_XLARGE

    ListView {
        id: settingsFlickable
        anchors.fill: parent

        model: 1
        delegate: Column {
            id: settingsContainer
            width: settingsPage.width
            spacing: UI.MARGIN_XLARGE

            ViewHeader {
                id: header
                text: "Settings"
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right

                Column {
                    width: parent.width

                    Item {
                        width: parent.width
                        height: UI.LIST_ITEM_HEIGHT

                        Label {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: UI.FONT_FAMILY_BOLD
                            font.weight: Font.Bold
                            font.pixelSize: UI.LIST_TILE_SIZE
                            color: theme.inverted ? UI.LIST_TITLE_COLOR_INVERTED : UI.LIST_TITLE_COLOR
                            text: "Offline mode"
                        }

                        Switch {
                            id: offlineSwitch
                            platformStyle: SwitchStyle {
                                 switchOn: "image://theme/" + appWindow.themeColor + "-meegotouch-switch-on-inverted"
                            }
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            onCheckedChanged: spotifySession.setOfflineMode(checked)

                            Component.onCompleted: checked = spotifySession.offlineMode;

                            Connections {
                                target: spotifySession
                                onOfflineModeChanged: offlineSwitch.checked = spotifySession.offlineMode
                            }
                        }
                    }

                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        font.family: UI.FONT_FAMILY_LIGHT
                        font.pixelSize: UI.LIST_SUBTILE_SIZE
                        font.weight: Font.Light
                        color: theme.inverted ? UI.LIST_SUBTITLE_COLOR_INVERTED : UI.LIST_SUBTITLE_COLOR
                        text: "When offline, only the playlists you've made available for offline listening will be playable."
                    }

                    Item {
                        width: parent.width
                        height: UI.MARGIN_XLARGE * 2
                    }
                }

                Selector {
                    title: "Stream"
                    model: ListModel {
                        ListElement { name: "Low bandwidth"; value: SpotifySession.LowQuality }
                        ListElement { name: "High bandwidth"; value: SpotifySession.HighQuality }
                    }
                    selectedIndex: spotifySession.streamingQuality == SpotifySession.LowQuality ? 0 : 1
                    onSelectedIndexChanged: spotifySession.streamingQuality = model.get(selectedIndex).value
                }

                Selector {
                    title: "Offline Sync"
                    model: ListModel {
                        ListElement { name: "Low Quality"; value: SpotifySession.LowQuality }
                        ListElement { name: "High Quality"; value: SpotifySession.HighQuality }
                    }
                    selectedIndex: spotifySession.syncQuality == SpotifySession.LowQuality ? 0 : 1
                    onSelectedIndexChanged: spotifySession.syncQuality = model.get(selectedIndex).value
                }

                Item {
                    width: parent.width
                    height: UI.LIST_ITEM_HEIGHT

                    Label {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: UI.FONT_FAMILY_BOLD
                        font.weight: Font.Bold
                        font.pixelSize: UI.LIST_TILE_SIZE
                        color: theme.inverted ? UI.LIST_TITLE_COLOR_INVERTED : UI.LIST_TITLE_COLOR
                        text: "Sync over 2G/3G"
                    }

                    Switch {
                        platformStyle: SwitchStyle {
                            switchOn: "image://theme/" + appWindow.themeColor + "-meegotouch-switch-on-inverted"
                        }
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: spotifySession.syncOverMobile
                        onCheckedChanged: spotifySession.setSyncOverMobile(checked)
                    }
                }

                Item {
                    width: parent.width
                    height: UI.MARGIN_XLARGE * 2

                    Separator {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                    }
                }

                Item {
                    width: parent.width
                    height: UI.LIST_ITEM_HEIGHT

                    LastfmLoginSheet {
                        id: lastfmLogin
                        title: "Scrobble to last.fm"
                    }

                    Rectangle {
                        id: background
                        anchors.fill: parent
                        // Fill page porders
                        anchors.leftMargin: -UI.MARGIN_XLARGE
                        anchors.rightMargin: -UI.MARGIN_XLARGE
                        opacity: lastfmMouseArea.pressed ? 1.0 : 0.0
                        color: "#22FFFFFF"
                        Behavior on opacity { NumberAnimation { duration: 50 } }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: lastfmSwitch.left

                        Label {
                            id: titleText
                            width: parent.width
                            font.family: UI.FONT_FAMILY_BOLD
                            font.weight: Font.Bold
                            font.pixelSize: UI.LIST_TILE_SIZE
                            elide: Text.ElideRight
                            color: theme.inverted ? UI.LIST_TITLE_COLOR_INVERTED : UI.LIST_TITLE_COLOR
                            text: "Scrobble to last.fm"
                        }
                        Label {
                            id: selectedValue
                            width: parent.width
                            font.family: UI.FONT_FAMILY_LIGHT
                            font.pixelSize: UI.LIST_SUBTILE_SIZE
                            font.weight: Font.Light
                            elide: Text.ElideRight
                            color: theme.inverted ? UI.LIST_SUBTITLE_COLOR_INVERTED : UI.LIST_SUBTITLE_COLOR
                            text: lastfm.user
                            visible: text.length > 0
                        }
                    }

                    MouseArea {
                        id: lastfmMouseArea
                        anchors.fill: parent
                        onClicked: {
                            lastfmLogin.open()
                        }
                    }

                    Switch {
                        id: lastfmSwitch
                        platformStyle: SwitchStyle {
                            switchOn: "image://theme/" + appWindow.themeColor + "-meegotouch-switch-on-inverted"
                        }
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        onCheckedChanged: {
                            if (checked && lastfm.user.length === 0) {
                                lastfmLogin.open();
                                checked = false;
                            } else {
                                lastfm.enabled = checked
                            }
                        }

                        Component.onCompleted: checked = lastfm.enabled;

                        Connections {
                            target: lastfm
                            onEnabledChanged: lastfmSwitch.checked = lastfm.enabled
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: UI.MARGIN_XLARGE * 2

                    Separator {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                    }
                }

                Item {
                    width: parent.width
                    height: UI.MARGIN_XLARGE
                }

                Button {
                    id: buttonAbout
                    text: "About"
                    platformStyle: ButtonStyle {
                        pressedBackground: "image://theme/" + appWindow.themeColor + "-meegotouch-button-inverted-background-pressed" + (position ? "-" + position : "")
                        disabledBackground: "image://theme/" + appWindow.themeColor + "-meegotouch-button-inverted-background-disabled" + (position ? "-" + position : "")
                        checkedBackground: "image://theme/" + appWindow.themeColor + "-meegotouch-button-inverted-background-selected" + (position ? "-" + position : "")
                        checkedDisabledBackground: "image://theme/" + appWindow.themeColor + "-meegotouch-button-inverted-background-disabled-selected" + (position ? "-" + position : "")
                    }
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: UI.PADDING_XXLARGE
                    anchors.rightMargin: UI.PADDING_XXLARGE

                    onClicked: {
                        aboutDialog.open();
                    }
                }

                Item {
                    width: parent.width
                    height: UI.MARGIN_XLARGE
                }

                Button {
                    id: button
                    platformStyle: ButtonStyle {
                        pressedBackground: "image://theme/" + appWindow.themeColor + "-meegotouch-button-inverted-background-pressed" + (position ? "-" + position : "")
                        disabledBackground: "image://theme/" + appWindow.themeColor + "-meegotouch-button-inverted-background-disabled" + (position ? "-" + position : "")
                        checkedBackground: "image://theme/" + appWindow.themeColor + "-meegotouch-button-inverted-background-selected" + (position ? "-" + position : "")
                        checkedDisabledBackground: "image://theme/" + appWindow.themeColor + "-meegotouch-button-inverted-background-disabled-selected" + (position ? "-" + position : "")
                    }
                    text: "Log out " + (spotifySession.user ? spotifySession.user.canonicalName : "")
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: UI.PADDING_XXLARGE
                    anchors.rightMargin: UI.PADDING_XXLARGE

                    onClicked: {
                        spotifySession.logout(false);
                        lastfm.forgetUser();
                    }
                }

                Item {
                    width: parent.width
                    height: UI.MARGIN_XLARGE * 2
                }
            }
        }
    }

    AboutDialog {
        id: aboutDialog
    }

    ScrollDecorator { flickableItem: settingsFlickable }
}
