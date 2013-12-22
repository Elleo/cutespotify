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


#include "qspotifysession.h"

#include <QtCore/QBuffer>
#include <QtCore/QCoreApplication>
#include <QtCore/QDebug>
#include <QtCore/QEvent>
#include <QtCore/QHash>
#include <QtCore/QIODevice>
#include <QtCore/QMutexLocker>
#include <QtCore/QSettings>
#include <QtCore/QStandardPaths>
#include <QtCore/QThread>
#include <QtCore/QWaitCondition>
#include <QtGui/QDesktopServices>
#include <QtGui/QImage>
#include <QtMultimedia/QAudioOutput>
#include <QtNetwork/QNetworkConfigurationManager>
#include <QtSystemInfo/QStorageInfo>
#include <QKeyEvent>

#include <assert.h>

#include "qspotifyalbum.h"
#include "qspotifyartist.h"
#include "qspotifyplayqueue.h"
#include "qspotifytrack.h"
#include "qspotifytracklist.h"
#include "qspotifyevents.h"
#include "qspotifyuser.h"
#include "spotify_key.h"

#define BUFFER_SIZE 409600
#define AUDIOSTREAM_UPDATE_INTERVAL 20

class QSpotifyAudioThreadWorker;

static QBuffer g_buffer;
static QMutex g_mutex;
static int g_readPos = 0;
static int g_writePos = 0;
static QSpotifyAudioThreadWorker *g_audioWorker;

static QMutex g_imageRequestMutex;
static QHash<QString, QWaitCondition *> g_imageRequestConditions;
static QHash<QString, QImage> g_imageRequestImages;
static QHash<sp_image *, QString> g_imageRequestObject;

QSpotifySession *QSpotifySession::m_instance = nullptr;

class QSpotifyAudioThreadWorker : public QObject
{
public:
    QSpotifyAudioThreadWorker();

    bool event(QEvent *);

private:
    void startStreaming(int channels, int sampleRate);
    void updateAudioBuffer();

    QAudioOutput *m_audioOutput;
    QIODevice *m_iodevice;
    int m_audioTimerID;
    int m_timeCounter;
    bool m_endOfTrack;
    int m_previousElapsedTime;
};

QSpotifyAudioThreadWorker::QSpotifyAudioThreadWorker()
    : QObject()
    , m_audioOutput(0)
    , m_iodevice(0)
    , m_audioTimerID(0)
    , m_timeCounter(0)
    , m_endOfTrack(false)
    , m_previousElapsedTime(0)
{
}

bool QSpotifyAudioThreadWorker::event(QEvent *e)
{
    qDebug() << "QSpotifyAudioThreadWorker::event";
    if (e->type() == QEvent::User + 3) {
        // StreamingStarted Event
        QSpotifyStreamingStartedEvent *ev = static_cast<QSpotifyStreamingStartedEvent *>(e);
        startStreaming(ev->channels(), ev->sampleRate());
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 4) {
        m_endOfTrack = true;
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 6) {
        // Resume
        if (m_audioOutput) {
            m_audioTimerID = startTimer(AUDIOSTREAM_UPDATE_INTERVAL);
            m_audioOutput->resume();
        }
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 7) {
        // Suspend
        if (m_audioOutput) {
            killTimer(m_audioTimerID);
            m_audioOutput->suspend();
        }
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 8) {
        // Stop
        QMutexLocker lock(&g_mutex);
        killTimer(m_audioTimerID);
        g_buffer.close();
        g_buffer.setData(QByteArray());
        g_readPos = 0;
        g_writePos = 0;
        if (m_audioOutput) {
            m_audioOutput->suspend();
            m_audioOutput->stop();
            delete m_audioOutput;
            m_audioOutput = 0;
            m_iodevice = 0;
        }
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 9) {
        // Reset buffers
        if (m_audioOutput) {
            QMutexLocker lock(&g_mutex);
            killTimer(m_audioTimerID);
            m_audioOutput->suspend();
            m_audioOutput->stop();
            g_buffer.close();
            g_buffer.setData(QByteArray());
            g_buffer.open(QIODevice::ReadWrite);
            g_readPos = 0;
            g_writePos = 0;
            m_audioOutput->reset();
            m_iodevice = m_audioOutput->start();
            m_audioOutput->suspend();
            m_audioTimerID = startTimer(AUDIOSTREAM_UPDATE_INTERVAL);
            m_timeCounter = 0;
            m_previousElapsedTime = 0;
        }
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 20) {
        QSpotifyVolumeEvent *ev = static_cast<QSpotifyVolumeEvent *>(e);
        m_audioOutput->setVolume(ev->volume() / 100.0);
        e->accept();
        return true;
    } else if (e->type() == QEvent::Timer) {
        QTimerEvent *te = static_cast<QTimerEvent *>(e);
        if (te->timerId() == m_audioTimerID) {
            updateAudioBuffer();
            e->accept();
            return true;
        }
    }
    return QObject::event(e);
}

