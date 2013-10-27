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

#include "lastfmscrobbler.h"

#include <QtCore/QSettings>

#include <lastfm_key.h>
#include <ws.h>
#include <misc.h>
#include <XmlQuery.h>
#include <Track.h>
#include <qspotifysession.h>
#include <qspotifytrack.h>

LastFmScrobbler::LastFmScrobbler()
    : QObject()
    , m_audioScrobbler(0)
    , m_currentTrack(0)
    , m_currentTrackCached(false)
{
    lastfm::ws::ApiKey = g_lastfmAPIKey;
    lastfm::ws::SharedSecret = g_lastfmSecret;

    connect(QSpotifySession::instance(), SIGNAL(currentTrackChanged()), SLOT(onCurrentTrackChanged()));
    connect(QSpotifySession::instance(), SIGNAL(currentTrackPositionChanged()), SLOT(onCurrentTrackPositionChanged()));
    connect(QSpotifySession::instance(), SIGNAL(offlineModeChanged()), SLOT(onOfflineModeChanged()));

    restoreUser();
}

LastFmScrobbler::~LastFmScrobbler()
{
    delete m_audioScrobbler;
    delete m_currentTrack;
}

void LastFmScrobbler::authenticate(const QString &username, const QString &password)
{
    forgetUser();

    QMap<QString, QString> params;
    params["method"] = "auth.getMobileSession";
    params["username"] = username;
    params["authToken"] = lastfm::md5((username.toUtf8() + lastfm::md5(password.toUtf8())).toUtf8());
    QNetworkReply* reply = lastfm::ws::post(params);
    connect(reply, SIGNAL(finished()), this, SLOT(onAuthentificateResponse()));
}

void LastFmScrobbler::onAuthentificateResponse()
{
    if (!sender())
        return;

    QNetworkReply *reply = dynamic_cast<QNetworkReply *>(sender());
    if (!reply)
        return;

    try {
        lastfm::XmlQuery const lfm = lastfm::ws::parse(reply);
        lastfm::ws::Username = lfm["session"]["name"].text();
        lastfm::ws::SessionKey = lfm["session"]["key"].text();

        delete m_audioScrobbler;
        m_audioScrobbler = new lastfm::Audioscrobbler;

        m_user = lastfm::ws::Username;
        m_sessionKey = lastfm::ws::SessionKey;
        m_enabled = true;
        saveUser();
        emit userChanged();
        emit enabledChanged();

    } catch(lastfm::ws::ParseError e) {
        forgetUser();

        switch (e.enumValue()) {
        case lastfm::ws::AuthenticationFailed:
            m_errorMessage = "Invalid username/password.";
            break;
        case lastfm::ws::InvalidApiKey:
            m_errorMessage = "Invalid API key.";
            break;
        case lastfm::ws::ServiceOffline:
            m_errorMessage = "This service is temporarily offline. Try again later.";
            break;
        case lastfm::ws::TryAgainLater:
            m_errorMessage = "There was a temporary error processing your request. Please try again.";
            break;
        case lastfm::ws::APIKeySuspended:
            m_errorMessage = "Suspended API key. Please contact the developer.";
            break;
        default:
            m_errorMessage = "Connection error.";
            break;
        }

        emit errorChanged();
    }
}

void LastFmScrobbler::forgetUser()
{
    m_user = QString();
    m_sessionKey = QString();
    lastfm::ws::Username = m_user;
    lastfm::ws::SessionKey = m_sessionKey;
    m_enabled = false;
    emit enabledChanged();
    emit userChanged();
    saveUser();
}

void LastFmScrobbler::setEnabled(bool e)
{
    if (m_enabled == e)
        return;

    m_enabled = e;
    emit enabledChanged();

    saveUser();

    if (!m_sessionKey.isEmpty() && m_enabled && !QSpotifySession::instance()->offlineMode()) {
        m_audioScrobbler->submit();
    } else {
        delete m_currentTrack;
        m_currentTrack = 0;
        m_currentTrackCached = false;
    }
}

void LastFmScrobbler::onCurrentTrackPositionChanged()
{
    if (!m_enabled || !m_currentTrack || m_currentTrackCached || lastfm::ws::SessionKey.isEmpty())
        return;

    uint played = QSpotifySession::instance()->currentTrackPlayedDuration() / 1000;
    if (played >= m_currentTrack->duration() / 2 || played >= 240) {
        m_audioScrobbler->cache(*m_currentTrack);
        m_currentTrackCached = true;
    }
}

void LastFmScrobbler::onCurrentTrackChanged()
{
    if (lastfm::ws::SessionKey.isEmpty() || !m_enabled)
        return;

    delete m_currentTrack;
    m_currentTrack = 0;
    m_currentTrackCached = false;

    QSpotifyTrack *track = QSpotifySession::instance()->currentTrack();
    if (!track)
        return;

    m_currentTrack = new lastfm::MutableTrack;
    m_currentTrack->setArtist(track->artists());
    m_currentTrack->setTitle(track->name());
    m_currentTrack->setTrackNumber(track->discIndex());
    m_currentTrack->setAlbum(track->album());
    m_currentTrack->setDuration(track->duration() / 1000);
    m_currentTrack->setSource(lastfm::Track::Player);
    m_currentTrack->stamp();

    if (!QSpotifySession::instance()->offlineMode()) {
        m_audioScrobbler->nowPlaying(*m_currentTrack);
        m_audioScrobbler->submit();
    }
}

void LastFmScrobbler::onOfflineModeChanged()
{
    if (!m_sessionKey.isEmpty() && m_enabled && !QSpotifySession::instance()->offlineMode())
        m_audioScrobbler->submit();
}

void LastFmScrobbler::saveUser()
{
    QSettings s;
    s.setValue("lastfmUser", m_user);
    s.setValue("lastfmSk", m_sessionKey);
    s.setValue("lastfmEnabled", m_enabled);
}

void LastFmScrobbler::restoreUser()
{
    QSettings s;
    m_user = s.value("lastfmUser").toString();
    m_sessionKey = s.value("lastfmSk").toString();
    m_enabled = s.value("lastfmEnabled", false).toBool();
    lastfm::ws::Username = m_user;
    lastfm::ws::SessionKey = m_sessionKey;
    emit userChanged();
    emit enabledChanged();

    m_audioScrobbler = new lastfm::Audioscrobbler;

    if (!m_sessionKey.isEmpty() && m_enabled && !QSpotifySession::instance()->offlineMode())
        m_audioScrobbler->submit();
}
