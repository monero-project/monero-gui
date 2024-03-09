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

#include <string>
#include <vector>

#include <gcrypt.h>

#include <span.h>

#include "s_expression.h"

namespace openpgp
{

enum algorithm : uint8_t
{
  rsa = 1,
};

class public_key_rsa
{
public:
  public_key_rsa(s_expression expression, size_t bits);

  size_t bits() const;
  const gcry_sexp_t &get() const;

private:
  s_expression m_expression;
  size_t m_bits;
};

class public_key_block : public std::vector<public_key_rsa>
{
public:
  public_key_block(const std::string &armored);
  public_key_block(const epee::span<const uint8_t> buffer);

  std::string user_id() const;

private:
  std::string m_user_id;
};

class signature_rsa
{
public:
  enum type : uint8_t
  {
    binary_document = 0,
    canonical_text_document = 1,
  };

  signature_rsa(
    uint8_t algorithm,
    std::pair<uint8_t, uint8_t> hash_leftmost_bytes,
    uint8_t hash_algorithm,
    const std::vector<uint8_t> &hashed_data,
    type type,
    s_expression signature,
    uint8_t version);

  static signature_rsa from_armored(const std::string &armored_signed_message);
  static signature_rsa from_base64(const std::string &base64);
  static signature_rsa from_buffer(const epee::span<const uint8_t> input);

  bool verify(const epee::span<const uint8_t> message, const public_key_rsa &public_key) const;

private:
  s_expression hash_message(const epee::span<const uint8_t> message, size_t public_key_bits) const;
  std::vector<uint8_t> hash_asn_object_id() const;
  s_expression hash_bytes(const epee::span<const uint8_t> message, size_t public_key_bits) const;

  static std::vector<uint8_t> format_hashed_appendix(
    uint8_t algorithm,
    uint8_t hash_algorithm,
    const std::vector<uint8_t> &hashed_data,
    uint8_t type,
    uint8_t version);

private:
  uint8_t m_hash_algorithm;
  std::pair<uint8_t, uint8_t> m_hash_leftmost_bytes;
  std::vector<uint8_t> m_hashed_appendix;
  s_expression m_signature;
  type m_type;
};

class message_armored
{
public:
  message_armored(const std::string &message_armored);

  operator epee::span<const uint8_t>() const;

private:
  std::string m_message;
};

} // namespace openpgp
