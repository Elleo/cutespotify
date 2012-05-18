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


#ifndef QSPOTIFYPLAYLISTCONTAINER_H
#define QSPOTIFYPLAYLISTCONTAINER_H

#include "qspotifyobject.h"
#include <QMetaType>

struct sp_playlistcontainer;
struct sp_playlistcontainer_callbacks;
struct sp_playlist;
class QSpotifyPlaylist;

class QSpotifyPlaylistContainer : public QSpotifyObject
{
    Q_OBJECT
public:
    ~QSpotifyPlaylistContainer();

    bool isLoaded();

    QList<QSpotifyPlaylist *> playlists() const { return m_playlists; }
    QList<QObject *> formattedPlaylists() const { return m_formattedAvailablePlaylists + m_formattedUnavailablePlaylists; }
    QList<QObject *> playlistsFlat() const { return m_playlistsFlat; }

    sp_playlistcontainer *spcontainer() { return m_container; }

Q_SIGNALS:
    void playlistContainerDataChanged();
    void playlistsNameChanged();

protected:
    bool updateData();

    bool event(QEvent *);

private Q_SLOTS:
    void updatePlaylists();

private:
    QSpotifyPlaylistContainer(sp_playlistcontainer *container);
    void addPlaylist(sp_playlist *, int pos = -1);

    void postUpdateEvent();

    sp_playlistcontainer *m_container;
    sp_playlistcontainer_callbacks *m_callbacks;

    QList<QSpotifyPlaylist *> m_playlists;
    QList<QObject *> m_formattedAvailablePlaylists;
    QList<QObject *> m_formattedUnavailablePlaylists;
    QList<QObject *> m_playlistsFlat;

    bool m_updateEventPosted;

    friend class QSpotifyUser;
    friend class QSpotifyPlaylist;
};

#endif // QSPOTIFYPLAYLISTCONTAINER_H
