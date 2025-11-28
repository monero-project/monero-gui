# Install script for directory: /Users/gjeane/work/draft_3/monero-gui/src

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE DIRECTORY FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-wallet-gui.app" USE_SOURCE_PERMISSIONS)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/opt/homebrew/opt/qt@5/lib"
      -delete_rpath "/opt/homebrew/opt/icu4c/lib"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/wallet/api"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/src/openpgp"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/translations"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/wallet"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/net"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/rpc"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/multisig"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device_trezor"
      -delete_rpath "/opt/homebrew/lib"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_core"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/blockchain_db"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/cryptonote_basic"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/checkpoints"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/ringct"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/device"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/hardforks"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/mnemonics"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/db_drivers/liblmdb"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-wallet-gui.app/Contents/MacOS/monero-wallet-gui")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/src/CMakeFiles/monero-wallet-gui.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin/scripts" TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE FILES "/Users/gjeane/work/draft_3/monero-gui/src/i2p/create_i2p_node.sh")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin/scripts" TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE FILES "/Users/gjeane/work/draft_3/monero-gui/src/i2p/create_i2p_node.sh")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin/scripts" TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE FILES "/Users/gjeane/work/draft_3/monero-gui/src/i2p/create_i2p_node_docker.sh")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/src/QR-Code-scanner/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/src/openpgp/cmake_install.cmake")
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/src/zxcvbn-c/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/gjeane/work/draft_3/monero-gui/cmake/src/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
