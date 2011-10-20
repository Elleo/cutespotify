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


#ifndef QSPOTIFYTRACKLIST_H
#define QSPOTIFYTRACKLIST_H

#include <QtCore/QObject>
#include <QtCore/QList>

class QSpotifyTrack;

class QSpotifyTrackList : public QObject
{
    Q_OBJECT
public:
    QSpotifyTrackList(bool reverse = false);

    QList<QSpotifyTrack *> tracks() const { return m_tracks; }

    void play();
    bool playTrackAtIndex(int i);
    bool next();
    bool previous();
    void playLast();

    int totalDuration() const;

    bool isShuffle() const { return m_shuffle; }
    void setShuffle(bool s);

    void addRef() { ++m_refCount; }
    void release();

private Q_SLOTS:
    void onTrackReady();

private:
    ~QSpotifyTrackList();
    void playCurrentTrack();

    int nextAvailable(int i);
    int previousAvailable(int i);

    bool m_reverse;

    QList<QSpotifyTrack *> m_tracks;

    int m_currentIndex;
    QSpotifyTrack *m_currentTrack;

    bool m_shuffle;
    QList<int> m_shuffleList;
    int m_shuffleIndex;

    int m_refCount;

    friend class QSpotifyTrack;
    friend class QSpotifyPlaylist;
    friend class QSpotifySearch;
    friend class QSpotifyPlayQueue;
    friend class QSpotifyAlbumBrowse;
    friend class QSpotifyArtistBrowse;
    friend class QSpotifyUser;
    friend class QSpotifyToplist;
};

#endif // QSPOTIFYTRACKLIST_H
