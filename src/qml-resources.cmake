file(GLOB GUI_ROOT_QML_FILES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/*.js"
    "${CMAKE_SOURCE_DIR}/*.qml"
)
file(GLOB_RECURSE GUI_DIRECTORY_QML_FILES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/components/*.qml"
    "${CMAKE_SOURCE_DIR}/fonts/FontAwesome/*.qml"
    "${CMAKE_SOURCE_DIR}/js/*.js"
    "${CMAKE_SOURCE_DIR}/pages/*.qml"
    "${CMAKE_SOURCE_DIR}/wizard/*.qml"
)
set(GUI_QML_FILES ${GUI_ROOT_QML_FILES} ${GUI_DIRECTORY_QML_FILES})

set(SCANNER_QML_FILE "${CMAKE_SOURCE_DIR}/components/QRCodeScanner.qml")
if(NOT WITH_SCANNER)
    list(REMOVE_ITEM GUI_QML_FILES "${SCANNER_QML_FILE}")
endif()

file(GLOB GUI_IMAGE_FILES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/images/*.ico"
    "${CMAKE_SOURCE_DIR}/images/*.png"
    "${CMAKE_SOURCE_DIR}/images/*.svg"
    "${CMAKE_SOURCE_DIR}/images/merchant/*.png"
    "${CMAKE_SOURCE_DIR}/images/themes/white/*.png"
)
file(GLOB GUI_FONT_FILES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/fonts/*.ttf"
    "${CMAKE_SOURCE_DIR}/fonts/FontAwesome/*.otf"
)
file(GLOB GUI_LANGUAGE_FILES CONFIGURE_DEPENDS
    "${CMAKE_SOURCE_DIR}/lang/flags/*.png"
)

set(GUI_ASSET_FILES
    ${GUI_IMAGE_FILES}
    ${GUI_FONT_FILES}
    ${GUI_LANGUAGE_FILES}
    "${CMAKE_SOURCE_DIR}/components/qmldir"
    "${CMAKE_SOURCE_DIR}/fonts/FontAwesome/qmldir"
    "${CMAKE_SOURCE_DIR}/images/themes/white/close.svg"
    "${CMAKE_SOURCE_DIR}/images/themes/white/fullscreen.svg"
    "${CMAKE_SOURCE_DIR}/images/themes/white/minimize.svg"
    "${CMAKE_SOURCE_DIR}/lang/languages.xml"
    "${CMAKE_SOURCE_DIR}/monero/utils/gpg_keys/binaryfate.asc"
    "${CMAKE_SOURCE_DIR}/monero/utils/gpg_keys/fluffypony.asc"
    "${CMAKE_SOURCE_DIR}/monero/utils/gpg_keys/luigi1111.asc"
    "${CMAKE_SOURCE_DIR}/qtquickcontrols2.conf"
    "${CMAKE_SOURCE_DIR}/wizard/template.pdf"
)

set(GUI_RESOURCE_ALIASES)
foreach(RESOURCE_FILE IN LISTS GUI_QML_FILES GUI_ASSET_FILES)
    if(NOT EXISTS "${RESOURCE_FILE}")
        message(FATAL_ERROR "Missing QML/resource file: ${RESOURCE_FILE}")
    endif()

    file(RELATIVE_PATH RESOURCE_ALIAS "${CMAKE_SOURCE_DIR}" "${RESOURCE_FILE}")
    if(RESOURCE_ALIAS IN_LIST GUI_RESOURCE_ALIASES)
        message(FATAL_ERROR "Duplicate QML/resource alias: ${RESOURCE_ALIAS}")
    endif()

    list(APPEND GUI_RESOURCE_ALIASES "${RESOURCE_ALIAS}")
    set_source_files_properties("${RESOURCE_FILE}" PROPERTIES
        QT_RESOURCE_ALIAS "${RESOURCE_ALIAS}"
    )
endforeach()

set(GUI_QML_SINGLETONS
    "${CMAKE_SOURCE_DIR}/fonts/FontAwesome/FontAwesome.qml"
    "${CMAKE_SOURCE_DIR}/components/Style.qml"
)
set_source_files_properties(${GUI_QML_FILES} PROPERTIES
    QT_QML_SKIP_QMLDIR_ENTRY TRUE
)
set_source_files_properties(${GUI_QML_SINGLETONS} PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)
set_source_files_properties("${CMAKE_SOURCE_DIR}/components/Style.qml" PROPERTIES
    QT_QML_SKIP_QMLDIR_ENTRY FALSE
)
