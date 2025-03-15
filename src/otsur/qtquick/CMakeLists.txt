set(URREGISTER_SOURCE
    UrRegister.cpp
    UrSender.cpp
    UrImageProvider.cpp
    UrCodeScanner.cpp
    ScanThread.cpp
)
set(URREGISTER_HEADERS
    UrRegister.h
    UrSender.h
    UrImageProvider.h
    UrCodeScanner.h
    ScanThread.h
    ScanResult.h
)
if (QT_VERSION_MAJOR EQUAL 6)
    find_package(Qt6 COMPONENTS Core Gui Widgets MultimediaWidgets QUIET)
else()
    find_package(Qt5 COMPONENTS Core Gui Widgets MultimediaWidgets REQUIRED)
endif()
find_package(ZXing REQUIRED)

add_library(otsqtquick STATIC ${URREGISTER_SOURCE} ${URREGISTER_HEADERS})
target_include_directories(otsqtquick PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR})

target_link_libraries(otsqtquick PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Widgets
    Qt::MultimediaWidgets
    qrcode
    bcur
    qrencode
    otsdata
    ZXing::ZXing
)
