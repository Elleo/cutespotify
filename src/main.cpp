/****************************************************************************
**
** Copyright (c) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Yoann Lopes (yoann.lopes@nokia.com)
**
** This file is part of the MeeSpot project.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions
** are met:
**
** Redistributions of source code must retain the above copyright notice,
** this list of conditions and the following disclaimer.
**
** Redistributions in binary form must reproduce the above copyright
** notice, this list of conditions and the following disclaimer in the
** documentation and/or other materials provided with the distribution.
**
** Neither the name of Nokia Corporation and its Subsidiary(-ies) nor the names of its
** contributors may be used to endorse or promote products derived from
** this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
** FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
** TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
** PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
** LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
** NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
****************************************************************************/


#include <QtCore/QDebug>
#include <QtCore/QSettings>
#include <QtCore/QStandardPaths>
#include <QtCore/QDir>
#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
#include <QtQuick/QQuickView>
#include <QtWidgets/QApplication>
#include <iostream>

//#include "src/hardwarekeyshandler.h"
#include <QtSpotify>
#include <qspotify_qmlplugin.h>

void silentDebug(QtMsgType type, const QMessageLogContext& context, const QString &msg)
{
    Q_UNUSED(context);
    if (type == QtMsgType::QtDebugMsg) {
        return;
    } else {
        std::cerr << msg.toStdString() << std::endl;
    }
}

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QApplication::setOrganizationName("com.mikeasoft.cutespotify");
    QApplication::setOrganizationDomain("com.mikeasoft.cutespotify");
    QApplication::setApplicationName("CuteSpotify");

    QString settingsPath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    QSettings::setPath(QSettings::NativeFormat, QSettings::UserScope, settingsPath);
    QSettings settings;
    if(!settings.contains("dataPath")) {
        // Set default path, but allow for it to be overridden
        // e.g. so data can be store on SD card
        settings.setValue("dataPath", settingsPath);
    }

    QApplication *app = new QApplication(argc, argv);
    QQuickView *view = new QQuickView();

    if (!app->arguments().contains(QLatin1String("--debug"))) {
        qInstallMessageHandler(silentDebug);
    }

    registerQmlTypes();
    view->rootContext()->setContextProperty(QLatin1String("spotifySession"), QSpotifySession::instance());
    view->engine()->addImageProvider(QLatin1String("spotify"), new QSpotifyImageProvider);

    //HardwareKeysHandler keyHandler;

    view->setSource(QUrl("qrc:/qml/main.qml"));
    view->setResizeMode(QQuickView::SizeRootObjectToView);

    view->show();
    return app->exec();
}
