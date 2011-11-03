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


#ifndef QSPOTIFYSEARCH_H
#define QSPOTIFYSEARCH_H

#include <QObject>

struct sp_search;
class QSpotifyTrackList;

class QSpotifySearch : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(QList<QObject *> tracks READ tracks NOTIFY resultsChanged)
    Q_PROPERTY(QList<QObject *> albums READ albums NOTIFY resultsChanged)
    Q_PROPERTY(QList<QObject *> artists READ artists NOTIFY resultsChanged)
    Q_PROPERTY(QString didYouMean READ didYouMean NOTIFY resultsChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
public:

    QSpotifySearch(QObject *parent = 0);
    ~QSpotifySearch();

    QString query() const { return m_query; }
    void setQuery(const QString &q);

    QList<QObject *> tracks() const;
    QList<QObject *> albums() const { return m_albumResults; }
    QList<QObject *> artists() const { return m_artistResults; }

    QString didYouMean() const { return m_didYouMean; }

    void setTracksLimit(int l) { m_tracksLimit = l; }
    void setAlbumsLimit(int l) { m_albumsLimit = l; }
    void setArtistsLimit(int l) { m_artistsLimit = l; }

    QSpotifyTrackList *trackResults() const { return m_trackResults; }

    bool busy() const { return m_busy; }

    Q_INVOKABLE void search();

    bool event(QEvent *);

Q_SIGNALS:
    void queryChanged();
    void resultsChanged();
    void busyChanged();

private:
    void clearSearch();
    void populateResults();

    sp_search *m_sp_search;

    QString m_query;
    QSpotifyTrackList *m_trackResults;
    QList<QObject *> m_albumResults;
    QList<QObject *> m_artistResults;
    QString m_didYouMean;
    bool m_busy;

    int m_tracksLimit;
    int m_albumsLimit;
    int m_artistsLimit;

};

#endif // QSPOTIFYSEARCH_H
