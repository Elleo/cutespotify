import QtQuick 2.0
import Sailfish.Silica 1.0


Dialog {
    id: logoutDialog
    allowedOrientations: Orientation.All


    property string userName

    DialogHeader {
        acceptText: qsTr("Log out ") + userName
    }


    Label {
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Theme.fontSizeExtraLarge
        text: qsTr("Log out ") + userName + "?"
    }
}
