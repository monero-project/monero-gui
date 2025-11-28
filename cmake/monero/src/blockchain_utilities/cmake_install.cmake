# Install script for directory: /Users/gjeane/work/draft_3/monero-gui/monero/src/blockchain_utilities

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-blockchain-import")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-import" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-import")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blocks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-import")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-import")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/CMakeFiles/blockchain_import.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-blockchain-export")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-export" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-export")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-export")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-export")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/CMakeFiles/blockchain_export.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-blockchain-mark-spent-outputs")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-mark-spent-outputs" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-mark-spent-outputs")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/wallet"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/rpc"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/multisig"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/mnemonics"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device_trezor"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      -delete_rpath "/opt/homebrew/lib"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/net"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-mark-spent-outputs")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-mark-spent-outputs")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/CMakeFiles/blockchain_blackball.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-blockchain-usage")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-usage" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-usage")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-usage")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-usage")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/CMakeFiles/blockchain_usage.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-blockchain-ancestry")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-ancestry" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-ancestry")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-ancestry")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-ancestry")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/CMakeFiles/blockchain_ancestry.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-blockchain-depth")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-depth" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-depth")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-depth")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-depth")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/CMakeFiles/blockchain_depth.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-blockchain-stats")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-stats" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-stats")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-stats")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-stats")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/CMakeFiles/blockchain_stats.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-blockchain-prune-known-spent-data")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-prune-known-spent-data" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-prune-known-spent-data")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/p2p"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/net"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-prune-known-spent-data")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-prune-known-spent-data")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/CMakeFiles/blockchain_prune_known_spent_data.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-blockchain-prune")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-prune" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-prune")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/p2p"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/net"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-prune")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-blockchain-prune")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/CMakeFiles/blockchain_prune.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
