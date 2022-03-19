set(PROJECT walletqt)

file(GLOB_RECURSE SOURCE_FILES *.cpp)
file(GLOB_RECURSE HEADER_FILES *.h)

if(APPLE)
    list(APPEND SOURCE_FILES "../qt/macoshelper.mm")
endif()

file(GLOB SOURCES_FOREIGN
  "../qt/*.cpp"
  "../daemon/*.cpp"
  "../model/*.cpp"
)

file(GLOB HEADERS_FOREIGN
  "../qt/*.h"
  "../daemon/*.h"
  "../model/*.h"
)

add_library(${PROJECT}
  ${SOURCE_FILES}
  ${HEADER_FILES}
  ${SOURCES_FOREIGN}
  ${HEADERS_FOREIGN}
)

# OpenGL
target_include_directories(${PROJECT} PUBLIC ${OPENGL_INCLUDE_DIR})
message(STATUS "OpenGL: include dir at ${OPENGL_INCLUDE_DIR}")
message(STATUS "OpenGL: libraries at ${OPENGL_LIBRARIES}")

target_include_directories(${PROJECT} PUBLIC
    ${CMAKE_SOURCE_DIR}/monero/include
    ${CMAKE_SOURCE_DIR}/monero/src
    ${CMAKE_SOURCE_DIR}/monero/external/qrcodegen
    ${CMAKE_SOURCE_DIR}/monero/external/easylogging++
    ${CMAKE_SOURCE_DIR}/monero/contrib/epee/include
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/src/QR-Code-scanner
    ${CMAKE_SOURCE_DIR}/src/zxcvbn-c
    ${CMAKE_SOURCE_DIR}/src/qt
    ${CMAKE_SOURCE_DIR}/src/daemon
    ${CMAKE_SOURCE_DIR}/src/monitor
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${X11_INCLUDE_DIR}
    ${Qt5Gui_PRIVATE_INCLUDE_DIRS}
)

target_link_libraries(${PROJECT}
  PUBLIC
    epee
    common
    net
    qrcodegen
    easylogging
    wallet_api
    ${QT5_LIBRARIES}
    ${EXTRA_LIBRARIES}
    openpgp
    qrdecoder
    translations
    zxcvbn
)
