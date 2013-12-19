#ifndef QSPOTIFYEVENTS_H
#define QSPOTIFYEVENTS_H

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


class QSpotifyVolumeEvent : public QEvent
{
public:
    QSpotifyVolumeEvent(int vol)
        : QEvent(Type(QEvent::User + 20))
        , m_vol(vol)
    { }

    int volume() const { return m_vol; }

private:
    int m_vol;
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

class QSpotifyOfflineErrorEvent : public QEvent
{
public:
    QSpotifyOfflineErrorEvent(sp_error error, const QString &message)
        : QEvent(Type(QEvent::User + 16))
        , m_error(error)
        , m_message(message)
    { }

    sp_error error() const { return m_error; }
    QString message() const { return m_message; }

private:
    sp_error m_error;
    QString m_message;
};

#endif // QSPOTIFYEVENTS_H
