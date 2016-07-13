TEMPLATE = app

QT += qml quick widgets

WALLET_ROOT=$$PWD/bitmonero

CONFIG += c++11

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
    oshelper.h


SOURCES += main.cpp \
    filter.cpp \
    clipboardAdapter.cpp \
    oscursor.cpp \
    src/libwalletqt/WalletManager.cpp \
    src/libwalletqt/Wallet.cpp \
    src/libwalletqt/PendingTransaction.cpp \
    src/libwalletqt/TransactionHistory.cpp \
    src/libwalletqt/TransactionInfo.cpp \
    oshelper.cpp

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

unix {
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



# translations files;
TRANSLATIONS = monero-core_en.ts \ # English (could be untranslated)
               monero-core_de.ts  # Deutsch


# extra make targets for lupdate and lrelease invocation
# use "make lupdate" to update *.ts files and "make lrelease" to generate *.qm files
lupdate.commands = lupdate $$_PRO_FILE_
lupdate.depends = $$SOURCES $$HEADERS 
lrelease.commands = lrelease $$_PRO_FILE_
lrelease.depends = lupdate
translate.commands = $(COPY) *.qm ${DESTDIR}
translate.depends = lrelease

QMAKE_EXTRA_TARGETS += lupdate lrelease



CONFIG(release, debug|release) {
   DESTDIR=release
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
    monero-core_de.ts \
    monero-core_en.ts

DISTFILES += \
    notes.txt
