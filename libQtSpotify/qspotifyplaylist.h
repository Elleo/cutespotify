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


#ifndef QSPOTIFYPLAYLIST_H
#define QSPOTIFYPLAYLIST_H

#include <QtCore/QSet>
#include <QtCore/QVector>

#include <libspotify/api.h>

#include "qspotifyobject.h"
#include "qspotifytracklist.h"

class QSpotifyAlbumBrowse;
class QSpotifyTrack;
struct sp_playlist;
struct sp_playlist_callbacks;
struct sp_track;

class QSpotifyPlaylist : public QSpotifyObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name NOTIFY playlistDataChanged)
    Q_PROPERTY(int trackCount READ trackCount NOTIFY playlistDataChanged)
    Q_PROPERTY(int totalDuration READ totalDuration NOTIFY playlistDataChanged)
    Q_PROPERTY(QList<QObject *> tracks READ tracksAsQObject NOTIFY tracksChanged)
    Q_PROPERTY(bool isLoaded READ isLoaded NOTIFY thisIsLoadedChanged)
    Q_PROPERTY(Type type READ type NOTIFY playlistDataChanged)
    Q_PROPERTY(OfflineStatus offlineStatus READ offlineStatus NOTIFY playlistDataChanged)
    Q_PROPERTY(QString listSection READ listSection NOTIFY thisIsLoadedChanged)
    Q_PROPERTY(QString owner READ owner NOTIFY playlistDataChanged)
    Q_PROPERTY(bool collaborative READ collaborative WRITE setCollaborative NOTIFY playlistDataChanged)
    Q_PROPERTY(int offlineDownloadProgress READ offlineDownloadProgress NOTIFY playlistDataChanged)
    Q_PROPERTY(bool availableOffline READ availableOffline WRITE setAvailableOffline NOTIFY availableOfflineChanged)
    Q_PROPERTY(int unseenCount READ unseenCount NOTIFY seenCountChanged)
    Q_PROPERTY(bool hasOfflineTracks READ hasOfflineTracks NOTIFY hasOfflineTracksChanged)
    Q_PROPERTY(QString trackFilter READ trackFilter WRITE setTrackFilter NOTIFY trackFilterChanged)
    Q_PROPERTY(QList<QObject *> playlists READ playlists NOTIFY playlistsChanged)
    Q_PROPERTY(int playlistCount READ playlistCount NOTIFY playlistsChanged)
    Q_ENUMS(Type)
    Q_ENUMS(OfflineStatus)
public:
    enum Type {
        Playlist = SP_PLAYLIST_TYPE_PLAYLIST,
        Folder = SP_PLAYLIST_TYPE_START_FOLDER,
        FolderEnd = SP_PLAYLIST_TYPE_END_FOLDER,
        None = SP_PLAYLIST_TYPE_PLACEHOLDER,
        Starred,
        Inbox
    };

    enum OfflineStatus {
        No = SP_PLAYLIST_OFFLINE_STATUS_NO,
        Yes = SP_PLAYLIST_OFFLINE_STATUS_YES,
        Downloading = SP_PLAYLIST_OFFLINE_STATUS_DOWNLOADING,
        Waiting = SP_PLAYLIST_OFFLINE_STATUS_WAITING
    };

    virtual ~QSpotifyPlaylist();

    bool isLoaded();

    QString name() const { return m_name; }
    int trackCount() const;
    int totalDuration() const;
    Type type() const { return m_type; }
    OfflineStatus offlineStatus() const { return m_offlineStatus; }
    QString owner() const { return m_owner; }
    bool collaborative() const { return m_collaborative; }
    void setCollaborative(bool c);
    int offlineDownloadProgress() const { return m_offlineDownloadProgress; }
    bool availableOffline() const { return m_availableOffline; }
    void setAvailableOffline(bool offline);
    QString listSection() const;
    QList<QSpotifyTrack *> tracks() const { return m_trackList->tracks(); }
    QList<QObject *> tracksAsQObject() const;
    int unseenCount() const;
    bool hasOfflineTracks() const { return m_offlineTracks.count() > 0; }
    QString trackFilter() const { return m_trackFilter; }
    void setTrackFilter(const QString &filter);
    QList<QObject *> playlists() const { return m_availablePlaylists + m_unavailablePlaylists; }
    int playlistCount() const { return m_availablePlaylists.count() + m_unavailablePlaylists.count(); }

    void clearPlaylists() {
        m_availablePlaylists.clear();
        m_unavailablePlaylists.clear();
    }

    bool contains(sp_track *t) const { return m_tracksSet.contains(t); }

    Q_INVOKABLE void add(QSpotifyTrack *track);
    Q_INVOKABLE void remove(QSpotifyTrack *track);

    Q_INVOKABLE void addAlbum(QSpotifyAlbumBrowse *);

    Q_INVOKABLE void rename(const QString &name);

    Q_INVOKABLE void removeFromContainer();
    Q_INVOKABLE void deleteFolderContent();

    Q_INVOKABLE bool isCurrentPlaylist() const;

public Q_SLOTS:
    void play();
    void enqueue();

Q_SIGNALS:
    void playlistDestroyed();
    void playlistDataChanged();
    void thisIsLoadedChanged();
    void tracksAdded(QVector<sp_track *>);
    void tracksRemoved(QVector<sp_track *>);
    void availableOfflineChanged();
    void seenCountChanged();
    void hasOfflineTracksChanged();
    void trackFilterChanged();
    void tracksChanged();
    void nameChanged();
    void playlistsChanged();

protected:
    bool updateData();
    bool event(QEvent *);

private Q_SLOTS:
    void onTrackChanged();

private:
    QSpotifyPlaylist(Type type, sp_playlist *playlist, bool incrRefCount = true);
    void addTrack(sp_track *track, int pos = -1);
    void registerTrackType(QSpotifyTrack *t);
    void unregisterTrackType(QSpotifyTrack *t);

    void postUpdateEvent();

    sp_playlist *m_sp_playlist;
    sp_playlist_callbacks *m_callbacks;

    QSpotifyTrackList *m_trackList;
    QSet<sp_track *> m_tracksSet;

    QString m_name;
    Type m_type;
    OfflineStatus m_offlineStatus;
    QString m_owner;
    bool m_collaborative;
    int m_offlineDownloadProgress;
    bool m_availableOffline;

    QSet<QSpotifyTrack *> m_offlineTracks;
    QSet<QSpotifyTrack *> m_availableTracks;

    QList<QObject *> m_availablePlaylists;
    QList<QObject *> m_unavailablePlaylists;

    QString m_uri;

    bool m_skipUpdateTracks;

    QString m_trackFilter;

    bool m_updateEventPosted;

    friend class QSpotifyPlaylistContainer;
    friend class QSpotifyUser;
    friend class QSpotifyTrack;
};

#endif // QSPOTIFYPLAYLIST_H
