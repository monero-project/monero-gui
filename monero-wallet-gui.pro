TEMPLATE = app

QT += qml quick widgets

WALLET_ROOT=$$PWD/monero

CONFIG += c++11

# cleaning "auto-generated" bitmonero directory on "make distclean"
QMAKE_DISTCLEAN += -r $$WALLET_ROOT

INCLUDEPATH +=  $$WALLET_ROOT/include \
                $$PWD/src/libwalletqt \
                $$PWD/src/QR-Code-generator \
                $$PWD/src \
                $$WALLET_ROOT/src

HEADERS += \
    filter.h \
    clipboardAdapter.h \
    oscursor.h \
    src/libwalletqt/WalletManager.h \
    src/libwalletqt/Wallet.h \
    src/libwalletqt/PendingTransaction.h \
    src/libwalletqt/TransactionHistory.h \
    src/libwalletqt/TransactionInfo.h \
    src/libwalletqt/QRCodeImageProvider.h \
    src/libwalletqt/Transfer.h \
    oshelper.h \
    TranslationManager.h \
    src/model/TransactionHistoryModel.h \
    src/model/TransactionHistorySortFilterModel.h \
    src/QR-Code-generator/BitBuffer.hpp \
    src/QR-Code-generator/QrCode.hpp \
    src/QR-Code-generator/QrSegment.hpp \
    src/model/AddressBookModel.h \
    src/libwalletqt/AddressBook.h \
    src/zxcvbn-c/zxcvbn.h \
    src/libwalletqt/UnsignedTransaction.h \
    MainApp.h

SOURCES += main.cpp \
    filter.cpp \
    clipboardAdapter.cpp \
    oscursor.cpp \
    src/libwalletqt/WalletManager.cpp \
    src/libwalletqt/Wallet.cpp \
    src/libwalletqt/PendingTransaction.cpp \
    src/libwalletqt/TransactionHistory.cpp \
    src/libwalletqt/TransactionInfo.cpp \
    src/libwalletqt/QRCodeImageProvider.cpp \
    oshelper.cpp \
    TranslationManager.cpp \
    src/model/TransactionHistoryModel.cpp \
    src/model/TransactionHistorySortFilterModel.cpp \
    src/QR-Code-generator/BitBuffer.cpp \
    src/QR-Code-generator/QrCode.cpp \
    src/QR-Code-generator/QrSegment.cpp \
    src/model/AddressBookModel.cpp \
    src/libwalletqt/AddressBook.cpp \
    src/zxcvbn-c/zxcvbn.c \
    src/libwalletqt/UnsignedTransaction.cpp \
    MainApp.cpp

!ios {
    HEADERS += src/daemon/DaemonManager.h
    SOURCES += src/daemon/DaemonManager.cpp
}

