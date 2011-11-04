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
#include "ScrobbleCache.h"
#include "misc.h"
#include <QCoreApplication>
#include <QFile>
#include <QDomElement>
#include <QDomDocument>
#if LASTFM_VERSION >= 0x00010000
using lastfm::ScrobbleCache;
#endif


ScrobbleCache::ScrobbleCache( const QString& username )
{
    Q_ASSERT( username.length() );

    m_path = lastfm::dir::runtimeData().filePath( username + "_subs_cache.xml" );
    m_username = username;

    QDomDocument xml;
    read( xml );
}


void
ScrobbleCache::read( QDomDocument& xml )
{
    m_tracks.clear();

    QFile file( m_path );
    file.open( QFile::Text | QFile::ReadOnly );
    QTextStream stream( &file );
    stream.setCodec( "UTF-8" );

    xml.setContent( stream.readAll() );

    for (QDomNode n = xml.documentElement().firstChild(); !n.isNull(); n = n.nextSibling())
        if (n.nodeName() == "track")
            m_tracks += Track( n.toElement() );
}


void
ScrobbleCache::write()
{
    if (m_tracks.isEmpty())
    {
        QFile::remove( m_path );
    }
    else {
        QDomDocument xml;
        QDomElement e = xml.createElement( "submissions" );
        e.setAttribute( "product", QCoreApplication::applicationName() );
        e.setAttribute( "version", "2" );

        foreach (Track i, m_tracks)
            e.appendChild( i.toDomElement( xml ) );

        xml.appendChild( e );

        QFileInfo(m_path).dir().mkpath(".");

        QFile file( m_path );
        file.open( QIODevice::WriteOnly | QIODevice::Text );

        QTextStream stream( &file );
        stream.setCodec( "UTF-8" );
        stream << "<?xml version='1.0' encoding='utf-8'?>\n";
        stream << xml.toString( 2 );
    }
}


void
ScrobbleCache::add( const Scrobble& track )
{
    add( QList<Track>() << track );
}


void
ScrobbleCache::add( const QList<Track>& tracks )
{
    foreach (const Track& track, tracks)
    {
        Scrobble::Invalidity invalidity;

        if (!Scrobble(track).isValid( &invalidity ))
        {
            qWarning() << invalidity;
        }
        else if (track.isNull())
            qDebug() << "Will not cache an empty track";

        else if (!m_tracks.contains( track ))
            m_tracks += track;
    }
    write();
}


int
ScrobbleCache::remove( const QList<Track>& toremove )
{
    QMutableListIterator<Track> i( m_tracks );
    while (i.hasNext()) {
        Track t = i.next();
        for (int x = 0; x < toremove.count(); ++x)
            if (toremove[x] == t)
                i.remove();
    }

    write();

    // yes we return # remaining, rather # removed, but this is an internal
    // function and the behaviour is documented so it's alright imo --mxcl
    return m_tracks.count();
}
