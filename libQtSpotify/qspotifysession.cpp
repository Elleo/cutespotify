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
#include "qspotifyuser.h"
#include "qspotifytrack.h"
#include "qspotifytracklist.h"
#include "qspotifyplayqueue.h"
#include "qspotifyalbum.h"
#include "qspotifyartist.h"
#include "spotify_key.h"

#include <QtCore/QHash>
#include <QtCore/QEvent>
#include <QtCore/QCoreApplication>
#include <QtMultimediaKit/QAudioOutput>
#include <QtCore/QIODevice>
#include <QtCore/QBuffer>
#include <QtCore/QMutexLocker>
#include <QtCore/QDebug>
#include <QtGui/QDesktopServices>
#include <QtNetwork/QNetworkConfigurationManager>

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

QSpotifySession *QSpotifySession::m_instance = 0;


class QSpotifyConnectionErrorEvent : public QEvent
{
public:
    QSpotifyConnectionErrorEvent(sp_error error, const QString &message)
        : QEvent(Type(QEvent::User + 1))
        , m_error(error)
        , m_message(message)
    { }

    sp_error error() const { return m_error; }
    QString message() const { return m_message; }

private:
    sp_error m_error;
    QString m_message;
};


class QSpotifyStreamingStartedEvent : public QEvent
{
public:
    QSpotifyStreamingStartedEvent(int channels, int sampleRate)
        : QEvent(Type(QEvent::User + 3))
        , m_channels(channels)
        , m_sampleRate(sampleRate)
    { }

    int channels() const { return m_channels; }
    int sampleRate() const { return m_sampleRate; }

private:
    int m_channels;
    int m_sampleRate;
};


class QSpotifyTrackProgressEvent : public QEvent
{
public:
    QSpotifyTrackProgressEvent(int delta)
        : QEvent(Type(QEvent::User + 10))
        , m_delta(delta)
    { }

    int delta() const { return m_delta; }

private:
    int m_delta;
};

class QSpotifyRequestImageEvent : public QEvent
{
public:
    QSpotifyRequestImageEvent(const QString &id)
        : QEvent(Type(User + 11))
        , m_id(id)
    { }

    QString imageId() const { return m_id; }

private:
    QString m_id;
};

class QSpotifyReceiveImageEvent : public QEvent
{
public:
    QSpotifyReceiveImageEvent(sp_image *image)
        : QEvent(Type(User + 12))
        , m_image(image)
    { }

    sp_image *image() const { return m_image; }

private:
    sp_image *m_image;
};


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
    if (!m_audioOutput) {
        QAudioFormat af;
        af.setChannelCount(channels);
        af.setCodec("audio/pcm");
        af.setSampleRate(sampleRate);
        af.setSampleSize(16);
        af.setSampleType(QAudioFormat::SignedInt);

        QAudioDeviceInfo info(QAudioDeviceInfo::defaultOutputDevice());
        if (!info.isFormatSupported(af)) {
            qWarning()<<"raw audio format not supported by backend, cannot play audio.";
            QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 5)));
            return;
        }

        m_audioOutput = new QAudioOutput(af);
        m_audioOutput->setBufferSize(BUFFER_SIZE);
        qDebug() << m_audioOutput->bufferSize();
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
    g_audioWorker = new QSpotifyAudioThreadWorker;
    exec();
    delete g_audioWorker;
}


static void callback_logged_in(sp_session *, sp_error error)
{
    QCoreApplication::postEvent(QSpotifySession::instance(), new QSpotifyConnectionErrorEvent(error, QString::fromUtf8(sp_error_message(error))));
    if (error == SP_ERROR_OK)
        QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 14)));
}

static void callback_logged_out(sp_session *)
{
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 15)));
}

static void callback_connection_error(sp_session *, sp_error error)
{
    QCoreApplication::postEvent(QSpotifySession::instance(), new QSpotifyConnectionErrorEvent(error, QString::fromUtf8(sp_error_message(error))));
}

static void callback_notify_main_thread(sp_session *)
{
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::User));
}

