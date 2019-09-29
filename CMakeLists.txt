cmake_minimum_required(VERSION 3.10)
project(monero-gui C CXX)

message(STATUS "Initiating compile using CMake ${CMAKE_VERSION}")

set(STATIC OFF)
set(DEBUG ON)
set(CMAKE_BUILD_TYPE Debug)

# GUI
set(VERSION_MAJOR "14")
set(VERSION_MINOR "0")
set(VERSION_REVISION "3")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION}")

set(USE_DEVICE_TREZOR OFF)
option(USE_DEVICE_TREZOR "Disable zxcvbn" OFF)
option(DISABLE_PASS_STRENGTH_METER "Disable zxcvbn" ON)
#option(WITH_SCANNER "Enable webcam QR scanner" OFF)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_CXX_FLAGS "-fPIC")
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
if(DEBUG)
	set(CMAKE_VERBOSE_MAKEFILE ON)
endif()
set(CMAKE_PREFIX_PATH $ENV{HOME}/Qt5.9/5.9.7/gcc_64)

if(STATIC)
	message(STATUS "Initiating static build")
	set(Boost_USE_STATIC_LIBS ON)
	set(CMAKE_FIND_LIBRARY_SUFFIXES ".a" ".so")
endif()

# Compile source files (.h/.cpp)
file(GLOB SOURCE_FILES
		"*.h"
		"*.cpp"
		"src/*.h"
        "src/libwalletqt/WalletManager.cpp"
        "src/libwalletqt/Wallet.cpp"
        "src/libwalletqt/PendingTransaction.cpp"
        "src/libwalletqt/TransactionHistory.cpp"
        "src/libwalletqt/TransactionInfo.cpp"
        "src/libwalletqt/QRCodeImageProvider.cpp" QR
        "src/QR-Code-generator/BitBuffer.cpp"
        "src/QR-Code-generator/QrCode.cpp"
        "src/QR-Code-generator/QrSegment.cpp"
        "src/libwalletqt/AddressBook.cpp"
        "src/libwalletqt/Subaddress.cpp"
        "src/libwalletqt/SubaddressAccount.cpp"
        "src/libwalletqt/UnsignedTransaction.cpp"
        "src/libwalletqt/WalletManager.h"
        "src/libwalletqt/Wallet.h"
        "src/libwalletqt/PendingTransaction.h"
        "src/libwalletqt/TransactionHistory.h"
        "src/libwalletqt/TransactionInfo.h"
        "src/libwalletqt/QRCodeImageProvider.h"
        "src/QR-Code-generator/BitBuffer.h"
        "src/QR-Code-generator/QrCode.h"
        "src/QR-Code-generator/QrSegment.h"
        "src/libwalletqt/Transfer.h"
        "src/libwalletqt/AddressBook.h"
        "src/libwalletqt/Subaddress.h"
        "src/libwalletqt/SubaddressAccount.h"
        "src/libwalletqt/UnsignedTransaction.h"

		"src/daemon/*.h"
		"src/daemon/*.cpp"
		"src/model/*.h"
		"src/model/*.cpp"
#		"src/QR-Code-generator/*.h"
#		"src/QR-Code-generator/*.cpp"
#		"src/QR-Code-scanner/*.h"
#		"src/QR-Code-scanner/*.cpp"
        "src/qt/*.h"
        "src/qt/*.cpp"
		)

# Include password strength library
add_definitions(-DDISABLE_PASS_STRENGTH_METER)
#if(DISABLE_PASS_STRENGTH_METER)
#    add_definitions(-DDISABLE_PASS_STRENGTH_METER)
#else()
#    message(STATUS "1111")
#    list(APPEND SOURCE_FILES
#        "src/zxcvbn-c/*.h"
#        "src/zxcvbn-c/*.cpp"
#        )
#endif()

include(CheckTrezor)  # Trezor support check
include(CMakePackageConfigHelpers)

# QT5
#set(RESOURCES
#    "resources/images.qrc"
#    )

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)
find_package(Qt5Widgets REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5Network REQUIRED)
find_package(Qt5Qml REQUIRED)
find_package(Qt5Multimedia REQUIRED)
find_package(Qt5Xml REQUIRED)
find_package(Qt5XmlPatterns REQUIRED)
find_package(Qt5Svg REQUIRED)

set(RESOURCES qml.qrc)
qt5_add_resources(QML_QRC ${RESOURCES})

add_executable(monero-gui main.cpp
        ${SOURCE_FILES}
        ${QML_QRC}
        )

target_include_directories(monero-gui PUBLIC ${Qt5Gui_PRIVATE_INCLUDE_DIRS})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Widgets_EXECUTABLE_COMPILE_FLAGS}")

# OpenGL
set(OpenGL_GL_PREFERENCE GLVND)
find_package(OpenGL REQUIRED)
target_include_directories(monero-gui PUBLIC ${OPENGL_INCLUDE_DIR})
message(STATUS "OpenGL: include dir at ${OPENGL_INCLUDE_DIR}")
message(STATUS "OpenGL: libraries at ${OPENGL_LIBRARIES}")

