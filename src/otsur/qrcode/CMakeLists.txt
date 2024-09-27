set(QRCODE_SOURCE
    QrCode.cpp
)
set(QRCODE_HEADERS
    QrCode.h
    QrCode_p.h
)

if (QT_VERSION_MAJOR EQUAL 6)
    find_package(Qt6 COMPONENTS Core Gui Widgets Svg REQUIRED)
else()
    find_package(Qt5 COMPONENTS Core Gui Widgets Svg REQUIRED)
endif()
message("qrcode Qt version: " ${QT_VERSION} "(Qt" ${QT_VERSION_MAJOR} ")")

add_library(qrcode STATIC ${QRCODE_SOURCE} ${QRCODE_HEADERS})
target_include_directories(qrcode PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(qrcode PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Widgets
    Qt${QT_VERSION_MAJOR}::Svg
    qrencode
)
