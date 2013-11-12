/****************************************************************************
**
** Copyright (c) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Yoann Lopes (yoann.lopes@nokia.com)
**
** This file is part of the MeeSpot project.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions
** are met:
**
** Redistributions of source code must retain the above copyright notice,
** this list of conditions and the following disclaimer.
**
** Redistributions in binary form must reproduce the above copyright
** notice, this list of conditions and the following disclaimer in the
** documentation and/or other materials provided with the distribution.
**
** Neither the name of Nokia Corporation and its Subsidiary(-ies) nor the names of its
** contributors may be used to endorse or promote products derived from
** this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
** FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
** TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
** PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
** LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
** NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
****************************************************************************/

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Layouts 0.1
import "UIConstants.js" as UI

Rectangle {
    id: listItem

    color: index % 2 == 0 ? Qt.rgba(1,1,1,0.5) : "transparent"

    signal clicked
    signal pressAndHold
    property alias pressed: mouseArea.pressed
    property alias name: mainText.text
    property string artist
    property string album
    property alias duration: timing.text
    property string coverId: ""
    property bool highlighted: false
    property bool starred: false
    property bool available: true
    property bool pressAndHoldEnabled: true
    property bool showIndex: false

    property color highlightColor: UI.SPOTIFY_COLOR

    property int titleSize: UI.LIST_TILE_SIZE
    property string titleFont: UI.FONT_FAMILY_BOLD
    property color titleColor: UI.LIST_TITLE_COLOR

    property int subtitleSize: UI.LIST_SUBTILE_SIZE
    property string subtitleFont: UI.FONT_FAMILY_LIGHT
    property color subtitleColor: UI.LIST_SUBTITLE_COLOR

    height: appWindow.showSidebar ? units.gu(4) : units.gu(8)
    width: parent.width

    SequentialAnimation {
        id: backAnimation
        property bool animEnded: false
        running: mouseArea.pressed && listItem.pressAndHoldEnabled

        ScriptAction { script: backAnimation.animEnded = false }
        PauseAnimation { duration: 200 }
        ParallelAnimation {
            NumberAnimation { target: background; property: "opacity"; to: 0.4; duration: 300 }
            ColorAnimation { target: mainText; property: "color"; to: "#DDDDDD"; duration: 300 }
            ColorAnimation { target: subText; property: "color"; to: "#DDDDDD"; duration: 300 }
            ColorAnimation { target: timing; property: "color"; to: "#DDDDDD"; duration: 300 }
            NumberAnimation { target: iconItem; property: "opacity"; to: 0.2; duration: 300 }
            NumberAnimation { target: coverContainer; property: "opacity"; to: 0.2; duration: 300 }
        }
        PauseAnimation { duration: 100 }
        ScriptAction { script: { backAnimation.animEnded = true; listItem.pressAndHold(); } }
        onRunningChanged: {
            if (!running) {
                coverContainer.opacity = available ? 1.0 : 0.2
                iconItem.opacity = 1.0
                mainText.color = highlighted ? listItem.highlightColor : listItem.titleColor
                subText.color = highlighted ? listItem.highlightColor : listItem.subtitleColor
                timing.color = highlighted ? listItem.highlightColor : listItem.subtitleColor
            }
        }
    }

    onHighlightedChanged: {
        mainText.color = highlighted ? listItem.highlightColor : listItem.titleColor
        subText.color = highlighted ? listItem.highlightColor : listItem.subtitleColor
        timing.color = highlighted ? listItem.highlightColor : listItem.subtitleColor
    }

    Loader {
        id: indexText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: listItem.showIndex ? 48 : 0
        sourceComponent: listItem.showIndex ? indexTextComponent : null
    }

    Component {
        id: indexTextComponent
        Label {
            text: (index + 1) + ".   "
            font.family: UI.FONT_FAMILY_LIGHT
            font.pixelSize: UI.FONT_SMALL
            horizontalAlignment: Text.AlignRight
            visible: listItem.showIndex
        }
    }

    Loader {
        id: coverContainer
        width: listItem.coverId.length > 0 ? 64 : 0; height: width
        anchors.left: indexText.right
        anchors.verticalCenter: parent.verticalCenter
        sourceComponent: listItem.coverId.length > 0 ? coverContainerComponent : null
    }

    Component {
        id: coverContainerComponent
        Rectangle {
            color: "#C9C9C9"
            opacity: listItem.available ? 1.0 : 0.2

            SpotifyImage {
                id: coverImage
                anchors.fill: parent
                spotifyId: listItem.coverId
            }
        }
    }

    Layouts {
        anchors {
            left: coverContainer.right
            leftMargin: listItem.coverId.length > 0 ? UI.MARGIN_XLARGE : 0
            right: parent.right
            bottom: parent.bottom
            top: parent.top
        }

        layouts: [
            ConditionalLayout {
                name: "phone"
                when: !appWindow.showSidebar

                Item {
                    anchors.fill: parent
                    anchors.margins: units.gu(0.5)

                    opacity: listItem.available ? 1.0 : 0.3

                    ItemLayout {
                        id: textLayout1

                        item: "text"

                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                        }

                        height: mainText.height
                    }

                    Label {
                        anchors {
                            left: parent.left
                            right: timingLayout1.left
                            top: textLayout1.bottom
                            bottom: parent.bottom
                        }

                        id: subText
                        text: artist + " | " + album

                        font.family: listItem.subtitleFont
                        font.pixelSize: listItem.subtitleSize
                        font.weight: Font.Light
                        color: highlighted ? listItem.highlightColor : listItem.subtitleColor
                        elide: Text.ElideRight
                        clip: true
                        visible: text != ""
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    ItemLayout {
                        id: timingLayout1
                        item: "timing"

                        anchors {
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }

                        width: units.gu(5)
                    }
                }
            },
            ConditionalLayout {
                name: "desktop"
                when: appWindow.showSidebar

                Item {
                    anchors.fill: parent
                    anchors.margins: units.gu(0.5)

                    ItemLayout {
                        id: textlayout2
                        item: "text"

                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }

                        width: Math.max(units.gu(40), parent.width * 0.4)

                    }

                    Label {
                        id: artistLabel

                        anchors {
                            left:  textlayout2.right
                            top:    parent.top
                            bottom: parent.bottom
                        }

                        width: units.gu(40)
                        text: artist

                        font.family: listItem.subtitleFont
                        font.pixelSize: listItem.subtitleSize
                        font.weight: Font.Light
                        color: highlighted ? listItem.highlightColor : listItem.subtitleColor
                        elide: Text.ElideRight
                        clip: true
                        visible: text != ""
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    Label {
                        id: albumText

                        anchors {
                            left: artistLabel.right
                            top: parent.top
                            bottom: parent.bottom
                        }

                        visible: parent.width > (textlayout2.width + artistLabel.width + albumText.width + timingLayout2.width)

                        width: units.gu(40)
                        text: album

                        font.family: listItem.subtitleFont
                        font.pixelSize: listItem.subtitleSize
                        font.weight: Font.Light

                        color: highlighted ? listItem.highlightColor : listItem.subtitleColor
                        elide: Text.ElideRight

                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    ItemLayout {
                        id: timingLayout2
                        item: "timing"

                        anchors {
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }

                        width: units.gu(5)
                    }
                }
            }
        ]

        Item {
            Layouts.item: "text"

            Label {
                id: mainText
                height: 34
                anchors.left: parent.left
                anchors.right: iconItem.left
                anchors.rightMargin: UI.MARGIN_XLARGE
                font.family: listItem.titleFont
                font.weight: Font.Bold
                font.pixelSize: listItem.titleSize
                color: highlighted ? listItem.highlightColor : listItem.titleColor
                elide: Text.ElideRight
                clip: true
                Behavior on color { ColorAnimation { duration: 200 } }
            }
            Image {
                id: iconItem
                anchors.right: parent.right
                anchors.bottom: mainText.bottom
                anchors.bottomMargin: 2
                width: 34; height: width
                smooth: true
                visible: listItem.starred
                source: "qrc:/qml/images/star.png"
            }
        }

        Label {
            Layouts.item: "timing"

            id: timing
            font.family: listItem.subtitleFont
            font.weight: Font.Light
            font.pixelSize: listItem.subtitleSize
            color: highlighted ? listItem.highlightColor : listItem.subtitleColor
            visible: text != ""

            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent
        onClicked: {
            if (!backAnimation.animEnded)
                listItem.clicked();
        }
    }
}
