#  Copyright (c) 2014-2024, The Monero Project
#
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without modification, are
#  permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice, this list of
#     conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright notice, this list
#     of conditions and the following disclaimer in the documentation and/or other
#     materials provided with the distribution.
#
#  3. Neither the name of the copyright holder nor the names of its contributors may be
#     used to endorse or promote products derived from this software without specific
#     prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
#  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
#  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
#  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
#  THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

include_guard(GLOBAL)

option(MONERO_GUI_BUNDLE_I2P "Copy a bundled i2p router binary next to the GUI" ON)
set(I2P_ROUTER_SOURCE "" CACHE FILEPATH "Path to a prebuilt i2p router executable to include in packages")

# SHA256 hashes for bundled i2pd binaries (i2pd v2.56.0 / v2.59.0)
set(I2P_SHA256_darwin-macos  "79a962913668a968282b10dae0b5ae8aabf5b2758e7bd2b2a32e7caa81b0bb63")
set(I2P_SHA256_linux-x86_64  "a34b0612f8f717fe022973042db63231e71c2074e0653fedadbcc87377bed202")
set(I2P_SHA256_linux-aarch64 "6ad067971e23fe64d014b67437657996d4500c9da12b42979f221fd97a7290e0")
set(I2P_SHA256_win64         "e631f95919e43f548567fff576b98ae5ab64607fd7b2095d83765829f6449029")

function(_monero_locate_i2p_router)
    if(I2P_ROUTER_SOURCE)
        return()
    endif()

    set(_search_patterns
        "${CMAKE_SOURCE_DIR}/external/i2p/bin/*/i2pd*"
        "${CMAKE_SOURCE_DIR}/external/i2p/bin/i2pd*"
    )

    set(_candidates)
    foreach(_pattern IN LISTS _search_patterns)
        file(GLOB _matches ${_pattern})
        list(APPEND _candidates ${_matches})
    endforeach()

    list(LENGTH _candidates _cand_len)
    if(_cand_len EQUAL 0)
        return()
    endif()

    list(SORT _candidates)

    set(_selected "")
    if(WIN32)
        foreach(_cand IN LISTS _candidates)
            get_filename_component(_ext "${_cand}" EXT)
            if(_ext STREQUAL ".exe")
                set(_selected "${_cand}")
                break()
            endif()
        endforeach()
    elseif(APPLE)
        foreach(_cand IN LISTS _candidates)
            if(_cand MATCHES "darwin")
                set(_selected "${_cand}")
                break()
            endif()
        endforeach()
    elseif(UNIX)
        # Detect host architecture and pick matching binary
        if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
            set(_arch_pattern "aarch64")
        else()
            set(_arch_pattern "x86_64")
        endif()
        foreach(_cand IN LISTS _candidates)
            if(_cand MATCHES "${_arch_pattern}")
                set(_selected "${_cand}")
                break()
            endif()
        endforeach()
    endif()

    if(NOT _selected)
        list(GET _candidates 0 _selected)
    endif()

    if(_selected)
        set(I2P_ROUTER_SOURCE "${_selected}" CACHE FILEPATH "Path to a prebuilt i2p router executable to include in packages" FORCE)
        message(STATUS "Auto-detected I2P router binary at ${I2P_ROUTER_SOURCE}")
    endif()
endfunction()

if(MONERO_GUI_BUNDLE_I2P)
    _monero_locate_i2p_router()
endif()

function(monero_bundle_i2p target_name)
    if(NOT MONERO_GUI_BUNDLE_I2P)
        message(STATUS "I2P bundling disabled via MONERO_GUI_BUNDLE_I2P=OFF")
        return()
    endif()

    if(NOT I2P_ROUTER_SOURCE)
        message(STATUS "No I2P router supplied (set I2P_ROUTER_SOURCE) – GUI will require it at runtime")
        return()
    endif()

    if(NOT EXISTS "${I2P_ROUTER_SOURCE}")
        message(FATAL_ERROR "I2P router source '${I2P_ROUTER_SOURCE}' does not exist")
    endif()

    # Verify SHA256 hash of the bundled binary
    get_filename_component(_i2p_dir "${I2P_ROUTER_SOURCE}" DIRECTORY)
    get_filename_component(_i2p_platform "${_i2p_dir}" NAME)
    if(DEFINED I2P_SHA256_${_i2p_platform})
        file(SHA256 "${I2P_ROUTER_SOURCE}" _actual_hash)
        if(NOT _actual_hash STREQUAL "${I2P_SHA256_${_i2p_platform}}")
            message(FATAL_ERROR
                "I2P router binary hash mismatch for '${I2P_ROUTER_SOURCE}'!\n"
                "  Expected: ${I2P_SHA256_${_i2p_platform}}\n"
                "  Got:      ${_actual_hash}\n"
                "The binary may have been tampered with.")
        endif()
        message(STATUS "I2P router binary hash verified OK (${_i2p_platform})")
    endif()

    if(WIN32)
        set(_i2p_target_name "i2pd.exe")
    else()
        set(_i2p_target_name "i2pd")
    endif()

    add_custom_command(TARGET ${target_name} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "${I2P_ROUTER_SOURCE}" "$<TARGET_FILE_DIR:${target_name}>/${_i2p_target_name}"
        COMMENT "Copying bundled i2p router to output directory"
    )

    if(UNIX AND NOT WIN32)
        add_custom_command(TARGET ${target_name} POST_BUILD
            COMMAND chmod a+rx "$<TARGET_FILE_DIR:${target_name}>/${_i2p_target_name}"
            COMMENT "Ensuring i2p router is executable"
        )
    endif()
endfunction()
