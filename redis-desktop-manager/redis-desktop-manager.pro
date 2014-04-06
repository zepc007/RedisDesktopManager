#-------------------------------------------------
#
# Redis Desktop Manager
#
#-------------------------------------------------

QT       += core gui network xml concurrent

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = rdm
TEMPLATE = app

#CONFIG -= debug
#CONFIG += release

SOURCES += \
    $$PWD/source/main.cpp \
    $$PWD/source/application.cpp \
    $$PWD/source/connection.cpp \
    $$PWD/source/widgets/*.cpp \
    $$PWD/source/crashhandler/*.cpp \
    $$PWD/source/updater/Updater.cpp \
    $$PWD/source/redis/*.cpp \
    $$PWD/source/network/*.cpp \
    $$PWD/source/models/*.cpp \
    $$PWD/source/models/items/*.cpp \
    $$PWD/source/models/value-view-formatters/*.cpp \

HEADERS  += \
    $$PWD/version.h \
    $$PWD/Redis.h \
    $$PWD/include/*.h \
    $$PWD/include/widgets/*.h \
    $$PWD/include/crashhandler/*.h \
    $$PWD/include/updater/Updater.h \
    $$PWD/include/redis/*.h \
    $$PWD/include/network/*.h \
    $$PWD/include/models/*.h \
    $$PWD/include/models/items/*.h \
    $$PWD/include/models/value-view-formatters/*.h \


DEPSDIR = $$PWD/../deps/
BREAKPADDIR = $$DEPSDIR/google-breakpad/src

win32 {
    CONFIG += c++11

    INCLUDEPATH += $$BREAKPADDIR\client\windows\handler\
    INCLUDEPATH += $$BREAKPADDIR\common\windows\
    INCLUDEPATH += $$BREAKPADDIR\client\windows\crash_generation
    INCLUDEPATH += $$BREAKPADDIR\client\windows\common\
    INCLUDEPATH += $$BREAKPADDIR\google_breakpad\common\
    INCLUDEPATH += $$BREAKPADDIR\processor
    INCLUDEPATH += $$BREAKPADDIR\

    CONFIG(release, debug|release) {
        WIN_DEPS_PATH = $$DEPSDIR/libs/win32/release/
    } else: CONFIG(debug, debug|release) {
        WIN_DEPS_PATH = $$DEPSDIR/libs/win32/debug/
    }

    #message(Deps path: $$WIN_DEPS_PATH)

    LIBS += -L$$WIN_DEPS_PATH -llibssh2
    LIBS += -lcommon -lcrash_generation_client -lexception_handler -llibeay32 -lssleay32 -lzlib
    LIBS += -lws2_32 -lkernel32 -luser32 -lshell32 -luuid -lole32 -ladvapi32
    PRE_TARGETDEPS += $$WIN_DEPS_PATH/libssh2.lib

    release: DESTDIR = ./../bin/windows/release
    debug:   DESTDIR = ./../bin/windows/debug

    RC_FILE += $$PWD/resources/rdm.rc
}

unix {
    macx { # os x 10.8
        CONFIG += c++11
        #CONFIG-=app_bundle

        LIBS += /usr/local/lib/libssh2.dylib
        LIBS += $$BREAKPADDIR/client/mac/build/Release/Breakpad.framework/Versions/A/Breakpad
        PRE_TARGETDEPS += /usr/local/lib/libssh2.dylib  $$BREAKPADDIR/client/mac/build/Release/Breakpad.framework

        INCLUDEPATH += $$PWD/../deps/libssh/include

        QMAKE_INFO_PLIST =  $$PWD/resources/Info.plist
        ICON = rdm.icns

        INCLUDEPATH += $$BREAKPADDIR/ \
                        $$BREAKPADDIR/client/mac/handler/ \
                        $$BREAKPADDIR/client/mac/ \
                        $$BREAKPADDIR/client/ \
                        $$BREAKPADDIR/client/mac/crash_generation/ \
                        $$BREAKPADDIR/common/mac/ \
                        $$BREAKPADDIR/common/linux/ \
                        $$BREAKPADDIR/common/ \
                        $$BREAKPADDIR/processor/ \
                        $$BREAKPADDIR/google_breakpad/common/ \
                        $$BREAKPADDIR/third_party/lss/ \

        LIBS += /System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation
        LIBS += /System/Library/Frameworks/CoreServices.framework/Versions/A/CoreServices

        #breakpad app need debug info inside binaries
        QMAKE_CXXFLAGS+=-g

        APP_DATA_FILES.files = $$BREAKPADDIR/client/mac/build/Release/Breakpad.framework
        APP_DATA_FILES.path = Contents/Frameworks
        QMAKE_BUNDLE_DATA += APP_DATA_FILES

        CRASHREPORTER_APP.files = $$DESTDIR/crashreporter
        CRASHREPORTER_APP.path = Contents/MacOS
        QMAKE_BUNDLE_DATA += CRASHREPORTER_APP

    }
    else { # ubuntu & debian

        QMAKE_CXXFLAGS += -std=gnu++0x -g #workaround for google breakpad

        LIBS += -Wl,-rpath=\\\$$ORIGIN/../lib #don't remove!!!
        LIBS += /usr/local/lib/libssh2.so  /usr/local/lib/libbreakpad.a /usr/local/lib/libbreakpad_client.a

        PRE_TARGETDEPS +=/usr/local/lib/libssh2.so \
                         /usr/local/lib/libbreakpad.a \
                         /usr/local/lib/libbreakpad_client.a \

        INCLUDEPATH += $$BREAKPADDIR/ \
            $$BREAKPADDIR/client/linux/handler/ \
            $$BREAKPADDIR/client/linux/crash_generation/ \
            $$BREAKPADDIR/client/linux/minidump_writer/ \
            $$BREAKPADDIR/client/linux/log/ \
            $$BREAKPADDIR/client/ \
            $$BREAKPADDIR/common/linux/ \
            $$BREAKPADDIR/common/ \
            $$BREAKPADDIR/google_breakpad/common/ \
            $$BREAKPADDIR/processor/ \
            $$BREAKPADDIR/third_party/lss/ \

        DEPENDPATH += $$BREAKPADDIR/ \
            $$BREAKPADDIR/client/linux/handler/ \
            $$BREAKPADDIR/client/linux/crash_generation/ \
            $$BREAKPADDIR/client/linux/minidump_writer/ \
            $$BREAKPADDIR/client/linux/log/ \
            $$BREAKPADDIR/client/ \
            $$BREAKPADDIR/common/linux/ \
            $$BREAKPADDIR/common/ \
            $$BREAKPADDIR/google_breakpad/common/ \
            $$BREAKPADDIR/processor/ \
            $$BREAKPADDIR/third_party/lss/ \

        target.path = /usr/share/redis-desktop-manager/bin
        target.files = $$DESTDIR/rdm $$DESTDIR/crashreporter  $$PWD/resources/qt.conf  $$PWD/resources/rdm.png
        INSTALLS += target

        deskicon.path = /usr/share/applications
        deskicon.files =  $$PWD/resources/rdm.desktop
        INSTALLS += deskicon

        data.path = /usr/share/redis-desktop-manager/lib
        data.files = lib/*
        INSTALLS += data
    }

    release: DESTDIR = ./../bin/linux/release
    debug:   DESTDIR = ./../bin/linux/debug
    OBJECTS_DIR = $$DESTDIR/.obj
    MOC_DIR = $$DESTDIR/.moc
    RCC_DIR = $$DESTDIR/.qrc
    UI_DIR = $$DESTDIR/.ui
}

INCLUDEPATH += $$DEPSDIR/libssh/include
DEPENDPATH += $$DEPSDIR/libssh/include
DEPENDPATH += $$BREAKPADDIR

INCLUDEPATH += $$PWD/source \
    $$PWD/source/models \
    $$PWD/source/models/items \
    $$PWD/source/network \
    $$PWD/source/redis \
    $$PWD/source/updater \
    $$PWD/source/widgets \
    $$PWD/"include" \
    $$PWD/include/models \
    $$PWD/include/models/items \
    $$PWD/include/models/value-view-formatters \
    $$PWD/include/network \
    $$PWD/include/redis \
    $$PWD/include/updater \
    $$PWD/include/crashhandler \
    $$PWD/include/widgets \
    $$PWD/resourses \
    $$PWD/ \

FORMS += \
    $$PWD/forms/*.ui \

RESOURCES += \
    $$PWD/resources/rdm.qrc

OTHER_FILES += \
    qt.conf \
    Info.plist


