cmake_minimum_required(VERSION 3.12)
project(monero-gui)

message(STATUS "Initiating compile using CMake ${CMAKE_VERSION}")

set(VERSION_MAJOR "17")
set(VERSION_MINOR "2")
set(VERSION_REVISION "1")
set(VERSION "0.${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_REVISION}")

option(STATIC "Link libraries statically, requires static Qt")

option(USE_DEVICE_TREZOR "Trezor support compilation" ON)
option(ENABLE_PASS_STRENGTH_METER "Enable zxcvbn library for password strength" OFF)
option(WITH_SCANNER "Enable webcam QR scanner" OFF)
option(DEV_MODE "Checkout latest monero master on build" OFF)

list(INSERT CMAKE_MODULE_PATH 0 "${CMAKE_SOURCE_DIR}/cmake")
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)
include(CheckLinkerFlag)
include(FindCcache)

if(DEBUG)
	set(CMAKE_VERBOSE_MAKEFILE ON)
endif()

set(BUILD_GUI_DEPS ON)
set(ARCH "x86-64" CACHE STRING "Target architecture")
set(BUILD_64 ON CACHE BOOL "Build 64-bit binaries")

if(NOT MANUAL_SUBMODULES)
  find_package(Git)
  if(GIT_FOUND)
    if(NOT DEV_MODE)
      function (check_submodule relative_path)
        execute_process(COMMAND git rev-parse "HEAD" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${relative_path} OUTPUT_VARIABLE localHead)
        execute_process(COMMAND git rev-parse "HEAD:${relative_path}" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} OUTPUT_VARIABLE checkedHead)
        string(COMPARE EQUAL "${localHead}" "${checkedHead}" upToDate)
        if (upToDate)
          message(STATUS "Submodule '${relative_path}' is up-to-date")
        else()
          message(FATAL_ERROR "Submodule '${relative_path}' is not using the checked head. Please update all submodules with\ngit submodule update --init --force --recursive\nor run cmake with -DMANUAL_SUBMODULES=1,\n or if you want to build from latest master run cmake with -DDEV_MODE=ON,\n or run make devmode")
        endif()
      endfunction ()
      message(STATUS "Checking submodules")
      check_submodule(monero)
    else()
      execute_process(COMMAND ${GIT_EXECUTABLE} fetch WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/monero RESULT_VARIABLE GIT_FETCH_RESULT)
      execute_process(COMMAND ${GIT_EXECUTABLE} checkout -f origin/master WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/monero RESULT_VARIABLE GIT_CHECKOUT_MASTER_RESULT)
      execute_process(COMMAND ${GIT_EXECUTABLE} submodule sync --recursive WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/monero RESULT_VARIABLE GIT_SUBMODULE_SYNC_RESULT)
      execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --force --recursive WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/monero RESULT_VARIABLE GIT_SUBMODULE_UPDATE_RESULT)
      if(NOT GIT_FETCH_RESULT EQUAL "0" OR NOT GIT_CHECKOUT_MASTER_RESULT EQUAL "0" OR NOT GIT_SUBMODULE_SYNC_RESULT EQUAL "0" OR NOT GIT_SUBMODULE_UPDATE_RESULT EQUAL "0")
        message(FATAL_ERROR "Updating git submodule to master (-DDEV_MODE=ON) failed")
      endif()
    endif()
  endif()
endif()

add_subdirectory(monero)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set_property(TARGET wallet_merged PROPERTY FOLDER "monero")
get_directory_property(ARCH_WIDTH DIRECTORY "monero" DEFINITION ARCH_WIDTH)
get_directory_property(UNBOUND_LIBRARY DIRECTORY "monero" DEFINITION UNBOUND_LIBRARY)
get_directory_property(DEVICE_TREZOR_READY DIRECTORY "monero" DEFINITION DEVICE_TREZOR_READY)
get_directory_property(TREZOR_DEP_LIBS DIRECTORY "monero" DEFINITION TREZOR_DEP_LIBS)

