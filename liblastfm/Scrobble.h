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
#ifndef LASTFM_SCROBBLE_H
#define LASTFM_SCROBBLE_H

#include "Track.h"

namespace lastfm
{
    struct Scrobble : lastfm::Track
    {
        Scrobble()
        {}

        Scrobble( const lastfm::Track& that ) : Track( that )
        {}

        QByteArray sourceString() const;

        QByteArray ratingCharacter() const
        {
            return d->extras["rating"].toLatin1();
        }

        bool isLoved() const { return ratingCharacter() == QChar('L'); }
        bool isBanned() const { return ratingCharacter() == QChar('B'); }
        bool isSkipped() const { return ratingCharacter() == QChar('S'); }

        /** if isValid() returns false, we will not scrobble the track */
        enum Invalidity
        {
            TooShort,
            ArtistNameMissing,
            TrackNameMissing,
            ArtistInvalid,
            NoTimestamp,
            FromTheFuture,
            FromTheDistantPast
        };

        /** @returns true if the server is unlikely to reject this scrobble */
        bool isValid( Invalidity* = 0 ) const;
    };
}

#endif
