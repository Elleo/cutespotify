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


#ifndef QSPOTIFYARTISTBROWSE_H
#define QSPOTIFYARTISTBROWSE_H

#include <QtCore/QStringList>

#include "qspotifysearch.h"

class QSpotifyAlbum;
class QSpotifyArtist;
class QSpotifyTrackList;
struct sp_artistbrowse;

class QSpotifyArtistBrowse : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QSpotifyArtist *artist READ artist WRITE setArtist NOTIFY artistChanged)
    Q_PROPERTY(QList<QObject *> topTracks READ topTracks NOTIFY dataChanged)
    Q_PROPERTY(QList<QObject *> albums READ albums NOTIFY dataChanged)
    Q_PROPERTY(int albumCount READ albumCount NOTIFY dataChanged)
    Q_PROPERTY(int singleCount READ singleCount NOTIFY dataChanged)
    Q_PROPERTY(int compilationCount READ compilationCount NOTIFY dataChanged)
    Q_PROPERTY(int appearsOnCount READ appearsOnCount NOTIFY dataChanged)
    Q_PROPERTY(QString pictureId READ pictureId NOTIFY dataChanged)
    Q_PROPERTY(QStringList biography READ biography NOTIFY dataChanged)
    Q_PROPERTY(QList<QObject *> similarArtists READ similarArtists NOTIFY dataChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
public:
    QSpotifyArtistBrowse(QObject *parent = 0);
    ~QSpotifyArtistBrowse();

    QSpotifyArtist *artist() const { return m_artist; }
    void setArtist(QSpotifyArtist *artist);

    QList<QObject *> topTracks() const;
    QList<QObject *> albums() const { return m_albums + m_singles + m_compilations + m_appearsOn; }

    int albumCount() const { return m_albums.count(); }
    int singleCount() const { return m_singles.count(); }
    int compilationCount() const { return m_compilations.count(); }
    int appearsOnCount() const { return m_appearsOn.count(); }

    QString pictureId() const { return m_pictureId; }

    QStringList biography() const { return m_biography; }

    QList<QObject *> similarArtists() const { return m_similarArtists; }

    bool busy() const { return m_busy; }

    bool event(QEvent *);

Q_SIGNALS:
    void artistChanged();
    void dataChanged();
    void busyChanged();

private Q_SLOTS:
    void searchArtists();
    void processTopHits();

private:
    void clearData();
    void processData();

    sp_artistbrowse *m_sp_artistbrowse;

    QSpotifyArtist *m_artist;
    QSpotifyTrackList *m_topTracks;
    QList<QObject *> m_albums;
    QList<QObject *> m_singles;
    QList<QObject *> m_compilations;
    QList<QObject *> m_appearsOn;
    QString m_pictureId;
    QStringList m_biography;
    QList<QObject *> m_similarArtists;
    bool m_busy;
    QSpotifySearch m_hackSearch;
    QSpotifySearch m_topHitsSearch;

    bool m_topHitsReady;
    bool m_dataReady;
};

#endif // QSPOTIFYARTISTBROWSE_H
