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

import QtQuick 2.4
import Ubuntu.Components 1.3
import "UIConstants.js" as UI

MySheet {
    id: lastfmSheet

    property alias title: label.text

    acceptButtonText: "Log in"
    rejectButtonText: "Cancel"

    content: Column {
        anchors.fill: parent
        spacing: 20

        Item {
            width: 1; height: 1
        }

        Label {
            id: label
            anchors.left: parent.left
            anchors.right:  parent.right
            anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)
            anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
            font.pixelSize: units.gu(UI.FONT_LARGE)
        }

        TextField {
            id: username
            placeholderText: "Username"
            anchors.left: parent.left
            anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)
            anchors.right: parent.right
            anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            Keys.onReturnPressed: {
                if (username.text.length > 0 && password.text.length > 0)
                    accept();
                else
                    password.forceActiveFocus();
            }
            onTextChanged: {
                if (username.text.length > 0 && password.text.length > 0)
                    acceptButton.enabled = true;
                else
                    acceptButton.enabled = false;
            }
        }

        TextField {
            id: password
            placeholderText: "Password"
            echoMode: TextInput.Password
            anchors.left: parent.left
            anchors.leftMargin: units.gu(UI.MARGIN_XLARGE)
            anchors.right: parent.right
            anchors.rightMargin: units.gu(UI.MARGIN_XLARGE)
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            Keys.onReturnPressed: {
                if (username.text.length > 0 && password.text.length > 0)
                    accept();
                else
                    username.forceActiveFocus();
            }
            onTextChanged: {
                if (username.text.length > 0 && password.text.length > 0)
                    acceptButton.enabled = true;
                else
                    acceptButton.enabled = false;
            }
        }
    }

    onAccepted: {
        authenticate();
    }

    function authenticate()
    {
        if (username.text.length > 0 && password.text.length > 0)
            lastfm.authenticate(username.text, password.text);
    }

    Timer {
        id: timer
        interval: 50
        onTriggered: username.forceActiveFocus();
    }

    onStatusChanged: {
        if (status == "Opening") {
            username.text = "";
            password.text = "";
        } else if (status == "Open") {
            timer.start();
        }
    }
}
