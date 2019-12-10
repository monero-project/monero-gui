cmake_minimum_required(VERSION 3.10)
project(monero-gui)

message(STATUS "Initiating compile using CMake ${CMAKE_VERSION}")

set(VERSION_MAJOR "14")
set(VERSION_MINOR "0")
set(VERSION_REVISION "3")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION}")

# libwallet requires a static build, so we only allow static compilation
set(STATIC ON)

option(USE_DEVICE_TREZOR ON)
option(ENABLE_PASS_STRENGTH_METER "Disable zxcvbn" OFF)
option(WITH_SCANNER "Enable webcam QR scanner" OFF)
option(DEV_MODE "Checkout latest monero master on build" OFF)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_SOURCE_DIR}/cmake")
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
if(DEBUG)
	set(CMAKE_VERBOSE_MAKEFILE ON)
endif()

set(BUILD_GUI_DEPS ON)
set(ARCH "x86-64")
set(BUILD_64 ON)
set(INSTALL_VENDORED_LIBUNBOUND=ON)

function (add_c_flag_if_supported flag var)
  string(REPLACE "-" "_" supported ${flag}_c)
  check_c_compiler_flag(${flag} ${supported})
  if(${${supported}})
    set(${var} "${${var}} ${flag}" PARENT_SCOPE)
  endif()
endfunction()

function (add_cxx_flag_if_supported flag var)
  string(REPLACE "-" "_" supported ${flag}_cxx)
  check_cxx_compiler_flag(${flag} ${supported})
  if(${${supported}})
    set(${var} "${${var}} ${flag}" PARENT_SCOPE)
  endif()
endfunction()

function (add_linker_flag_if_supported flag var)
  string(REPLACE "-" "_" supported ${flag}_ld)
  string(REPLACE "," "_" supported ${flag}_ld)
  check_linker_flag(${flag} ${supported})
  if(${${supported}})
    set(${var} "${${var}} ${flag}" PARENT_SCOPE)
  endif()
endfunction()

find_package(Git)
if(GIT_FOUND)
  if(NOT DEV_MODE)
    find_package(Git)
    function (check_submodule relative_path)
      execute_process(COMMAND git rev-parse "HEAD" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${relative_path} OUTPUT_VARIABLE localHead)
      execute_process(COMMAND git rev-parse "HEAD:${relative_path}" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} OUTPUT_VARIABLE checkedHead)
      string(COMPARE EQUAL "${localHead}" "${checkedHead}" upToDate)
      if (upToDate)
        message(STATUS "Submodule '${relative_path}' is up-to-date")
      else()
        message(FATAL_ERROR "Submodule '${relative_path}' is not using the checked head. Please update all submodules with\ngit submodule update --init --force\nor run cmake with -DMANUAL_SUBMODULES=1,\n or if you want to build from latest master run cmake with -DEV_MODE,\n or run make devmode")
      endif()
    endfunction ()
    message(STATUS "Checking submodules")
    check_submodule(monero)
  else()
    execute_process(COMMAND cd monero && git checkout origin/master)
  endif()
endif()

add_subdirectory(monero)
set_property(TARGET wallet_merged PROPERTY FOLDER "monero")
get_directory_property(ARCH_WIDTH DIRECTORY "monero" DEFINITION ARCH_WIDTH)

if(STATIC)
	message(STATUS "Initiating static build")
	set(Boost_USE_STATIC_LIBS ON)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
  add_definitions(-DMONERO_GUI_STATIC)
endif()

# Include password strength library
if(ENABLE_PASS_STRENGTH_METER)
    message(STATUS "Buildin with pass strength meter support.")
else()
    add_definitions(-DDISABLE_PASS_STRENGTH_METER)
endif()

include(CheckTrezor)  # Trezor support check
include(CMakePackageConfigHelpers)

