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
#include "Audioscrobbler.h"
#include "NowPlaying.h"
#include "ScrobbleCache.h"
#include "ScrobblerSubmission.h"
#include "ws.h"


namespace lastfm
{
    struct AudioscrobblerPrivate
    {
        AudioscrobblerPrivate()
            : cache( ws::Username )
        {}

        ~AudioscrobblerPrivate()
        {
            delete np;
            delete submitter;
        }

        QPointer<NowPlaying> np;
        QPointer<ScrobblerSubmission> submitter;
        ScrobbleCache cache;
    };
}


lastfm::Audioscrobbler::Audioscrobbler()
        : d( new AudioscrobblerPrivate() )
{
    d->np = new NowPlaying();
    connect(d->np, SIGNAL(done(QByteArray)), SLOT(onNowPlayingReturn(QByteArray)), Qt::QueuedConnection);
    d->submitter = new ScrobblerSubmission;
    connect(d->submitter, SIGNAL(done(QByteArray)), SLOT(onSubmissionReturn(QByteArray)), Qt::QueuedConnection);
}


lastfm::Audioscrobbler::~Audioscrobbler()
{
    delete d;
}


void
lastfm::Audioscrobbler::nowPlaying( const Track& track )
{
    d->np->submit( track );
}


void
lastfm::Audioscrobbler::cache( const Track& track )
{
    d->cache.add( track );
}


void
lastfm::Audioscrobbler::cache( const QList<Track>& tracks )
{
    d->cache.add( tracks );
}


void
lastfm::Audioscrobbler::submit()
{
    d->submitter->setTracks( d->cache.tracks() );
    d->submitter->submitNextBatch();

    if (d->submitter->isActive())
        emit status( Scrobbling );
}

void
lastfm::Audioscrobbler::onNowPlayingReturn( const QByteArray& result )
{
    if (result.isEmpty())
        return;

    lastfm::XmlQuery xml(result);
    QString status = xml.attribute("status");

    if (status == "ok")
    {
        d->np->reset();
    }
    else
    {
        int errorCode = xml["error"].attribute("code").toInt();
        if (errorCode == lastfm::ws::TryAgainLater || errorCode == lastfm::ws::RateLimitExceeded)
            d->np->retry();
    }
}


void
lastfm::Audioscrobbler::onSubmissionReturn( const QByteArray& result )
{
    if (result.isEmpty())
        return;

    lastfm::XmlQuery xml(result);
    QString statusCode = xml.attribute("status");

    if (statusCode == "ok")
    {
        d->cache.remove(d->submitter->batch());
        d->submitter->submitNextBatch();

        if (d->submitter->batch().isEmpty())
        {
            emit status(Audioscrobbler::TracksScrobbled);
        }
    }
    else
    {
        int errorCode = xml["error"].attribute("code").toInt();
        if (errorCode == lastfm::ws::TryAgainLater || errorCode == lastfm::ws::RateLimitExceeded)
            d->submitter->retry();
    }
}
