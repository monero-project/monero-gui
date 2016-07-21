TEMPLATE = app

QT += qml quick widgets

WALLET_ROOT=$$PWD/bitmonero

CONFIG += c++11

# cleaning "auto-generated" bitmonero directory on "make clean"
QMAKE_CLEAN += -r $$WALLET_ROOT

INCLUDEPATH += $$WALLET_ROOT/include \
                $$PWD/src/libwalletqt



HEADERS += \
    filter.h \
    clipboardAdapter.h \
    oscursor.h \
    src/libwalletqt/WalletManager.h \
    src/libwalletqt/Wallet.h \
    src/libwalletqt/PendingTransaction.h \
    src/libwalletqt/TransactionHistory.h \
    src/libwalletqt/TransactionInfo.h \
    oshelper.h \
    TranslationManager.h


SOURCES += main.cpp \
    filter.cpp \
    clipboardAdapter.cpp \
    oscursor.cpp \
    src/libwalletqt/WalletManager.cpp \
    src/libwalletqt/Wallet.cpp \
    src/libwalletqt/PendingTransaction.cpp \
    src/libwalletqt/TransactionHistory.cpp \
    src/libwalletqt/TransactionInfo.cpp \
    oshelper.cpp \
    TranslationManager.cpp

lupdate_only {
SOURCES = *.qml \
          components/*.qml \
          pages/*.qml \
          wizard/*.qml
}

LIBS += -L$$WALLET_ROOT/lib \
        -lwallet_merged \
        -lwallet_merged2

win32 {
    #QMAKE_LFLAGS += -static
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
    LIBS+= \
        -Wl,-Bstatic \
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
}

macx {
    LIBS+= \
	-L/usr/local/lib \
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



# translations files;
TRANSLATIONS = $$PWD/translations/monero-core_en.ts \ # English (could be untranslated)
                   $$PWD/translations/monero-core_de.ts \ # Deutsch
                   $$PWD/translations/monero-core_zh.ts \ # Chineese
                   $$PWD/translations/monero-core_ru.ts \ # Russian
                   $$PWD/translations/monero-core_it.ts \ # Italian
                   $$PWD/translations/monero-core_pl.ts \ # Polish



# extra make targets for lupdate and lrelease invocation
# use "make lupdate" to update *.ts files and "make lrelease" to generate *.qm files
trans_update.commands = lupdate $$_PRO_FILE_
trans_update.depends = $$_PRO_FILE_

trans_release.commands = lrelease $$_PRO_FILE_
trans_release.depends = trans_update $$TRANSLATIONS

#translate.commands = $(MKDIR) ${DESTDIR}/i18n && $(COPY) $$PWD/translations/*.qm ${DESTDIR}/i18n
translate.depends = trans_release

QMAKE_EXTRA_TARGETS += trans_update trans_release translate

# updating transations only in release mode as this is requires to re-link project
# even if no changes were made.

#PRE_TARGETDEPS += translate

CONFIG(release, debug|release) {
   DESTDIR=release
   PRE_TARGETDEPS += translate
}

CONFIG(debug, debug|release) {
   DESTDIR=debug
}


RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)




OTHER_FILES += \
    .gitignore \
    $$TRANSLATIONS

DISTFILES += \
    notes.txt
