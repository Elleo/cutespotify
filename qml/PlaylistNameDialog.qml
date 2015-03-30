import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: playlistNameDialog

    property alias acceptText: header.acceptText
    property variant playlist

    Column {
        width: parent.width

        DialogHeader {
            id: header
        }
        TextField {
            id: textEntry
            width: parent.width
            text: playlist.name
            focus: true
            placeholderText: qsTr("Enter playlist name")
            EnterKey.onClicked: playlistNameDialog.accept()
        }
    }
    onAccepted: {
        playlist.rename(textEntry.text.trim())
    }
}
