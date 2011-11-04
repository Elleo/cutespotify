/*
   Copyright 2009 Last.fm Ltd.
      - Primarily authored by Max Howell, Jono Cole and Doug Mansell

   This file is part of liblastfm.

   liblastfm is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   liblastfm is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with liblastfm.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef LASTFM_ALBUM_H
#define LASTFM_ALBUM_H

#include "Artist.h"
#include <QString>
#include <QUrl>

namespace lastfm
{
    class Album
    {
        Artist m_artist;
        QString m_title;

    public:
        Album()
        {}


        Album( Artist artist, QString title ) : m_artist( artist ), m_title( title )
        {}

        bool operator==( const Album& that ) const { return m_title == that.m_title && m_artist == that.m_artist; }
        bool operator!=( const Album& that ) const { return m_title != that.m_title || m_artist != that.m_artist; }

        operator QString() const { return title(); }
        QString title() const { return m_title.isEmpty() ? "[unknown]" : m_title; }
        Artist artist() const { return m_artist; }

        /** artist may have been set, since we allow that in the ctor, but should we handle untitled albums? */
        bool isNull() const { return m_title.isEmpty(); }

    };
}

#endif //LASTFM_ALBUM_H