static void callback_metadata_updated(sp_session *)
{
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 2)));
}

static void callback_userinfo_updated(sp_session* )
{
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 2)));
}

static int callback_music_delivery(sp_session *, const sp_audioformat *format, const void *frames, int num_frames)
{
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

static void callback_end_of_track(sp_session *)
{
    QCoreApplication::postEvent(g_audioWorker, new QEvent(QEvent::Type(QEvent::User + 4)));
}

static void callback_play_token_lost(sp_session *)
{
    QCoreApplication::postEvent(QSpotifySession::instance(), new QEvent(QEvent::Type(QEvent::User + 13)));
}

static void callback_log_message(sp_session *, const char *data)
{
    fprintf(stderr, data);
}

QSpotifySession::QSpotifySession()
    : QObject(0)
    , m_timerID(0)
    , m_connectionStatus(LoggedOut)
    , m_connectionError(Ok)
    , m_connectionRules(AllowSyncOverWifi | AllowNetworkIfRoaming)
    , m_streamingQuality(Unknown)
    , m_syncQuality(Unknown)
    , m_syncOverMobile(false)
    , m_user(0)
    , m_pending_connectionRequest(false)
    , m_isLoggedIn(false)
    , m_explicitLogout(false)
    , m_offlineMode(false)
    , m_forcedOfflineMode(false)
    , m_ignoreNextConnectionError(false)
    , m_playQueue(new QSpotifyPlayQueue)
    , m_currentTrack(0)
    , m_isPlaying(false)
    , m_currentTrackPosition(0)
    , m_shuffle(false)
    , m_repeat(false)
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
    connect(m_resourceSet, SIGNAL(resourcesGranted(QList<ResourcePolicy::ResourceType>)), this, SLOT(resourceAcquiredHandler(QList<ResourcePolicy::ResourceType>)));
    connect(m_resourceSet, SIGNAL(lostResources()), this, SLOT(resourceLostHandler()));
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

    m_sp_config.api_version = SPOTIFY_API_VERSION;
    m_sp_config.cache_location = "/home/user/MyDocs/.meespot";
    m_sp_config.settings_location = "/home/user/MyDocs/.meespot";
    m_sp_config.application_key = g_appkey;
    m_sp_config.application_key_size = g_appkey_size;
    m_sp_config.user_agent = "MeeSpot";
    m_sp_config.callbacks = &m_sp_callbacks;
    sp_error error = sp_session_create(&m_sp_config, &m_sp_session);
    if (error != SP_ERROR_OK) {
        fprintf(stderr, "failed to create session: %s\n",
                sp_error_message(error));
    } else {
        QSettings settings;

        // Remove stored login information from older version of MeeSpot
        if (settings.contains("username")) {
            settings.remove("username");
            settings.remove("password");
        }

        m_offlineMode = settings.value("offlineMode", false).toBool();

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
    }
}

QSpotifySession::~QSpotifySession()
{
}

QSpotifySession *QSpotifySession::instance()
{
    if (!m_instance) {
        m_instance = new QSpotifySession;
        m_instance->init();
    }
    return m_instance;
}

void QSpotifySession::cleanUp()
{
    stop();
    delete m_playQueue;
    m_audioThread->quit();
    m_audioThread->wait();
    delete m_audioThread;
    delete m_user;
    logout(true);
    sp_session_release(m_sp_session);
    delete m_resourceSet;
    delete m_networkConfManager;
}

