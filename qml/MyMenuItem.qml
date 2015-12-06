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


// MenuItem is a component that is used in menus.

import QtQuick 2.4
import Ubuntu.Components 1.3
import "UIConstants.js" as UI

Item {
    id: root

    // Common API
    property string text
    signal clicked
    property alias pressed: mouseArea.pressed

    width: parent ? parent.width: 0
/*
    Rectangle {
       id: backgroundRec
       // ToDo: remove hardcoded values
       color: pressed ? "darkgray" : "transparent"
       anchors.fill : root
       opacity : 0.5
    }
*/
            BorderImage {
               id: backgroundImage
               anchors.fill : root
               border { left: 22; top: 22;
                        right: 22; bottom: 22 }
            }

    Text {
        id: menuText
        text: parent.text
        elide: Text.ElideRight

        anchors.top : root.top
        anchors.bottom : root.bottom
        anchors.left : root.left
        anchors.right : root.right
  }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: { if (parent.enabled) parent.clicked();}
    }

    onClicked: if (parent) parent.closeLayout();
    onVisibleChanged: if (root.parent) root.parent.relayout();
}