void QSpotifyAudioThreadWorker::startStreaming(int channels, int sampleRate)
{
    qDebug() << "QSpotifyAudioThreadWorker::startStreaming";
    if (!m_audioOutput) {
        QAudioFormat af;
        af.setChannelCount(channels);
        af.setCodec("audio/pcm");
        af.setSampleRate(sampleRate);
        af.setSampleSize(16);
        af.setSampleType(QAudioFormat::SignedInt);

        QAudioDeviceInfo info(QAudioDeviceInfo::defaultOutputDevice());
        if (!info.isFormatSupported(af)) {
            QList<QAudioDeviceInfo> devices = QAudioDeviceInfo::availableDevices(QAudio::AudioOutput);
            for (int i = 0; i < devices.size(); i++) {
                QAudioDeviceInfo dev = devices[i];
                qWarning() << dev.deviceName();
            }
            QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 5)));
            return;
        }

        m_audioOutput = new QAudioOutput(af);
        m_audioOutput->setBufferSize(BUFFER_SIZE);
        QSettings settings;
        int vol = settings.value("volume", 50).toInt();
        m_audioOutput->setVolume(vol / 100.0);
        m_iodevice = m_audioOutput->start();
        m_audioOutput->suspend();
        m_audioTimerID = startTimer(AUDIOSTREAM_UPDATE_INTERVAL);
        m_endOfTrack = false;
        m_timeCounter = 0;
        m_previousElapsedTime = 0;
    }
}

void QSpotifyAudioThreadWorker::updateAudioBuffer()
{
    qDebug() << "QSpotifyAudioThreadWorker::updateAudioBuffer";
    if (!m_audioOutput)
        return;

    if (m_audioOutput->state() == QAudio::SuspendedState)
        m_audioOutput->resume();

    if (m_endOfTrack && m_audioOutput->state() == QAudio::IdleState) {
        killTimer(m_audioTimerID);
        int elapsedTime = int(m_audioOutput->processedUSecs() / 1000);
        QCoreApplication::postEvent(QSpotifySession::instance(), new QSpotifyTrackProgressEvent(elapsedTime - m_previousElapsedTime));
        QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 4)));
        m_previousElapsedTime = elapsedTime;
        return;
    } else {
        g_mutex.lock();
        int toRead = qMin(g_writePos - g_readPos, m_audioOutput->bytesFree());
        g_buffer.seek(g_readPos);
        char data[toRead];
        int read =  g_buffer.read(&data[0], toRead);
        g_readPos += read;
        g_mutex.unlock();

        m_iodevice->write(&data[0], read);

    }

    m_timeCounter += AUDIOSTREAM_UPDATE_INTERVAL;
    if (m_timeCounter >= 1000) {
        m_timeCounter = 0;
        int elapsedTime = int(m_audioOutput->processedUSecs() / 1000);
        QCoreApplication::postEvent(QSpotifySession::instance(), new QSpotifyTrackProgressEvent(elapsedTime - m_previousElapsedTime));
        m_previousElapsedTime = elapsedTime;
    }
}


class QSpotifyAudioThread : public QThread
{
public:
    void run();
};

void QSpotifyAudioThread::run()
{
    qDebug() << "QSpotifyAudioThread::run";
    g_audioWorker = new QSpotifyAudioThreadWorker;
    exec();
    delete g_audioWorker;
}


static void SP_CALLCONV callback_logged_in(sp_session *, sp_error error)
{
    qDebug() << "Log in: " << QString::fromUtf8(sp_error_message(error));
    QCoreApplication::postEvent(QSpotifySession::instance(), new QSpotifyConnectionErrorEvent(error, QString::fromUtf8(sp_error_message(error))));
    if (error == SP_ERROR_OK)
        QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 14)));
}

static void SP_CALLCONV callback_logged_out(sp_session *)
{
    qDebug() << "Logged out";
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 15)));
}

static void SP_CALLCONV callback_connection_error(sp_session *, sp_error error)
{
    qDebug() << "Connection error "  << QString::fromUtf8(sp_error_message(error));
    QCoreApplication::postEvent(QSpotifySession::instance(), new QSpotifyConnectionErrorEvent(error, QString::fromUtf8(sp_error_message(error))));
}

static void SP_CALLCONV callback_notify_main_thread(sp_session *)
{
    qDebug() << "Notify main thread";
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::User));
}

static void SP_CALLCONV callback_metadata_updated(sp_session *)
{
    qDebug() << "Metadata updated";
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 2)));
}

static void SP_CALLCONV callback_userinfo_updated(sp_session* )
{
    qDebug() << "User info updated";
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 2)));
}