if (NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_definitions(-DQT_NO_DEBUG)
endif()

if(STATIC)
  message(STATUS "Initiating static build")
  set(Boost_USE_STATIC_LIBS ON)
  set(Boost_USE_STATIC_RUNTIME ON)
  set(CMAKE_FIND_LIBRARY_SUFFIXES ".a" ${CMAKE_FIND_LIBRARY_SUFFIXES})
  add_definitions(-DMONERO_GUI_STATIC)
endif()

# Include password strength library
if(ENABLE_PASS_STRENGTH_METER)
    message(STATUS "Building with pass strength meter support.")
else()
    add_definitions(-DDISABLE_PASS_STRENGTH_METER)
endif()

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

# OpenSSL
if(APPLE AND NOT OPENSSL_ROOT_DIR)
  execute_process(COMMAND brew --prefix openssl OUTPUT_VARIABLE OPENSSL_ROOT_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
find_package(OpenSSL REQUIRED)
message(STATUS "OpenSSL: Version ${OPENSSL_VERSION}")
message(STATUS "OpenSSL: include dir at ${OPENSSL_INCLUDE_DIR}")
message(STATUS "OpenSSL: libraries at ${OPENSSL_LIBRARIES} ${OPENSSL_SSL_LIBRARIES}")

if(WITH_SCANNER)
    add_definitions(-DWITH_SCANNER)
endif()

# Sodium
find_library(SODIUM_LIBRARY sodium)
message(STATUS "libsodium: libraries at ${SODIUM_LIBRARY}")

# LibUSB
find_package(LibUSB)
message(STATUS "libusb: include dir at ${LibUSB_INCLUDE_DIRS}")
message(STATUS "libusb: libraries at ${LibUSB_LIBRARIES}")

# HIDApi
if(NOT ANDROID)
  find_package(HIDAPI REQUIRED)
  message(STATUS "libhidapi: include dir at ${HIDAPI_INCLUDE_DIRS}")
  message(STATUS "libhidapi: libraries at ${HIDAPI_LIBRARIES}")
endif()

# Boost
if(DEBUG)
    set(Boost_DEBUG ON)
endif()
if(APPLE AND NOT BOOST_ROOT)
  execute_process(COMMAND brew --prefix boost OUTPUT_VARIABLE BOOST_ROOT OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
if(MINGW)
  set(Boost_THREADAPI win32)
endif()
find_package(Boost 1.58 REQUIRED COMPONENTS
		system
		filesystem
		thread
		date_time
		chrono
		regex
		serialization
		program_options
		locale)

if(UNIX AND NOT APPLE AND NOT ANDROID)
    set(CMAKE_SKIP_RPATH ON)
    set(CMAKE_FIND_LIBRARY_SUFFIXES_PREV ${CMAKE_FIND_LIBRARY_SUFFIXES})
    set(CMAKE_FIND_LIBRARY_SUFFIXES ".so")
    find_package(X11 REQUIRED)
    set(CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES_PREV})
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
  Qt5Gui
  Qt5Qml
  Qt5Svg
  Qt5Xml
)

if(WITH_SCANNER)
  list(APPEND QT5_LIBRARIES Qt5Multimedia)
endif()

if(APPLE)
  list(APPEND QT5_LIBRARIES Qt5MacExtras)
endif()

if(UNIX)
  if(NOT CMAKE_PREFIX_PATH AND DEFINED ENV{CMAKE_PREFIX_PATH})
    message(STATUS "Using CMAKE_PREFIX_PATH environment variable: '$ENV{CMAKE_PREFIX_PATH}'")
    set(CMAKE_PREFIX_PATH $ENV{CMAKE_PREFIX_PATH})
  endif()
  if(APPLE AND NOT CMAKE_PREFIX_PATH)
    execute_process(COMMAND brew --prefix qt5 OUTPUT_VARIABLE QT5_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)
    list(APPEND CMAKE_PREFIX_PATH ${QT5_DIR})
  endif()
endif()

find_package(PkgConfig REQUIRED)

# TODO: drop this once we switch to Qt 5.14+
pkg_check_modules(Qt5QmlModels_PKG_CONFIG QUIET Qt5QmlModels)
if(Qt5QmlModels_PKG_CONFIG_FOUND)
  list(APPEND QT5_LIBRARIES Qt5QmlModels)
endif()

# TODO: drop this once we switch to Qt 5.12+
find_package(Qt5XmlPatterns QUIET)
if(Qt5XmlPatterns_FOUND)
  list(APPEND QT5_LIBRARIES Qt5XmlPatterns)
endif()

foreach(QT5_MODULE ${QT5_LIBRARIES})
  find_package(${QT5_MODULE} REQUIRED)
  include_directories(${${QT5_MODULE}_INCLUDE_DIRS})
endforeach()

if(NOT (CMAKE_CROSSCOMPILING AND ANDROID))
  pkg_check_modules(QT5_PKG_CONFIG REQUIRED ${QT5_LIBRARIES})
else()
  set(QT5_LIBRARIES_ABI)
  foreach(QT5_MODULE ${QT5_LIBRARIES})
    list(APPEND QT5_LIBRARIES_ABI "${QT5_MODULE}_${CMAKE_ANDROID_ARCH_ABI}")
  endforeach()
  pkg_check_modules(QT5_PKG_CONFIG REQUIRED ${QT5_LIBRARIES_ABI})
endif()

get_target_property(QMAKE_IMPORTED_LOCATION Qt5::qmake IMPORTED_LOCATION)
get_filename_component(QT_INSTALL_PREFIX "${QMAKE_IMPORTED_LOCATION}/../.." ABSOLUTE)

if(APPLE AND NOT STATIC)
  set(CMAKE_BUILD_RPATH "${QT_INSTALL_PREFIX}/lib")
endif()

if(QT5_PKG_CONFIG_FOUND)
  set(QT5_PKG_CONFIG "QT5_PKG_CONFIG")
  if(STATIC)
    set(QT5_PKG_CONFIG "${QT5_PKG_CONFIG}_STATIC")
  endif()

  if(UNIX AND CMAKE_PREFIX_PATH)
    if(APPLE)
      list(JOIN ${QT5_PKG_CONFIG}_LDFLAGS_OTHER " " ${QT5_PKG_CONFIG}_LDFLAGS_OTHER)
    endif()
    # temporal workaround for https://bugreports.qt.io/browse/QTBUG-80922
    STRING(REPLACE "${QT5_PKG_CONFIG_Qt5Core_PREFIX}" "${QT_INSTALL_PREFIX}" ${QT5_PKG_CONFIG}_LDFLAGS_OTHER "${${QT5_PKG_CONFIG}_LDFLAGS_OTHER}")
    STRING(REPLACE "${QT5_PKG_CONFIG_Qt5Core_PREFIX}" "${QT_INSTALL_PREFIX}" ${QT5_PKG_CONFIG}_LIBRARIES "${${QT5_PKG_CONFIG}_LIBRARIES}")
    STRING(REPLACE "${QT5_PKG_CONFIG_Qt5Core_PREFIX}" "${QT_INSTALL_PREFIX}" ${QT5_PKG_CONFIG}_INCLUDE_DIRS "${${QT5_PKG_CONFIG}_INCLUDE_DIRS}")
    STRING(REPLACE "${QT5_PKG_CONFIG_Qt5Core_PREFIX}" "${QT_INSTALL_PREFIX}" ${QT5_PKG_CONFIG}_LIBRARY_DIRS "${${QT5_PKG_CONFIG}_LIBRARY_DIRS}")
  endif()

  set(QT5_LIBRARIES ${${QT5_PKG_CONFIG}_LIBRARIES} ${${QT5_PKG_CONFIG}_LDFLAGS_OTHER})
  include_directories(${${QT5_PKG_CONFIG}_INCLUDE_DIRS})
  link_directories(${${QT5_PKG_CONFIG}_LIBRARY_DIRS})
endif()

list(APPEND QT5_LIBRARIES
  ${Qt5Gui_PLUGINS}
  ${Qt5Svg_PLUGINS}
  ${Qt5Qml_PLUGINS}
  ${Qt5Network_PLUGINS}
)

if(STATIC)
  set(QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/Qt/labs/folderlistmodel)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/Qt/labs/settings)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtGraphicalEffects)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtGraphicalEffects/private)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtMultimedia)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQml)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQml/Models.2)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick.2)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick/Controls)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick/Controls.2)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick/Dialogs)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick/Dialogs/Private)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick/Layouts)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick/PrivateWidgets)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick/Templates.2)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick/Window.2)
  list(APPEND QT5_EXTRA_PATHS ${QT5_PKG_CONFIG_Qt5Qml_PREFIX}/qml/QtQuick/XmlListModel)

  set(QT5_EXTRA_LIBRARIES_LIST
    qtquicktemplates2plugin
    Qt5QuickTemplates2
    qtquickcontrols2plugin
    Qt5QuickControls2
    dialogplugin
    dialogsprivateplugin
    qmlfolderlistmodelplugin
    qmlsettingsplugin
    qmlxmllistmodelplugin
    qquicklayoutsplugin
    modelsplugin
  )

  if(WITH_SCANNER)
    list(APPEND QT5_EXTRA_LIBRARIES_LIST
      declarative_multimedia
      Qt5MultimediaQuick_p
    )
  endif()

  list(APPEND QT5_EXTRA_LIBRARIES_LIST
    qtgraphicaleffectsplugin
    qtgraphicaleffectsprivate
    qtquick2plugin
    qtquickcontrolsplugin
    widgetsplugin
    windowplugin
  )

  if(NOT ${Qt5Core_VERSION} VERSION_LESS 5.14)
     list(APPEND QT5_EXTRA_LIBRARIES_LIST qmlplugin)
  endif()

  set(QT5_EXTRA_LIBRARIES)
  foreach(LIBRARY ${QT5_EXTRA_LIBRARIES_LIST})
    find_library(${LIBRARY}_LIBRARY ${LIBRARY} PATHS ${QT5_EXTRA_PATHS} REQUIRED)
    list(APPEND QT5_EXTRA_LIBRARIES ${${LIBRARY}_LIBRARY})
  endforeach()

  if(MINGW)
    if(CMAKE_BUILD_TYPE STREQUAL "Debug")
      list(APPEND QT5_EXTRA_LIBRARIES D3D11 Dwrite D2d1)
    endif()
  endif()

  set(QT5_LIBRARIES
    ${QT5_EXTRA_LIBRARIES}
    ${QT5_LIBRARIES}
  )

  set(QT5_INTEGRATION_LIBRARIES_LIST
    Qt5EventDispatcherSupport
    Qt5PacketProtocol
    Qt5ThemeSupport
    Qt5FontDatabaseSupport
  )

  if(UNIX AND NOT APPLE)
    list(APPEND QT5_INTEGRATION_LIBRARIES_LIST
      Qt5XcbQpa
      Qt5ServiceSupport
      Qt5GlxSupport
    )
  elseif(MINGW)
    list(APPEND QT5_INTEGRATION_LIBRARIES_LIST qtfreetype)
  endif()

  foreach(LIBRARY ${QT5_INTEGRATION_LIBRARIES_LIST})
    find_library(${LIBRARY}_LIBRARY ${LIBRARY} PATHS ${QT5_EXTRA_PATHS} REQUIRED)
    list(APPEND QT5_LIBRARIES ${${LIBRARY}_LIBRARY})
  endforeach()

  if(UNIX AND NOT APPLE)
    pkg_check_modules(X11XCB_XCBGLX REQUIRED x11-xcb xcb-glx)
    list(APPEND QT5_LIBRARIES ${X11XCB_XCBGLX_LIBRARIES})
    pkg_check_modules(FONTCONFIG REQUIRED fontconfig)
    list(APPEND QT5_LIBRARIES ${FONTCONFIG_STATIC_LIBRARIES})
  endif()