lupdate_only {
SOURCES = *.qml \
          components/*.qml \
          pages/*.qml \
          wizard/*.qml \
          wizard/*js
}


ios:armv7 {
    message("target is armv7")
    LIBS += \
        -L$$PWD/../ofxiOSBoost/build/libs/boost/lib/armv7 \
}
ios:arm64 {
    message("target is arm64")
    LIBS += \
        -L$$PWD/../ofxiOSBoost/build/libs/boost/lib/arm64 \
}
!ios {
LIBS += -L$$WALLET_ROOT/lib \
        -lwallet_merged \
        -lepee \
        -lunbound \
        -leasylogging \
        -lreadline \
}


ios {
    message("Host is IOS")

    QMAKE_LFLAGS += -v
    QMAKE_IOS_DEVICE_ARCHS = arm64
    CONFIG += arm64
    LIBS += -L$$WALLET_ROOT/lib-ios \
        -lwallet_merged \
        -lepee \
        -lunbound

    LIBS+= \
        -L$$PWD/../OpenSSL-for-iPhone/lib \
        -L$$PWD/../ofxiOSBoost/build/libs/boost/lib/arm64 \
        -lboost_serialization \
        -lboost_thread \
        -lboost_system \
        -lboost_date_time \
        -lboost_filesystem \
        -lboost_regex \
        -lboost_chrono \
        -lboost_program_options \
        -lssl \
        -lcrypto \
        -ldl
}

CONFIG(WITH_SCANNER) {
    if( greaterThan(QT_MINOR_VERSION, 5) ) {
        message("using camera scanner")
        QT += multimedia
        DEFINES += "WITH_SCANNER"
        INCLUDEPATH += $$PWD/src/QR-Code-scanner
        HEADERS += \
            src/QR-Code-scanner/QrScanThread.h \
            src/QR-Code-scanner/QrCodeScanner.h
        SOURCES += \
            src/QR-Code-scanner/QrScanThread.cpp \
            src/QR-Code-scanner/QrCodeScanner.cpp
        android {
            INCLUDEPATH += $$PWD/../ZBar/include
            LIBS += -lzbarjni -liconv
        } else {
            LIBS += -lzbar
        }
    } else {
        message("Skipping camera scanner because of Incompatible Qt Version !")
    }
}


# currently we only support x86 build as qt.io only provides prebuilt qt for x86 mingw

win32 {

    # QMAKE_HOST.arch is unreliable, will allways report 32bit if mingw32 shell is run.
    # Obtaining arch through uname should be reliable. This also fixes building the project in Qt creator without changes.
    MSYS_HOST_ARCH = $$system(uname -a | grep -o "x86_64")

    # WIN64 Host settings
    contains(MSYS_HOST_ARCH, x86_64) {
        message("Host is 64bit")
        MSYS_ROOT_PATH=c:/msys64

    # WIN32 Host settings
    } else {
        message("Host is 32bit")
        MSYS_ROOT_PATH=c:/msys32
    }

    # WIN64 Target settings
    contains(QMAKE_HOST.arch, x86_64) {
        MSYS_MINGW_PATH=/mingw64

    # WIN32 Target settings
    } else {
        MSYS_MINGW_PATH=/mingw32
    }
    
    MSYS_PATH=$$MSYS_ROOT_PATH$$MSYS_MINGW_PATH

    # boost root path
    BOOST_PATH=$$MSYS_PATH/boost
    BOOST_MINGW_PATH=$$MSYS_MINGW_PATH/boost

    LIBS+=-L$$MSYS_PATH/lib
    LIBS+=-L$$MSYS_MINGW_PATH/lib
    LIBS+=-L$$BOOST_PATH/lib
    LIBS+=-L$$BOOST_MINGW_PATH/lib
    
    LIBS+= \
        -Wl,-Bstatic \
        -lboost_serialization-mt-s \
        -lboost_thread-mt-s \
        -lboost_system-mt-s \
        -lboost_date_time-mt-s \
        -lboost_filesystem-mt-s \
        -lboost_regex-mt-s \
        -lboost_chrono-mt-s \
        -lboost_program_options-mt-s \
        -lssl \
        -lcrypto \
        -Wl,-Bdynamic \
        -lws2_32 \
        -lwsock32 \
        -lIphlpapi \
        -lgdi32
    
    !contains(QMAKE_TARGET.arch, x86_64) {
        message("Target is 32bit")
        ## Windows x86 (32bit) specific build here
        ## there's 2Mb stack in libwallet allocated internally, so we set stack=4Mb
        ## this fixes app crash for x86 Windows build
        QMAKE_LFLAGS += -Wl,--stack,4194304
    } else {
        message("Target is 64bit")
    }

}

linux {
    CONFIG(static) {
        message("using static libraries")
        LIBS+= -Wl,-Bstatic    
        QMAKE_LFLAGS += -static-libgcc -static-libstdc++
   #     contains(QT_ARCH, x86_64) {
            LIBS+= -lunbound
   #     }
    } else {
      # On some distro's we need to add dynload
      LIBS+= -ldl
    }

    LIBS+= \
        -lboost_serialization \
        -lboost_thread \
        -lboost_system \
        -lboost_date_time \
        -lboost_filesystem \
        -lboost_regex \
        -lboost_chrono \
        -lboost_program_options \
        -lssl \
        -lcrypto

    if(!android) {
        LIBS+= \
            -Wl,-Bdynamic \
            -lGL
    }
    # currently monero has an issue with "static" build and linunwind-dev,
    # so we link libunwind-dev only for non-Ubuntu distros
    CONFIG(libunwind_off) {
        message(Building without libunwind)
    } else {
        message(Building with libunwind)
        LIBS += -Wl,-Bdynamic -lunwind
    }
}

macx {
    # mixing static and shared libs are not supported on mac
    # CONFIG(static) {
    #     message("using static libraries")
    #     LIBS+= -Wl,-Bstatic
    # }
    LIBS+= \
        -L/usr/local/lib \
        -L/usr/local/opt/openssl/lib \
        -L/usr/local/opt/boost/lib \
        -lboost_serialization \
        -lboost_thread-mt \
        -lboost_system \
        -lboost_date_time \
        -lboost_filesystem \
        -lboost_regex \
        -lboost_chrono \
        -lboost_program_options \
        -lssl \
        -lcrypto \
        -ldl

}


# translation stuff
TRANSLATIONS =  \ # English is default language, no explicit translation file
                $$PWD/translations/monero-core.ts \ # translation source (copy this file when creating a new translation)
                $$PWD/translations/monero-core_ar.ts \ # Arabic
                $$PWD/translations/monero-core_pt-br.ts \ # Portuguese (Brazil)
                $$PWD/translations/monero-core_de.ts \ # German
                $$PWD/translations/monero-core_eo.ts \ # Esperanto
                $$PWD/translations/monero-core_es.ts \ # Spanish
                $$PWD/translations/monero-core_fi.ts \ # Finnish
                $$PWD/translations/monero-core_fr.ts \ # French
                $$PWD/translations/monero-core_hr.ts \ # Croatian
                $$PWD/translations/monero-core_id.ts \ # Indonesian
                $$PWD/translations/monero-core_hi.ts \ # Hindi
                $$PWD/translations/monero-core_it.ts \ # Italian
                $$PWD/translations/monero-core_ja.ts \ # Japanese
                $$PWD/translations/monero-core_nl.ts \ # Dutch
                $$PWD/translations/monero-core_pl.ts \ # Polish
                $$PWD/translations/monero-core_ru.ts \ # Russian
                $$PWD/translations/monero-core_sv.ts \ # Swedish
                $$PWD/translations/monero-core_zh-cn.ts \ # Chinese (Simplified-China)
                $$PWD/translations/monero-core_zh-tw.ts \ # Chinese (Traditional-Taiwan)
                $$PWD/translations/monero-core_he.ts \ # Hebrew
                $$PWD/translations/monero-core_ko.ts \ # Korean
                $$PWD/translations/monero-core_ro.ts \ # Romanian

CONFIG(release, debug|release) {
    DESTDIR = release/bin
    LANGUPD_OPTIONS = -locations relative -no-ui-lines
    LANGREL_OPTIONS = -compress -nounfinished -removeidentical

} else {
    DESTDIR = debug/bin
    LANGUPD_OPTIONS =
#    LANGREL_OPTIONS = -markuntranslated "MISS_TR "
}

TARGET_FULL_PATH = $$OUT_PWD/$$DESTDIR
TRANSLATION_TARGET_DIR = $$TARGET_FULL_PATH/translations

macx {
    TARGET_FULL_PATH = $$sprintf("%1/%2/%3.app", $$OUT_PWD, $$DESTDIR, $$TARGET)
    TRANSLATION_TARGET_DIR = $$TARGET_FULL_PATH/Contents/Resources/translations
}


!ios {
    isEmpty(QMAKE_LUPDATE) {
        win32:LANGUPD = $$[QT_INSTALL_BINS]\lupdate.exe
        else:LANGUPD = $$[QT_INSTALL_BINS]/lupdate
    }

    isEmpty(QMAKE_LRELEASE) {
        win32:LANGREL = $$[QT_INSTALL_BINS]\lrelease.exe
        else:LANGREL = $$[QT_INSTALL_BINS]/lrelease
    }

    langupd.command = \
        $$LANGUPD $$LANGUPD_OPTIONS $$shell_path($$_PRO_FILE) -ts $$_PRO_FILE_PWD/$$TRANSLATIONS



    langrel.depends = langupd
    langrel.input = TRANSLATIONS
    langrel.output = $$TRANSLATION_TARGET_DIR/${QMAKE_FILE_BASE}.qm
    langrel.commands = \
        $$LANGREL $$LANGREL_OPTIONS ${QMAKE_FILE_IN} -qm $$TRANSLATION_TARGET_DIR/${QMAKE_FILE_BASE}.qm
    langrel.CONFIG += no_link

    QMAKE_EXTRA_TARGETS += langupd deploy deploy_win
    QMAKE_EXTRA_COMPILERS += langrel
}






# Update: no issues with the "slow link process" anymore,
# for development, just build debug version of libwallet_merged lib
# by invoking 'get_libwallet_api.sh Debug'
# so we update translations everytime even for debug build

PRE_TARGETDEPS += langupd compiler_langrel_make_all

RESOURCES += qml.qrc
CONFIG += qtquickcompiler

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
macx {
    deploy.commands += macdeployqt $$sprintf("%1/%2/%3.app", $$OUT_PWD, $$DESTDIR, $$TARGET) -qmldir=$$PWD
}

win32 {
    deploy.commands += windeployqt $$sprintf("%1/%2/%3.exe", $$OUT_PWD, $$DESTDIR, $$TARGET) -release -qmldir=$$PWD
    # Win64 msys2 deploy settings
    contains(QMAKE_HOST.arch, x86_64) {
        deploy.commands += $$escape_expand(\n\t) $$PWD/windeploy_helper.sh $$DESTDIR
    }
}

linux:!android {
    deploy.commands += $$escape_expand(\n\t) $$PWD/linuxdeploy_helper.sh $$DESTDIR $$TARGET
}

android{
    deploy.commands += make install INSTALL_ROOT=$$DESTDIR && androiddeployqt --input android-libmonero-wallet-gui.so-deployment-settings.json --output $$DESTDIR --deployment bundled --android-platform android-21 --jdk /usr/lib/jvm/java-8-openjdk-amd64 -qmldir=$$PWD
}


OTHER_FILES += \
    .gitignore \
    $$TRANSLATIONS

DISTFILES += \
    notes.txt \
    monero/src/wallet/CMakeLists.txt \
    components/MobileHeader.qml


# windows application icon
RC_FILE = monero-core.rc

# mac application icon
ICON = $$PWD/images/appicon.icns