static int SP_CALLCONV callback_music_delivery(sp_session *, const sp_audioformat *format, const void *frames, int num_frames)
{
    qDebug() << "Music delivery";
    if (num_frames == 0)
        return 0;

    QMutexLocker locker(&g_mutex);

    if (!g_buffer.isOpen()) {
        g_buffer.open(QIODevice::ReadWrite);
        QCoreApplication::postEvent(g_audioWorker,
                                    new QSpotifyStreamingStartedEvent(format->channels, format->sample_rate));
    }

    int availableFrames = (BUFFER_SIZE - (g_writePos - g_readPos)) / (sizeof(int16_t) * format->channels);
    int writtenFrames = qMin(num_frames, availableFrames);

    if (writtenFrames == 0)
        return 0;

    g_buffer.seek(g_writePos);
    g_writePos += g_buffer.write((const char *) frames, writtenFrames * sizeof(int16_t) * format->channels);

    return writtenFrames;
}

static void SP_CALLCONV callback_end_of_track(sp_session *)
{
    qDebug() << "End of track";
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 4)));
    QCoreApplication::postEvent(g_audioWorker, new QEvent(QEvent::Type(QEvent::User + 4)));
}

static void SP_CALLCONV callback_play_token_lost(sp_session *)
{
    qDebug() << "Play token lost";
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 13)));
}

static void SP_CALLCONV callback_log_message(sp_session *, const char *data)
{
    fprintf(stderr, "%s\n", data);
}

static void SP_CALLCONV callback_offline_error(sp_session *, sp_error error)
{
    qDebug() << "Offline error " << QString::fromUtf8(sp_error_message(error));
    if (error != SP_ERROR_OK)
        QCoreApplication::postEvent(QSpotifySession::instance(), new QSpotifyOfflineErrorEvent(error, QString::fromUtf8(sp_error_message(error))));
}

QSpotifySession::QSpotifySession()
    : QObject(0)
    , m_timerID(0)
    , m_sp_session(nullptr)
    , m_connectionStatus(LoggedOut)
    , m_connectionError(Ok)
    , m_connectionRules(AllowSyncOverWifi | AllowNetworkIfRoaming)
    , m_streamingQuality(Unknown)
    , m_syncQuality(Unknown)
    , m_syncOverMobile(false)
    , m_user(nullptr)
    , m_pending_connectionRequest(false)
    , m_isLoggedIn(false)
    , m_explicitLogout(false)
    , m_offlineMode(false)
    , m_forcedOfflineMode(false)
    , m_ignoreNextConnectionError(false)
    , m_playQueue(new QSpotifyPlayQueue)
    , m_currentTrack(nullptr)
    , m_isPlaying(false)
    , m_currentTrackPosition(0)
    , m_currentTrackPlayedDuration(0)
    , m_shuffle(false)
    , m_repeat(false)
    , m_repeatOne(false)
{
    connect(qApp, SIGNAL(aboutToQuit()), this, SLOT(cleanUp()));

    m_networkConfManager = new QNetworkConfigurationManager;
    connect(m_networkConfManager, SIGNAL(onlineStateChanged(bool)), this, SLOT(onOnlineChanged()));
    connect(m_networkConfManager, SIGNAL(onlineStateChanged(bool)), this, SIGNAL(isOnlineChanged()));
    connect(m_networkConfManager, SIGNAL(configurationChanged(QNetworkConfiguration)), this, SIGNAL(isOnlineChanged()));
    connect(m_networkConfManager, SIGNAL(configurationChanged(QNetworkConfiguration)), this, SLOT(configurationChanged()));

    m_audioThread = new QSpotifyAudioThread;
    m_audioThread->start(QThread::HighestPriority);

    // Resource management stuff
    m_resourceSet = new ResourcePolicy::ResourceSet(QLatin1String("player"), 0, false, true);
    m_audioResource = new ResourcePolicy::AudioResource(QLatin1String("player"));
    m_audioResource->setProcessID(QCoreApplication::applicationPid());
    m_audioResource->setStreamTag(QLatin1String("media.name"), QLatin1String("*"));
    m_audioResource->setOptional(false);
    m_resourceSet->addResourceObject(m_audioResource);
    m_resourceSet->addResourceObject(new ResourcePolicy::ScaleButtonResource);
    connect(m_resourceSet, SIGNAL(resourcesGranted(QList<ResourcePolicy::ResourceType>)), this, SLOT(resourceAcquiredHandler(QList<ResourcePolicy::ResourceType>)));
    connect(m_resourceSet, SIGNAL(lostResources()), this, SLOT(resourceLostHandler()));
    QCoreApplication::instance()->installEventFilter(this);
}

