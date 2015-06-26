import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSpotify 1.0

Dialog {
    id: playlistSelectionDialog

    property var track: null
    property var album: null
    property Component delegate: defaultDelegate

    canAccept: false

    Component.onCompleted: populatePlaylists()

    ListModel {id: playlistsModel}

    DialogHeader {
        id: header
        title: qsTr("Add to playlist")
    }

    SilicaListView {
        id: playlists
        width: parent.width
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        clip: true
        model: playlistsModel
        delegate: playlistSelectionDialog.delegate
        VerticalScrollDecorator {}
    }

    Component {
        id: defaultDelegate
        BackgroundItem {
            id: defaultDelegateItem
            height: Theme.itemSizeSmall
            Label {
                anchors {
                    left: parent.left
                    leftMargin: Theme.paddingLarge
                    right: parent.right
                    rightMargin: Theme.paddingLarge
                    verticalCenter: parent.verticalCenter
                }
                text: name
                color: defaultDelegateItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                truncationMode: TruncationMode.Fade
            }

            onClicked: {
                if (playlistSelectionDialog.track) {
                    if (object) {
                        object.add(playlistSelectionDialog.track)
                    } else {
                        // TODO check return value.
                        spotifySession.user.createPlaylistFromTrack(playlistSelectionDialog.track);
                    }
                } else if (playlistSelectionDialog.album) {
                    if (object) {
                        object.addAlbum(playlistSelectionDialog.album);
                    } else {
                        // TODO check return value.
                        spotifySession.user.createPlaylistFromAlbum(playlistSelectionDialog.album)
                    }
                }
                playlistSelectionDialog.canAccept = true;
                playlistSelectionDialog.accept()
            }
        }
    }

    function populatePlaylists() {
        if (spotifySession.user) {
            var userPlaylists = spotifySession.user.playlistsFlat
            for (var i in userPlaylists) {
                if (userPlaylists[i].type === SpotifyPlaylist.Playlist && spotifySession.user.canModifyPlaylist(userPlaylists[i]))
                    playlistsModel.append({"name": userPlaylists[i].name, "object": userPlaylists[i] })
            }
            playlistsModel.append({"name": "New playlist" });
        }
    }
}
