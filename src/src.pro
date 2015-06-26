TARGET = harbour-cutespot

QT += \
    concurrent \
    multimedia \
    qml \
    quick

DEFINES += APP_VERSION=\\\"$$VERSION\\\"

SOURCES += \
    main.cpp \
    customiconprovider.cpp

RESOURCES += \
    ../res.qrc

QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic -Wl,-rpath=/usr/share/harbour-cutespot/lib/ -Llibspotify/lib/

isEmpty(PREFIX) {
    PREFIX = /usr/
}

CONFIG += link_pkgconfig
PKGCONFIG += sailfishapp
INCLUDEPATH += /usr/include/sailfishapp

lib.path = $$PREFIX/share/harbour-cutespot/lib/
ARCH = $$QMAKE_HOST.arch
equals(ARCH, armv7l) {
lib.files = ../libspotify/lib/lib*
} else {
lib.files = ../libspotify_emu/lib/lib*
}
qtpulse.path = $$PREFIX/share/harbour-cutespot/lib/audio/
qtpulse.files = ../libspotify/lib/audio/*
desktop.path = $$PREFIX/share/applications/
desktop.files = ../harbour-cutespot.desktop
icon.path = $$PREFIX/share/icons/hicolor/86x86/apps/
icon.files = ../harbour-cutespot.png
target.path = $$PREFIX/bin
INSTALLS += target desktop lib icon qtpulse

include(../libQtSpotify/libQtSpotify.pri)

HEADERS += \
    customiconprovider.h
