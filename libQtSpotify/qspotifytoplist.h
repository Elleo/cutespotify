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


#ifndef QSPOTIFYTOPLIST_H
#define QSPOTIFYTOPLIST_H

#include <QtCore/QDateTime>
#include <QtCore/QObject>

class QSpotifyTrackList;
struct sp_toplistbrowse;

class QSpotifyToplist : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject *> tracks READ tracks NOTIFY resultsChanged)
    Q_PROPERTY(QList<QObject *> albums READ albums NOTIFY resultsChanged)
    Q_PROPERTY(QList<QObject *> artists READ artists NOTIFY resultsChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

public:

    QSpotifyToplist(QObject *parent = 0);
    ~QSpotifyToplist();

    QList<QObject *> tracks() const;
    QList<QObject *> albums() const { return m_albumResults; }
    QList<QObject *> artists() const { return m_artistResults; }

    bool busy() const { return m_busy; }

    Q_INVOKABLE void updateResults();

    bool event(QEvent *);

Q_SIGNALS:
    void resultsChanged();
    void busyChanged();

private:
    void clear();
    void populateResults(sp_toplistbrowse *tl);

    sp_toplistbrowse *m_sp_browsetracks;
    sp_toplistbrowse *m_sp_browseartists;
    sp_toplistbrowse *m_sp_browsealbums;

    bool m_busy;

    QSpotifyTrackList *m_trackResults;
    QList<QObject *> m_albumResults;
    QList<QObject *> m_artistResults;

    QDateTime m_lastUpdate;

};

#endif // QSPOTIFYTOPLIST_H
