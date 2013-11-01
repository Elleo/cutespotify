
QT += network
CONFIG       += mobility
MOBILITY += multimedia systeminfo

INCLUDEPATH += $$PWD

SOURCES += $$PWD/qspotifysession.cpp \
    $$PWD/qspotifyuser.cpp \
    $$PWD/qspotifyobject.cpp \
    $$PWD/qspotifytrack.cpp \
    $$PWD/qspotifyplaylist.cpp \
    $$PWD/qspotifyplaylistcontainer.cpp \
    $$PWD/qspotifytracklist.cpp \
    $$PWD/qspotifyartist.cpp \
    $$PWD/qspotifyalbum.cpp \
    $$PWD/qspotifyimageprovider.cpp \
    $$PWD/qspotifysearch.cpp \
    $$PWD/qspotifyplayqueue.cpp \
    $$PWD/qspotifyalbumbrowse.cpp \
    $$PWD/qspotifyartistbrowse.cpp \
    $$PWD/qspotifytoplist.cpp

HEADERS += $$PWD/qspotifysession.h \
    $$PWD/spotify_key.h \
    $$PWD/qspotifyuser.h \
    $$PWD/qspotifyobject.h \
    $$PWD/qspotifytrack.h \
    $$PWD/qspotifyplaylist.h \
    $$PWD/qspotifyplaylistcontainer.h \
    $$PWD/qspotifytracklist.h \
    $$PWD/QtSpotify \
    $$PWD/qspotify_qmlplugin.h \
    $$PWD/qspotifyartist.h \
    $$PWD/qspotifyalbum.h \
    $$PWD/qspotifyimageprovider.h \
    $$PWD/qspotifysearch.h \
    $$PWD/qspotifyplayqueue.h \
    $$PWD/qspotifyalbumbrowse.h \
    $$PWD/qspotifyartistbrowse.h \
    $$PWD/qspotifytoplist.h \
    ../libQtSpotify/qspotifyevents.h

QMAKE_CXXFLAGS += -std=c++11

INCLUDEPATH += $$PWD/../libspotify/include
LIBS += -L$$PWD/../libspotify/lib -lspotify

INCLUDEPATH += /usr/include/resource/qt4
PKGCONFIG += libresourceqt1






