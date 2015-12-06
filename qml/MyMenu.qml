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

import QtQuick 2.4
import Ubuntu.Components 1.3

MyPopup {
    id: root

    // Common API
    default property alias content: contentField.children

    // Common API inherited from Popup:
    /*
        function open()
        function close()

        property QDeclarativeItem* visualParent
        property int status
    */

    property int layoutContentHeight

    // platformStyle API
//    property Style platformStyle: MenuStyle{}
//    property alias style: root.platformStyle // Deprecated
    property alias platformTitle: titleBar.children
    property alias title: titleBar.children // Deprecated
    property alias __footer: footerBar.children

    // private api
    property int __statusBarDelta: visualParent ? 0 :
                 __findItem( "appWindowContent") != null ? 0 :
                 __findItem( "pageStackWindow") != null && __findItem( "pageStackWindow").showStatusBar ? 36 : 0

    property string __animationChief: "abstractMenu"
//    property int __pressDelay: platformStyle.pressDelay

    // This item will find the object with the given objectName ... or will return
    function __findItem( objectName ) {
        var next = parent;

        if (next != null) {
            while (next) {
                if(next.objectName == objectName){
                    return next;
                }

                next = next.parent;
            }
        }

        return null;
    }

/*    __dim: platformStyle.dim
    __fadeInDuration: platformStyle.fadeInDuration
    __fadeOutDuration: platformStyle.fadeOutDuration
    __fadeInDelay: platformStyle.fadeInDelay
    __fadeOutDelay: platformStyle.fadeOutDelay
    __faderBackground: platformStyle.faderBackground
    __fadeInEasingType: platformStyle.fadeInEasingType
    __fadeOutEasingType: platformStyle.fadeOutEasingType
*/
    anchors.fill: parent

    // This is needed for menus which are not instantiated inside the
    // content window of the PageStackWindow:
    Item {
        id: roundedCorners
        visible: root.status != "Closed" && !visualParent
                 && __findItem( "pageStackWindow") != null
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height - __statusBarDelta - 2
        anchors.bottom: parent.bottom
        z: 10001

        // compensate for the widening of the edges of the fader (which avoids artefacts during rotation)
        anchors.topMargin:    +1
        anchors.rightMargin:  +1
        anchors.bottomMargin: +1
        anchors.leftMargin:   +1

        Image {
            anchors.top : parent.top
            anchors.left: parent.left
            source: "image://theme/meegotouch-applicationwindow-corner-top-left"
        }
        Image {
            anchors.top: parent.top
            anchors.right: parent.right
            source: "image://theme/meegotouch-applicationwindow-corner-top-right"
        }
        Image {
            anchors.bottom : parent.bottom
            anchors.left: parent.left
            source: "image://theme/meegotouch-applicationwindow-corner-bottom-left"
        }
        Image {
            anchors.bottom : parent.bottom
            anchors.right: parent.right
            source: "image://theme/meegotouch-applicationwindow-corner-bottom-right"
        }
    }

    // Shadows:
    Image {
        anchors.top : menuItem.top
        anchors.right: menuItem.left
        anchors.bottom : menuItem.bottom
        source: "image://theme/meegotouch-menu-shadow-left"
        visible: root.status != "Closed"
    }
    Image {
        anchors.bottom : menuItem.top
        anchors.left: menuItem.left
        anchors.right : menuItem.right
        source: "image://theme/meegotouch-menu-shadow-top"
        visible: root.status != "Closed"
    }
    Image {
        anchors.top : menuItem.top
        anchors.left: menuItem.right
        anchors.bottom : menuItem.bottom
        source: "image://theme/meegotouch-menu-shadow-right"
        visible: root.status != "Closed"
    }
    Image {
        anchors.top : menuItem.bottom
        anchors.left: menuItem.left
        anchors.right : menuItem.right
        source: "image://theme/meegotouch-menu-shadow-bottom"
        visible: root.status != "Closed"
    }

    Item {
        id: menuItem
        //ToDo: add support for layoutDirection Qt::RightToLeft
        width:  parent.width // ToDo: better width heuristic
        height: titleBar.height + flickableContent.height + footerBar.height
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        state: statesWrapper.state

        BorderImage {
           id: backgroundImage
           source: "image://theme/meegotouch-menu-background"
           anchors.fill : parent
           border { left: 22; top: 22;
                    right: 22; bottom: 22 }
        }

        // this item contains the whole menu (content rectangle)
        Item {
            id: backgroundRect
            anchors.fill: parent

                Item {
                    id: titleBar
                    anchors.left: parent.left
                    anchors.right: parent.right

                    height: childrenRect.height
                }

                Item {
                    // Required to have the ScrollDecorator+Flickable handled
                    // by the column as a single item while keeping the
                    // ScrollDecorator working
                    id: flickableContent
                    anchors.left: parent.left
                    anchors.right: parent.right

                    anchors.top: backgroundRect.top
                    anchors.topMargin: titleBar.height
                    property int maxHeight : visualParent
                                             ? visualParent.height - __statusBarDelta
                                               - footerBar.height - titleBar.height
                                             : root.parent
                                                     ? root.parent.height - __statusBarDelta
                                                       - footerBar.height - titleBar.height
                                                     : 350

                    height: root.layoutContentHeight < maxHeight
                            ? root.layoutContentHeight 
                            : maxHeight

                    Flickable {
                        id: flickable
                        anchors.fill: parent
                        contentWidth: parent.width
                        contentHeight: root.layoutContentHeight
                        interactive: contentHeight > flickable.height
                        flickableDirection: Flickable.VerticalFlick
                        clip: true

                        Item {
                            id: contentRect
                            height: root.layoutContentHeight

                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right

                            Item {
                                id: contentField
                                anchors.fill: contentRect

                                function closeMenu() { root.close(); }
                            }
                        }
                    }
                    /*ScrollDecorator {
                        id: scrollDecorator
                        flickableItem: flickable
                    }*/
                }

                Item {
                    id: footerBar
                    anchors.left: parent.left
                    anchors.right: parent.right

                    anchors.top: backgroundRect.top
                    anchors.topMargin: titleBar.height + flickableContent.height
                    height: childrenRect.height
                }

        }
    }

    onPrivateClicked: close() // "reject()"

    StateGroup {
        id: statesWrapper

        state: "hidden"

        states: [
            State {
                name: "visible"
                when: root.__animationChief == "abstractMenu" && (root.status == "Opening" || root.status == "Open")
                PropertyChanges {
                    target: menuItem
                    opacity: 1.0
                }
            },
            State {
                name: "hidden"
                when: root.__animationChief == "abstractMenu" && (root.status == "Closing" || root.status == "Closed")
                PropertyChanges {
                    target: menuItem
                    opacity: 0.0
                }
            }
        ]

        transitions: [
            Transition {
                from: "visible"; to: "hidden"
                SequentialAnimation {
                    ScriptAction {script: {
                            __fader().state = "hidden";
                            root.status = "Closing";
                        }
                    }

                    NumberAnimation {target: menuItem; property: "opacity";
                                     from: 0.0; to: 1.0; duration: 0}

                    NumberAnimation {target: menuItem; property: "anchors.bottomMargin";
                                     easing.type: Easing.InOutQuint;
                                     from: 0; to: -menuItem.height; duration: 350}

                    NumberAnimation {target: menuItem; property: "opacity";
                                     from: 1.0; to: 0.0; duration: 0}

                    ScriptAction {script: {
                            status = "Closed";
                        }
                    }
                }
            },
            Transition {
                from: "hidden"; to: "visible"
                SequentialAnimation {
                    ScriptAction {script: {
                            __fader().state = "visible";
                            root.status = "Opening";
                        }
                    }

                    NumberAnimation {target: menuItem; property: "anchors.bottomMargin";
                                     easing.type: Easing.InOutQuint;
                                     from: -menuItem.height; to: 0; duration: 350}

                    ScriptAction {script: {
                            status = "Open";
                        }
                    }
                }
            }
        ]
    }
}