endif()

if(ANDROID)
  set(QT5_EXTRA_LIBRARIES_LIST
    GLESv2
    log
    z
    jnigraphics
    android
    EGL
    Qt5VirtualKeyboard_${CMAKE_ANDROID_ARCH_ABI}
    c++_shared
  )
  foreach(LIBRARY ${QT5_EXTRA_LIBRARIES_LIST})
    find_library(${LIBRARY}_LIBRARY ${LIBRARY} PATHS "${ANDROID_TOOLCHAIN_ROOT}/sysroot/usr/lib/${CMAKE_LIBRARY_ARCHITECTURE}/${ANDROID_PLATFORM_LEVEL}" REQUIRED)
    list(APPEND QT5_LIBRARIES ${${LIBRARY}_LIBRARY})
  endforeach()
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
elseif(APPLE)
  set(EXTRA_LIBRARIES "-framework AppKit")
elseif(OPENBSD OR ANDROID)
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
add_c_flag_if_supported(-Werror C_SECURITY_FLAGS)
add_cxx_flag_if_supported(-Werror CXX_SECURITY_FLAGS)
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
if (APPLE)
  add_linker_flag_if_supported(-Wl,-bind_at_load LD_SECURITY_FLAGS)
  add_linker_flag_if_supported(-Wl,-dead_strip LD_SECURITY_FLAGS)
  add_linker_flag_if_supported(-Wl,-dead_strip_dylibs LD_SECURITY_FLAGS)
