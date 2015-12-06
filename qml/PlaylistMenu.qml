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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtSpotify 1.0
import "UIConstants.js" as UI
import "Utilities.js" as Utilities

MyMenu {
    id: playlistMenu

    property variant playlist: null
    property bool userOwnsPlaylist: spotifySession.user ? spotifySession.user.ownsPlaylist(playlist) : false

    layoutContentHeight: layout.height

    NotificationBanner {
        id: banner
    }

    PlaylistNameSheet{
        id: renameSheet
        title: "Rename playlist"
        onAccepted: playlist.rename(Utilities.trim(renameSheet.playlistName))
    }
/*
    Component {
        id: confirmDeleteDialog
        Dialog {
            id: deleteInnerDialog;
            property bool deleteFolderContent: false
            text: playlist ? playlist.name : ""
            Button {
                text: "Yes";
                onClicked: {
                    if (deleteFolderContent)
                        playlist.deleteFolderContent();
                    else
                        playlist.removeFromContainer()
                    deleteFolderContent = false;
                    PopupUtils.close(deleteInnerDialog)
                }
            }
            Button {
                text: "No";
                onClicked: {
                    deleteFolderContent = false;
                    PopupUtils.close(deleteInnerDialog)
                }
            }
        }
    }
*/
    MyMenuLayout {
        id: layout

        MyMenuItem {
            text: "Play";
            onClicked: { playlist.play() }
            visible: (playlist && playlist.trackCount > 0) ? true : false
        }
        MyMenuItem {
            text: "Add to queue";
            onClicked: { playlist.enqueue() }
            visible: (playlist && (playlist.trackCount > 0 || playlist.type === SpotifyPlaylist.Folder)) ? true : false
        }
        MyMenuItem {
            text: "Rename"
            onClicked: { renameSheet.playlistName = playlist.name; renameSheet.open() }
            visible: ((playlist && playlist.type == SpotifyPlaylist.Playlist && userOwnsPlaylist) ? true : false)
                     && !spotifySession.offlineMode
        }
        MyMenuItem {
            id: collabItem
            onClicked: { playlist.collaborative = !playlist.collaborative }
            visible: ((playlist && playlist.type == SpotifyPlaylist.Playlist && userOwnsPlaylist) ? true : false)
                     && !spotifySession.offlineMode
        }
        MyMenuItem {
            id: offlineItem
            visible: (playlist && playlist.type !== SpotifyPlaylist.Folder) ? true : false
            onClicked: { playlist.availableOffline = !playlist.availableOffline }
        }
        MyMenuItem {
            id: setFolderOfflineItem
            visible: ((playlist && playlist.type === SpotifyPlaylist.Folder) ? true : false) && !spotifySession.offlineMode
            text: "Set offline mode for content"
            onClicked: { playlist.availableOffline = true }
        }
        MyMenuItem {
            id: unsetFolderOfflineItem
            visible: (playlist && playlist.type === SpotifyPlaylist.Folder) ? true : false
            text: "Unset offline mode for content"
            onClicked: { playlist.availableOffline = false }
        }
        MyMenuItem {
            id: deleteItem
            onClicked: {
                if (playlist.type === SpotifyPlaylist.Folder) {
                    confirmDeleteDialog.titleText = "Delete folder?";
                } else {
                    confirmDeleteDialog.titleText = userOwnsPlaylist ? "Delete playlist?" : "Unsubscribe from playlist?";
                }
                confirmDeleteDialog.open();
            }
            visible: ((playlist && (playlist.type == SpotifyPlaylist.Playlist || playlist.type == SpotifyPlaylist.Folder)) ? true : false)
                     && !spotifySession.offlineMode
        }
        MyMenuItem {
            id: deleteFolderContentItem
            text: "Delete folder and content"
            onClicked: {
                confirmDeleteDialog.deleteFolderContent = true;
                confirmDeleteDialog.titleText = "Delete folder and its content?";
                confirmDeleteDialog.open();
            }
            visible: ((playlist && playlist.type == SpotifyPlaylist.Folder) ? true : false)
                     && !spotifySession.offlineMode
        }
    }

    onStatusChanged: {
        if (status == "Opening" && playlist) {
            collabItem.text = (playlist.collaborative ? "Unset" : "Set") +  " collaborative";
            offlineItem.text = (playlist.availableOffline ? "Unset" : "Set") + " offline mode"
            if (playlist.type === SpotifyPlaylist.Folder) {
                deleteItem.text = "Delete";
            } else {
                deleteItem.text = userOwnsPlaylist ? "Delete" : "Unsubscribe";
            }
        }
    }
}
