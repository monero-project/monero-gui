TEMPLATE = app

QT += qml quick widgets

HEADERS += \
    filter.h \
    clipboardAdapter.h


SOURCES += main.cpp \
    filter.cpp \
    clipboardAdapter.cpp

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

# copy language files (xml and images) to the output directory
copydata.commands = $(COPY_DIR) $$shell_path($$PWD/lang) $$shell_path($$DESTDIR/lang)
QMAKE_EXTRA_TARGETS += copydata
POST_TARGETDEPS += copydata