# force version update
function (monero_gui_add_library_with_deps)
  cmake_parse_arguments(MONERO_ADD_LIBRARY "" "NAME" "DEPENDS;SOURCES" ${ARGN})
  source_group("${MONERO_ADD_LIBRARY_NAME}" FILES ${MONERO_ADD_LIBRARY_SOURCES})

  # Define a ("virtual") object library and an actual library that links those
  # objects together. The virtual libraries can be arbitrarily combined to link
  # any subset of objects into one library archive. This is used for releasing
  # libwallet, which combines multiple components.
  set(objlib obj_${MONERO_ADD_LIBRARY_NAME})
  add_library(${objlib} OBJECT ${MONERO_ADD_LIBRARY_SOURCES})
  add_library("${MONERO_ADD_LIBRARY_NAME}" $<TARGET_OBJECTS:${objlib}>)
  if (MONERO_ADD_LIBRARY_DEPENDS)
    add_dependencies(${objlib} ${MONERO_ADD_LIBRARY_DEPENDS})
  endif()
  set_property(TARGET "${MONERO_ADD_LIBRARY_NAME}" PROPERTY FOLDER "libs")
  target_compile_definitions(${objlib}
    PRIVATE $<TARGET_PROPERTY:${MONERO_ADD_LIBRARY_NAME},INTERFACE_COMPILE_DEFINITIONS>)
endfunction ()

function (monero_gui_add_library name)
    monero_gui_add_library_with_deps(NAME "${name}" SOURCES ${ARGN})
endfunction()

include_directories(${EASYLOGGING_INCLUDE})
link_directories(${EASYLOGGING_LIBRARY_DIRS})


include(VersionGui)
monero_gui_add_library(gui_version SOURCES version.js DEPENDS genversiongui)

message(STATUS "${CMAKE_MODULE_PATH}")

find_package(X11 REQUIRED)

# OpenSSL
find_package(OpenSSL REQUIRED)
message(STATUS "OpenSSL: Version ${OPENSSL_VERSION}")
message(STATUS "OpenSSL: include dir at ${OPENSSL_INCLUDE_DIR}")
message(STATUS "OpenSSL: libraries at ${OPENSSL_LIBRARIES} ${OPENSSL_SSL_LIBRARIES}")

# Zbar (for QR scanner)
if(WITH_SCANNER)
    add_definitions(-DWITH_SCANNER)
    find_package(ZBar0)
    message(STATUS "libzbar: include dir at ${ZBAR_INCLUDE_DIR}")
    message(STATUS "libzbar: libraries at ${ZBAR_LIBRARIES}")
endif()

# Sodium
find_library(SODIUM_LIBRARY sodium)
message(STATUS "libsodium: libraries at ${SODIUM_LIBRARY}")

# LibUSB
find_package(LibUSB)
message(STATUS "libusb: include dir at ${LibUSB_INCLUDE_DIRS}")
message(STATUS "libusb: libraries at ${LibUSB_LIBRARIES}")

# HIDApi
find_package(HIDAPI REQUIRED)
message(STATUS "libhidapi: include dir at ${HIDAPI_INCLUDE_DIRS}")
message(STATUS "libhidapi: libraries at ${HIDAPI_LIBRARIES}")

# Boost
if(DEBUG)
    set(Boost_DEBUG ON)
endif()
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

if(LINUX)
    find_package(X11 REQUIRED)
    message(STATUS "X11_FOUND = ${X11_FOUND}")
    message(STATUS "X11_INCLUDE_DIR = ${X11_INCLUDE_DIR}")
    message(STATUS "X11_LIBRARIES = ${X11_LIBRARIES}")
    include_directories(${X11_INCLUDE_DIR})
    link_directories(${X11_LIBRARIES})
    if(STATIC)
        find_library(XCB_LIBRARY xcb)
        message(STATUS "Found xcb library: ${XCB_LIBRARY}")
    endif()
endif()

if(MINGW)
    string(REGEX MATCH "^[^/]:/[^/]*" msys2_install_path "${CMAKE_C_COMPILER}")
    message(STATUS "MSYS location: ${msys2_install_path}")
    set(CMAKE_INCLUDE_PATH "${msys2_install_path}/mingw${ARCH_WIDTH}/include")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/Qt/labs/folderlistmodel")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/Qt/labs/settings")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtGraphicalEffects")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtGraphicalEffects/private")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtMultimedia")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick.2")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick/Controls")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick/Controls.2")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick/Dialogs")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick/Dialogs/Private")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick/Layouts")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick/PrivateWidgets")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick/Templates.2")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick/Window.2")
    link_directories("${msys2_install_path}/mingw${ARCH_WIDTH}/qml/QtQuick/XmlListModel")
    # This is necessary because otherwise CMake will make Boost libraries -lfoo
    # rather than a full path. Unfortunately, this makes the shared libraries get
    # linked due to a bug in CMake which misses putting -static flags around the
    # -lfoo arguments.
    set(DEFLIB ${msys2_install_path}/mingw${ARCH_WIDTH}/lib)
    list(REMOVE_ITEM CMAKE_C_IMPLICIT_LINK_DIRECTORIES ${DEFLIB})
    list(REMOVE_ITEM CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES ${DEFLIB})
