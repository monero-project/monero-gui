# Install script for directory: /Users/gjeane/work/draft_3/monero-gui/monero/src/gen_ssl_cert

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/Users/gjeane/work/draft_3/monero-gui/cmake/bin/monero-gen-ssl-cert")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-gen-ssl-cert" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-gen-ssl-cert")
    execute_process(COMMAND /usr/bin/install_name_tool
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/common"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/contrib/epee/src"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/crypto"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/randomx"
      -delete_rpath "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/external/easylogging++"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-gen-ssl-cert")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" -u -r "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/monero-gen-ssl-cert")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Unspecified" OR NOT CMAKE_INSTALL_COMPONENT)
  include("/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/gen_ssl_cert/CMakeFiles/gen_ssl_cert.dir/install-cxx-module-bmi-Debug.cmake" OPTIONAL)
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/Users/gjeane/work/draft_3/monero-gui/cmake/monero/src/gen_ssl_cert/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
