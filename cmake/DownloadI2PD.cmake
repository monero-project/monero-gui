# Copyright (c) 2014-2023, The Monero Project
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of
#    conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list
#    of conditions and the following disclaimer in the documentation and/or other
#    materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be
#    used to endorse or promote products derived from this software without specific
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Module to download and prepare I2P daemon binaries

# Set I2P daemon version and URLs based on platform
set(I2PD_VERSION "2.45.1")

if(WIN32)
    set(I2PD_BIN_URL "https://github.com/PurpleI2P/i2pd/releases/download/${I2PD_VERSION}/i2pd_${I2PD_VERSION}_win64.zip")
    set(I2PD_BIN_FILENAME "i2pd_${I2PD_VERSION}_win64.zip")
    set(I2PD_BIN_HASH "a1f4b0e294ee6a051a1103f13a10b4d6e70eec5e4cbe7b9f6fc76cc3e27fa55c")
    set(I2PD_EXTRACT_BIN "i2pd.exe")
elseif(APPLE)
    set(I2PD_BIN_URL "https://github.com/PurpleI2P/i2pd/releases/download/${I2PD_VERSION}/i2pd_${I2PD_VERSION}_osx.tar.gz")
    set(I2PD_BIN_FILENAME "i2pd_${I2PD_VERSION}_osx.tar.gz")
    set(I2PD_BIN_HASH "a4551f3f92faf3438feccd433f24e302b4fee0c11c2f485f696b8e0be2afe79c")
    set(I2PD_EXTRACT_BIN "i2pd")
elseif(UNIX)
    # For Linux, use the appropriate architecture
    if(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
        set(I2PD_BIN_URL "https://github.com/PurpleI2P/i2pd/releases/download/${I2PD_VERSION}/i2pd_${I2PD_VERSION}_linux_x64.tar.gz")
        set(I2PD_BIN_FILENAME "i2pd_${I2PD_VERSION}_linux_x64.tar.gz")
        set(I2PD_BIN_HASH "0be54ffe5d3103fb5a1d0e46c780a53eda4234f506d4a87bdfc9b03d81e9bd11")
    else()
        set(I2PD_BIN_URL "https://github.com/PurpleI2P/i2pd/releases/download/${I2PD_VERSION}/i2pd_${I2PD_VERSION}_linux_i386.tar.gz")
        set(I2PD_BIN_FILENAME "i2pd_${I2PD_VERSION}_linux_i386.tar.gz")
        set(I2PD_BIN_HASH "53d70e3551b1e69c65d0aaab57d9da73f436e47c6ede908a7f9d4f2f44ef5a6c")
    endif()
    set(I2PD_EXTRACT_BIN "i2pd")
endif()

# Target directory for I2P daemon binaries
set(I2PD_BIN_DIR "${CMAKE_BINARY_DIR}/bin")

# Download I2P daemon binary if not already present
if(NOT EXISTS "${I2PD_BIN_DIR}/${I2PD_EXTRACT_BIN}")
    message(STATUS "Downloading I2P daemon binary from ${I2PD_BIN_URL}")
    
    # Create binary directory if it doesn't exist
    file(MAKE_DIRECTORY ${I2PD_BIN_DIR})
    
    # Download I2P daemon binary
    file(DOWNLOAD ${I2PD_BIN_URL} "${I2PD_BIN_DIR}/${I2PD_BIN_FILENAME}"
        EXPECTED_HASH SHA256=${I2PD_BIN_HASH}
        SHOW_PROGRESS
        TLS_VERIFY ON)
    
    # Extract I2P daemon binary
    if(WIN32)
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xzf "${I2PD_BIN_DIR}/${I2PD_BIN_FILENAME}"
            WORKING_DIRECTORY ${I2PD_BIN_DIR}
        )
    else()
        execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xzf "${I2PD_BIN_DIR}/${I2PD_BIN_FILENAME}"
            WORKING_DIRECTORY ${I2PD_BIN_DIR}
        )
        
        # Make binary executable
        execute_process(
            COMMAND chmod +x "${I2PD_BIN_DIR}/${I2PD_EXTRACT_BIN}"
        )
    endif()
    
    message(STATUS "I2P daemon binary extracted to ${I2PD_BIN_DIR}/${I2PD_EXTRACT_BIN}")
else()
    message(STATUS "I2P daemon binary already exists at ${I2PD_BIN_DIR}/${I2PD_EXTRACT_BIN}")
endif()

# Install I2P daemon binary
install(FILES "${I2PD_BIN_DIR}/${I2PD_EXTRACT_BIN}" DESTINATION bin) 