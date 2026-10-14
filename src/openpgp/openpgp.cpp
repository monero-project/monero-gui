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
#include <locale> // needed by string_coding.h
#include <stdexcept>
#include <string>
#include <utility>
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

constexpr const uint8_t signature_type_subkey_binding = 0x18;
constexpr const uint8_t subpacket_type_key_flags = 27;
constexpr const uint8_t key_flag_sign_data = 0x02;

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

bool is_trailing_whitespace(char character)
{
  return character == ' ' || character == '\t' || character == '\r';
}

std::string get_armored_block_contents(const std::string &text, const std::string &header, const std::string &tail)
{
  static constexpr const char dashes[] = "-----";
  const std::string armor_header = dashes + header + dashes;
  auto block_start = find_line_starting_with(text.begin(), text.end(), armor_header);
  auto block_headers = find_next_line(block_start, text.end());
  auto block_end = find_line_starting_with(block_headers, text.end(), dashes);
  auto contents_begin = find_next_line(find_empty_line(block_headers, block_end), block_end);
  if (contents_begin == block_end)
  {
    throw std::runtime_error("armored block not found");
  }

  const std::string armor_tail = dashes + tail + dashes;
  if (static_cast<size_t>(std::distance(block_end, text.end())) < armor_tail.size() ||
    !std::equal(armor_tail.begin(), armor_tail.end(), block_end))
  {
    throw std::runtime_error("armor tail line not found");
  }

  return std::string(contents_begin, block_end);
}

bool is_base64(const std::string &base64)
{
  if (base64.size() % 4 != 0)
  {
    return false;
  }

  size_t padding = 0;
  while (padding < 2 && padding < base64.size() && base64[base64.size() - 1 - padding] == '=')
  {
    ++padding;
  }

  return std::all_of(base64.begin(), base64.end() - padding, [](char character) {
    return (character >= 'A' && character <= 'Z') || (character >= 'a' && character <= 'z') ||
      (character >= '0' && character <= '9') || character == '+' || character == '/';
  });
}

uint32_t crc24(const std::string &data)
{
  uint32_t crc = 0xb704ce;
  for (const char character : data)
  {
    crc ^= static_cast<uint32_t>(static_cast<uint8_t>(character)) << 16;
    for (size_t bit = 0; bit < 8; ++bit)
    {
      crc <<= 1;
      if (crc & 0x1000000)
      {
        crc ^= 0x1864cfb;
      }
    }
  }
  return crc & 0xffffff;
}

std::string decode_armored_contents(const std::string &contents)
{
  std::string base64;
  base64.reserve(contents.size());
  std::string checksum;
  bool checksum_found = false;
  for (auto line_begin = contents.begin(); line_begin != contents.end();)
  {
    const auto next_line = find_next_line(line_begin, contents.end());
    auto line_end = next_line;
    while (line_end != line_begin && (*(line_end - 1) == '\n' || is_trailing_whitespace(*(line_end - 1))))
    {
      --line_end;
    }

    if (line_begin != line_end)
    {
      if (checksum_found)
      {
        throw std::runtime_error("unexpected data after armor checksum");
      }

      if (*line_begin == '=')
      {
        checksum.assign(line_begin + 1, line_end);
        checksum_found = true;
      }
      else
      {
        base64.append(line_begin, line_end);
      }
    }

    line_begin = next_line;
  }

  if (!is_base64(base64))
  {
    throw std::runtime_error("invalid armored data");
  }
  std::string decoded = epee::string_encoding::base64_decode(base64);

  if (checksum_found)
  {
    if (checksum.size() != 4 || !is_base64(checksum))
    {
      throw std::runtime_error("invalid armor checksum");
    }
    const std::string checksum_decoded = epee::string_encoding::base64_decode(checksum);
    if (checksum_decoded.size() != 3)
    {
      throw std::runtime_error("invalid armor checksum");
    }
    const uint32_t expected = (static_cast<uint32_t>(static_cast<uint8_t>(checksum_decoded[0])) << 16) |
      (static_cast<uint32_t>(static_cast<uint8_t>(checksum_decoded[1])) << 8) |
      static_cast<uint32_t>(static_cast<uint8_t>(checksum_decoded[2]));
    if (crc24(decoded) != expected)
    {
      throw std::runtime_error("armor checksum mismatch");
    }
  }

  return decoded;
}

