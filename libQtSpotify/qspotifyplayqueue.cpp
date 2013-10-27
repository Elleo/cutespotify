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


#include "qspotifyplayqueue.h"

#include "qspotifysession.h"
#include "qspotifytrack.h"
#include "qspotifytracklist.h"

QSpotifyPlayQueue::QSpotifyPlayQueue()
    : QObject()
    , m_implicitTracks(0)
    , m_currentExplicitTrack(0)
    , m_currentTrackIndex(0)
    , m_shuffle(false)
    , m_repeat(false)
{
}

QSpotifyPlayQueue::~QSpotifyPlayQueue()
{
    clear();
}

void QSpotifyPlayQueue::playTrack(QSpotifyTrack *track)
{
    if (m_currentExplicitTrack) {
        m_currentExplicitTrack->release();
        m_currentExplicitTrack = 0;
    }

    if (m_implicitTracks != track->m_trackList) {
        if (m_implicitTracks)
            m_implicitTracks->release();
        m_implicitTracks = track->m_trackList;
        m_implicitTracks->addRef();
    }
    m_implicitTracks->playTrackAtIndex(m_implicitTracks->m_tracks.indexOf(track));
    m_implicitTracks->setShuffle(m_shuffle);

    emit tracksChanged();
}

void QSpotifyPlayQueue::enqueueTrack(QSpotifyTrack *track)
{
    track->addRef();
    m_explicitTracks.enqueue(track);

    emit tracksChanged();
}

void QSpotifyPlayQueue::enqueueTracks(QList<QSpotifyTrack *> tracks)
{
    for (int i = 0; i < tracks.count(); ++i) {
        QSpotifyTrack *t = tracks.at(i);
        t->addRef();
        m_explicitTracks.enqueue(t);
    }
    emit tracksChanged();
}

void QSpotifyPlayQueue::selectTrack(QSpotifyTrack *track)
{
    if (m_currentExplicitTrack == track || m_implicitTracks->m_currentTrack == track)
        return;

    if (m_currentExplicitTrack) {
        m_currentExplicitTrack->release();
        m_currentExplicitTrack = 0;
    }

    int explicitPos = m_explicitTracks.indexOf(track);
    if (explicitPos != -1) {
        m_explicitTracks.removeAt(explicitPos);
        m_currentExplicitTrack = track;
        if (m_currentExplicitTrack->isLoaded())
            onTrackReady();
        else
            connect(m_currentExplicitTrack, SIGNAL(isLoadedChanged()), this, SLOT(onTrackReady()));
    } else {
        m_implicitTracks->playTrackAtIndex(m_implicitTracks->m_tracks.indexOf(track));
    }

    emit tracksChanged();
}

bool QSpotifyPlayQueue::isExplicitTrack(int index)
{
    return index > m_currentTrackIndex && index <= m_currentTrackIndex + m_explicitTracks.count();
}

void QSpotifyPlayQueue::playNext(bool repeat)
{
    if (repeat) {
        QSpotifySession::instance()->stop(true);
        QSpotifySession::instance()->play(m_currentExplicitTrack ? m_currentExplicitTrack : m_implicitTracks->m_currentTrack);
    } else {
        if (m_currentExplicitTrack) {
            m_currentExplicitTrack->release();
            m_currentExplicitTrack = 0;
        }

        if (m_explicitTracks.isEmpty()) {
            if (m_implicitTracks) {
                if (!m_implicitTracks->next()) {
                    if (m_repeat) {
                        m_implicitTracks->play();
                    } else {
                        QSpotifySession::instance()->stop();
                        m_implicitTracks->release();
                        m_implicitTracks = 0;
                    }
                }
            } else {
                QSpotifySession::instance()->stop();
            }
        } else {
            m_currentExplicitTrack = m_explicitTracks.dequeue();
            if (m_currentExplicitTrack->isLoaded())
                onTrackReady();
            else
                connect(m_currentExplicitTrack, SIGNAL(isLoadedChanged()), this, SLOT(onTrackReady()));
        }
    }

    emit tracksChanged();
}

