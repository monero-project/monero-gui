//
//  utils.hpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef UTILS_HPP
#define UTILS_HPP

#include <stdint.h>
#include <vector>
#include <utility>
#include <string>
#include <array>

namespace ur {

typedef std::vector<uint8_t> ByteVector;
typedef std::vector<std::string> StringVector;

ByteVector sha256(const ByteVector &buf);
ByteVector crc32_bytes(const ByteVector &buf);
uint32_t crc32_int(const ByteVector &buf);

ByteVector string_to_bytes(const std::string& s);

std::string data_to_hex(const ByteVector& in);
std::string data_to_hex(uint32_t n);

ByteVector int_to_bytes(uint32_t n);
uint32_t bytes_to_int(const ByteVector& in);

std::string join(const StringVector &strings, const std::string &separator);
StringVector split(const std::string& s, char separator);

StringVector partition(const std::string& string, size_t size);

std::string take_first(const std::string &s, size_t count);
std::string drop_first(const std::string &s, size_t count);

template<typename T>
void append(std::vector<T>& target, const std::vector<T>& source) {
    target.insert(target.end(), source.begin(), source.end());
}

template<typename T, size_t N>
void append(std::vector<T>& target, const std::array<T, N>& source) {
    target.insert(target.end(), source.begin(), source.end());
}

template<typename T>
std::vector<T> join(const std::vector<std::vector<T>>& parts) {
    std::vector<T> result;
    for(auto part: parts) { append(result, part); }
    return result;
}

template<typename T>
std::pair<std::vector<T>, std::vector<T>> split(const std::vector<T>& buf, size_t count) {
    auto first = buf.begin();
    auto c = std::min(buf.size(), count);
    auto last = first + c;
    auto a = std::vector(first, last);
    auto b = std::vector(last, buf.end());
    return std::make_pair(a, b);
}

template<typename T>
std::vector<T> take_first(const std::vector<T> &buf, size_t count) {
    auto first = buf.begin();
    auto c = std::min(buf.size(), count);
    auto last = first + c;
    return std::vector(first, last);
}

void xor_into(ByteVector& target, const ByteVector& source);
ByteVector xor_with(const ByteVector& a, const ByteVector& b);

bool is_ur_type(char c);
bool is_ur_type(const std::string& s);

std::string to_lowercase(const std::string& s);
bool has_prefix(const std::string& s, const std::string& prefix);

}

#endif // UTILS_HPP