// RFC 4880 section 7.1
std::string get_cleartext_signed_text(const std::string &contents)
{
  std::string text;
  text.reserve(contents.size());
  for (auto line_begin = contents.begin(); line_begin != contents.end();)
  {
    const auto line_end = std::find(line_begin, contents.end(), '\n');

    if (line_begin != contents.begin())
    {
      text.push_back('\n');
    }

    auto begin = line_begin;
    if (std::distance(begin, line_end) >= 2 && *begin == '-' && *(begin + 1) == ' ')
    {
      begin += 2;
    }
    auto end = line_end;
    while (end != begin && is_trailing_whitespace(*(end - 1)))
    {
      --end;
    }
    text.append(begin, end);

    line_begin = line_end != contents.end() ? line_end + 1 : line_end;
  }
  return text;
}

bool is_rsa_public_key(const std::vector<uint8_t> &data)
{
  constexpr const size_t algorithm_offset = sizeof(uint8_t) + sizeof(uint32_t);
  return data.size() > algorithm_offset && data[0] == 4 && data[algorithm_offset] == openpgp::algorithm::rsa;
}

public_key_rsa read_public_key(const std::vector<uint8_t> &data)
{
  deserializer<epee::span<const uint8_t>> serialized(epee::to_span(data));

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

  const mpi public_key_n = serialized.read_mpi();
  const mpi public_key_e = serialized.read_mpi();

  return public_key_rsa(
    s_expression("(public-key (rsa (n %m) (e %m)))", public_key_n.get(), public_key_e.get()),
    gcry_mpi_get_nbits(public_key_n.get()));
}

bool subkey_binding_allows_signing(const std::vector<uint8_t> &data)
{
  deserializer<epee::span<const uint8_t>> signature(epee::to_span(data));

  if (signature.read_big_endian<uint8_t>() != 4 ||
    signature.read_big_endian<uint8_t>() != signature_type_subkey_binding)
  {
    return false;
  }

  /* const auto algorithm = */ signature.read_big_endian<uint8_t>();
  /* const auto hash_algorithm = */ signature.read_big_endian<uint8_t>();

  const auto hashed_data_length = signature.read_big_endian<uint16_t>();
  deserializer<epee::span<const uint8_t>> subpackets(signature.read_span(hashed_data_length));
  while (!subpackets.empty())
  {
    const size_t length = subpackets.read_subpacket_length();
    if (length == 0)
    {
      throw std::runtime_error("invalid signature subpacket length");
    }

    const uint8_t type = subpackets.read_big_endian<uint8_t>() & 0x7f;
    const epee::span<const uint8_t> subpacket = subpackets.read_span(length - 1);
    if (type == subpacket_type_key_flags)
    {
      return subpacket.size() > 0 && (subpacket[0] & key_flag_sign_data) != 0;
    }
  }

  return false;
}

} // namespace

bool initialize()
{
  if (gcry_control(GCRYCTL_INITIALIZATION_FINISHED_P))
  {
    return true;
  }

  if (gcry_check_version(GCRYPT_VERSION) == nullptr)
  {
    return false;
  }
  gcry_control(GCRYCTL_DISABLE_SECMEM, 0);
  gcry_control(GCRYCTL_INITIALIZATION_FINISHED, 0);
  return true;
}

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
  : public_key_block(epee::to_byte_span(epee::to_span(decode_armored_contents(
      get_armored_block_contents(armored, "BEGIN PGP PUBLIC KEY BLOCK", "END PGP PUBLIC KEY BLOCK")))))
{
}