void QSpotifySession::init()
{
    m_sp_callbacks.logged_in = callback_logged_in;
    m_sp_callbacks.logged_out = callback_logged_out;
    m_sp_callbacks.metadata_updated = callback_metadata_updated;
    m_sp_callbacks.connection_error = callback_connection_error;
    m_sp_callbacks.message_to_user = 0;
    m_sp_callbacks.notify_main_thread = callback_notify_main_thread;
    m_sp_callbacks.music_delivery = callback_music_delivery;
    m_sp_callbacks.play_token_lost = callback_play_token_lost;
    m_sp_callbacks.log_message = callback_log_message;
    m_sp_callbacks.end_of_track = callback_end_of_track;
    m_sp_callbacks.streaming_error = 0;
    m_sp_callbacks.userinfo_updated = callback_userinfo_updated;
    m_sp_callbacks.start_playback = 0;
    m_sp_callbacks.stop_playback = 0;
    m_sp_callbacks.get_audio_buffer_stats = 0;
    m_sp_callbacks.offline_status_updated = 0;
    m_sp_callbacks.offline_error = callback_offline_error;
    m_sp_callbacks.credentials_blob_updated = 0;

    memset(&m_sp_config, 0, sizeof(m_sp_config));
    m_sp_config.api_version = SPOTIFY_API_VERSION;
    m_sp_config.cache_location = "/home/nemo/.local/share/CuteSpotify";
    m_sp_config.settings_location = "/home/nemo/.local/share/CuteSpotify";
    m_sp_config.application_key = g_appkey;
    m_sp_config.application_key_size = g_appkey_size;
    m_sp_config.user_agent = "CuteSpotify";
    m_sp_config.callbacks = &m_sp_callbacks;
    sp_error error = sp_session_create(&m_sp_config, &m_sp_session);

    if (error != SP_ERROR_OK)
    {
        fprintf(stderr, "failed to create session: %s\n",
                sp_error_message(error));

        m_sp_session = nullptr;
        return;
    }

    QStorageInfo storageInfo;
    qlonglong totalSpace = storageInfo.totalDiskSpace(QString::fromLatin1(m_sp_config.cache_location));
    sp_session_set_cache_size(m_sp_session, totalSpace / 1000000 - 1000);

    QSettings settings;

    // Remove stored login information from older version of MeeSpot
    if (settings.contains("username")) {
        settings.remove("username");
        settings.remove("password");
    }

    m_offlineMode = settings.value("offlineMode", false).toBool();
    m_invertedTheme = settings.value("invertedTheme", true).toBool();

    checkNetworkAccess();

    StreamingQuality quality = StreamingQuality(settings.value("streamingQuality", int(LowQuality)).toInt());
    setStreamingQuality(quality);

    StreamingQuality syncQuality = StreamingQuality(settings.value("syncQuality", int(HighQuality)).toInt());
    setSyncQuality(syncQuality);

    bool syncMobile = settings.value("syncOverMobile", false).toBool();
    setSyncOverMobile(syncMobile);

    QString storedLogin = getStoredLoginInformation();
    if (!storedLogin.isEmpty()) {
        login(storedLogin);
    }

    bool shuffle = settings.value("shuffle", false).toBool();
    setShuffle(shuffle);

    bool repeat = settings.value("repeat", false).toBool();
    setRepeat(repeat);

    bool repeatOne = settings.value("repeatOne", false).toBool();
    setRepeatOne(repeatOne);

    m_volume = settings.value("volume", 50).toInt();

    connect(this, SIGNAL(offlineModeChanged()), m_playQueue, SLOT(onOfflineModeChanged()));
}

QSpotifySession::~QSpotifySession()
{
}

QSpotifySession *QSpotifySession::instance()
{
    qDebug() << "QSpotifySession::instance";
    if (!m_instance) {
        m_instance = new QSpotifySession;
        m_instance->init();
    }
    return m_instance;
}

void QSpotifySession::cleanUp()
{
    qDebug() << "QSpotifySession::cleanUp";
    stop();
    m_audioThread->quit();
    m_audioThread->wait();
    logout(true);
    sp_session_release(m_sp_session);
    delete m_playQueue;
    delete m_networkConfManager;
    delete m_audioThread;
    delete m_user;
}

bool QSpotifySession::eventFilter(QObject *obj, QEvent *e)
{
    if(e->type() == QEvent::KeyPress) {
        QKeyEvent *ek = dynamic_cast<QKeyEvent *>(e);
        int key = ek->key();
        if (key == Qt::Key_VolumeUp || key == Qt::Key_VolumeDown) {
            if (key == Qt::Key_VolumeUp && m_volume <= 90) {
                m_volume += 10;
            } else if (key == Qt::Key_VolumeDown && m_volume >= 10) {
                m_volume -= 10;
            }
            setVolume(m_volume);
            e->accept();
            return true;
        }
    }

    return QObject::eventFilter(obj, e);
}

