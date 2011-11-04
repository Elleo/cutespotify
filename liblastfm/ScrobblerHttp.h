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
#ifndef SCROBBLER_HTTP_H
#define SCROBBLER_HTTP_H

#include <QPointer>
#include <QUrl>
#include "XmlQuery.h"
class QNetworkReply;


/** This was a QHttp class, but then we realised QNetworkAccessManager and that
  * is oodles better. So we chnaged it to use that. */
class ScrobblerHttp : public QObject
{
    Q_OBJECT

public:
    void retry();
    bool isActive() const { return !rp.isNull(); }

protected:
    ScrobblerHttp( QObject* parent = 0 );

protected slots:
    virtual void request() = 0;

signals:
    void done( const QByteArray& data );

protected:
    class QTimer *m_retry_timer;
    QPointer<QNetworkReply> rp;

private slots:
    void onRequestFinished();

private:
    void resetRetryTimer();
};


class ScrobblerPostHttp : public ScrobblerHttp
{
protected:
    QMap<QString, QString> m_data;

public:
    ScrobblerPostHttp()
    {}

    /** if you reimplement call the base version after setting m_data */
    virtual void request();

};

#endif