// TODO: Public-Key expiration, User ID and Public-Key certification, Subkey binding signature verification
public_key_block::public_key_block(const epee::span<const uint8_t> buffer)
{
  const packet_stream packets(buffer);

  const std::vector<uint8_t> *data = packets.find_first(packet_tag::type::user_id);
  if (data == nullptr)
  {
    throw std::runtime_error("user id is missing");
  }
  m_user_id.assign(data->begin(), data->end());

  // Only use subkeys allowed to sign
  bool primary_key_found = false;
  const std::vector<uint8_t> *subkey = nullptr;
  packets.for_each([this, &primary_key_found, &subkey](packet_tag::type type, const std::vector<uint8_t> &packet) {
    switch (type)
    {
    case packet_tag::type::public_key:
      if (primary_key_found)
      {
        throw std::runtime_error("multiple public keys");
      }
      push_back(read_public_key(packet));
      primary_key_found = true;
      subkey = nullptr;
      break;
    case packet_tag::type::public_subkey:
      subkey = &packet;
      break;
    case packet_tag::type::signature:
      if (subkey != nullptr)
      {
        if (is_rsa_public_key(*subkey) && subkey_binding_allows_signing(packet))
        {
          push_back(read_public_key(*subkey));
        }
        subkey = nullptr;
      }
      break;
    default:
      break;
    }
  });

  if (!primary_key_found)
  {
    throw std::runtime_error("public key is missing");
  }
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
  type signature_type,
  s_expression signature,
  uint8_t version)
  : m_hash_algorithm(hash_algorithm)
  , m_hash_leftmost_bytes(hash_leftmost_bytes)
  , m_hashed_appendix(format_hashed_appendix(algorithm, hash_algorithm, hashed_data, signature_type, version))
  , m_signature(std::move(signature))
  , m_type(signature_type)
{
}

signature_rsa signature_rsa::from_armored(const std::string &armored_signed_message)
{
  const std::string decoded = decode_armored_contents(
    get_armored_block_contents(armored_signed_message, "BEGIN PGP SIGNATURE", "END PGP SIGNATURE"));
  return from_buffer(epee::to_byte_span(epee::to_span(decoded)));
}

signature_rsa signature_rsa::from_base64(const std::string &base64)
{
  return from_buffer(epee::to_byte_span(epee::to_span(decode_armored_contents(base64))));
}

signature_rsa signature_rsa::from_buffer(const epee::span<const uint8_t> input)
{
  const packet_stream packets(input);

  const std::vector<uint8_t> *data = packets.find_first(packet_tag::type::signature);
  if (data == nullptr)
  {
    throw std::runtime_error("signature is missing");
  }

  deserializer<epee::span<const uint8_t>> buffer(epee::to_span(*data));

  const auto version = buffer.read_big_endian<uint8_t>();
  if (version != 4)
  {
    throw std::runtime_error("unsupported signature version");
  }

  const auto signature_type = static_cast<type>(buffer.read_big_endian<uint8_t>());
  if (signature_type != type::binary_document && signature_type != type::canonical_text_document)
  {
    throw std::runtime_error("unsupported signature type");
  }

  const auto algorithm = buffer.read_big_endian<uint8_t>();
  if (algorithm != openpgp::algorithm::rsa)
  {
    throw std::runtime_error("unsupported signature algorithm");
  }

  const auto hash_algorithm = buffer.read_big_endian<uint8_t>();
  if (hash_algorithm != openpgp::hash::algorithm::sha256)
  {
    throw std::runtime_error("unsupported signature hash algorithm");
  }

  const auto hashed_data_length = buffer.read_big_endian<uint16_t>();
  const std::vector<uint8_t> hashed_data = buffer.read(hashed_data_length);

  const auto unhashed_data_length = buffer.read_big_endian<uint16_t>();
  buffer.read_span(unhashed_data_length);

  const auto hash_leftmost_byte_0 = buffer.read_big_endian<uint8_t>();
  const auto hash_leftmost_byte_1 = buffer.read_big_endian<uint8_t>();

  const mpi signature = buffer.read_mpi();

  return signature_rsa(
    algorithm,
    {hash_leftmost_byte_0, hash_leftmost_byte_1},
    hash_algorithm,
    hashed_data,
    signature_type,
    s_expression("(sig-val (rsa (s %m)))", signature.get()),
    version);
}

