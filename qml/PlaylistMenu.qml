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

    QueryDialog {
        id: confirmDeleteDialog
        parent: playlistMenu.parent
        titleText: userOwnsPlaylist ? "Delete playlist?" : "Unsubscribe from playlist?"
        message: playlist ? playlist.name : ""
        acceptButtonText: "Yes"
        rejectButtonText: "No"
        onAccepted: { playlist.removeFromContainer() }
    }

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
            visible: (playlist && playlist.trackCount > 0) ? true : false
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
            onClicked: { playlist.availableOffline = !playlist.availableOffline }
        }
        MyMenuItem {
            id: deleteItem
            onClicked: { confirmDeleteDialog.open(); }
            visible: ((playlist && playlist.type == SpotifyPlaylist.Playlist) ? true : false)
                     && !spotifySession.offlineMode
        }
    }

    onStatusChanged: {
        if (status == DialogStatus.Opening && playlist) {
            collabItem.text = (playlist.collaborative ? "Unset" : "Set") +  " collaborative";
            deleteItem.text = userOwnsPlaylist ? "Delete" : "Unsubscribe";
            offlineItem.text = (playlist.availableOffline ? "Unset" : "Set") + " offline mode"
        }
    }
}
