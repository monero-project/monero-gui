if(NOT DEFINED EXECUTABLE)
    message(FATAL_ERROR "EXECUTABLE is not set")
endif()

if(NOT DEFINED INSTALL_NAME_TOOL)
    set(INSTALL_NAME_TOOL install_name_tool)
endif()

execute_process(
    COMMAND otool -l "${EXECUTABLE}"
    OUTPUT_VARIABLE _otool_output
    RESULT_VARIABLE _otool_result
)

if(NOT _otool_result EQUAL 0)
    message(FATAL_ERROR "Failed to read rpaths from ${EXECUTABLE}")
endif()

string(REGEX MATCHALL "path (/opt/homebrew|/usr/local)[^ \n]*" _homebrew_rpath_lines "${_otool_output}")

foreach(_line IN LISTS _homebrew_rpath_lines)
    string(REGEX REPLACE "^path " "" _rpath "${_line}")

    message(STATUS "Deleting Homebrew rpath: ${_rpath}")

    execute_process(
        COMMAND "${INSTALL_NAME_TOOL}" -delete_rpath "${_rpath}" "${EXECUTABLE}"
        RESULT_VARIABLE _delete_result
        OUTPUT_QUIET
        ERROR_QUIET
    )
endforeach()
