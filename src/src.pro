
TEMPLATE = app
TARGET = CuteSpotify

QT += \
    concurrent \
    multimedia \
    qml \
    quick \
    systeminfo \
    widgets

SOURCES += \
    lastfmscrobbler.cpp \
    main.cpp

HEADERS += \
    lastfmscrobbler.h

RESOURCES += \
    ../res.qrc

QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic -Wl,-rpath=/opt/click.ubuntu.com/com.mikeasoft.cutespotify/current/lib/ -Llibspotify/lib/

isEmpty(PREFIX) {
    PREFIX = /usr/local
}

target.path = $$PREFIX/bin
INSTALLS += target

include(../libQtSpotify/libQtSpotify.pri)
include(../liblastfm/liblastfm.pri)
