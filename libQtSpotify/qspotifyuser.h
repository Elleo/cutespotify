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


#ifndef QSPOTIFYUSER_H
#define QSPOTIFYUSER_H

#include "qspotifyobject.h"

struct sp_user;
class QSpotifyPlaylistContainer;
class QSpotifyPlaylist;
class QSpotifyTrack;
class QSpotifyAlbumBrowse;

class QSpotifyUser : public QSpotifyObject
{
    Q_OBJECT
    Q_PROPERTY(QString canonicalName READ canonicalName NOTIFY userDataChanged)
    Q_PROPERTY(QString displayName READ displayName NOTIFY userDataChanged)
    Q_PROPERTY(QString fullName READ fullName NOTIFY userDataChanged)
    Q_PROPERTY(QString picture READ picture NOTIFY userDataChanged)
    Q_PROPERTY(QList<QObject *> playlists READ playlistsAsQObject NOTIFY playlistsChanged)
public:
    ~QSpotifyUser();

    bool isLoaded();

    QString canonicalName() const { return m_canonicalName; }
    QString displayName() const { return m_displayName; }
    QString fullName() const { return m_fullName; }
    QString picture() const { return m_picture; }

    QSpotifyPlaylistContainer *playlistContainer() const;
    QSpotifyPlaylist *starredList() const;
    QSpotifyPlaylist *inbox() const;

    QList<QSpotifyPlaylist *> playlists() const;
    QList<QObject *> playlistsAsQObject() const;

    Q_INVOKABLE bool createPlaylist(const QString &name);
    Q_INVOKABLE bool createPlaylistFromTrack(QSpotifyTrack *track);
    Q_INVOKABLE bool createPlaylistFromAlbum(QSpotifyAlbumBrowse *album);
    Q_INVOKABLE void removePlaylist(QSpotifyPlaylist *playlist);
    Q_INVOKABLE bool ownsPlaylist(QSpotifyPlaylist *playlist);
    Q_INVOKABLE bool canModifyPlaylist(QSpotifyPlaylist *playlist);

Q_SIGNALS:
    void userDataChanged();
    void playlistsChanged();

protected:
    bool updateData();

private:
    QSpotifyUser(sp_user *user);

    sp_user *m_sp_user;

    QString m_canonicalName;
    QString m_displayName;
    QString m_fullName;
    QString m_picture;

    mutable QSpotifyPlaylistContainer *m_playlistContainer;
    mutable QSpotifyPlaylist *m_starredList;
    mutable QSpotifyPlaylist *m_inbox;

    friend class QSpotifySession;
    friend class QSpotifyPlaylist;
};

#endif // QSPOTIFYUSER_H
