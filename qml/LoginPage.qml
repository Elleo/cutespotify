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
import QtSpotify 1.0
import "UIConstants.js" as UI

Page {

    title: "CuteSpotify"

    NotificationBanner {
        id: errorBanner
    }

    Connections {
        target: spotifySession
        onConnectionErrorChanged: {
            if (spotifySession.connectionError != SpotifySession.Ok) {
                errorBanner.text = spotifySession.connectionErrorMessage;
                errorBanner.show();
            }
        }
    }

    Image {
        id: logo
        source: "qrc:/qml/images/cutespotify-logo.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    Column {
        id: fields
        visible: !spotifySession.pendingConnectionRequest && spotifySession.connectionStatus == SpotifySession.LoggedOut
        spacing: units.gu(UI.DEFAULT_MARGIN)
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: units.gu(UI.PADDING_XXLARGE)
        anchors.rightMargin: units.gu(UI.PADDING_XXLARGE)
        anchors.top: logo.bottom
        anchors.topMargin: units.gu(UI.PADDING_XXLARGE)

        TextField {
            id: username
            placeholderText: "Username"
            width: parent.width
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            Keys.onReturnPressed: {
                if (username.text.length > 0 && password.text.length > 0 && termsCheck.checked)
                    login();
                else
                    password.forceActiveFocus();
            }
        }
        TextField {
            id: password
            placeholderText: "Password"
            echoMode: TextInput.Password
            width: parent.width
            /*platformStyle: TextFieldStyle {
                backgroundSelected: "image://theme/" + appWindow.themeColor + "-meegotouch-textedit-background-selected"
            }
            platformSipAttributes: SipAttributes {
                actionKeyLabel: (username.text.length > 0 && password.text.length > 0 && termsCheck.checked) ? "Log in" : "Next"
                actionKeyEnabled: true
            }*/
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            Keys.onReturnPressed: {
                if (username.text.length > 0 && password.text.length > 0 && termsCheck.checked)
                    login();
                else
                    username.forceActiveFocus();
            }
        }

        Item {
            height: termsText.height + units.gu(5)
            width: parent.width

            CheckBox {
                id: termsCheck
                anchors.verticalCenter: parent.verticalCenter
            /*    platformStyle: CheckBoxStyle {
                    backgroundSelected: "image://theme/" + appWindow.themeColor + "-meegotouch-button-checkbox-" + (theme.inverted ? "inverted-" : "") + "background-selected"
                    backgroundPressed: "image://theme/" + appWindow.themeColor + "-meegotouch-button-checkbox-" + (theme.inverted ? "inverted-" : "") + "background-pressed"
                    backgroundDisabled: "image://theme/" + appWindow.themeColor + "-meegotouch-button-checkbox-" + (theme.inverted ? "inverted-" : "") + "background-disabled"
                }*/
            }
            Label {
                id: termsText
                anchors.left: termsCheck.right
                anchors.leftMargin: units.gu(2)
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                text: "I have read and accepted the Spotify® <a href='http://www.spotify.com/legal/end-user-agreement/'>Terms and Conditions of Use</a> and <a href='http://www.spotify.com/legal/mobile-terms-and-conditions/'>Mobile Terms of Use</a>."
                wrapMode: Text.WordWrap
                font.pixelSize: units.gu(UI.FONT_LSMALL)
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }

        Item {
            height: units.gu(UI.DEFAULT_MARGIN)
            width: 1
        }
        Button {
            id: button
            text: "Log in"

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: units.gu(UI.PADDING_XXLARGE)
            anchors.rightMargin: units.gu(UI.PADDING_XXLARGE)
            enabled: username.text.length > 0 && password.text.length > 0 && termsCheck.checked

            onClicked: {
                login();
            }
        }

        Item {
            height: units.gu(UI.DEFAULT_MARGIN) * 3
            width: 1
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: units.gu(UI.FONT_LSMALL)
            onLinkActivated: Qt.openUrlExternally(link)
            horizontalAlignment: Text.AlignHCenter
            text: "Need a Spotify® Premium account?<br>Get one at <a href='http://www.spotify.com'>www.spotify.com</a>."
        }
    }

    function login() {
        spotifySession.login(username.text, password.text);
        password.text = ""
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: units.gu(UI.DEFAULT_MARGIN) * 2
        visible: !fields.visible
        spacing: units.gu(UI.DEFAULT_MARGIN) * 2

        Label {
            id: loggingText
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Logging in"

            Connections {
                target:  spotifySession
                onLoggingIn: loggingText.text = "Logging in"
                onLoggingOut: loggingText.text = "Logging out"
            }
        }

        ActivityIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: parent.visible
        }
    }
}
