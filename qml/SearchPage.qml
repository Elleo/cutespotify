import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSpotify 1.0

Page {
    enabled: !spotifySession.offlineMode
    allowedOrientations: Orientation.All

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

                Component.onCompleted: {
                        search.query = "";
                        search.search(true)
                }
            }

            SectionHeader {
                visible: tracksView.count > 0
                text: qsTr("Tracks")
            }

            Repeater {
                id: tracksView
                property variant modelVar: search.trackResultsPreview()
                width: parent.width
                model: modelVar
                delegate: TrackDelegate { listModel: tracksView.modelVar}

                Component.onCompleted: modelVar = search.trackResultsPreview()
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

                Component {
                    id: trackDelegate
                    TrackDelegate {
                        listModel: search.trackResults()
                    }
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
                delegate: ArtistDelegate { listModel: artistsView.modelVar }
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

                Component {
                    id: artistDelegate
                    ArtistDelegate { listModel: search.artists()}
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
                delegate: AlbumDelegate { listModel: albumsView.modelVar }
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

                Component {
                    id: albumDelegate
                    AlbumDelegate { listModel: search.albums() }
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
                delegate: PlaylistSearchDelegate { listModel: search.playlistsPreview() }
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

                Component {
                    id: playlistDelegate
                    PlaylistSearchDelegate {
                        listModel: search.playlists()
                    }
                }
            }
        }
    }
}
