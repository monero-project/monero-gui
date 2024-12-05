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

#include <vector>

#include <gcrypt.h>
#include <span.h>

namespace openpgp
{

class hash
{
public:
  enum algorithm : uint8_t
  {
    sha256 = 8,
  };

  hash(const hash &) = delete;
  hash &operator=(const hash &) = delete;

  hash(uint8_t algorithm)
    : algo(algorithm)
    , consumed(0)
  {
    if (gcry_md_open(&md, algo, 0) != GPG_ERR_NO_ERROR)
    {
      throw std::runtime_error("failed to create message digest object");
    }
  }

  ~hash()
  {
    gcry_md_close(md);
  }

  hash &operator<<(uint8_t byte)
  {
    gcry_md_putc(md, byte);
    ++consumed;
    return *this;
  }

  hash &operator<<(const epee::span<const uint8_t> &bytes)
  {
    gcry_md_write(md, &bytes[0], bytes.size());
    consumed += bytes.size();
    return *this;
  }

  hash &operator<<(const std::vector<uint8_t> &bytes)
  {
    return *this << epee::to_span(bytes);
  }

  std::vector<uint8_t> finish() const
  {
    std::vector<uint8_t> result(gcry_md_get_algo_dlen(algo));
    const void *digest = gcry_md_read(md, algo);
    if (digest == nullptr)
    {
      throw std::runtime_error("failed to read the digest");
    }
    memcpy(&result[0], digest, result.size());
    return result;
  }

  size_t consumed_bytes() const
  {
    return consumed;
  }

private:
  const uint8_t algo;
  gcry_md_hd_t md;
  size_t consumed;
};

}