void QSpotifySession::setVolume(int vol)
{
    QCoreApplication::postEvent(g_audioWorker, new QSpotifyVolumeEvent(vol));
    QSettings settings;
    settings.setValue("volume", vol);
    emit volumeChanged();
}

bool QSpotifySession::event(QEvent *e)
{
    if (e->type() == QEvent::User) {
        qDebug() << "Process spotify event";
        processSpotifyEvents();
        e->accept();
        return true;
    } else if (e->type() == QEvent::Timer) {
        qDebug() << "Timer, start spotify events";
        QTimerEvent *te = static_cast<QTimerEvent *>(e);
        if (te->timerId() == m_timerID) {
            processSpotifyEvents();
            e->accept();
            return true;
        }
    } else if (e->type() == QEvent::User + 1) {
        qDebug() << "Connection error";
        // ConnectionError event
        QSpotifyConnectionErrorEvent *ev = static_cast<QSpotifyConnectionErrorEvent *>(e);
        setConnectionError(ConnectionError(ev->error()), ev->message());
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 2) {
        qDebug() << "Meta data";
        // Metadata event
        emit metadataUpdated();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 4) {
        qDebug() << "End track";
        // End of track event
        playNext(m_repeatOne);
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 5) {
        qDebug() << "Stop";
        stop();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 10) {
        qDebug() << "Track progress";
        // Track progressed
        QSpotifyTrackProgressEvent *ev = static_cast<QSpotifyTrackProgressEvent *>(e);
        m_currentTrackPosition += ev->delta();
        m_currentTrackPlayedDuration += ev->delta();
        emit currentTrackPositionChanged();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 11) {
        qDebug() << "Send image request";
        QSpotifyRequestImageEvent *ev = static_cast<QSpotifyRequestImageEvent *>(e);
        sendImageRequest(ev->imageId());
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 12) {
        qDebug() << "Receive image request";
        QSpotifyReceiveImageEvent *ev = static_cast<QSpotifyReceiveImageEvent *>(e);
        receiveImageResponse(ev->image());
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 13) {
        qDebug() << "Play token lost";
        // Play Token Lost
        emit playTokenLost();
        pause();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 14) {
        // LoggedIn
        qDebug() << "Logged in 1";
        onLoggedIn();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 15) {
        qDebug() << "Logged out";
        // LoggedOut
        onLoggedOut();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 16) {
        qDebug() << "Offline error";
        // Offline error
        QSpotifyOfflineErrorEvent *ev = static_cast<QSpotifyOfflineErrorEvent *>(e);
        m_offlineErrorMessage = ev->message();
        emit offlineErrorMessageChanged();
        e->accept();
        return true;
    }
    return QObject::event(e);
}

void QSpotifySession::processSpotifyEvents()
{
    qDebug() << "QSpotifySession::processSpotifyEvents";
    if (m_timerID)
        killTimer(m_timerID);

    int nextTimeout = 0;

    do {
        assert(isValid());

        qDebug() << "Processing events...";
        sp_session_process_events(m_sp_session, &nextTimeout);
        // update connection state
        setConnectionStatus(ConnectionStatus(sp_session_connectionstate(m_sp_session)));
        if (m_offlineMode && m_connectionStatus == LoggedIn) {
            setConnectionRule(AllowNetwork, true);
            setConnectionRule(AllowNetwork, false);
        }
    } while (nextTimeout == 0);
    m_timerID = startTimer(nextTimeout);
}

void QSpotifySession::setStreamingQuality(StreamingQuality q)
{
    qDebug() << "QSpotifySession::setStreamingQuality";
    if (m_streamingQuality == q)
        return;

    m_streamingQuality = q;
    QSettings s;
    s.setValue("streamingQuality", int(q));
    sp_session_preferred_bitrate(m_sp_session, sp_bitrate(q));

    emit streamingQualityChanged();
}

void QSpotifySession::setSyncQuality(StreamingQuality q)
{
    qDebug() << "QSpotifySession::setSyncQuality";
    if (m_syncQuality == q)
        return;

    m_syncQuality = q;
    QSettings s;
    s.setValue("syncQuality", int(q));
    sp_session_preferred_offline_bitrate(m_sp_session, sp_bitrate(q), true);

    emit syncQualityChanged();
}

void QSpotifySession::setInvertedTheme(bool inverted)
{
    qDebug() << "QSpotifySession::setInvertedTheme";
    if (m_invertedTheme == inverted)
        return;

    m_invertedTheme = inverted;
    QSettings s;
    s.setValue("invertedTheme", inverted);

    emit invertedThemeChanged();
}

