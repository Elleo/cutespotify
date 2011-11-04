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
#include "NowPlaying.h"
#include "Track.h"
#include "ws.h"
#include <QTimer>


NowPlaying::NowPlaying()
{
    // we wait 5 seconds to prevent the server panicking when people skip a lot
    // tracks in succession
    m_timer = new QTimer( this );
    m_timer->setSingleShot( true );
    connect( m_timer, SIGNAL(timeout()), SLOT(request()) );
}


void
NowPlaying::reset()
{
    m_timer->stop();
    m_data.clear();
}


void
NowPlaying::submit( const lastfm::Track& track )
{
    if (track.isNull())
        return;

    m_data["method"] = "track.updateNowPlaying";
    m_data["track"] = track.title();
    m_data["artist"] = track.artist();
    m_data["album"] = track.album();
    m_data["trackNumber"] = QByteArray::number(track.trackNumber());
    m_data["duration"] = QByteArray::number(track.duration());

    // m_time is initialised to midnight, so a bug exists that if the app is
    // started after 00:00 and before 00:04 we trigger via the timer. But meh!
    uint ms = m_delay.elapsed();

    if (ms < 10000) {
        m_timer->setInterval( 10000 - ms );
        m_timer->start();
    }
    else {
        m_delay.restart();
        request();
    }
}
