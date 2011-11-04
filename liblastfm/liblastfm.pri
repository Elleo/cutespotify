
QT += network xml

INCLUDEPATH += $$PWD

HEADERS += \
    liblastfm/ScrobblerSubmission.h \
    liblastfm/ScrobblerHttp.h \
    liblastfm/ScrobblePoint.h \
    liblastfm/ScrobbleCache.h \
    liblastfm/Scrobble.h \
    liblastfm/NowPlaying.h \
    liblastfm/Audioscrobbler.h \
    liblastfm/global.h \
    liblastfm/Track.h \
    liblastfm/Album.h \
    liblastfm/Artist.h \
    liblastfm/ws.h \
    liblastfm/misc.h \
    liblastfm/NetworkAccessManager.h \
    liblastfm/lastfm_key.h \
    liblastfm/XmlQuery.h

SOURCES += \
    liblastfm/ScrobblerSubmission.cpp \
    liblastfm/ScrobblerHttp.cpp \
    liblastfm/ScrobbleCache.cpp \
    liblastfm/Scrobble.cpp \
    liblastfm/NowPlaying.cpp \
    liblastfm/Audioscrobbler.cpp \
    liblastfm/Track.cpp \
    liblastfm/ws.cpp \
    liblastfm/misc.cpp \
    liblastfm/NetworkAccessManager.cpp \
    liblastfm/XmlQuery.cpp



























