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

#include "mpi.h"

namespace openpgp
{

size_t bits_to_bytes(size_t bits)
{
  constexpr const uint16_t bits_in_byte = 8;
  return (bits + bits_in_byte - 1) / bits_in_byte;
}

std::string strip_line_breaks(const std::string &string)
{
  std::string result;
  result.reserve(string.size());
  for (const auto &character : string)
  {
    if (character != '\r' && character != '\n')
    {
      result.push_back(character);
    }
  }
  return result;
}

struct packet_tag
{
  enum type : uint8_t
  {
    signature = 2,
    public_key = 6,
    user_id = 13,
    public_subkey = 14,
  };

  const type packet_type;
  const size_t length;
};

template <
  typename byte_container,
  typename = typename std::enable_if<(sizeof(typename byte_container::value_type) == 1)>::type>
class deserializer
{
public:
  deserializer(byte_container buffer)
    : buffer(std::move(buffer))
    , cursor(0)
  {
  }

  bool empty() const
  {
    return buffer.size() - cursor == 0;
  }

  packet_tag read_packet_tag()
  {
    const auto tag = read_big_endian<uint8_t>();

    constexpr const uint8_t format_mask = 0b11000000;
    constexpr const uint8_t format_old_tag = 0b10000000;
    if ((tag & format_mask) != format_old_tag)
    {
      throw std::runtime_error("invalid packet tag");
    }

    const packet_tag::type packet_type = static_cast<packet_tag::type>((tag & 0b00111100) >> 2);
    const uint8_t length_type = tag & 0b00000011;

    size_t length;
    switch (length_type)
    {
    case 0:
      length = read_big_endian<uint8_t>();
      break;
    case 1:
      length = read_big_endian<uint16_t>();
      break;
    case 2:
      length = read_big_endian<uint32_t>();
      break;
    default:
      throw std::runtime_error("unsupported packet length type");
    }

    return {packet_type, length};
  }

  mpi read_mpi()
  {
    const size_t bit_length = read_big_endian<uint16_t>();
    return mpi(read_span(bits_to_bytes(bit_length)));
  }

  std::vector<uint8_t> read(size_t size)
  {
    if (buffer.size() - cursor < size)
    {
      throw std::runtime_error("insufficient buffer size");
    }

    const size_t offset = cursor;
    cursor += size;

    return {&buffer[offset], &buffer[cursor]};
  }

  template <typename T, typename = typename std::enable_if<std::is_integral<T>::value>::type>
  T read_big_endian()
  {
    if (buffer.size() - cursor < sizeof(T))
    {
      throw std::runtime_error("insufficient buffer size");
    }
    T result = 0;
    for (size_t read = 0; read < sizeof(T); ++read)
    {
      result = (result << 8) | static_cast<uint8_t>(buffer[cursor++]);
    }
    return result;
  }

  epee::span<const uint8_t> read_span(size_t size)
  {
    if (buffer.size() - cursor < size)
    {
      throw std::runtime_error("insufficient buffer size");
    }

    const size_t offset = cursor;
    cursor += size;

    return {reinterpret_cast<const uint8_t *>(&buffer[offset]), size};
  }

private:
  byte_container buffer;
  size_t cursor;
};

} // namespace openpgp
