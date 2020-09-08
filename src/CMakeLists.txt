add_subdirectory(QR-Code-generator)
add_subdirectory(QR-Code-scanner)
add_subdirectory(daemon)
add_subdirectory(libwalletqt)
add_subdirectory(model)
add_subdirectory(openpgp)
add_subdirectory(zxcvbn-c)

qt5_add_resources(RESOURCES ../qml.qrc)

# Compile source files (.h/.cpp)
file(GLOB SOURCE_FILES
	"*.h"
	"*.cpp"
    "main/*.h"
    "main/*.cpp"
    "libwalletqt/WalletManager.cpp"
    "libwalletqt/WalletListenerImpl.cpp"
    "libwalletqt/Wallet.cpp"
    "libwalletqt/PassphraseHelper.cpp"
    "libwalletqt/PendingTransaction.cpp"
    "libwalletqt/TransactionHistory.cpp"
    "libwalletqt/TransactionInfo.cpp"
    "libwalletqt/QRCodeImageProvider.cpp" QR
    "QR-Code-generator/BitBuffer.cpp"
    "QR-Code-generator/QrCode.cpp"
    "QR-Code-generator/QrSegment.cpp"
    "libwalletqt/AddressBook.cpp"
    "libwalletqt/Subaddress.cpp"
    "libwalletqt/SubaddressAccount.cpp"
    "libwalletqt/UnsignedTransaction.cpp"
    "libwalletqt/WalletManager.h"
    "libwalletqt/Wallet.h"
    "libwalletqt/PassphraseHelper.h"
    "libwalletqt/PendingTransaction.h"
    "libwalletqt/TransactionHistory.h"
    "libwalletqt/TransactionInfo.h"
    "libwalletqt/QRCodeImageProvider.h"
    "QR-Code-generator/BitBuffer.h"
    "QR-Code-generator/QrCode.h"
    "QR-Code-generator/QrSegment.h"
    "libwalletqt/Transfer.h"
    "libwalletqt/AddressBook.h"
    "libwalletqt/Subaddress.h"
    "libwalletqt/SubaddressAccount.h"
    "libwalletqt/UnsignedTransaction.h"
    "daemon/*.h"
    "daemon/*.cpp"
    "model/*.h"
    "model/*.cpp"
    "qt/*.h"
    "qt/*.cpp"
)
if(APPLE)
    list(APPEND SOURCE_FILES "qt/macoshelper.mm")
endif()

if(ENABLE_PASS_STRENGTH_METER)
    file(GLOB PASS_STRENGTH_FILES
        "zxcvbn-c/zxcvbn.h"
        "zxcvbn-c/zxcvbn.c"
    )
endif()

if(WITH_SCANNER)
    file(GLOB QR_CODE_FILES
        "QR-Code-generator/*.h"
    	"QR-Code-generator/*.cpp"
    	"QR-Code-scanner/*.h"
    	"QR-Code-scanner/*.cpp"
    )
endif()

set(EXECUTABLE_FLAG)
if(MINGW)
    set(EXECUTABLE_FLAG WIN32)

    set(ICON ${PROJECT_SOURCE_DIR}/images/appicon.ico)
    set(ICON_RC ${CMAKE_CURRENT_BINARY_DIR}/icon.rc)
    set(ICON_RES ${CMAKE_CURRENT_BINARY_DIR}/icon.o)
    file(WRITE ${ICON_RC} "IDI_ICON1 ICON DISCARDABLE \"${ICON}\"")
    add_custom_command(OUTPUT ${ICON_RES} COMMAND windres ${ICON_RC} ${ICON_RES} MAIN_DEPENDENCY ${ICON_RC})
    list(APPEND RESOURCES ${ICON_RES})
endif()

if(APPLE)
    set(ICON ${PROJECT_SOURCE_DIR}/images/appicon.icns)
    set_source_files_properties(${ICON} PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    list(APPEND RESOURCES ${ICON})
endif()

add_executable(monero-wallet-gui ${EXECUTABLE_FLAG} main/main.cpp
    ${SOURCE_FILES}
    ${PASS_STRENGTH_FILES}
    ${QR_CODE_FILES}
    ${RESOURCES}
)

set_target_properties(monero-wallet-gui PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/share/Info.plist"
)

# OpenGL
target_include_directories(monero-wallet-gui PUBLIC ${OPENGL_INCLUDE_DIR})
message(STATUS "OpenGL: include dir at ${OPENGL_INCLUDE_DIR}")
message(STATUS "OpenGL: libraries at ${OPENGL_LIBRARIES}")

target_include_directories(monero-wallet-gui PUBLIC ${Qt5Gui_PRIVATE_INCLUDE_DIRS})

file(GLOB_RECURSE SRC_SOURCES *.cpp)
file(GLOB_RECURSE SRC_HEADERS *.h)

target_include_directories(monero-wallet-gui PUBLIC
	${CMAKE_SOURCE_DIR}/monero/include
    ${CMAKE_SOURCE_DIR}/monero/src
    ${CMAKE_SOURCE_DIR}/monero/external/easylogging++
    ${CMAKE_SOURCE_DIR}/monero/contrib/epee/include
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/daemon
	${CMAKE_CURRENT_SOURCE_DIR}/libwalletqt
	${CMAKE_CURRENT_SOURCE_DIR}/model
	${CMAKE_CURRENT_SOURCE_DIR}/QR-Code-generator
	${CMAKE_CURRENT_SOURCE_DIR}/QR-Code-scanner
	${CMAKE_CURRENT_SOURCE_DIR}/zxcvbn-c
    ${LibUSB_INCLUDE_DIRS}
    ${HIDAPI_INCLUDE_DIRS}
    ${X11_INCLUDE_DIR}
    ${Boost_INCLUDE_DIRS}
    ${OPENSSL_INCLUDE_DIR}
    ${ZBAR_INCLUDE_DIR}
)

target_compile_definitions(monero-wallet-gui
	PUBLIC
	${Qt5Widgets_DEFINITIONS}
    ${Qt5Qml_DEFINITIONS}
)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Widgets_EXECUTABLE_COMPILE_FLAGS}")

