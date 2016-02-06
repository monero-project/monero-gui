TEMPLATE = app

QT += qml quick widgets

HEADERS += \
    filter.h \
    clipboardAdapter.h \
    oscursor.h


SOURCES += main.cpp \
    filter.cpp \
    clipboardAdapter.cpp \
    oscursor.cpp

lupdate_only {
SOURCES = *.qml \
          components/*.qml \
          pages/*.qml \
          wizard/*.qml
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






