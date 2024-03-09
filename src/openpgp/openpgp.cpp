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

#include "openpgp.h"

#include <algorithm>
#include <locale>
#include <vector>

#include <string_coding.h>

#include "hash.h"
#include "mpi.h"
#include "packet_stream.h"
#include "s_expression.h"
#include "serialization.h"

namespace openpgp
{
namespace
{

std::string::const_iterator find_next_line(std::string::const_iterator begin, const std::string::const_iterator &end)
{
  begin = std::find(begin, end, '\n');
  return begin != end ? ++begin : end;
}

std::string::const_iterator find_line_starting_with(
  std::string::const_iterator it,
  const std::string::const_iterator &end,
  const std::string &starts_with)
{
  for (std::string::const_iterator next_line; it != end; it = next_line)
  {
    next_line = find_next_line(it, end);
    const size_t line_length = static_cast<size_t>(std::distance(it, next_line));
    if (line_length >= starts_with.size() && std::equal(starts_with.begin(), starts_with.end(), it))
    {
      return it;
    }
  }
  return end;
}

std::string::const_iterator find_empty_line(std::string::const_iterator it, const std::string::const_iterator &end)
{
  for (; it != end && *it != '\r' && *it != '\n'; it = find_next_line(it, end))
  {
  }
  return it;
}

std::string get_armored_block_contents(const std::string &text, const std::string &block_name)
{
  static constexpr const char dashes[] = "-----";
  const std::string armor_header = dashes + block_name + dashes;
  auto block_start = find_line_starting_with(text.begin(), text.end(), armor_header);
  auto block_headers = find_next_line(block_start, text.end());
  auto block_end = find_line_starting_with(block_headers, text.end(), dashes);
  auto contents_begin = find_next_line(find_empty_line(block_headers, block_end), block_end);
  if (contents_begin == block_end)
  {
    throw std::runtime_error("armored block not found");
  }
  return std::string(contents_begin, block_end);
}

} // namespace

public_key_rsa::public_key_rsa(s_expression expression, size_t bits)
  : m_expression(std::move(expression))
  , m_bits(bits)
{
}

const gcry_sexp_t &public_key_rsa::get() const
{
  return m_expression.get();
}

size_t public_key_rsa::bits() const
{
  return m_bits;
}

public_key_block::public_key_block(const std::string &armored)
  : public_key_block(epee::to_byte_span(epee::to_span(epee::string_encoding::base64_decode(
      strip_line_breaks(get_armored_block_contents(armored, "BEGIN PGP PUBLIC KEY BLOCK"))))))
{
}

// TODO: Public-Key expiration, User ID and Public-Key certification, Subkey binding checks
public_key_block::public_key_block(const epee::span<const uint8_t> buffer)
{
  packet_stream packets(buffer);

  const std::vector<uint8_t> *data = packets.find_first(packet_tag::type::user_id);
  if (data == nullptr)
  {
    throw std::runtime_error("user id is missing");
  }
  m_user_id.assign(data->begin(), data->end());

  const auto append_public_key = [this](const std::vector<uint8_t> &data) {
    deserializer<std::vector<uint8_t>> serialized(data);

    const auto version = serialized.read_big_endian<uint8_t>();
    if (version != 4)
    {
      throw std::runtime_error("unsupported public key version");
    }

    /* const auto timestamp  = */ serialized.read_big_endian<uint32_t>();

    const auto algorithm = serialized.read_big_endian<uint8_t>();
    if (algorithm != openpgp::algorithm::rsa)
    {
      throw std::runtime_error("unsupported public key algorithm");
    }

    {
      const mpi public_key_n = serialized.read_mpi();
      const mpi public_key_e = serialized.read_mpi();

      emplace_back(
        s_expression("(public-key (rsa (n %m) (e %m)))", public_key_n.get(), public_key_e.get()),
        gcry_mpi_get_nbits(public_key_n.get()));
    }
  };

  data = packets.find_first(packet_tag::type::public_key);
  if (data == nullptr)
  {
    throw std::runtime_error("public key is missing");
  }
  append_public_key(*data);

  packets.for_each(packet_tag::type::public_subkey, append_public_key);
}

std::string public_key_block::user_id() const
{
  return m_user_id;
}

// TODO: Signature expiration check
signature_rsa::signature_rsa(
  uint8_t algorithm,
  std::pair<uint8_t, uint8_t> hash_leftmost_bytes,
  uint8_t hash_algorithm,
  const std::vector<uint8_t> &hashed_data,
  type type,
  s_expression signature,
  uint8_t version)
  : m_hash_algorithm(hash_algorithm)
  , m_hash_leftmost_bytes(hash_leftmost_bytes)
  , m_hashed_appendix(format_hashed_appendix(algorithm, hash_algorithm, hashed_data, type, version))
  , m_signature(std::move(signature))
  , m_type(type)
{
}

signature_rsa signature_rsa::from_armored(const std::string &armored_signed_message)
{
  return from_base64(get_armored_block_contents(armored_signed_message, "BEGIN PGP SIGNATURE"));
}

signature_rsa signature_rsa::from_base64(const std::string &base64)
{
  std::string decoded = epee::string_encoding::base64_decode(strip_line_breaks(base64));
  epee::span<const uint8_t> buffer(reinterpret_cast<const uint8_t *>(&decoded[0]), decoded.size());
  return from_buffer(buffer);
}

signature_rsa signature_rsa::from_buffer(const epee::span<const uint8_t> input)
{
  packet_stream packets(input);

  const std::vector<uint8_t> *data = packets.find_first(packet_tag::type::signature);
  if (data == nullptr)
  {
    throw std::runtime_error("signature is missing");
  }

  deserializer<std::vector<uint8_t>> buffer(*data);

  const auto version = buffer.read_big_endian<uint8_t>();
  if (version != 4)
  {
    throw std::runtime_error("unsupported signature version");
  }

  const auto signature_type = static_cast<type>(buffer.read_big_endian<uint8_t>());

  const auto algorithm = buffer.read_big_endian<uint8_t>();
  if (algorithm != openpgp::algorithm::rsa)
  {
    throw std::runtime_error("unsupported signature algorithm");
  }

  const auto hash_algorithm = buffer.read_big_endian<uint8_t>();

  const auto hashed_data_length = buffer.read_big_endian<uint16_t>();
  std::vector<uint8_t> hashed_data = buffer.read(hashed_data_length);

  const auto unhashed_data_length = buffer.read_big_endian<uint16_t>();
  buffer.read_span(unhashed_data_length);

  std::pair<uint8_t, uint8_t> hash_leftmost_bytes{buffer.read_big_endian<uint8_t>(), buffer.read_big_endian<uint8_t>()};

  const mpi signature = buffer.read_mpi();

  return signature_rsa(
    algorithm,
    std::move(hash_leftmost_bytes),
    hash_algorithm,
    hashed_data,
    signature_type,
    s_expression("(sig-val (rsa (s %m)))", signature.get()),
    version);
}

bool signature_rsa::verify(const epee::span<const uint8_t> message, const public_key_rsa &public_key) const
{
  const s_expression signed_data = hash_message(message, public_key.bits());
  return gcry_pk_verify(m_signature.get(), signed_data.get(), public_key.get()) == 0;
}

s_expression signature_rsa::hash_message(const epee::span<const uint8_t> message, size_t public_key_bits) const
{
  switch (m_type)
  {
  case type::binary_document:
    return hash_bytes(message, public_key_bits);
  case type::canonical_text_document:
  {
    std::vector<uint8_t> crlf_formatted;
    crlf_formatted.reserve(message.size());
    const size_t message_size = message.size();
    for (size_t offset = 0; offset < message_size; ++offset)
    {
      const auto &character = message[offset];
      if (character == '\r')
      {
        continue;
      }
      if (character == '\n')
      {
        const bool skip_last_crlf = offset + 1 == message_size;
        if (skip_last_crlf)
        {
          break;
        }
        crlf_formatted.push_back('\r');
      }
      crlf_formatted.push_back(character);
    }
    return hash_bytes(epee::to_span(crlf_formatted), public_key_bits);
  }
  default:
    throw std::runtime_error("unsupported signature type");
  }
}

std::vector<uint8_t> signature_rsa::hash_asn_object_id() const
{
  size_t size;
  if (gcry_md_algo_info(m_hash_algorithm, GCRYCTL_GET_ASNOID, nullptr, &size) != GPG_ERR_NO_ERROR)
  {
    throw std::runtime_error("failed to get ASN.1 Object Identifier (OID) size");
  }

  std::vector<uint8_t> asn_object_id(size);
  if (gcry_md_algo_info(m_hash_algorithm, GCRYCTL_GET_ASNOID, &asn_object_id[0], &size) != GPG_ERR_NO_ERROR)
  {
    throw std::runtime_error("failed to get ASN.1 Object Identifier (OID)");
  }

  return asn_object_id;
}

s_expression signature_rsa::hash_bytes(const epee::span<const uint8_t> message, size_t public_key_bits) const
{
  const std::vector<uint8_t> plain_hash = (hash(m_hash_algorithm) << message << m_hashed_appendix).finish();
  if (plain_hash.size() < 2)
  {
    throw std::runtime_error("insufficient message hash size");
  }
  if (plain_hash[0] != m_hash_leftmost_bytes.first || plain_hash[1] != m_hash_leftmost_bytes.second)
  {
    throw std::runtime_error("signature checksum doesn't match the expected value");
  }

  std::vector<uint8_t> asn_object_id = hash_asn_object_id();

  const size_t public_key_bytes = bits_to_bytes(public_key_bits);
  if (public_key_bytes < plain_hash.size() + asn_object_id.size() + 11)
  {
    throw std::runtime_error("insufficient public key bit length");
  }

  std::vector<uint8_t> emsa_pkcs1_v1_5_encoded;
  emsa_pkcs1_v1_5_encoded.reserve(public_key_bytes);
  emsa_pkcs1_v1_5_encoded.push_back(0);
  emsa_pkcs1_v1_5_encoded.push_back(1);
  const size_t ps_size = public_key_bytes - plain_hash.size() - asn_object_id.size() - 3;
  emsa_pkcs1_v1_5_encoded.insert(emsa_pkcs1_v1_5_encoded.end(), ps_size, 0xff);
  emsa_pkcs1_v1_5_encoded.push_back(0);
  emsa_pkcs1_v1_5_encoded.insert(emsa_pkcs1_v1_5_encoded.end(), asn_object_id.begin(), asn_object_id.end());
  emsa_pkcs1_v1_5_encoded.insert(emsa_pkcs1_v1_5_encoded.end(), plain_hash.begin(), plain_hash.end());

  mpi value(emsa_pkcs1_v1_5_encoded);
  return s_expression("(data (flags raw) (value %m))", value.get());
}

std::vector<uint8_t> signature_rsa::format_hashed_appendix(
  uint8_t algorithm,
  uint8_t hash_algorithm,
  const std::vector<uint8_t> &hashed_data,
  uint8_t type,
  uint8_t version)
{
  const uint16_t hashed_data_size = static_cast<uint16_t>(hashed_data.size());
  const uint32_t hashed_pefix_size = sizeof(version) + sizeof(type) + sizeof(algorithm) + sizeof(hash_algorithm) +
    sizeof(hashed_data_size) + hashed_data.size();

  std::vector<uint8_t> appendix;
  appendix.reserve(hashed_pefix_size + sizeof(version) + sizeof(uint8_t) + sizeof(hashed_pefix_size));
  appendix.push_back(version);
  appendix.push_back(type);
  appendix.push_back(algorithm);
  appendix.push_back(hash_algorithm);
  appendix.push_back(static_cast<uint8_t>(hashed_data_size >> 8));
  appendix.push_back(static_cast<uint8_t>(hashed_data_size));
  appendix.insert(appendix.end(), hashed_data.begin(), hashed_data.end());
  appendix.push_back(version);
  appendix.push_back(0xff);
  appendix.push_back(static_cast<uint8_t>(hashed_pefix_size >> 24));
  appendix.push_back(static_cast<uint8_t>(hashed_pefix_size >> 16));
  appendix.push_back(static_cast<uint8_t>(hashed_pefix_size >> 8));
  appendix.push_back(static_cast<uint8_t>(hashed_pefix_size));

  return appendix;
}

message_armored::message_armored(const std::string &message_armored)
  : m_message(get_armored_block_contents(message_armored, "BEGIN PGP SIGNED MESSAGE"))
{
}

message_armored::operator epee::span<const uint8_t>() const
{
  return epee::to_byte_span(epee::to_span(m_message));
}

} // namespace openpgp
