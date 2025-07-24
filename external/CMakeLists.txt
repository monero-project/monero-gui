add_library(quirc STATIC
    quirc/lib/decode.c
    quirc/lib/identify.c
    quirc/lib/quirc.c
    quirc/lib/version_db.c
)
set_target_properties(quirc PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(quirc PUBLIC quirc/lib)

set(CMAKE_CXX_STANDARD 17)
option(WITH_LIBRARY "" OFF)
if (STATIC)
    option(WITH_STATIC "" ON)
endif()
add_subdirectory(i2pd/build)

if(WIN32)
    set(I2PD_BINARY ${CMAKE_BINARY_DIR}/external/i2pd/build/i2pd.exe)
else()
    set(I2PD_BINARY ${CMAKE_BINARY_DIR}/external/i2pd/build/i2pd)
endif()
