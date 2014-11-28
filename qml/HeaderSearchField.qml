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


import QtQuick 1.1
import "UIConstants.js" as UI
import com.nokia.meego 1.0

Item {
    id: root

    property alias showDuration: hideTimer.interval
    property alias text: searchField.text
    signal returnPressed

    width: parent.width
    state: "hidden"

    function show() {
        root.state = "visible"
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 4500
        repeat: false
        onTriggered: root.state = "hidden"
    }

    AdvancedTextField {
        id: searchField
        placeholderText: "Search"
        width: parent.width
        y: units.gu(UI.MARGIN_XLARGE)
        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
        platformSipAttributes: SipAttributes {
            actionKeyLabel: "Close"
            actionKeyEnabled: true
        }
        Keys.onReturnPressed: { root.returnPressed() }

        onActiveFocusChanged: {
            if (activeFocus)
                hideTimer.stop();
            else {
                if (text.length === 0)
                    hideTimer.restart();
            }
        }
    }

    Separator {
        id: separator
        width: parent.width
        anchors.bottom: parent.bottom
    }

    states: [
        State {
            name: "hidden"
            PropertyChanges {
                target: searchField
                opacity: 0.0
            }
            PropertyChanges {
                target: separator
                opacity: 0.0
            }
            PropertyChanges {
                target: root
                height: 0
            }
        },
        State {
            name: "visible"
            PropertyChanges {
                target: searchField
                opacity: 1.0
            }
            PropertyChanges {
                target: separator
                opacity: 1.0
            }
            PropertyChanges {
                target: root
                height: searchField.height + units.gu(UI.MARGIN_XLARGE) * 2 + separator.height
            }
        }

    ]

    transitions: [
        Transition {
            to: "hidden"
            SequentialAnimation {
                NumberAnimation { target: searchField; properties: "opacity"; duration: 300 }
                NumberAnimation { target: root; properties: "height"; duration: 300 }
                PropertyAction { target: separator; properties: "opacity" }
            }
        },
        Transition {
            to: "visible"
            SequentialAnimation {
                PropertyAction { target: separator; properties: "opacity"  }
                PropertyAction { target: root; properties: "height"  }
                NumberAnimation { target:searchField; properties: "opacity"; duration: 300 }
            }
        }
    ]
}
