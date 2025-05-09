set(CMAKE_CXX_STANDARD 17)

add_library(i2pmanager STATIC
    I2PDaemon.cpp
)

find_package(ZLIB REQUIRED)

target_link_libraries(i2pmanager
    PUBLIC
        Qt5::Core
    PRIVATE
        i2pddaemon
        i2pd
        i2pdclient
        i2pdlang
        ZLIB::ZLIB
        pthread
)
