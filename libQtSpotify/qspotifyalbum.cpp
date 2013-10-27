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


#include "qspotifyalbum.h"

#include <QtCore/QDebug>

#include <libspotify/api.h>

#include "qspotifyartist.h"
#include "qspotifysession.h"

QSpotifyAlbum::QSpotifyAlbum(sp_album *album)
    : QSpotifyObject(true)
    , m_isAvailable(false)
    , m_year(0)
    , m_type(Unknown)
{
    connect(this, SIGNAL(dataChanged()), this, SIGNAL(albumDataChanged()));
    sp_album_add_ref(album);
    m_sp_album = album;
    metadataUpdated();
}

QSpotifyAlbum::~QSpotifyAlbum()
{
    sp_album_release(m_sp_album);
}

bool QSpotifyAlbum::isLoaded()
{
    return sp_album_is_loaded(m_sp_album);
}

bool QSpotifyAlbum::updateData()
{
    bool updated = false;

    bool isAvailable = sp_album_is_available(m_sp_album);
    sp_artist *a = sp_album_artist((m_sp_album));
    QString artist;
    if (a)
        artist = QString::fromUtf8(sp_artist_name(a));
    QString name = QString::fromUtf8(sp_album_name(m_sp_album));
    int year = sp_album_year(m_sp_album);
    Type type = Type(sp_album_type(m_sp_album));

    // Get cover
    const byte *album_cover_id = sp_album_cover(m_sp_album, SP_IMAGE_SIZE_NORMAL);
    if (album_cover_id != 0 && m_coverId.isEmpty()) {
        sp_link *link = sp_link_create_from_album_cover(m_sp_album, SP_IMAGE_SIZE_NORMAL);
        if (link) {
            char buffer[200];
            int uriSize = sp_link_as_string(link, &buffer[0], 200);
            m_coverId = QString::fromUtf8(&buffer[0], uriSize);
            sp_link_release(link);
            updated = true;
        }
    }

    if (isAvailable != m_isAvailable) {
        m_isAvailable = isAvailable;
        updated = true;
    }
    if (artist != m_artist) {
        m_artist = artist;
        updated = true;
    }
    if (name != m_name) {
        m_name = name;
        updated = true;
    }
    if (year != m_year) {
        m_year = year;
        updated = true;
    }
    if (type != m_type) {
        m_type = type;
        updated = true;
    }

    return updated;
}
