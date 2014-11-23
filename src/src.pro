
TEMPLATE = app
TARGET = CuteSpotify

QT += \
    concurrent \
    multimedia \
    qml \
    quick \
    widgets

SOURCES += \
    main.cpp


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
