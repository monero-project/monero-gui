add_subdirectory(QR-Code-scanner)
add_subdirectory(openpgp)
add_subdirectory(zxcvbn-c)

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
    "libwalletqt/QRCodeImageProvider.cpp"
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
    "libwalletqt/Transfer.h"
    "libwalletqt/AddressBook.h"
    "libwalletqt/Subaddress.h"
    "libwalletqt/SubaddressAccount.h"
    "libwalletqt/UnsignedTransaction.h"
    "daemon/*.h"
    "daemon/*.cpp"
    "p2pool/*.h"
    "p2pool/*.cpp"
    "model/*.h"
    "model/*.cpp"
    "qt/*.h"
    "qt/*.cpp"
)
if(QML_TESTS)
    list(APPEND SOURCE_FILES "${CMAKE_SOURCE_DIR}/tests/qml/QmlTestHarness.cpp")
endif()
if(APPLE)
    list(APPEND SOURCE_FILES "qt/macoshelper.mm")
endif()

set(monero_wallet_gui_sources
    ${SOURCE_FILES}
)

target_sources(monero-wallet-gui PRIVATE ${monero_wallet_gui_sources})

set_target_properties(monero-wallet-gui PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/share/Info.plist"
)

# OpenGL
target_include_directories(monero-wallet-gui PUBLIC ${OPENGL_INCLUDE_DIR})
message(STATUS "OpenGL: include dir at ${OPENGL_INCLUDE_DIR}")
message(STATUS "OpenGL: libraries at ${OPENGL_LIBRARIES}")

target_include_directories(monero-wallet-gui PUBLIC
	${CMAKE_SOURCE_DIR}/monero/include
    ${CMAKE_SOURCE_DIR}/monero/src
    ${CMAKE_SOURCE_DIR}/monero/external/easylogging++
    ${CMAKE_SOURCE_DIR}/monero/contrib/epee/include
    ${CMAKE_SOURCE_DIR}/monero/external/qrcodegen
	${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_CURRENT_SOURCE_DIR}/daemon
    ${CMAKE_CURRENT_SOURCE_DIR}/p2pool
	${CMAKE_CURRENT_SOURCE_DIR}/libwalletqt
	${CMAKE_CURRENT_SOURCE_DIR}/model
	${CMAKE_CURRENT_SOURCE_DIR}/QR-Code-scanner
	${CMAKE_CURRENT_SOURCE_DIR}/zxcvbn-c
)

if(QML_TESTS)
    target_include_directories(monero-wallet-gui PRIVATE "${CMAKE_SOURCE_DIR}/tests/qml")
    target_compile_definitions(monero-wallet-gui PRIVATE
        QML_TESTS
        QML_TEST_SOURCE_DIR="${CMAKE_SOURCE_DIR}/tests/qml"
    )
endif()
if(APPLE)
    if(NOT ICU_ROOT)
        execute_process(COMMAND brew --prefix icu4c OUTPUT_VARIABLE ICU_ROOT OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
    find_package(ICU REQUIRED COMPONENTS data i18n uc)
    target_link_directories(monero-wallet-gui PRIVATE ${ICU_ROOT}/lib)
endif()

target_link_libraries(monero-wallet-gui
    PRIVATE
    epee
    common
    net
    wallet_api
    qrcodegen
    easylogging
    ${QT_LIBRARIES}
    ${EXTRA_LIBRARIES}
    openpgp
    qrdecoder
    translations
    zxcvbn
)

if(MINGW)
    # Static Boost.Locale records ICU and iconv as bare library names. Keep the
    # depends library search path scoped to the executable that consumes them.
    target_link_directories(monero-wallet-gui PRIVATE "${BOOST_LIBRARYDIR}")
endif()

if(WITH_SCANNER)
    target_link_libraries(monero-wallet-gui PRIVATE qrscanner)
    if(LINUX AND NOT ANDROID)
        target_link_libraries(monero-wallet-gui
            PRIVATE
            jpeg
            v4l2
            v4lconvert
            rt
        )
    endif()
endif()

include(Deploy)