void QSpotifyPlayQueue::playPrevious()
{
    if (m_currentExplicitTrack) {
        m_currentExplicitTrack->release();
        m_currentExplicitTrack = 0;
    }

    if (m_implicitTracks) {
        if (!m_implicitTracks->previous()) {
            if (m_repeat) {
                m_implicitTracks->playLast();
            } else {
                QSpotifySession::instance()->stop();
                m_implicitTracks->release();
                m_implicitTracks = 0;
            }
        }
    } else {
        QSpotifySession::instance()->stop();
    }

    emit tracksChanged();
}

void QSpotifyPlayQueue::clear()
{
    if (m_currentExplicitTrack) {
        m_currentExplicitTrack->release();
        m_currentExplicitTrack = 0;
    }

    if (m_implicitTracks) {
        m_implicitTracks->release();
        m_implicitTracks = 0;
    }

    int c = m_explicitTracks.count();
    for (int i = 0; i < c; ++i)
        m_explicitTracks[i]->release();
    m_explicitTracks.clear();
}

void QSpotifyPlayQueue::setShuffle(bool s)
{
    if (m_shuffle == s)
        return;
    m_shuffle = s;
    if (m_implicitTracks)
        m_implicitTracks->setShuffle(s);

    emit tracksChanged();
}

void QSpotifyPlayQueue::setRepeat(bool r)
{
    if (m_repeat == r)
        return;

    m_repeat = r;

    emit tracksChanged();
}

void QSpotifyPlayQueue::onTrackReady()
{
    disconnect(this, SLOT(onTrackReady()));
    if (m_currentExplicitTrack)
        QSpotifySession::instance()->play(m_currentExplicitTrack);
}

QList<QObject *> QSpotifyPlayQueue::tracks() const
{
    QList<QObject *> list;

    if (!m_implicitTracks)
        return list;

    int currIndex = 0;

    if (m_shuffle) {
        for (int i = 0; i < m_implicitTracks->m_shuffleList.count(); ++i) {
            QSpotifyTrack * t = m_implicitTracks->m_tracks.at(m_implicitTracks->m_shuffleList.at(i));
            list.append((QObject*)t);
            if (t == m_implicitTracks->m_currentTrack)
                currIndex = i;
        }
    } else {
        if (m_implicitTracks->m_reverse) {
            int i = m_implicitTracks->previousAvailable(m_implicitTracks->m_tracks.count());
            while (i >= 0) {
                QSpotifyTrack * t = m_implicitTracks->m_tracks.at(i);
                list.append((QObject*)t);
                if (t == m_implicitTracks->m_currentTrack)
                    currIndex = m_implicitTracks->m_tracks.count() - 1 - i;
                i = m_implicitTracks->previousAvailable(i);
            }
        } else {
            int i = m_implicitTracks->nextAvailable(-1);
            while (i < m_implicitTracks->m_tracks.count()) {
                QSpotifyTrack * t = m_implicitTracks->m_tracks.at(i);
                list.append((QObject*)t);
                if (t == m_implicitTracks->m_currentTrack)
                    currIndex = i;
                i = m_implicitTracks->nextAvailable(i);
            }
        }
    }

    if (m_currentExplicitTrack)
        list.insert(++currIndex, (QObject*)m_currentExplicitTrack);
    for (int i = 0; i < m_explicitTracks.count(); ++i)
        list.insert(++currIndex, (QObject*)m_explicitTracks.at(i));

    if (m_currentExplicitTrack)
        m_currentTrackIndex = list.indexOf((QObject *)m_currentExplicitTrack);
    else if (m_implicitTracks->m_currentTrack)
        m_currentTrackIndex = list.indexOf((QObject *)m_implicitTracks->m_currentTrack);

    return list;
}

bool QSpotifyPlayQueue::isCurrentTrackList(QSpotifyTrackList *tl)
{
    return m_implicitTracks == tl;
}

void QSpotifyPlayQueue::tracksUpdated()
{
    emit tracksChanged();
}

void QSpotifyPlayQueue::onOfflineModeChanged()
{
    if (m_shuffle && m_implicitTracks)
        m_implicitTracks->setShuffle(true);
    emit tracksChanged();
}
