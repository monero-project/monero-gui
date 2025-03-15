//
//  xoshiro256.hpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef XOSHIRO256_HPP
#define XOSHIRO256_HPP

#include <stdint.h>
#include <array>
#include <string>
#include "utils.hpp"

namespace ur {

class Xoshiro256 {
public:
    explicit Xoshiro256(const std::array<uint64_t, 4>& a);
    explicit Xoshiro256(const std::array<uint8_t, 32>& a);

    explicit Xoshiro256(const ByteVector& bytes);
    explicit Xoshiro256(const std::string& s);
    explicit Xoshiro256(uint32_t crc32);

    uint64_t next();
    double next_double();
    uint64_t next_int(uint64_t low, uint64_t high);
    uint8_t next_byte();
    ByteVector next_data(size_t count);

    void jump();
    void long_jump();

private:
    uint64_t s[4];

    void set_s(const std::array<uint8_t, 32>& a);
    void hash_then_set_s(const ByteVector& bytes);
};

}

#endif // XOSHIRO256_HPP
