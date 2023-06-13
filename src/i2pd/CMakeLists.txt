add_library(i2p STATIC
    I2PDManager.cpp
)
find_package(ZLIB)
target_link_libraries(i2p PRIVATE i2pd ZLIB::ZLIB)
