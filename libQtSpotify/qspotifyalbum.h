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


#ifndef QSPOTIFYALBUM_H
#define QSPOTIFYALBUM_H

#include "qspotifyobject.h"

struct sp_album;
struct sp_artist;
class QSpotifyArtist;

class QSpotifyAlbum : public QSpotifyObject
{
    Q_OBJECT

    Q_PROPERTY(bool isAvailable READ isAvailable NOTIFY albumDataChanged)
    Q_PROPERTY(QString artist READ artist NOTIFY albumDataChanged)
    Q_PROPERTY(QString name READ name NOTIFY albumDataChanged)
    Q_PROPERTY(int year READ year NOTIFY albumDataChanged)
    Q_PROPERTY(Type type READ type NOTIFY albumDataChanged)
    Q_PROPERTY(QString sectionType READ sectionType NOTIFY albumDataChanged)
    Q_PROPERTY(QString coverId READ coverId NOTIFY albumDataChanged)
    Q_ENUMS(Type)
public:
    enum Type {
        Album = 0,
        Single = 1,
        Compilation = 2,
        Unknown = 3
    };

    ~QSpotifyAlbum();

    bool isLoaded();

    bool isAvailable() const { return m_isAvailable; }
    QString artist() const { return m_artist; }
    QString name() const { return m_name; }
    int year() const { return m_year; }
    Type type() const { return m_type; }
    void setSectionType(const QString &t) { m_sectionType = t; }
    QString sectionType() const { return m_sectionType; }
    QString coverId() const { return m_coverId; }

    sp_album *spalbum() const { return m_sp_album; }

Q_SIGNALS:
    void albumDataChanged();

protected:
    bool updateData();

private:
    QSpotifyAlbum(sp_album *album);

    sp_album *m_sp_album;

    bool m_isAvailable;
    QString m_artist;
    QString m_name;
    int m_year;
    Type m_type;
    QString m_sectionType;
    QString m_coverId;

    friend class QSpotifySession;
    friend class QSpotifyTrack;
    friend class QSpotifyArtistBrowse;
    friend class QSpotifySearch;
    friend class QSpotifyToplist;
};

#endif // QSPOTIFYALBUM_H
