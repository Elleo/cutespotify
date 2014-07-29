import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {

    SpotifyImage {
        id: coverImage
        anchors.top: parent.top
        width: parent.width
        height: width
        visible: spotifySession.currentTrack ? true : false
        spotifyId: spotifySession.currentTrack ? spotifySession.currentTrack.albumCoverId : ""
    }

    Image {
        anchors.centerIn: parent
        source: "qrc:/qml/images/cutespotify.png"
        visible: spotifySession.currentTrack ? false : true
        opacity: 0.5
    }

    Label {
        id: trackLabel
        anchors {
            top: coverImage.bottom
            left: parent.left
            leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
        }
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeSmall
        text: spotifySession.currentTrack ? spotifySession.currentTrack.name : ""
    }

    Label {
        id: artistsLabel
        anchors {
            top: trackLabel.bottom
            left: parent.left
            leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.paddingMedium
        }
        truncationMode: TruncationMode.Fade
        font.pixelSize: Theme.fontSizeTiny
        text: spotifySession.currentTrack ? spotifySession.currentTrack.artists : ""
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: spotifySession.currentTrack ? (spotifySession.isPlaying ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play") : ""
            onTriggered: {
                spotifySession.isPlaying ? spotifySession.pause() : spotifySession.resume()
            }
        }

        CoverAction {
            iconSource: spotifySession.currentTrack ? "image://theme/icon-cover-next-song" : ""
            onTriggered: {
                spotifySession.playNext()
            }
        }

    }
}
