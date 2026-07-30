add_library(zxcvbn STATIC zxcvbn.c)
set_target_properties(zxcvbn PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_include_directories(zxcvbn PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_compile_definitions(zxcvbn PRIVATE CHARSET_SIZE=49)
