import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSpotify 1.0

Page {
    id: searchlistPage
    property var listModel
    property var listDelegate
    property var pageTitle

    SilicaListView {
        anchors.fill: parent
        width: parent.width
        model: listModel
        delegate: listDelegate
        header: PageHeader { title: pageTitle}
        VerticalScrollDecorator { }
    }
}
