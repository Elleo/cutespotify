TARGET = CuteSpotify

QT += \
    concurrent \
    multimedia \
    qml \
    quick \
    systeminfo \
    widgets 

CONFIG += qmsystem2-qt5

HEADERS += \
    hardwarekeyshandler.h

SOURCES += \
    main.cpp \
    hardwarekeyshandler.cpp

RESOURCES += \
    ../res.qrc

QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic -Wl,-rpath=/usr/share/cutespotify/ -Llibspotify/lib/

isEmpty(PREFIX) {
    PREFIX = /usr/
}

CONFIG += link_pkgconfig
PKGCONFIG += sailfishapp
INCLUDEPATH += /usr/include/sailfishapp

lib.path = $$PREFIX/share/cutespotify/
lib.files = ../libspotify/lib/libspotify*
desktop.path = $$PREFIX/share/applications/
desktop.files = ../cutespotify.desktop
icon.path = $$PREFIX/share/icons/hicolor/90x90/apps/
icon.files = ../cutespotify.png
target.path = $$PREFIX/bin
INSTALLS += target desktop lib icon

include(../libQtSpotify/libQtSpotify.pri)