endif()
if (NOT APPLE AND NOT (WIN32 AND CMAKE_C_COMPILER_ID STREQUAL "GNU"))
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

# some windows linker bits
if (WIN32)
  add_linker_flag_if_supported(-Wl,--dynamicbase LD_SECURITY_FLAGS)
  add_linker_flag_if_supported(-Wl,--nxcompat LD_SECURITY_FLAGS)
  add_linker_flag_if_supported(-Wl,--high-entropy-va LD_SECURITY_FLAGS)
endif()

if(STATIC)
  add_linker_flag_if_supported(-static-libgcc STATIC_FLAGS)
  add_linker_flag_if_supported(-static-libstdc++ STATIC_FLAGS)
  if(MINGW)
    add_linker_flag_if_supported(-static STATIC_FLAGS)
  endif()
endif()

# With GCC 6.1.1 the compiled binary malfunctions due to aliasing. Until that
# is fixed in the code (Issue #847), force compiler to be conservative.
add_c_flag_if_supported(-fno-strict-aliasing C_SECURITY_FLAGS)
add_cxx_flag_if_supported(-fno-strict-aliasing CXX_SECURITY_FLAGS)

add_c_flag_if_supported(-fPIC C_SECURITY_FLAGS)
add_cxx_flag_if_supported(-fPIC CXX_SECURITY_FLAGS)

message(STATUS "Using C security hardening flags: ${C_SECURITY_FLAGS}")
message(STATUS "Using C++ security hardening flags: ${CXX_SECURITY_FLAGS}")
message(STATUS "Using linker security hardening flags: ${LD_SECURITY_FLAGS}")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11 ${C_SECURITY_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 ${CXX_SECURITY_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LD_SECURITY_FLAGS} ${STATIC_FLAGS}")

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
    find_library(VERSION_LIBRARY version PATHS /usr/x86_64-w64-mingw32/lib)
    if(VERSION_LIBRARY STREQUAL "VERSION_LIBRARY-NOTFOUND")
      set(VERSION_LIBRARY Version)
    endif()
    list(APPEND EXTRA_LIBRARIES setupapi ${VERSION_LIBRARY})
  endif()
endif()

add_subdirectory(external)
add_subdirectory(translations)
add_subdirectory(src)