void QSpotifySession::onLoggedIn()
{
    qDebug() << "Logged in";
    if (m_user)
        return;

    m_isLoggedIn = true;
    m_user = new QSpotifyUser(sp_session_user(m_sp_session));

    m_pending_connectionRequest = false;
    emit pendingConnectionRequestChanged();
    emit isLoggedInChanged();

    checkNetworkAccess();
    qDebug() << "Done";
}

void QSpotifySession::onLoggedOut()
{
    qDebug() << "QSpotifySession::onLoggedOut";
    if (!m_explicitLogout)
        return;

    delete m_user;
    m_user = 0;
    m_explicitLogout = false;
    m_isLoggedIn = false;

    m_pending_connectionRequest = false;
    emit pendingConnectionRequestChanged();
    emit isLoggedInChanged();
}

void QSpotifySession::setConnectionStatus(ConnectionStatus status)
{
    qDebug() << "QSpotifySession::setConnectionStatus";
    if (m_connectionStatus == status)
        return;

    m_connectionStatus = status;
    emit connectionStatusChanged();
}

void QSpotifySession::setConnectionError(ConnectionError error, const QString &message)
{
    qDebug() << "QSpotifySession::setConnectionError";
    if (error == Ok || m_offlineMode)
        return;

    if (m_pending_connectionRequest) {
        m_pending_connectionRequest = false;
        emit pendingConnectionRequestChanged();
    }

    if (error == UnableToContactServer && m_ignoreNextConnectionError) {
        m_ignoreNextConnectionError = false;
        return;
    }

    if (error == UnableToContactServer) {
        setOfflineMode(true, true);
    }

    m_connectionError = error;
    m_connectionErrorMessage = message;
    if (error != Ok && m_currentTrack && !m_currentTrack->isAvailableOffline())
        pause();
    emit connectionErrorChanged();
}

void QSpotifySession::login(const QString &username, const QString &password)
{
    qDebug() << "QSpotifySession::login";
    if (!isValid() || m_isLoggedIn || m_pending_connectionRequest)
        return;

    m_pending_connectionRequest = true;
    emit pendingConnectionRequestChanged();
    emit loggingIn();

    if (password.isEmpty()) {
        qDebug() << "Relogin";
        sp_session_relogin(m_sp_session);
    } else {
        qDebug() << "Fresh login";
        sp_session_login(m_sp_session, username.toUtf8().constData(), password.toUtf8().constData(), true, NULL);
    }
}

void QSpotifySession::logout(bool keepLoginInfo)
{
    qDebug() << "QSpotifySession::logout";
    if (!m_isLoggedIn || m_pending_connectionRequest)
        return;

    stop();
    m_playQueue->clear();

    if (!keepLoginInfo) {
        setOfflineMode(false);
        sp_session_forget_me(m_sp_session);
    }

    m_explicitLogout = true;

    m_pending_connectionRequest = true;
    emit pendingConnectionRequestChanged();
    emit loggingOut();
    sp_session_logout(m_sp_session);
}

void QSpotifySession::setShuffle(bool s)
{
    qDebug() << "QSpotifySession::setShuffle";
    if (m_shuffle == s)
        return;

    QSettings settings;
    settings.setValue("shuffle", s);
    m_playQueue->setShuffle(s);
    m_shuffle = s;
    emit shuffleChanged();
}

void QSpotifySession::setRepeat(bool r)
{
    qDebug() << "QSpotifySession::setRepeat";
    if (m_repeat == r)
        return;

    QSettings s;
    s.setValue("repeat", r);
    m_playQueue->setRepeat(r);
    m_repeat = r;
    emit repeatChanged();
}

void QSpotifySession::setRepeatOne(bool r)
{
    qDebug() << "QSpotifySession::setRepeatOne";
    if (m_repeatOne == r)
        return;

    QSettings s;
    s.setValue("repeatOne", r);
    m_repeatOne = r;
    emit repeatOneChanged();
}

void QSpotifySession::play(QSpotifyTrack *track)
{
    qDebug() << "QSpotifySession::play";
    if (track->error() != QSpotifyTrack::Ok || !track->isAvailable() || m_currentTrack == track)
        return;

    if (m_currentTrack)
        stop(true);

    if (!track->seen())
        track->setSeen(true);

    sp_error error = sp_session_player_load(m_sp_session, track->m_sp_track);
    if (error != SP_ERROR_OK) {
        fprintf(stderr, "failed to load track: %s\n",
                sp_error_message(error));
        return;
    }
    m_currentTrack = track;
    m_currentTrackPosition = 0;
    m_currentTrackPlayedDuration = 0;
    emit currentTrackChanged();
    emit currentTrackPositionChanged();

    beginPlayBack();
    m_resourceSet->acquire();
}

void QSpotifySession::beginPlayBack()
{
    qDebug() << "QSpotifySession::beginPlayBack";
    sp_session_player_play(m_sp_session, true);
    m_isPlaying = true;
    emit isPlayingChanged();

    QCoreApplication::postEvent(g_audioWorker, new QEvent(QEvent::Type(QEvent::User + 6)));
}

