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

#ifndef LASTFMSCROBBLER_H
#define LASTFMSCROBBLER_H

#include <QtCore/QObject>
#include <Audioscrobbler.h>

class LastFmScrobbler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user READ user NOTIFY userChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
public:
    LastFmScrobbler();
    ~LastFmScrobbler();

    Q_INVOKABLE void authenticate(const QString &username, const QString &password);

    QString user() const { return m_user; }
    Q_INVOKABLE void forgetUser();

    bool enabled() const { return m_enabled; }
    void setEnabled(bool e);

    QString error() const { return m_errorMessage; }

Q_SIGNALS:
    void userChanged();
    void enabledChanged();
    void errorChanged();

private Q_SLOTS:
    void onAuthentificateResponse();
    void onCurrentTrackChanged();
    void onCurrentTrackPositionChanged();
    void onOfflineModeChanged();

private:
    void saveUser();
    void restoreUser();

    QString m_user;
    QString m_sessionKey;

    bool m_enabled;

    lastfm::Audioscrobbler *m_audioScrobbler;
    lastfm::MutableTrack *m_currentTrack;
    bool m_currentTrackCached;

    QString m_errorMessage;

};

#endif // LASTFMSCROBBLER_H
