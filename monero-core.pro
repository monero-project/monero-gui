TEMPLATE = app

QT += qml quick widgets

WALLET_ROOT=$$PWD/monero

CONFIG += c++11

# cleaning "auto-generated" bitmonero directory on "make distclean"
QMAKE_DISTCLEAN += -r $$WALLET_ROOT

INCLUDEPATH += $$WALLET_ROOT/include \
                $$PWD/src/libwalletqt \
                $$PWD/src/QR-Code-generator \
                $$PWD/src

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
    oshelper.h \
    TranslationManager.h \
    src/model/TransactionHistoryModel.h \
    src/model/TransactionHistorySortFilterModel.h \
    src/QR-Code-generator/BitBuffer.hpp \
    src/QR-Code-generator/QrCode.hpp \
    src/QR-Code-generator/QrSegment.hpp


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
    src/QR-Code-generator/QrSegment.cpp

lupdate_only {
SOURCES = *.qml \
          components/*.qml \
          pages/*.qml \
          wizard/*.qml \
          wizard/*js
}

LIBS += -L$$WALLET_ROOT/lib \
        -lwallet_merged \
        -lunbound


# currently we only support x86 build as qt.io only provides prebuilt qt for x86 mingw

win32 {

    contains(QMAKE_HOST.arch, x86_64) {
        message("Host is 64bit")
        MSYS_PATH=c:/msys64/mingw32
    } else {
        message("Host is 32bit")
        MSYS_PATH=c:/msys32/mingw32
    }

    !contains(QMAKE_TARGET.arch, x86_64) {
        message("Target is 32bit")
        ## Windows x86 (32bit) specific build here
        ## there's 2Mb stack in libwallet allocated internally, so we set stack=4Mb
        ## this fixes app crash for x86 Windows build
        QMAKE_LFLAGS += -Wl,--stack,4194304
    } else {
        message("Target is 64bit")
    }

    LIBS+=-L$$MSYS_PATH/lib

    LIBS+= \
        -Wl,-Bstatic \
        -lboost_serialization-mt \
        -lboost_thread-mt \
        -lboost_system-mt \
        -lboost_date_time-mt \
        -lboost_filesystem-mt \
        -lboost_regex-mt \
        -lboost_chrono-mt \
        -lboost_program_options-mt \
        -lssl \
        -lcrypto \
        -Wl,-Bdynamic \
        -lws2_32 \
        -lwsock32 \
        -lIphlpapi \
        -lgdi32



}

linux {
    CONFIG(static) {
        LIBS+= -Wl,-Bstatic
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
        -lcrypto \
        -Wl,-Bdynamic \
        -ldl
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
                $$PWD/translations/monero-core_de.ts \ # Deutsch
                $$PWD/translations/monero-core_zh.ts \ # Chineese
                $$PWD/translations/monero-core_ru.ts \ # Russian
                $$PWD/translations/monero-core_it.ts \ # Italian
                $$PWD/translations/monero-core_pl.ts \ # Polish

CONFIG(release, debug|release) {
    DESTDIR = release/bin
    LANGUPD_OPTIONS = -locations relative -no-ui-lines
    LANGREL_OPTIONS = -compress -nounfinished -removeidentical

} else {
    DESTDIR = debug/bin
    LANGUPD_OPTIONS =
    LANGREL_OPTIONS = -markuntranslated "MISS_TR "
}

TARGET_FULL_PATH = $$OUT_PWD/$$DESTDIR
TRANSLATION_TARGET_DIR = $$TARGET_FULL_PATH/translations

macx {
    TARGET_FULL_PATH = $$sprintf("%1/%2/%3.app", $$OUT_PWD, $$DESTDIR, $$TARGET)
    TRANSLATION_TARGET_DIR = $$TARGET_FULL_PATH/Contents/Resources/translations
}



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



# Update: no issues with the "slow link process" anymore,
# for development, just build debug version of libwallet_merged lib
# by invoking 'get_libwallet_api.sh Debug'
# so we update translations everytime even for debug build

PRE_TARGETDEPS += langupd compiler_langrel_make_all


RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
macx {
    deploy.commands += macdeployqt $$sprintf("%1/%2/%3.app", $$OUT_PWD, $$DESTDIR, $$TARGET) -qmldir=$$PWD
}

win32 {
    deploy.commands += windeployqt $$sprintf("%1/%2/%3.exe", $$OUT_PWD, $$DESTDIR, $$TARGET) -release -qmldir=$$PWD
}



OTHER_FILES += \
    .gitignore \
    $$TRANSLATIONS

DISTFILES += \
    notes.txt


# windows application icon
RC_FILE = monero-core.rc

# mac application icon
ICON = $$PWD/images/appicon.icns
