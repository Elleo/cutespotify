import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    id: logoutDialog

    onAccepted: {
        spotifySession.logout(false);
    }

    DialogHeader {
        acceptText: qsTr("Log out ") + (spotifySession.user ? spotifySession.user.canonicalName : "")
    }


    Label {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeExtraLarge
        text: qsTr("Log out ") + (spotifySession.user ? spotifySession.user.canonicalName : "") + "?"
    }
}