bool QSpotifySession::event(QEvent *e)
{
    if (e->type() == QEvent::User) {
        processSpotifyEvents();
        e->accept();
        return true;
    } else if (e->type() == QEvent::Timer) {
        QTimerEvent *te = static_cast<QTimerEvent *>(e);
        if (te->timerId() == m_timerID) {
            processSpotifyEvents();
            e->accept();
            return true;
        }
    } else if (e->type() == QEvent::User + 1) {
        // ConnectionError event
        QSpotifyConnectionErrorEvent *ev = static_cast<QSpotifyConnectionErrorEvent *>(e);
        setConnectionError(ConnectionError(ev->error()), ev->message());
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 2) {
        // Metadata event
        emit metadataUpdated();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 4) {
        // End of track event
        playNext();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 5) {
        stop();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 10) {
        // Track progressed
        QSpotifyTrackProgressEvent *ev = static_cast<QSpotifyTrackProgressEvent *>(e);
        m_currentTrackPosition += ev->delta();
        emit currentTrackPositionChanged();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 11) {
        QSpotifyRequestImageEvent *ev = static_cast<QSpotifyRequestImageEvent *>(e);
        sendImageRequest(ev->imageId());
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 12) {
        QSpotifyReceiveImageEvent *ev = static_cast<QSpotifyReceiveImageEvent *>(e);
        receiveImageResponse(ev->image());
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 13) {
        // Play Token Lost
        emit playTokenLost();
        pause();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 14) {
        // LoggedIn
        onLoggedIn();
        e->accept();
        return true;
    } else if (e->type() == QEvent::User + 15) {
        // LoggedOut
        onLoggedOut();
        e->accept();
        return true;
    }
    return QObject::event(e);
}

