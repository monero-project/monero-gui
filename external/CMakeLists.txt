file(GLOB I2PD_SOURCES "i2pd/daemon/*.cpp" "i2pd/libi2pd/*.cpp" "i2pd/libi2pd_client/*.cpp" "i2pd/i18n/*.cpp")

add_library(quirc STATIC
    quirc/lib/decode.c
    quirc/lib/identify.c
    quirc/lib/quirc.c
    quirc/lib/version_db.c
)
set_target_properties(quirc PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(quirc PUBLIC quirc/lib)

add_library(i2pd STATIC
    ${I2PD_SOURCES}
)
set_target_properties(i2pd PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(i2pd PUBLIC i2pd/daemon i2pd/libi2pd i2pd/libi2pd_client i2pd/i18n)