endif()

set(QT5_LIBRARIES
  Qt5Core
  Qt5Quick
  Qt5QuickControls2
  Qt5Widgets
  Qt5Gui
  Qt5Network
  Qt5Qml
  Qt5Multimedia
  Qt5Xml
  Qt5XmlPatterns
  Qt5Svg
)

foreach(QT5_MODULE ${QT5_LIBRARIES})
  find_package(${QT5_MODULE} REQUIRED)
endforeach()

find_package(PkgConfig)
if(PKGCONFIG_FOUND)
  pkg_check_modules(QT5_PKG_CONFIG ${QT5_LIBRARIES})

  if(QT5_PKG_CONFIG_FOUND)
    set(QT5_PKG_CONFIG "QT5_PKG_CONFIG")
    if(STATIC)
      set(QT5_PKG_CONFIG "${QT5_PKG_CONFIG}_STATIC")
    endif()

    set(QT5_LIBRARIES ${${QT5_PKG_CONFIG}_LIBRARIES} ${${QT5_PKG_CONFIG}_LDFLAGS_OTHER})
    include_directories(${${QT5_PKG_CONFIG}_INCLUDE_DIRS})
    link_directories(${${QT5_PKG_CONFIG}_LIBRARY_DIRS})
  endif()
endif()

list(APPEND QT5_LIBRARIES
  ${Qt5Gui_PLUGINS}
  ${Qt5Svg_PLUGINS}
  ${Qt5Qml_PLUGINS}
  ${Qt5Network_PLUGINS}
)

if(STATIC)
  set(QT5_LIBRARIES
    qtquickcontrols2plugin # has to be the first one, depends on Qt5QuickControls2
    ${QT5_LIBRARIES}
    declarative_multimedia
    dialogplugin
    dialogsprivateplugin
    qmlfolderlistmodelplugin
    qmlsettingsplugin
    qmlxmllistmodelplugin
    qquicklayoutsplugin
    Qt5EventDispatcherSupport
    Qt5FontDatabaseSupport
    Qt5MultimediaQuick_p
    Qt5PacketProtocol
    Qt5ThemeSupport
    qtgraphicaleffectsplugin
    qtgraphicaleffectsprivate
    qtquick2plugin
    qtquickcontrolsplugin
    qtquicktemplates2plugin
    widgetsplugin
    windowplugin
  )

  if(MINGW)
    list(APPEND QT5_LIBRARIES qtfreetype)

    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
      list(APPEND QT5_LIBRARIES D3D11 Dwrite D2d1)
    endif()
  endif()
endif()

message(STATUS "Using Boost include dir at ${Boost_INCLUDE_DIRS}")
message(STATUS "Using Boost libraries at ${Boost_LIBRARIES}")

include_directories(SYSTEM ${Boost_INCLUDE_DIRS})
if(MINGW)
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wa,-mbig-obj")
  set(EXTRA_LIBRARIES mswsock;ws2_32;iphlpapi;crypt32;bcrypt)
  if(DEPENDS)
    set(ICU_LIBRARIES icuio icui18n icuuc icudata icutu iconv)
  else()
    set(ICU_LIBRARIES icuio icuin icuuc icudt icutu iconv)
  endif()
elseif(APPLE OR OPENBSD OR ANDROID)
  set(EXTRA_LIBRARIES "")
elseif(FREEBSD)
  set(EXTRA_LIBRARIES execinfo)
elseif(DRAGONFLY)
  find_library(COMPAT compat)
  set(EXTRA_LIBRARIES execinfo ${COMPAT})
elseif(CMAKE_SYSTEM_NAME MATCHES "(SunOS|Solaris)")
  set(EXTRA_LIBRARIES socket nsl resolv)
elseif(NOT MSVC AND NOT DEPENDS)
  find_library(RT rt)
  set(EXTRA_LIBRARIES ${RT})
endif()

list(APPEND EXTRA_LIBRARIES ${CMAKE_DL_LIBS})