void QSpotifySession::pause()
{
    qDebug() << "QSpotifySession::pause";
    if (!m_isPlaying)
        return;

    sp_session_player_play(m_sp_session, false);
    m_isPlaying = false;
    emit isPlayingChanged();

    QCoreApplication::postEvent(g_audioWorker, new QEvent(QEvent::Type(QEvent::User + 7)));

    m_resourceSet->release();
}

void QSpotifySession::resume()
{
    qDebug () << "QSpotifySession::resume";
    if (m_isPlaying || !m_currentTrack)
        return;

    beginPlayBack();
    m_resourceSet->acquire();
}

void QSpotifySession::stop(bool dontEmitSignals)
{
    qDebug() << "QSpotifySession::stop";
    if (!m_isPlaying && !m_currentTrack)
        return;

    sp_session_player_unload(m_sp_session);
    m_isPlaying = false;
    m_currentTrack = 0;
    m_currentTrackPosition = 0;
    m_currentTrackPlayedDuration = 0;

    if (!dontEmitSignals) {
        emit isPlayingChanged();
        emit currentTrackChanged();
        emit currentTrackPositionChanged();
    }

    QCoreApplication::postEvent(g_audioWorker, new QEvent(QEvent::Type(QEvent::User + 8)));

    m_resourceSet->release();
}

void QSpotifySession::seek(int offset)
{
    qDebug () << "QSpotifySession::seek";
    if (!m_currentTrack)
        return;

    sp_session_player_seek(m_sp_session, offset);

    m_currentTrackPosition = offset;
    emit currentTrackPositionChanged();

    QCoreApplication::postEvent(g_audioWorker, new QEvent(QEvent::Type(QEvent::User + 9)));
}

void QSpotifySession::playNext(bool repeat)
{
    qDebug() << "QSpotifySession::playNext";
    m_playQueue->playNext(repeat);
}

void QSpotifySession::playPrevious()
{
    qDebug() << "QSpotifySession::playPrevious";
    m_playQueue->playPrevious();
}

void QSpotifySession::enqueue(QSpotifyTrack *track)
{
    qDebug() << "QSpotifySession::enqieue";
    m_playQueue->enqueueTrack(track);
}

void QSpotifySession::resourceAcquiredHandler(const QList<ResourcePolicy::ResourceType> &)
{
    beginPlayBack();
}

void QSpotifySession::resourceLostHandler()
{
    pause();
}

QString QSpotifySession::formatDuration(qint64 d) const
{
    qDebug() << "QSpotifySession::formatDuration";
    d /= 1000;
    int s = d % 60;
    d /= 60;
    int m = d % 60;
    int h = d / 60;

    QString r;
    if (h > 0)
        r += QString::number(h) + QLatin1String(":");
    r += QLatin1String(m > 9 || h == 0 ? "" : "0") + QString::number(m) + QLatin1String(":");
    r += QLatin1String(s > 9 ? "" : "0") + QString::number(s);

    return r;
}

QString QSpotifySession::getStoredLoginInformation() const
{
    qDebug() << "QSpotifySession::getStoredLoginInformation";
    QString username;
    char buffer[200];
    int size = sp_session_remembered_user(m_sp_session, &buffer[0], 200);
    if (size > 0) {
        username = QString::fromUtf8(&buffer[0], size);
    }
    return username;
}

QImage QSpotifySession::requestSpotifyImage(const QString &id)
{
    qDebug() << "QSpotifySession::requestSpotifyImage";
    g_imageRequestMutex.lock();
    g_imageRequestConditions.insert(id, new QWaitCondition);
    QCoreApplication::postEvent(this, new QSpotifyRequestImageEvent(id));
    g_imageRequestConditions[id]->wait(&g_imageRequestMutex);
    delete g_imageRequestConditions.take(id);

    QImage im = g_imageRequestImages.take(id);

    g_imageRequestMutex.unlock();

    return im;
}

static void SP_CALLCONV callback_image_loaded(sp_image *image, void *)
{
    qDebug() << "callback_image_loaded";
    QCoreApplication::postEvent(QSpotifySession::instance(), new QSpotifyReceiveImageEvent(image));
}

void QSpotifySession::sendImageRequest(const QString &id)
{
    qDebug() << "QSpotifySession::sendImageRequest";
    sp_link *link = sp_link_create_from_string(id.toUtf8().constData());
    sp_image *image = sp_image_create_from_link(m_sp_session, link);
    sp_link_release(link);

    g_imageRequestObject.insert(image, id);
    sp_image_add_load_callback(image, callback_image_loaded, 0);
}

