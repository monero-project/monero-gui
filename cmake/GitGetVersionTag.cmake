# Copyright (c) 2014-2019, The Monero Project
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
# 
# Parts of this file are originally copyright (c) 2012-2013 The Cryptonote developers

function (git_get_version_tag git directory result_var)
  execute_process(COMMAND "${git}" rev-parse --short HEAD
    WORKING_DIRECTORY ${directory}
    OUTPUT_VARIABLE COMMIT
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(NOT COMMIT)
    message(WARNING "${directory}: cannot determine current commit. Make sure that you are building from a Git working tree")
    set(${result_var} "unknown" PARENT_SCOPE)
    return()
  endif()

  execute_process(COMMAND "${git}" describe --tags --exact-match
    WORKING_DIRECTORY ${directory}
    OUTPUT_VARIABLE TAG
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(TAG)
    message(STATUS "${directory}: building tagged release ${TAG}-${COMMIT}")
    set(${result_var} "${TAG}-${COMMIT}" PARENT_SCOPE)
    return()
  endif()

  execute_process(COMMAND "${git}" describe --tags --long
    WORKING_DIRECTORY ${directory}
    OUTPUT_VARIABLE MOST_RECENT_TAG
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(MOST_RECENT_TAG)
    message(STATUS "${directory}: ahead of or behind a tagged release, building ${MOST_RECENT_TAG}")
    set(${result_var} "${MOST_RECENT_TAG}" PARENT_SCOPE)
    return()
  endif()

  message(STATUS "${directory}: building ${COMMIT} commit")
  set(${result_var} "${COMMIT}" PARENT_SCOPE)
endfunction()
