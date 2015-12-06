/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4;
import Ubuntu.Components 1.3;
import "UIConstants.js" as UI

MyCommonDialog {
    id: root

    // Common API
    property ListModel model: ListModel{}
    property int selectedIndex: -1   // read & write
    //property string titleText: "Selection Dialog"

    property Component delegate:          // Note that this is the default delegate for the list
        Component {
            id: defaultDelegate

            Item {
                id: delegateItem
                property bool selected: index == selectedIndex;

                anchors.left: parent.left
                anchors.right: parent.right

                MouseArea {
                    id: delegateMouseArea
                    anchors.fill: parent;
                    onPressed: selectedIndex = index;
                    onClicked:  accept();
                }


                Rectangle {
                    id: backgroundRect
                    anchors.fill: parent
                }

                BorderImage {
                    id: background
                    anchors.fill: parent
                    border { left: units.gu(UI.CORNER_MARGINS); top: units.gu(UI.CORNER_MARGINS); right: units.gu(UI.CORNER_MARGINS); bottom: units.gu(UI.CORNER_MARGINS) }
                }

                Text {
                    id: itemText
                    elide: Text.ElideRight
                    anchors.verticalCenter: delegateItem.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    text: name;
                }
            }
        }

    // the title field consists of the following parts: title string and
    // a close button (which is in fact an image)
    // it can additionally have an icon
    titleText:"Selection Dialog"

    // the content field which contains the selection content
    Item {

        id: selectionContent
        property int listViewHeight : root.model.count * 32
        property int maxListViewHeight : root.parent
                ? root.parent.height * 0.87 - 50
                : 350
        height: listViewHeight > maxListViewHeight ? maxListViewHeight : listViewHeight
        width: root.width

        ListView {
            id: selectionListView

            currentIndex : -1
            anchors.fill: parent
            model: root.model
            delegate: root.delegate
            focus: true
            clip: true

            Scrollbar {
                id: scrollDecorator
                flickableItem: selectionListView
            }
        }

    }
}