void QSpotifySession::receiveImageResponse(sp_image *image)
{
    qDebug() << "QSpotifySession::receiveImageResponse";
    sp_image_remove_load_callback(image, callback_image_loaded, 0);

    QString id = g_imageRequestObject.take(image);
    QImage im;
    if (sp_image_error(image) == SP_ERROR_OK) {
        size_t dataSize;
        const void *data = sp_image_data(image, &dataSize);
        im = QImage::fromData(reinterpret_cast<const uchar *>(data), dataSize, "JPG");
    }

    sp_image_release(image);

    g_imageRequestMutex.lock();
    g_imageRequestImages.insert(id, im);
    g_imageRequestConditions[id]->wakeAll();
    g_imageRequestMutex.unlock();
}

bool QSpotifySession::isOnline() const
{
    qDebug() << "QSpotifySession::isOnline";
    return m_networkConfManager->isOnline();
}

void QSpotifySession::onOnlineChanged()
{
    qDebug() << "QSpotifySession::onOnlineChanged";
    checkNetworkAccess();
}

void QSpotifySession::configurationChanged()
{
    qDebug() << "QSpotifySession::configurationChanged";
    checkNetworkAccess();
}

void QSpotifySession::checkNetworkAccess()
{
    qDebug() << "QSpotifySession::checkNetworkAccess";
    if (!m_networkConfManager->isOnline()) {
        sp_session_set_connection_type(m_sp_session, SP_CONNECTION_TYPE_NONE);
        setOfflineMode(true, true);
    } else {
        bool wifi = false;
        bool mobile = false;
        bool roaming = false;
        QList<QNetworkConfiguration> confs = m_networkConfManager->allConfigurations(QNetworkConfiguration::Active);
        for (int i = 0; i < confs.count(); ++i) {
            QString bearer = QLatin1String("WLAN"); //confs.at(i).bearerName(); // TODO: Fix
            if (bearer == QLatin1String("WLAN")) {
                wifi = true;
                break;
            }
            if (bearer == QLatin1String("2G")
                    || bearer == QLatin1String("CDMA2000")
                    || bearer == QLatin1String("WCDMA")
                    || bearer == QLatin1String("HSPA")
                    || bearer == QLatin1String("WiMAX")) {
                mobile = true;
            }
            if (confs.at(i).isRoamingAvailable())
                roaming = true;
        }

        sp_connection_type type;
        if (wifi)
            type = SP_CONNECTION_TYPE_WIFI;
        else if (roaming)
            type = SP_CONNECTION_TYPE_MOBILE_ROAMING;
        else if (mobile)
            type = SP_CONNECTION_TYPE_MOBILE;
        else
            type = SP_CONNECTION_TYPE_UNKNOWN;

        sp_session_set_connection_type(m_sp_session, type);

        if (m_forcedOfflineMode)
            setOfflineMode(false, true);
        else
            setConnectionRule(AllowNetwork, !m_offlineMode);
    }
}

void QSpotifySession::setConnectionRules(ConnectionRules r)
{
    qDebug() << "QSpotifySession::setConnectionRules";
    if (m_connectionRules == r)
        return;

    m_connectionRules = r;
    sp_session_set_connection_rules(m_sp_session, sp_connection_rules(int(m_connectionRules)));
    emit connectionRulesChanged();
}

void QSpotifySession::setConnectionRule(ConnectionRule r, bool on)
{
    qDebug() << "QSpotifySession::setConnectionRule";
    ConnectionRules oldRules = m_connectionRules;
    if (on)
        m_connectionRules |= r;
    else
        m_connectionRules &= ~r;

    if (m_connectionRules != oldRules) {
        sp_session_set_connection_rules(m_sp_session, sp_connection_rules(int(m_connectionRules)));
        emit connectionRulesChanged();
    }
}

void QSpotifySession::setOfflineMode(bool on, bool forced)
{
    qDebug() << "QSpotifySession::setOfflineMode";
    if (m_offlineMode == on)
        return;

    m_offlineMode = on;

    if (m_offlineMode && m_currentTrack && !m_currentTrack->isAvailableOffline())
        stop();

    if (!forced) {
        QSettings s;
        s.setValue("offlineMode", m_offlineMode);

        if (m_offlineMode)
            m_ignoreNextConnectionError = true;
    }

    m_forcedOfflineMode = forced && on;

    setConnectionRule(AllowNetwork, !on);

    emit offlineModeChanged();
}

void QSpotifySession::setSyncOverMobile(bool s)
{
    qDebug() << "QSpotifySession::setSyncOverMobile";
    if (m_syncOverMobile == s)
        return;

    m_syncOverMobile = s;

    QSettings settings;
    settings.setValue("syncOverMobile", m_syncOverMobile);

    setConnectionRule(AllowSyncOverMobile, s);
    emit syncOverMobileChanged();
}
