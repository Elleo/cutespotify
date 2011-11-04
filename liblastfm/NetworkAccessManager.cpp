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
#include "NetworkAccessManager.h"
//#include "InternetConnectionMonitor.h"
#include "ws.h"
#include "misc.h"
#include <QCoreApplication>
#include <QNetworkRequest>


namespace lastfm
{
    QByteArray UserAgent;
}


lastfm::NetworkAccessManager::NetworkAccessManager( QObject* parent )
               : QNetworkAccessManager( parent )
{
    // can't be done in above init, as applicationName() won't be set
    if (lastfm::UserAgent.isEmpty())
    {
        QByteArray name = QCoreApplication::applicationName().toUtf8();
        QByteArray version = QCoreApplication::applicationVersion().toUtf8();
        if (version.size()) version.prepend( ' ' );
        lastfm::UserAgent = name + version;
    }
}


lastfm::NetworkAccessManager::~NetworkAccessManager()
{
}


QNetworkProxy
lastfm::NetworkAccessManager::proxy( const QNetworkRequest& request )
{
    Q_UNUSED( request );

    return QNetworkProxy::applicationProxy();
}


QNetworkReply*
lastfm::NetworkAccessManager::createRequest( Operation op, const QNetworkRequest& request_, QIODevice* outgoingData )
{
    QNetworkRequest request = request_;

    request.setRawHeader( "User-Agent", lastfm::UserAgent );

    return QNetworkAccessManager::createRequest( op, request, outgoingData );
}
