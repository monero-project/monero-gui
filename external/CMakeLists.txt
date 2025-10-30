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
    if (MINGW)
        set(WITH_STATIC ON)
        set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)
        set(ZLIB_INCLUDE_DIR /usr/x86_64-w64-mingw32/include)
        set(ZLIB_LIBRARY /usr/x86_64-w64-mingw32/lib/libz.a)
    else()
        set(Boost_USE_STATIC_RUNTIME ON)
    endif()
else()
    if (MINGW)
        set(WITH_STATIC ON)
    endif()
endif()

if (APPLE)
    set(HOMEBREW 1)
endif()

add_subdirectory(i2pd/build)

if(WIN32)
    set(I2PD_BINARY ${CMAKE_BINARY_DIR}/external/i2pd/build/i2pd.exe)
    set(I2PD_BIN ${CMAKE_BINARY_DIR}/bin/i2pd.exe)
else()
    set(I2PD_BINARY ${CMAKE_BINARY_DIR}/external/i2pd/build/i2pd)
    set(I2PD_BIN ${CMAKE_BINARY_DIR}/bin/i2pd)
endif()

add_custom_target(copy_i2pd ALL
        DEPENDS ${I2PD_BINARY}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/bin
    COMMAND ${CMAKE_COMMAND} -E copy ${I2PD_BINARY} ${I2PD_BIN})
