# Rules for building translations.

TRANSLATIONS = $$files($$PWD/translations/monero-core_*.ts)
TRANSLATION_TARGET_DIR = $$OUT_PWD/translations

CONFIG(release, debug|release) {
    LANGUPD_OPTIONS = -locations relative -no-ui-lines
    LANGREL_OPTIONS = -compress -nounfinished -removeidentical
}

TRANSLATION_TARGET_DIR = $$OUT_PWD/translations

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

    QMAKE_EXTRA_TARGETS += langupd
    QMAKE_EXTRA_COMPILERS += langrel

    # Compile an initial version of translation files when running qmake
    # the first time and generate the resource file for translations.
    !exists($$TRANSLATION_TARGET_DIR) {
        mkpath($$TRANSLATION_TARGET_DIR)
    }
    qrc_entry = "<RCC>"
    qrc_entry += '  <qresource prefix="/">'
    write_file($$TRANSLATION_TARGET_DIR/translations.qrc, qrc_entry)
    for(tsfile, TRANSLATIONS) {
        qmfile = $$TRANSLATION_TARGET_DIR/$$basename(tsfile)
        qmfile ~= s/.ts$/.qm/
        system($$LANGREL $$LANGREL_OPTIONS $$tsfile -qm $$qmfile)
        qrc_entry = "    <file>$$basename(qmfile)</file>"
        write_file($$TRANSLATION_TARGET_DIR/translations.qrc, qrc_entry, append)
    }
    qrc_entry = "  </qresource>"
    qrc_entry += "</RCC>"
    write_file($$TRANSLATION_TARGET_DIR/translations.qrc, qrc_entry, append)
    RESOURCES += $$TRANSLATION_TARGET_DIR/translations.qrc
}


# Update: no issues with the "slow link process" anymore,
# for development, just build debug version of libwallet_merged lib
# by invoking 'get_libwallet_api.sh Debug'
# so we update translations everytime even for debug build

PRE_TARGETDEPS += langupd compiler_langrel_make_all

lupdate_only {
SOURCES = *.qml \
          components/*.qml \
          pages/*.qml \
          wizard/*.qml \
          wizard/*js
}
