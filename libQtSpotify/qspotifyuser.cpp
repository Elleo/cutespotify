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


#include "qspotifyuser.h"
#include "qspotifyplaylistcontainer.h"
#include "qspotifysession.h"
#include "qspotifyplaylist.h"
#include "qspotifytrack.h"
#include "qspotifyalbumbrowse.h"
#include "qspotifyalbum.h"

#include <libspotify/api.h>

QSpotifyUser::QSpotifyUser(sp_user *user)
    : QSpotifyObject(true)
    , m_playlistContainer(0)
    , m_starredList(0)
    , m_inbox(0)
{
    sp_user_add_ref(user);
    m_sp_user = user;
    m_canonicalName = QString::fromUtf8(sp_user_canonical_name(m_sp_user));

    connect(this, SIGNAL(dataChanged()), this, SIGNAL(userDataChanged()));

    metadataUpdated();
}

QSpotifyUser::~QSpotifyUser()
{
    delete m_playlistContainer;
    sp_user_release(m_sp_user);
}

bool QSpotifyUser::isLoaded()
{
    return sp_user_is_loaded(m_sp_user);
}

bool QSpotifyUser::updateData()
{
    QString canonicalName = QString::fromUtf8(sp_user_canonical_name(m_sp_user));
    QString displayName = QString::fromUtf8(sp_user_display_name(m_sp_user));

    bool updated = false;
    if (m_canonicalName != canonicalName) {
        m_canonicalName = canonicalName;
        updated = true;
    }
    if (m_displayName != displayName) {
        m_displayName = displayName;
        updated = true;
    }

    return updated;
}

QSpotifyPlaylistContainer *QSpotifyUser::playlistContainer() const
{
    if (!m_playlistContainer) {
        sp_playlistcontainer *pc;
        if (QSpotifySession::instance()->user() == this) {
            pc = sp_session_playlistcontainer(QSpotifySession::instance()->m_sp_session);
            sp_playlistcontainer_add_ref(pc);
        } else {
            pc = sp_session_publishedcontainer_for_user_create(QSpotifySession::instance()->m_sp_session, m_canonicalName.toUtf8().constData());
        }
        m_playlistContainer = new QSpotifyPlaylistContainer(pc);
        connect(m_playlistContainer, SIGNAL(playlistContainerDataChanged()), this, SIGNAL(playlistsChanged()));
    }
    return m_playlistContainer;
}

QSpotifyPlaylist *QSpotifyUser::starredList() const
{
    if (!m_starredList) {
        sp_playlist *sl;
        if (QSpotifySession::instance()->user() == this) {
            sl = sp_session_starred_create(QSpotifySession::instance()->m_sp_session);
        } else {
            sl = sp_session_starred_for_user_create(QSpotifySession::instance()->m_sp_session, m_canonicalName.toUtf8().constData());
        }
        m_starredList = new QSpotifyPlaylist(QSpotifyPlaylist::Starred, sl, false);
        connect(m_starredList, SIGNAL(playlistDataChanged()), this, SIGNAL(playlistsChanged()));
    }
    return m_starredList;
}

QSpotifyPlaylist *QSpotifyUser::inbox() const
{
    if (QSpotifySession::instance()->user() != this)
        return 0;

    if (!m_inbox) {
        sp_playlist *in;
        in = sp_session_inbox_create(QSpotifySession::instance()->m_sp_session);
        m_inbox = new QSpotifyPlaylist(QSpotifyPlaylist::Inbox, in, false);
        connect(m_inbox, SIGNAL(playlistDataChanged()), this, SIGNAL(playlistsChanged()));
    }
    return m_inbox;
}

QList<QObject*> QSpotifyUser::playlistsAsQObject() const
{
    QList<QSpotifyPlaylist*> pls = playlists();
    QList<QObject*> list;
    list.append((QObject*)inbox());
    list.append((QObject*)starredList());
    for (int i = 0; i < pls.count(); ++i) {
        if (pls.at(i)->isLoaded() && sp_playlistcontainer_playlist_type(m_playlistContainer->m_container, i) == SP_PLAYLIST_TYPE_PLAYLIST)
            list.append((QObject*)(pls[i]));
    }
    return list;
}

QList<QSpotifyPlaylist *> QSpotifyUser::playlists() const
{
    return playlistContainer()->playlists();
}


bool QSpotifyUser::createPlaylist(const QString &name)
{
    if (name.trimmed().isEmpty())
        return false;

    QString n = name;
    if (n.size() > 255)
        n.resize(255);
    sp_playlist *pl = sp_playlistcontainer_add_new_playlist(m_playlistContainer->m_container, n.toUtf8().constData());
    return pl != 0;
}

bool QSpotifyUser::createPlaylistFromTrack(QSpotifyTrack *track)
{
    if (!track)
        return false;

    sp_playlist *pl = sp_playlistcontainer_add_new_playlist(m_playlistContainer->m_container, track->name().toUtf8().constData());
    if (pl == 0)
        return false;
    sp_playlist_add_tracks(pl, const_cast<sp_track* const*>(&track->m_sp_track), 1, 0, QSpotifySession::instance()->spsession());
    return true;
}

bool QSpotifyUser::createPlaylistFromAlbum(QSpotifyAlbumBrowse *album)
{
    if (!album || !album->m_albumTracks || album->m_albumTracks->m_tracks.count() < 1)
        return false;

    QString playlistName = album->album()->artist() + QLatin1String(" - ") + album->album()->name();
    sp_playlist *pl = sp_playlistcontainer_add_new_playlist(m_playlistContainer->m_container, playlistName.toUtf8().constData());
    if (pl == 0)
        return false;

    int c = album->m_albumTracks->m_tracks.count();
    const sp_track *tracks[c];
    for (int i = 0; i < c; ++i)
        tracks[i] = album->m_albumTracks->m_tracks.at(i)->sptrack();
    sp_playlist_add_tracks(pl, const_cast<sp_track* const*>(tracks), c, 0, QSpotifySession::instance()->spsession());
    return true;
}

void QSpotifyUser::removePlaylist(QSpotifyPlaylist *playlist)
{
    if (!playlist)
        return;

    int i = m_playlistContainer->m_playlists.indexOf(playlist);
    if (i > -1)
        sp_playlistcontainer_remove_playlist(m_playlistContainer->m_container, i);
}

bool QSpotifyUser::ownsPlaylist(QSpotifyPlaylist *playlist)
{
    if (!playlist)
        return false;
    return playlist->owner() == m_canonicalName;
}

bool QSpotifyUser::canModifyPlaylist(QSpotifyPlaylist *playlist)
{
    if (!playlist)
        return false;
    return ownsPlaylist(playlist) || playlist->collaborative();
}
