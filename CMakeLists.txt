cmake_minimum_required(VERSION 3.10)
project(monero-gui)

message(STATUS "Initiating compile using CMake ${CMAKE_VERSION}")

set(LINUX ON)
set(DEBUG ON)
set(CMAKE_BUILD_TYPE Release)

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

if(STATIC)
	message(STATUS "Initiating static build")
	set(Boost_USE_STATIC_LIBS ON)
	set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
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

find_package(Qt5Core REQUIRED)
find_package(Qt5Quick REQUIRED)
find_package(Qt5Widgets REQUIRED)
find_package(Qt5Gui REQUIRED)
find_package(Qt5Network REQUIRED)
find_package(Qt5Qml REQUIRED)
message(STATUS "${CMAKE_MODULE_PATH}")
find_package(Qt5Multimedia REQUIRED)
find_package(Qt5Xml REQUIRED)
find_package(Qt5XmlPatterns REQUIRED)
find_package(Qt5Svg REQUIRED)

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
    # This is necessary because otherwise CMake will make Boost libraries -lfoo
    # rather than a full path. Unfortunately, this makes the shared libraries get
    # linked due to a bug in CMake which misses putting -static flags around the
    # -lfoo arguments.
    set(DEFLIB ${msys2_install_path}/mingw${ARCH_WIDTH}/lib)
    list(REMOVE_ITEM CMAKE_C_IMPLICIT_LINK_DIRECTORIES ${DEFLIB})
    list(REMOVE_ITEM CMAKE_CXX_IMPLICIT_LINK_DIRECTORIES ${DEFLIB})
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
    list(APPEND EXTRA_LIBRARIES setupapi)
  endif()
endif()

add_subdirectory(src)

# Required to make wallet_merged build before the gui
add_dependencies(monero-gui wallet_merged)

