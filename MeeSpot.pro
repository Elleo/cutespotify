# Add more folders to ship with the application, here

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

QT+= qml quick widgets multimedia concurrent
symbian:TARGET.UID3 = 0xE119349A

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

CONFIG += qmsystem2

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    src/lastfmscrobbler.cpp
#    src/hardwarekeyshandler.cpp \

OTHER_FILES += \
    qml/MainPage.qml \
    qml/main.qml \
    MeeSpot.desktop \
    MeeSpot.png \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    MeeSpot.conf \
    qml/LoginPage.qml \
    qml/UIConstants.js \
    qml/PlaylistPage.qml \
    qml/TracklistPage.qml \
    qml/PlaylistDelegate.qml \
    qml/TrackDelegate.qml \
    qml/Player.qml \
    qml/QuickControls.qml \
    qml/FullControls.qml \
    qml/NotificationBanner.qml \
    qml/SettingsPage.qml \
    qml/ViewHeader.qml \
    qml/Selector.qml \
    qml/SearchPage.qml \
    qml/SpotifyImage.qml \
    qml/AdvancedTextField.qml \
    qml/Utilities.js \
    qml/TrackMenu.qml \
    qml/PlaylistMenu.qml \
    qml/MyMenuLayout.qml \
    qml/MyMenuItem.qml \
    qml/MyMenu.qml \
    qml/MyPopup.qml \
    qml/MyFader.qml \
    qml/PlaylistNameSheet.qml \
    qml/AlbumPage.qml \
    qml/AlbumHeader.qml \
    qml/AlbumTrackDelegate.qml \
    qml/AlbumMenu.qml \
    qml/ArtistPage.qml \
    qml/ArtistHeader.qml \
    qml/AlbumDelegate.qml \
    qml/ArtistDelegate.qml \
    qml/AboutDialog.qml \
    qml/MyMenuItemStyle.qml \
    qml/MySheet.qml \
    qml/InboxTrackDelegate.qml \
    qml/HeaderSearchField.qml \
    qml/Separator.qml \
    qtc_packaging/debian_harmattan/postrm \
    qml/ToplistPage.qml \
    qml/MySelectionDialog.qml \
    qml/MyCommonDialog.qml \
    qml/Scrollbar.qml \
    qml/LastfmLoginSheet.qml \
    qml/FolderPage.qml

RESOURCES += \
    res.qrc

# Please do not modify the following two lines. Required for deployment.
include(deployment.pri)
qtcAddDeployment()

include(libQtSpotify/libQtSpotify.pri)
include(liblastfm/liblastfm.pri)

QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic -Wl,-rpath,/opt/MeeSpot/lib

HEADERS += \
    src/lastfmscrobbler.h
#    src/hardwarekeyshandler.h


























