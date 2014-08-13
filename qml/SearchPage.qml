import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSpotify 1.0

Page {
    enabled: !spotifySession.offlineMode

    SpotifySearch {
        id: search
    }

    SilicaFlickable {
        width: parent.width
        anchors.fill: parent
        contentHeight: contentColumn.height

        VerticalScrollDecorator { }

        Column {
            id: contentColumn
            width: parent.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTr("Search")
            }

            SearchField {
                id: searchField
                placeholderText: qsTr("Search")
                width: parent.width
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                onTextChanged: {
                    search.query = text.trim()
                    search.search(true)
                }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: {searchField.focus = false;}
            }

            SectionHeader {
                visible: tracksView.count > 0
                text: qsTr("Tracks")
            }

            Repeater {
                id: tracksView
                width: parent.width
                model: search.trackResultsPreview()
                delegate: trackDelegate
            }

            SeeMoreItem {
                visible: tracksView.count > 0
                moreText: qsTr("tracks")
                onClicked: {
                    search.searchTracks()
                    pageStack.push(Qt.resolvedUrl("SearchListPage.qml"),
                                   {"pageTitle": qsTr("Tracks for \"") + search.query + ("\""),
                                       "listModel": search.trackResults(),
                                       "listDelegate": trackDelegate})
                }
            }

            SectionHeader {
                visible: artistsView.count > 0
                text: qsTr("Artists")
            }

            Repeater {
                id: artistsView
                width: parent.width
                property variant modelVar: search.artistsPreview()
                model: modelVar
                delegate: artistDelegate
            }

            SeeMoreItem {
                visible: artistsView.count > 0
                moreText: qsTr("artists")
                onClicked: {
                    search.searchArtists()
                    pageStack.push(Qt.resolvedUrl("SearchListPage.qml"),
                                   {"pageTitle": qsTr("Artists for \"") + search.query + ("\""),
                                       "listModel": search.artists(),
                                       "listDelegate": artistDelegate})
                }
            }

            SectionHeader {
                visible: albumsView.count > 0
                text: qsTr("Albums")
            }

            Repeater {
                id: albumsView
                property variant modelVar: search.albumsPreview()
                width: parent.width
                model: modelVar
                delegate: albumDelegate
            }

            SeeMoreItem {
                visible: albumsView.count > 0
                moreText: qsTr("albums")
                onClicked: {
                    search.searchAlbums()
                    pageStack.push(Qt.resolvedUrl("SearchListPage.qml"),
                                   {"pageTitle": qsTr("Albums for \"") + search.query + ("\""),
                                       "listModel": search.albums(),
                                       "listDelegate": albumDelegate})
                }
            }

            SectionHeader {
                visible: playlistsView.count > 0
                text: qsTr("Playlists")
            }

            Repeater {
                id: playlistsView
                width: parent.width
                model: search.playlistsPreview()
                delegate: playlistDelegate
            }

            SeeMoreItem {
                visible: playlistsView.count > 0
                moreText: qsTr("playlists")
                onClicked: {
                    search.searchPlaylists()
                    pageStack.push(Qt.resolvedUrl("SearchListPage.qml"),
                                   {"pageTitle": qsTr("Playlists for \"") + search.query + ("\""),
                                       "listModel": search.playlists(),
                                       "listDelegate": playlistDelegate})
                }
            }
        }

        Component {
            id: trackDelegate
            TrackDelegate {
                name: trackName
                artistAndAlbum: artists + " | " + album
                duration: trackDuration
                isPlaying: isCurrentPlayingTrack
                starred: isStarred
                available: isAvailable
                // TODO onClicked: model.play()
                //                onPressAndHold: { menu.track = modelData; menu.open(); }
            }
        }

        Component {
            id: artistDelegate
            ArtistDelegate {
                name: model.name
                portrait: model.pictureId
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ArtistPage.qml"),
                                   { "browse": artistsView.modelVar.artistBrowse(index),
                                       "artistName": model.name,
                                       "artistPicId": model.pictureId})
                }
            }
        }

        Component {
            id: albumDelegate
            AlbumDelegate {
                name: model.name
                artist: model.artist
                albumCover: model.coverId
                onClicked: { pageStack.push(Qt.resolvedUrl("AlbumPage.qml"),
                                            { "browse": albumsView.modelVar.albumBrowse(index),
                                                "name": name, "coverId": model.coverId,
                                                "artist": artist, "albumYear": model.year}) }
                onPressAndHold: {
                    //                        menuAlbumBrowse.album = modelData;
                    //                        if (menuAlbumBrowse.totalDuration > 0)
                    //                            albumMenu.open()
                }
            }
        }

        Component {
            id: playlistDelegate
            PlaylistDelegate {
                // TODO probably a diffrent delegate would be nice as the model
                // item is different.

                title: model.name
                iconSource: "image://theme/icon-m-sounds"

                onClicked: {
                    console.log("qml: Loading playlist")
                    // TODO either adapt tracklist page or make a new page pageStack.push(Qt.resolvedUrl("TracklistPage.qml"), { playlist: modelData.playlist });
                }
            }
        }
    }
}