if(APPLE)
  include_directories(SYSTEM /usr/include/malloc)
  if(POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
  endif()
endif()

if (APPLE AND NOT IOS)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=x86-64 -fvisibility=default -std=c++11")
endif()

if(APPLE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=default -DGTEST_HAS_TR1_TUPLE=0")
endif()

# warnings
add_c_flag_if_supported(-Wformat C_SECURITY_FLAGS)
add_cxx_flag_if_supported(-Wformat CXX_SECURITY_FLAGS)
add_c_flag_if_supported(-Wformat-security C_SECURITY_FLAGS)
add_cxx_flag_if_supported(-Wformat-security CXX_SECURITY_FLAGS)

# -fstack-protector
if (NOT OPENBSD AND NOT (WIN32 AND (CMAKE_C_COMPILER_ID STREQUAL "GNU" AND CMAKE_C_COMPILER_VERSION VERSION_LESS 9.1)))
  add_c_flag_if_supported(-fstack-protector C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-fstack-protector CXX_SECURITY_FLAGS)
  add_c_flag_if_supported(-fstack-protector-strong C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-fstack-protector-strong CXX_SECURITY_FLAGS)
endif()

# New in GCC 8.2
if (NOT OPENBSD AND NOT (WIN32 AND (CMAKE_C_COMPILER_ID STREQUAL "GNU" AND CMAKE_C_COMPILER_VERSION VERSION_LESS 9.1)))
  add_c_flag_if_supported(-fcf-protection=full C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-fcf-protection=full CXX_SECURITY_FLAGS)
endif()
if (NOT WIN32 AND NOT OPENBSD)
  add_c_flag_if_supported(-fstack-clash-protection C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-fstack-clash-protection CXX_SECURITY_FLAGS)
endif()

# Removed in GCC 9.1 (or before ?), but still accepted, so spams the output
if (NOT (CMAKE_C_COMPILER_ID STREQUAL "GNU" AND NOT CMAKE_C_COMPILER_VERSION VERSION_LESS 9.1))
  add_c_flag_if_supported(-mmitigate-rop C_SECURITY_FLAGS)
  add_cxx_flag_if_supported(-mmitigate-rop CXX_SECURITY_FLAGS)
endif()

# linker
if (NOT (WIN32 AND CMAKE_C_COMPILER_ID STREQUAL "GNU"))
  # Windows binaries die on startup with PIE when compiled with GCC
  add_linker_flag_if_supported(-pie LD_SECURITY_FLAGS)
endif()
add_linker_flag_if_supported(-Wl,-z,relro LD_SECURITY_FLAGS)
add_linker_flag_if_supported(-Wl,-z,now LD_SECURITY_FLAGS)
add_linker_flag_if_supported(-Wl,-z,noexecstack noexecstack_SUPPORTED)
if (noexecstack_SUPPORTED)
  set(LD_SECURITY_FLAGS "${LD_SECURITY_FLAGS} -Wl,-z,noexecstack")
endif()
add_linker_flag_if_supported(-Wl,-z,noexecheap noexecheap_SUPPORTED)
if (noexecheap_SUPPORTED)
  set(LD_SECURITY_FLAGS "${LD_SECURITY_FLAGS} -Wl,-z,noexecheap")
endif()

message(STATUS "Using C security hardening flags: ${C_SECURITY_FLAGS}")
message(STATUS "Using C++ security hardening flags: ${CXX_SECURITY_FLAGS}")
message(STATUS "Using linker security hardening flags: ${LD_SECURITY_FLAGS}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${C_SECURITY_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXX_SECURITY_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LD_SECURITY_FLAGS}")

if (HIDAPI_FOUND OR LibUSB_COMPILE_TEST_PASSED)
  if (APPLE)
    if(DEPENDS)
      list(APPEND EXTRA_LIBRARIES "-framework Foundation -framework IOKit")
    else()
      find_library(COREFOUNDATION CoreFoundation)
      find_library(IOKIT IOKit)
      list(APPEND EXTRA_LIBRARIES ${IOKIT})
      list(APPEND EXTRA_LIBRARIES ${COREFOUNDATION})
    endif()
  endif()
  if (WIN32)
    list(APPEND EXTRA_LIBRARIES setupapi Version)
  endif()
endif()

add_subdirectory(src)

# Required to make wallet_merged build before the gui
add_dependencies(monero-gui wallet_merged)

