add_library(i2p STATIC
    I2PDManager.cpp
)

find_package(ZLIB REQUIRED)

find_package(Boost REQUIRED)

target_include_directories(i2p
    PRIVATE
        "../../external/i2pd/libi2pd"
        "../../external/i2pd/libi2pd_client"
        "../../external/i2pd/i18n"
        ${Boost_INCLUDE_DIRS}
)

target_link_libraries(i2p
    PRIVATE
        libi2pdclient
        libi2pd
        libi2pdlang
        ZLIB::ZLIB
)