bool signature_rsa::verify(const epee::span<const uint8_t> message, const public_key_rsa &public_key) const
{
  const std::vector<uint8_t> plain_hash = hash_message(message);
  if (plain_hash.size() < 2)
  {
    throw std::runtime_error("insufficient message hash size");
  }
  if (plain_hash[0] != m_hash_leftmost_bytes.first || plain_hash[1] != m_hash_leftmost_bytes.second)
  {
    return false;
  }

  const std::vector<uint8_t> asn_object_id = hash_asn_object_id();

  const size_t public_key_bytes = bits_to_bytes(public_key.bits());
  if (public_key_bytes < plain_hash.size() + asn_object_id.size() + 11)
  {
    return false;
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

  const mpi value(emsa_pkcs1_v1_5_encoded);
  const s_expression signed_data("(data (flags raw) (value %m))", value.get());
  return gcry_pk_verify(m_signature.get(), signed_data.get(), public_key.get()) == 0;
}

std::vector<uint8_t> signature_rsa::hash_message(const epee::span<const uint8_t> message) const
{
  switch (m_type)
  {
  case type::binary_document:
    return (hash(m_hash_algorithm) << message << m_hashed_appendix).finish();
  case type::canonical_text_document:
  {
    std::vector<uint8_t> crlf_formatted;
    crlf_formatted.reserve(message.size());
    const size_t message_size = message.size();
    for (size_t offset = 0; offset < message_size; ++offset)
    {
      const auto &character = message[offset];
      if (character == '\r' && offset + 1 < message_size && message[offset + 1] == '\n')
      {
        continue;
      }
      if (character == '\n')
      {
        crlf_formatted.push_back('\r');
      }
      crlf_formatted.push_back(character);
    }
    return (hash(m_hash_algorithm) << crlf_formatted << m_hashed_appendix).finish();
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
  if (size == 0)
  {
    throw std::runtime_error("hash algorithm has no ASN.1 Object Identifier (OID)");
  }

  std::vector<uint8_t> asn_object_id(size);
  if (gcry_md_algo_info(m_hash_algorithm, GCRYCTL_GET_ASNOID, asn_object_id.data(), &size) != GPG_ERR_NO_ERROR)
  {
    throw std::runtime_error("failed to get ASN.1 Object Identifier (OID)");
  }

  return asn_object_id;
}

std::vector<uint8_t> signature_rsa::format_hashed_appendix(
  uint8_t algorithm,
  uint8_t hash_algorithm,
  const std::vector<uint8_t> &hashed_data,
  uint8_t type,
  uint8_t version)
{
  const uint16_t hashed_data_size = static_cast<uint16_t>(hashed_data.size());
  const uint32_t hashed_prefix_size = sizeof(version) + sizeof(type) + sizeof(algorithm) + sizeof(hash_algorithm) +
    sizeof(hashed_data_size) + hashed_data.size();

  std::vector<uint8_t> appendix;
  appendix.reserve(hashed_prefix_size + sizeof(version) + sizeof(uint8_t) + sizeof(hashed_prefix_size));
  appendix.push_back(version);
  appendix.push_back(type);
  appendix.push_back(algorithm);
  appendix.push_back(hash_algorithm);
  appendix.push_back(static_cast<uint8_t>(hashed_data_size >> 8));
  appendix.push_back(static_cast<uint8_t>(hashed_data_size));
  appendix.insert(appendix.end(), hashed_data.begin(), hashed_data.end());
  appendix.push_back(version);
  appendix.push_back(0xff);
  appendix.push_back(static_cast<uint8_t>(hashed_prefix_size >> 24));
  appendix.push_back(static_cast<uint8_t>(hashed_prefix_size >> 16));
  appendix.push_back(static_cast<uint8_t>(hashed_prefix_size >> 8));
  appendix.push_back(static_cast<uint8_t>(hashed_prefix_size));

  return appendix;
}

message_armored::message_armored(const std::string &message_armored)
  : m_message(get_cleartext_signed_text(
      get_armored_block_contents(message_armored, "BEGIN PGP SIGNED MESSAGE", "BEGIN PGP SIGNATURE")))
{
}

message_armored::operator epee::span<const uint8_t>() const
{
  return epee::to_byte_span(epee::to_span(m_message));
}

} // namespace openpgp
