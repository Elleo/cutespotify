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
#ifndef LASTFM_ARTIST_H
#define LASTFM_ARTIST_H

#include "global.h"
#include <QMap>
#include <QString>
#include <QUrl>

namespace lastfm
{
    class Artist
    {
        QString m_name;
        QList<QUrl> m_images;

    public:
        Artist()
        {}

        Artist( const QString& name ) : m_name( name )
        {}

        /** will be QUrl() unless you got this back from a getInfo or something call */
        QUrl imageUrl( ImageSize size = Large ) const { return m_images.value( size ); }

        bool isNull() const { return m_name.isEmpty(); }

        bool operator==( const Artist& that ) const { return m_name == that.m_name; }
        bool operator!=( const Artist& that ) const { return m_name != that.m_name; }

        operator QString() const
        {
            /** if no artist name is set, return the musicbrainz unknown identifier
              * in case some part of the GUI tries to display it anyway. Note isNull
              * returns false still. So you should have queried that! */
            return m_name.isEmpty() ? "[unknown]" : m_name;
        }
        QString name() const { return QString(*this); }

    };
}

#endif
