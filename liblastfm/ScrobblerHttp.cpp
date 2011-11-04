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
#include "ScrobblerHttp.h"
#include <QTimer>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include "ws.h"


ScrobblerHttp::ScrobblerHttp( QObject* parent )
             : QObject( parent )
{
    m_retry_timer = new QTimer( this );
    m_retry_timer->setSingleShot( true );
    connect( m_retry_timer, SIGNAL(timeout()), SLOT(request()) );
    resetRetryTimer();
}


void
ScrobblerHttp::onRequestFinished()
{
    if (rp->error() == QNetworkReply::OperationCanceledError)
        ; //we aborted it
    if (rp->error())
    {
        qWarning() << "ERROR!" << rp->error();
        emit done( QByteArray() );
    }
    else
    {
        emit done( rp->readAll() );

        // if it is running then someone called retry() in the slot connected to
        // the done() signal above, so don't reset it, init
        if (!m_retry_timer->isActive())
            resetRetryTimer();
    }

    rp->deleteLater();
}


void
ScrobblerHttp::retry()
{
    if (!m_retry_timer->isActive())
    {
        int const i = m_retry_timer->interval();
        if (i < 120 * 60 * 1000)
            m_retry_timer->setInterval( i * 2 );
    }

    qDebug() << "Will retry in" << m_retry_timer->interval() / 1000 << "seconds";

    m_retry_timer->start();
}


void
ScrobblerHttp::resetRetryTimer()
{
    m_retry_timer->setInterval( 30 * 1000 );
}


void
ScrobblerPostHttp::request()
{
    if (m_data.isEmpty())
        return;

    if (rp)
        rp->deleteLater();

    rp = lastfm::ws::post(m_data);
    connect( rp, SIGNAL(finished()), SLOT(onRequestFinished()) );
    rp->setParent( this );
}
