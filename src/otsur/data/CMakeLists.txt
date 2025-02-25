set(QRCODE_SOURCE
    MoneroData.cpp
)
set(QRCODE_HEADERS
    MoneroData.h
    MoneroTxData.h
    MoneroWalletData.h
    UrTypes.h
)

if (QT_VERSION_MAJOR EQUAL 6)
    find_package(Qt6 COMPONENTS Core REQUIRED)
else()
    find_package(Qt5 COMPONENTS Core REQUIRED)
endif()
message("qrcode Qt version: " ${QT_VERSION} "(Qt" ${QT_VERSION_MAJOR} ")")

add_library(otsdata STATIC ${QRCODE_SOURCE} ${QRCODE_HEADERS})
target_include_directories(otsdata PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(otsdata PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
)
