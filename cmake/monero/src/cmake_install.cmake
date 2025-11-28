# Install script for directory: /Users/gjeane/work/draft_3/monero-gui/monero/src

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

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/lmdb/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/multisig/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/net/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/mnemonics/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/rpc/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/seraphis_crypto/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/serialization/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/wallet/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/p2p/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_protocol/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/simplewallet/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/gen_multisig/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/gen_ssl_cert/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/daemonizer/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/daemon/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_utilities/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/debug_utilities/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blocks/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device_trezor/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
