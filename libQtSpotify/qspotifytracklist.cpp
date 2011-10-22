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


#include "qspotifytracklist.h"

#include "qspotifytrack.h"
#include "qspotifysession.h"

QSpotifyTrackList::QSpotifyTrackList(bool reverse)
    : QObject()
    , m_reverse(reverse)
    , m_currentIndex(0)
    , m_currentTrack(0)
    , m_shuffle(false)
    , m_shuffleIndex(0)
    , m_refCount(1)
{
}

QSpotifyTrackList::~QSpotifyTrackList()
{
    int c = m_tracks.count();
    for (int i = 0; i < c; ++i)
        m_tracks[i]->release();
}

void QSpotifyTrackList::play()
{
    if (m_tracks.count() == 0)
        return;

    if (m_shuffle)
        playTrackAtIndex(m_shuffleList.first());
    else
        playTrackAtIndex(m_reverse ? previousAvailable(m_tracks.count()) : nextAvailable(-1));
}

bool QSpotifyTrackList::playTrackAtIndex(int i)
{
    if (i < 0 || i >= m_tracks.count()) {
        m_currentTrack->release();
        m_currentTrack = 0;
        m_currentIndex = 0;
        return false;
    }

    if (m_shuffle)
        m_shuffleIndex = m_shuffleList.indexOf(i);
    m_currentTrack = m_tracks.at(i);
    m_currentTrack->addRef();
    m_currentIndex = i;
    playCurrentTrack();
    return true;
}

bool QSpotifyTrackList::next()
{
    if (m_shuffle) {
        if (m_shuffleIndex + 1 >= m_shuffleList.count()) {
            m_currentTrack->release();
            m_currentTrack = 0;
            return false;
        }
        return playTrackAtIndex(m_shuffleList.at(m_shuffleIndex + 1));
    } else {
        int index = m_tracks.indexOf(m_currentTrack);
        if (index == -1) {
            int newi = qMin(m_currentIndex, m_tracks.count() - 1);
            return playTrackAtIndex(m_reverse ? previousAvailable(newi) : nextAvailable(newi - 1));
        }
        return playTrackAtIndex(m_reverse ? previousAvailable(index) : nextAvailable(index));
    }
}

bool QSpotifyTrackList::previous()
{
    if (m_shuffle) {
        if (m_shuffleIndex - 1 < 0) {
            m_currentTrack->release();
            m_currentTrack = 0;
            return false;
        }
        return playTrackAtIndex(m_shuffleList.at(m_shuffleIndex - 1));
    } else {
        int index = m_tracks.indexOf(m_currentTrack);
        if (index == -1) {
            int newi = qMin(m_currentIndex, m_tracks.count() - 1);
            return playTrackAtIndex(m_reverse ? nextAvailable(newi - 1) : previousAvailable(newi));
        }
        return playTrackAtIndex(m_reverse ? nextAvailable(index) : previousAvailable(index));
    }
}

void QSpotifyTrackList::playLast()
{
    if (m_tracks.count() == 0)
        return;

    if (m_shuffle)
        playTrackAtIndex(m_shuffleList.last());
    else
        playTrackAtIndex(m_reverse ? nextAvailable(-1) : previousAvailable(m_tracks.count()));
}

void QSpotifyTrackList::playCurrentTrack()
{
    if (!m_currentTrack)
        return;

    if (m_currentTrack->isLoaded())
        onTrackReady();
    else
        connect(m_currentTrack, SIGNAL(isLoadedChanged()), this, SLOT(onTrackReady()));
}

void QSpotifyTrackList::onTrackReady()
{
    disconnect(this, SLOT(onTrackReady()));
    QSpotifySession::instance()->play(m_currentTrack);
}

void QSpotifyTrackList::setShuffle(bool s)
{
    m_shuffle = s;

    m_shuffleList.clear();
    m_shuffleIndex = 0;
    bool currentTrackStillExists = m_currentTrack && m_tracks.contains(m_currentTrack);

    if (m_shuffle) {
        qsrand(QTime::currentTime().msec());
        int currentTrackIndex = 0;
        if (currentTrackStillExists) {
            currentTrackIndex = m_tracks.indexOf(m_currentTrack);
            m_shuffleList.append(currentTrackIndex);
        }
        QList<int> indexes;
        for (int i = 0; i < m_tracks.count(); ++i) {
            if ((currentTrackStillExists && i == currentTrackIndex) || !m_tracks.at(i)->isAvailable())
                continue;
            indexes.append(i);
        }
        while (!indexes.isEmpty()) {
            int i = indexes.takeAt(indexes.count() == 1 ? 0 : (qrand() % (indexes.count() - 1)));
            m_shuffleList.append(i);
        }
    }
}

void QSpotifyTrackList::release()
{
    --m_refCount;
    if (m_refCount == 0)
        deleteLater();
}

int QSpotifyTrackList::totalDuration() const
{
    qint64 total = 0;
    for (int i = 0; i < m_tracks.count(); ++i)
        total += m_tracks.at(i)->duration();

    return total;
}

int QSpotifyTrackList::nextAvailable(int i)
{
    do {
        ++i;
    } while (i < m_tracks.count() && !m_tracks.at(i)->isAvailable());
    return i;
}

int QSpotifyTrackList::previousAvailable(int i)
{
    do {
        --i;
    } while (i > -1 && !m_tracks.at(i)->isAvailable());
    return i;
}
