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
#include "ScrobblerSubmission.h"
#include "ScrobbleCache.h"
#include "Scrobble.h"

using lastfm::Track;
using lastfm::Scrobble;

void
ScrobblerSubmission::setTracks( const QList<Track>& tracks )
{
    m_tracks = tracks;
    // submit in chronological order
    qSort( m_tracks.begin(), m_tracks.end() );
}


void
ScrobblerSubmission::submitNextBatch()
{
    if (isActive())
        // the tracks cannot be submitted at this time
        // if a parent Scrobbler instance exists, it will submit another batch
        // when the current one is done
        return;

    m_batch.clear(); //yep before isEmpty() check
    m_data.clear();

    if (m_tracks.isEmpty())
        return;

    m_data["method"] = "track.scrobble";

    for (int i = 0; i < 50 && !m_tracks.isEmpty(); ++i)
    {
        Scrobble s = m_tracks.takeFirst();

        QByteArray const N = QByteArray::number( i );
        m_data["timestamp[" + N + "]"] = QString::number(s.timestamp().toTime_t());
        m_data["album[" + N + "]"] = s.album();
        m_data["track[" + N + "]"] = s.title();
        m_data["artist[" + N + "]"] = s.artist();
        m_data["duration[" + N + "]"] = QString::number(s.duration());
        m_data["trackNumber[" + N + "]"] = QString::number(s.trackNumber());

        m_batch += s;
    }

    request();
};
