import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    id: lastFMDialog

    onAccepted: {
        spotifySession.lfmLogin(lfmUser.text, lfmPass.text)
    }

    DialogHeader {
        acceptText: qsTr("Login to Last.fm")
    }

    Column {
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: Theme.itemSizeLarge
        anchors.leftMargin: Theme.paddingLarge
        anchors.rightMargin: Theme.paddingLarge

        TextField {
            id: lfmUser
            visible: !spotifySession.lfmLoggedIn
            placeholderText: qsTr("Last.fm Username")
            width: parent.width
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            Keys.onReturnPressed: {
                lfmPass.forceActiveFocus();
            }
        }

        TextField {
            id: lfmPass
            visible: !spotifySession.lfmLoggedIn
            placeholderText: "Last.fm Password"
            echoMode: TextInput.Password
            width: parent.width
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            Keys.onReturnPressed: {
                // TODO maybe some input checking?
                lastFMDialog.accept()
            }
        }
    }
}