# OpenSSL
find_package(OpenSSL REQUIRED)
target_include_directories(monero-gui PUBLIC ${OPENSSL_INCLUDE_DIR})
message(STATUS "OpenSSL: Version ${OPENSSL_VERSION}")
message(STATUS "OpenSSL: include dir at ${OPENSSL_INCLUDE_DIR}")
message(STATUS "OpenSSL: libraries at ${OPENSSL_LIBRARIES} ${OPENSSL_SSL_LIBRARIES}")

# Zbar (for QR scanner)
#find_package(ZBar0)
#target_include_directories(monero-gui PUBLIC ${ZBAR_INCLUDE_DIR})
#message(STATUS "libzbar: include dir at ${ZBAR_INCLUDE_DIR}")
#message(STATUS "libzbar: libraries at ${ZBAR_LIBRARIES}")

# Unwind
find_package(Libunwind)
target_include_directories(monero-gui PUBLIC ${LIBUNWIND_INCLUDE_DIR})
message(STATUS "libunwind: include dir at ${LIBUNWIND_INCLUDE_DIR}")
message(STATUS "libunwind: libraries at ${LIBUNWIND_LIBRARIES}")

# Sodium
if(STATIC)
	set(sodium_USE_STATIC_LIBS ON)
endif()
find_package(Sodium REQUIRED)
target_include_directories(monero-gui PUBLIC ${sodium_INCLUDE_DIR})
message(STATUS "libsodium: include dir at ${sodium_INCLUDE_DIR}")
message(STATUS "libsodium: libraries at ${sodium_LIBRARY_DEBUG}")
if(sodium_VERSION)
	message(STATUS "libsodium: Version ${sodium_VERSION}")
endif()

# LibUSB
find_package(LibUSB)
target_include_directories(monero-gui PUBLIC ${LibUSB_INCLUDE_DIRS})
message(STATUS "libusb: include dir at ${LibUSB_INCLUDE_DIRS}")
message(STATUS "libusb: libraries at ${LibUSB_LIBRARIES}")

# HIDApi
find_package(HIDAPI REQUIRED)
target_include_directories(monero-gui PUBLIC ${HIDAPI_INCLUDE_DIRS})
message(STATUS "libhidapi: include dir at ${HIDAPI_INCLUDE_DIRS}")
message(STATUS "libhidapi: libraries at ${HIDAPI_LIBRARIES}")

# Boost
#if(DEBUG)
#    set(Boost_DEBUG ON)
#endif()
find_package(Boost 1.62 REQUIRED COMPONENTS
		system
		filesystem
		thread
		date_time
		chrono
		regex
		serialization
		program_options
		locale)

target_include_directories(monero-gui PUBLIC ${Boost_INCLUDE_DIRS})
message(STATUS "Using Boost include dir at ${Boost_INCLUDE_DIRS}")
message(STATUS "Using Boost libraries at ${Boost_LIBRARIES}")

target_include_directories(monero-gui PUBLIC
		${CMAKE_CURRENT_SOURCE_DIR}/monero/include
		${CMAKE_CURRENT_SOURCE_DIR}/monero/src
		${CMAKE_CURRENT_SOURCE_DIR}/src
		${CMAKE_CURRENT_SOURCE_DIR}/src/daemon
		${CMAKE_CURRENT_SOURCE_DIR}/src/libwalletqt
		${CMAKE_CURRENT_SOURCE_DIR}/src/model
		${CMAKE_CURRENT_SOURCE_DIR}/src/QR-Code-generator
		#${CMAKE_CURRENT_SOURCE_DIR}/src/QR-Code-scanner
		${CMAKE_CURRENT_SOURCE_DIR}/src/daemon/zxcvbn-c
        "/usr/include/libusb-1.0/"  # REMOVEME
		)

target_compile_definitions(monero-gui
		PUBLIC
		${Qt5Widgets_DEFINITIONS}
		${Qt5Qml_DEFINITIONS}
		)

set(CMAKE_CXX_FLAGS "${Qt5Widgets_EXECUTABLE_COMPILE_FLAGS}")
set(CMAKE_CXX_FLAGS "-std=c++0x")

target_link_libraries(monero-gui
		${CMAKE_SOURCE_DIR}/monero/lib/libwallet_merged.a
		#${ZBAR_LIBRARIES}  QR
		${CMAKE_SOURCE_DIR}/monero/lib/libunbound.a
		${sodium_LIBRARY_RELEASE}
		${CMAKE_SOURCE_DIR}/monero/lib/liblmdb.a
		${CMAKE_SOURCE_DIR}/monero/lib/libepee.a
		${CMAKE_SOURCE_DIR}/monero/lib/libepee_readline.a
		${CMAKE_SOURCE_DIR}/monero/lib/libeasylogging.a
		${CMAKE_DL_LIBS}
		${Boost_LIBRARIES}
		${OPENSSL_LIBRARIES}
		${OPENSSL_SSL_LIBRARIES}
        ${LibUSB_LIBRARIES}
		${HIDAPI_LIBRARIES}
		pthread
		Qt5::Core
		Qt5::Quick
		Qt5::Widgets
		Qt5::Gui
		Qt5::Network
		Qt5::Qml
		Qt5::Multimedia
		Qt5::Xml
		Qt5::XmlPatterns
		Qt5::Svg
		)

install(TARGETS monero-gui
		DESTINATION ${CMAKE_INSTALL_PREFIX}
		)
