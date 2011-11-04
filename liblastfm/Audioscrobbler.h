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
#ifndef LASTFM_AUDIOSCROBBLER_H
#define LASTFM_AUDIOSCROBBLER_H

#include "global.h"
#include <QByteArray>
#include <QList>
#include <QString>
#include <QObject>
#include <QVariant>

namespace lastfm
{
    /** @author Max Howell <max@last.fm>
      * An implementation of the Audioscrobbler Realtime Submissions Protocol
      * version 1.2.1 for a single Last.fm user
      * http://www.audioscrobbler.net/development/protocol/
      */
    class Audioscrobbler : public QObject
    {
        Q_OBJECT

    public:
        /** You will need to do QCoreApplication::setVersion and
          * QCoreApplication::setApplicationName for this to work, also you will
          * need to have set all the keys in the Ws namespace in WsKeys.h */
        Audioscrobbler();
        ~Audioscrobbler();

    public slots:
        /** will ask Last.fm to update the now playing information for the
          * authenticated user */
        void nowPlaying( const Track& );
        /** will cache the track, but we won't submit it until you call submit() */
        void cache( const Track& );
        /** will submit the submission cache for this user */
        void submit();

    public:
        void cache( const QList<Track>& );

    public:
        enum Status
        {
            Connecting,
            Handshaken,
            Scrobbling,
            TracksScrobbled,

            StatusMax
        };

        enum Error
        {
            /** the following will show via the status signal, the scrobbler will
              * not submit this session (np too), however caching will continue */
            ErrorBadSession = StatusMax,
            ErrorBannedClientVersion,
            ErrorInvalidSessionKey,
            ErrorBadTime,
            ErrorThreeHardFailures,
            ErrorBusy,
            ErrorOffline
        };

    signals:
        /** the controller should show status in an appropriate manner */
        void status( int code );

    private slots:
        void onNowPlayingReturn( const QByteArray& );
        void onSubmissionReturn( const QByteArray& );

    private:
        class AudioscrobblerPrivate* d;
    };
}


static inline QDebug operator<<( QDebug d, lastfm::Audioscrobbler::Status status )
{
    return d << lastfm::qMetaEnumString<lastfm::Audioscrobbler>( status, "Status" );
}
static inline QDebug operator<<( QDebug d, lastfm::Audioscrobbler::Error error )
{
    return d << lastfm::qMetaEnumString<lastfm::Audioscrobbler>( error, "Status" );
}

#endif
