
QT += network xml

INCLUDEPATH += $$PWD

HEADERS += \
    $$PWD/ScrobblerSubmission.h \
    $$PWD/ScrobblerHttp.h \
    $$PWD/ScrobblePoint.h \
    $$PWD/ScrobbleCache.h \
    $$PWD/Scrobble.h \
    $$PWD/NowPlaying.h \
    $$PWD/Audioscrobbler.h \
    $$PWD/global.h \
    $$PWD/Track.h \
    $$PWD/Album.h \
    $$PWD/Artist.h \
    $$PWD/ws.h \
    $$PWD/misc.h \
    $$PWD/NetworkAccessManager.h \
    $$PWD/lastfm_key.h \
    $$PWD/XmlQuery.h

SOURCES += \
    $$PWD/ScrobblerSubmission.cpp \
    $$PWD/ScrobblerHttp.cpp \
    $$PWD/ScrobbleCache.cpp \
    $$PWD/Scrobble.cpp \
    $$PWD/NowPlaying.cpp \
    $$PWD/Audioscrobbler.cpp \
    $$PWD/Track.cpp \
    $$PWD/ws.cpp \
    $$PWD/misc.cpp \
    $$PWD/NetworkAccessManager.cpp \
    $$PWD/XmlQuery.cpp
