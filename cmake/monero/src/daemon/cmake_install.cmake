# Install script for directory: /Users/gjeane/work/draft_3/monero-gui/monero/src/daemon

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Debug")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monerod")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monerod" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monerod")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/daemonizer"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/rpc"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blocks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/serialization"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_protocol"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/p2p"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/net"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monerod")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monerod")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/daemon/CMakeFiles/daemon.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/daemon/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
