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

#include <span.h>

#include "serialization.h"

namespace openpgp
{

class packet_stream
{
public:
  packet_stream(const epee::span<const uint8_t> buffer)
    : packet_stream(deserializer<epee::span<const uint8_t>>(buffer))
  {
  }

  template <
    typename byte_container,
    typename = typename std::enable_if<(sizeof(typename byte_container::value_type) == 1)>::type>
  packet_stream(deserializer<byte_container> buffer)
  {
    while (!buffer.empty())
    {
      packet_tag tag = buffer.read_packet_tag();
      packets.push_back({std::move(tag), buffer.read(tag.length)});
    }
  }

  const std::vector<uint8_t> *find_first(packet_tag::type type) const
  {
    for (const auto &packet : packets)
    {
      if (packet.first.packet_type == type)
      {
        return &packet.second;
      }
    }
    return nullptr;
  }

  template <typename Callback>
  void for_each(packet_tag::type type, Callback &callback) const
  {
    for (const auto &packet : packets)
    {
      if (packet.first.packet_type == type)
      {
        callback(packet.second);
      }
    }
  }

private:
  std::vector<std::pair<packet_tag, std::vector<uint8_t>>> packets;
};

} // namespace openpgp