void QSpotifySession::processSpotifyEvents()
{
    if (m_timerID)
        killTimer(m_timerID);
    int nextTimeout;
    do {
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
    if (m_syncQuality == q)
        return;

    m_syncQuality = q;
    QSettings s;
    s.setValue("syncQuality", int(q));
    sp_session_preferred_offline_bitrate(m_sp_session, sp_bitrate(q), false);

    emit syncQualityChanged();
}

void QSpotifySession::onLoggedIn()
{
    if (m_user)
        return;

    m_isLoggedIn = true;
    m_user = new QSpotifyUser(sp_session_user(m_sp_session));

    m_pending_connectionRequest = false;
    emit pendingConnectionRequestChanged();
    emit isLoggedInChanged();

    checkNetworkAccess();
}

void QSpotifySession::onLoggedOut()
{
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
    if (m_connectionStatus == status)
        return;

    m_connectionStatus = status;
    emit connectionStatusChanged();
}

void QSpotifySession::setConnectionError(ConnectionError error, const QString &message)
{
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
    if (!isValid() || m_isLoggedIn || m_pending_connectionRequest)
        return;

    m_pending_connectionRequest = true;
    emit pendingConnectionRequestChanged();
    emit loggingIn();

    if (password.isEmpty())
        sp_session_relogin(m_sp_session);
    else
        sp_session_login(m_sp_session, username.toLatin1().constData(), password.toLatin1().constData(), true);
}

void QSpotifySession::logout(bool keepLoginInfo)
{
    if (!m_isLoggedIn || m_pending_connectionRequest)
        return;

    stop();
    m_playQueue->clear();

    if (!keepLoginInfo)
        sp_session_forget_me(m_sp_session);

    m_explicitLogout = true;

    m_pending_connectionRequest = true;
    emit pendingConnectionRequestChanged();
    emit loggingOut();
    sp_session_logout(m_sp_session);
}

void QSpotifySession::setShuffle(bool s)
{
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
    if (m_repeat == r)
        return;

    QSettings s;
    s.setValue("repeat", r);
    m_playQueue->setRepeat(r);
    m_repeat = r;
    emit repeatChanged();
}

void QSpotifySession::play(QSpotifyTrack *track)
{
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
    emit currentTrackChanged();
    emit currentTrackPositionChanged();

    m_resourceSet->acquire();
}

void QSpotifySession::beginPlayBack()
{
    sp_session_player_play(m_sp_session, true);
    m_isPlaying = true;
    emit isPlayingChanged();

    QCoreApplication::postEvent(g_audioWorker, new QEvent(QEvent::Type(QEvent::User + 6)));
}

void QSpotifySession::pause()
{
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
    if (m_isPlaying || !m_currentTrack)
        return;

    m_resourceSet->acquire();
}

void QSpotifySession::stop(bool dontEmitSignals)
{
    if (!m_isPlaying && !m_currentTrack)
        return;

    sp_session_player_unload(m_sp_session);
    m_isPlaying = false;
    m_currentTrack = 0;
    m_currentTrackPosition = 0;

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
    if (!m_currentTrack)
        return;

    sp_session_player_seek(m_sp_session, offset);

    m_currentTrackPosition = offset;
    emit currentTrackPositionChanged();

    QCoreApplication::postEvent(g_audioWorker, new QEvent(QEvent::Type(QEvent::User + 9)));
}

void QSpotifySession::playNext()
{
    m_playQueue->playNext();
}

void QSpotifySession::playPrevious()
{
    m_playQueue->playPrevious();
}

void QSpotifySession::enqueue(QSpotifyTrack *track)
{
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
    d /= 1000;
    int s = d % 60;
    d /= 60;
    int m = d % 60;
    int h = d / 60;

    QString r;
    if (h > 0)
        r += QString::number(h) + QLatin1String(":");
    r += QLatin1String(m > 9 ? "" : "0") + QString::number(m) + QLatin1String(":");
    r += QLatin1String(s > 9 ? "" : "0") + QString::number(s);

    return r;
}

QString QSpotifySession::getStoredLoginInformation() const
{
    QString username;
    char buffer[200];
    int size = sp_session_remembered_user(m_sp_session, &buffer[0], 200);
    if (size > 0) {
        username = QString::fromLatin1(&buffer[0], size);
    }
    return username;
}

QImage QSpotifySession::requestSpotifyImage(const QString &id)
{
    g_imageRequestMutex.lock();
    g_imageRequestConditions.insert(id, new QWaitCondition);
    QCoreApplication::postEvent(this, new QSpotifyRequestImageEvent(id));
    g_imageRequestConditions[id]->wait(&g_imageRequestMutex);
    delete g_imageRequestConditions.take(id);

    QImage im = g_imageRequestImages.take(id);

    g_imageRequestMutex.unlock();

    return im;
}

static void callback_image_loaded(sp_image *image, void *)
{
    QCoreApplication::postEvent(QSpotifySession::instance(), new QSpotifyReceiveImageEvent(image));
}

void QSpotifySession::sendImageRequest(const QString &id)
{
    sp_link *link = sp_link_create_from_string(id.toLatin1().constData());
    sp_image *image = sp_image_create_from_link(m_sp_session, link);
    sp_link_release(link);

    g_imageRequestObject.insert(image, id);
    sp_image_add_load_callback(image, callback_image_loaded, 0);
}

void QSpotifySession::receiveImageResponse(sp_image *image)
{
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
    return m_networkConfManager->isOnline();
}

void QSpotifySession::onOnlineChanged()
{
    checkNetworkAccess();
}

void QSpotifySession::configurationChanged()
{
    checkNetworkAccess();
}

void QSpotifySession::checkNetworkAccess()
{
    if (!m_networkConfManager->isOnline()) {
        sp_session_set_connection_type(m_sp_session, SP_CONNECTION_TYPE_NONE);
        setOfflineMode(true, true);
    } else {
        bool wifi = false;
        bool mobile = false;
        bool roaming = false;
        QList<QNetworkConfiguration> confs = m_networkConfManager->allConfigurations(QNetworkConfiguration::Active);
        for (int i = 0; i < confs.count(); ++i) {
            QString bearer = confs.at(i).bearerName();
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
    if (m_connectionRules == r)
        return;

    m_connectionRules = r;
    sp_session_set_connection_rules(m_sp_session, sp_connection_rules(int(m_connectionRules)));
    emit connectionRulesChanged();
}

void QSpotifySession::setConnectionRule(ConnectionRule r, bool on)
{
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
    if (m_syncOverMobile == s)
        return;

    m_syncOverMobile = s;

    QSettings settings;
    settings.setValue("syncOverMobile", m_syncOverMobile);

    setConnectionRule(AllowSyncOverMobile, s);
    emit syncOverMobileChanged();
}
