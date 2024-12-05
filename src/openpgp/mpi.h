// Copyright (c) 2020-2024, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#pragma once

#include <gcrypt.h>

namespace openpgp
{

class mpi
{
public:
  mpi(const mpi &) = delete;
  mpi &operator=(const mpi &) = delete;

  mpi(mpi &&other)
    : data(other.data)
  {
    other.data = nullptr;
  }

  template <
    typename byte_container,
    typename = typename std::enable_if<(sizeof(typename byte_container::value_type) == 1)>::type>
  mpi(const byte_container &buffer, gcry_mpi_format format = GCRYMPI_FMT_USG)
    : mpi(&buffer[0], buffer.size(), format)
  {
  }

  mpi(const void *buffer, size_t size, gcry_mpi_format format = GCRYMPI_FMT_USG)
  {
    if (gcry_mpi_scan(&data, format, buffer, size, nullptr) != GPG_ERR_NO_ERROR)
    {
      throw std::runtime_error("failed to read mpi from buffer");
    }
  }

  ~mpi()
  {
    gcry_mpi_release(data);
  }

  const gcry_mpi_t &get() const
  {
    return data;
  }

private:
  gcry_mpi_t data;
};

} // namespace openpgp