target_link_libraries(monero-wallet-gui
    wallet_merged
    ${LMDB_LIBRARY}
    epee
    ${UNBOUND_LIBRARY}
    ${SODIUM_LIBRARY}
    easylogging
    blockchain_db
    randomx
    hardforks
    ${Boost_LIBRARIES}
    ${OPENSSL_LIBRARIES}
    ${CMAKE_DL_LIBS}
    ${LibUSB_LIBRARIES}
    ${HIDAPI_LIBRARIES}
    ${QT5_LIBRARIES}
    ${EXTRA_LIBRARIES}
    ${ICU_LIBRARIES}
    openpgp
    translations
)

if(DEVICE_TREZOR_READY)
    target_link_libraries(monero-wallet-gui ${TREZOR_DEP_LIBS})
endif()

if(X11_FOUND)
    target_link_libraries(monero-wallet-gui ${X11_LIBRARIES})
endif()

if(WITH_SCANNER)
    target_link_libraries(monero-wallet-gui
        ${ZBAR_LIBRARIES}
        jpeg
        v4l2
        v4lconvert
        rt
    )
endif()

add_custom_command(TARGET monero-wallet-gui POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:daemon> $<TARGET_FILE_DIR:monero-wallet-gui>)

if(DEPLOY)
    get_target_property(_qmake_executable Qt5::qmake IMPORTED_LOCATION)
    get_filename_component(_qt_bin_dir "${_qmake_executable}" DIRECTORY)

    if(APPLE AND NOT IOS)
        find_program(MACDEPLOYQT_EXECUTABLE macdeployqt HINTS "${_qt_bin_dir}")
        add_custom_command(TARGET monero-wallet-gui
                           POST_BUILD
                           COMMAND "${MACDEPLOYQT_EXECUTABLE}" "$<TARGET_FILE_DIR:monero-wallet-gui>/../.." -always-overwrite -qmldir="${CMAKE_SOURCE_DIR}"
                           COMMENT "Running macdeployqt..."
        )

        # workaround for a Qt bug that requires manually adding libqsvg.dylib to bundle
        find_file(_qt_svg_dylib "libqsvg.dylib" PATHS "${CMAKE_PREFIX_PATH}/plugins/imageformats" NO_DEFAULT_PATH)
        if(_qt_svg_dylib)
            add_custom_command(TARGET monero-wallet-gui
                               POST_BUILD
                               COMMAND ${CMAKE_COMMAND} -E copy ${_qt_svg_dylib} $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/
                               COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change "${CMAKE_PREFIX_PATH}/lib/QtGui.framework/Versions/5/QtGui" "@executable_path/../Frameworks/QtGui.fr    amework/Versions/5/QtGui" $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/libqsvg.dylib
                               COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change "${CMAKE_PREFIX_PATH}/lib/QtWidgets.framework/Versions/5/QtWidgets" "@executable_path/../Frameworks/    QtGui.framework/Versions/5/QtGui" $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/libqsvg.dylib
                               COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change "${CMAKE_PREFIX_PATH}/lib/QtSvg.framework/Versions/5/QtSvg" "@executable_path/../Frameworks/QtGui.fr    amework/Versions/5/QtGui" $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/libqsvg.dylib
                               COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change "${CMAKE_PREFIX_PATH}/lib/QtCore.framework/Versions/5/QtCore" "@executable_path/../Frameworks/QtGui.    framework/Versions/5/QtGui" $<TARGET_FILE_DIR:monero-wallet-gui>/../PlugIns/imageformats/libqsvg.dylib
                               COMMENT "Copying libqsvg.dylib, running install_name_tool"
            )
        endif()
    endif()
endif()


install(TARGETS monero-wallet-gui
    DESTINATION ${CMAKE_INSTALL_PREFIX}
)
