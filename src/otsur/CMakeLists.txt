cmake_minimum_required(VERSION 3.10)
project(libotsur VERSION 0.1 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

option(USE_EXTERNAL_QRENCODE "Use an external qrencode library" OFF)

add_subdirectory(bcur)
add_subdirectory(qrcode)
add_subdirectory(data)
add_subdirectory(qtquick)
if(NOT DEFINED USE_EXTERNAL_QRENCODE OR NOT USE_EXTERNAL_QRENCODE)
    add_subdirectory(qrencode)
endif()
