//
//  xoshiro256.cpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#include "xoshiro256.hpp"
#include <limits>
#include <cstring>

/*  Written in 2018 by David Blackman and Sebastiano Vigna (vigna@acm.org)

To the extent possible under law, the author has dedicated all copyright
and related and neighboring rights to this software to the public domain
worldwide. This software is distributed without any warranty.

See <http://creativecommons.org/publicdomain/zero/1.0/>. */

/* This is xoshiro256** 1.0, one of our all-purpose, rock-solid
   generators. It has excellent (sub-ns) speed, a state (256 bits) that is
   large enough for any parallel application, and it passes all tests we
   are aware of.

   For generating just floating-point numbers, xoshiro256+ is even faster.

   The state must be seeded so that it is not everywhere zero. If you have
   a 64-bit seed, we suggest to seed a splitmix64 generator and use its
   output to fill s. */

namespace ur {

static inline uint64_t rotl(const uint64_t x, int k) {
	return (x << k) | (x >> (64 - k));
}

Xoshiro256::Xoshiro256(const std::array<uint64_t, 4>& a) {
    s[0] = a[0];
    s[1] = a[1];
    s[2] = a[2];
    s[3] = a[3];
}

void Xoshiro256::set_s(const std::array<uint8_t, 32>& a) {
    for(int i = 0; i < 4; i++) {
        auto o = i * 8;
        uint64_t v = 0;
        for(int n = 0; n < 8; n++) {
            v <<= 8;
            v |= a[o + n];
        }
        s[i] = v;
    }
}

void Xoshiro256::hash_then_set_s(const ByteVector& bytes) {
    auto digest = sha256(bytes);
    std::array<uint8_t, 32> a;
    memcpy(a.data(), &digest[0], 32);
    set_s(a);
}

Xoshiro256::Xoshiro256(const std::array<uint8_t, 32>& a) {
    set_s(a);
}

Xoshiro256::Xoshiro256(const ByteVector& bytes) {
    hash_then_set_s(bytes);
}

Xoshiro256::Xoshiro256(const std::string& s) {
    ByteVector bytes(s.begin(), s.end());
    hash_then_set_s(bytes);
}

Xoshiro256::Xoshiro256(uint32_t crc32) {
    auto bytes = int_to_bytes(crc32);
    hash_then_set_s(bytes);
}

double Xoshiro256::next_double() {
    auto m = ((double)std::numeric_limits<uint64_t>::max()) + 1;
    return next() / m;
}

uint64_t Xoshiro256::next_int(uint64_t low, uint64_t high) {
    return uint64_t(next_double() * (high - low + 1)) + low;
}

uint8_t Xoshiro256::next_byte() {
    return uint8_t(next_int(0, 255));
}

ByteVector Xoshiro256::next_data(size_t count) {
    ByteVector result;
    result.reserve(count);
    for(int i = 0; i < count; i++) {
        result.push_back(next_byte());
    }
    return result;
}

uint64_t Xoshiro256::next() {
	const uint64_t result = rotl(s[1] * 5, 7) * 9;

	const uint64_t t = s[1] << 17;

	s[2] ^= s[0];
	s[3] ^= s[1];
	s[1] ^= s[2];
	s[0] ^= s[3];

	s[2] ^= t;

	s[3] = rotl(s[3], 45);

	return result;
}

/* This is the jump function for the generator. It is equivalent
   to 2^128 calls to next(); it can be used to generate 2^128
   non-overlapping subsequences for parallel computations. */

void Xoshiro256::jump() {
	static const uint64_t JUMP[] = { 0x180ec6d33cfd0aba, 0xd5a61266f0c9392c, 0xa9582618e03fc9aa, 0x39abdc4529b1661c };

	uint64_t s0 = 0;
	uint64_t s1 = 0;
	uint64_t s2 = 0;
	uint64_t s3 = 0;
	for(int i = 0; i < sizeof JUMP / sizeof *JUMP; i++)
		for(int b = 0; b < 64; b++) {
			if (JUMP[i] & UINT64_C(1) << b) {
				s0 ^= s[0];
				s1 ^= s[1];
				s2 ^= s[2];
				s3 ^= s[3];
			}
			next();
		}

	s[0] = s0;
	s[1] = s1;
	s[2] = s2;
	s[3] = s3;
}

/* This is the long-jump function for the generator. It is equivalent to
   2^192 calls to next(); it can be used to generate 2^64 starting points,
   from each of which jump() will generate 2^64 non-overlapping
   subsequences for parallel distributed computations. */

void Xoshiro256::long_jump() {
	static const uint64_t LONG_JUMP[] = { 0x76e15d3efefdcbbf, 0xc5004e441c522fb3, 0x77710069854ee241, 0x39109bb02acbe635 };

	uint64_t s0 = 0;
	uint64_t s1 = 0;
	uint64_t s2 = 0;
	uint64_t s3 = 0;
	for(int i = 0; i < sizeof LONG_JUMP / sizeof *LONG_JUMP; i++)
		for(int b = 0; b < 64; b++) {
			if (LONG_JUMP[i] & UINT64_C(1) << b) {
				s0 ^= s[0];
				s1 ^= s[1];
				s2 ^= s[2];
				s3 ^= s[3];
			}
			next();
		}

	s[0] = s0;
	s[1] = s1;
	s[2] = s2;
	s[3] = s3;
}

}
