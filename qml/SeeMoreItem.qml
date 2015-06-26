import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: moreItem

    property string moreText;

    width: parent.width
    height: Theme.itemSizeSmall
    Label {
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr("See more %1...".arg(moreText))
        color: moreItem.highlighted ? Theme.highlightColor : Theme.primaryColor
    }
}
