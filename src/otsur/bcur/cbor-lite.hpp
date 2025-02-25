#ifndef BC_UR_CBOR_LITE_HPP
#define BC_UR_CBOR_LITE_HPP

// From: https://bitbucket.org/isode/cbor-lite/raw/6c770624a97e3229e3f200be092c1b9c70a60ef1/include/cbor-lite/codec.h

// This file is part of CBOR-lite which is copyright Isode Limited
// and others and released under a MIT license. For details, see the
// COPYRIGHT.md file in the top-level folder of the CBOR-lite software
// distribution.

#include <exception>
#include <iterator>
#include <string>
#include <type_traits>
#include <cstdint>

#ifndef __BYTE_ORDER__
#error __BYTE_ORDER__ not defined
#elif (__BYTE_ORDER__ != __ORDER_LITTLE_ENDIAN__) && (__BYTE_ORDER__ != __ORDER_BIG_ENDIAN__)
#error __BYTE_ORDER__ neither __ORDER_BIG_ENDIAN__ nor __ORDER_LITTLE_ENDIAN__
#endif

namespace CborLite {

class Exception : public std::exception {
public:
    Exception() noexcept {
    }
    virtual ~Exception() noexcept = default;

    explicit Exception(const char* d) noexcept {
        what_ += std::string(": ") + d;
    }

    explicit Exception(const std::string& d) noexcept {
        what_ += ": " + d;
    }

    Exception(const Exception& e) noexcept : what_(e.what_) {
    }

    Exception(Exception&& e) noexcept : what_(std::move(e.what_)) {
        // Note that e.what_ is not re-initialized to "CBOR Exception" as
        // the moved-from object is not expected to ever be reused.
    }

    Exception& operator=(const Exception&) = delete;
    Exception& operator=(Exception&&) = delete;

    virtual const char* what() const noexcept {
        return what_.c_str();
    }

private:
    std::string what_ = "CBOR Exception";
};

using Tag = std::uint_fast64_t;

namespace Major {
constexpr Tag unsignedInteger = 0u;
constexpr Tag negativeInteger = 1u << 5;
constexpr Tag byteString = 2u << 5;
constexpr Tag textString = 3u << 5;
constexpr Tag array = 4u << 5;
constexpr Tag map = 5u << 5;
constexpr Tag semantic = 6u << 5;
constexpr Tag floatingPoint = 7u << 5;
constexpr Tag simple = 7u << 5;
constexpr Tag mask = 0xe0u;
} // namespace Major

namespace Minor {
constexpr Tag length1 = 24u;
constexpr Tag length2 = 25u;
constexpr Tag length4 = 26u;
constexpr Tag length8 = 27u;

constexpr Tag False = 20u;
constexpr Tag True = 21u;
constexpr Tag null = 22u;
constexpr Tag undefined = 23u;
constexpr Tag halfFloat = 25u; // not implemented
constexpr Tag singleFloat = 26u;
constexpr Tag doubleFloat = 27u;

constexpr Tag dataTime = 0u;
constexpr Tag epochDataTime = 1u;
constexpr Tag positiveBignum = 2u;
constexpr Tag negativeBignum = 3u;
constexpr Tag decimalFraction = 4u;
constexpr Tag bigfloat = 5u;
constexpr Tag convertBase64Url = 21u;
constexpr Tag convertBase64 = 22u;
constexpr Tag convertBase16 = 23u;
constexpr Tag cborEncodedData = 24u;
constexpr Tag uri = 32u;
constexpr Tag base64Url = 33u;
constexpr Tag base64 = 34u;
constexpr Tag regex = 35u;
constexpr Tag mimeMessage = 36u;
constexpr Tag selfDescribeCbor = 55799u;

constexpr Tag mask = 0x1fu;
} // namespace Minor

constexpr Tag undefined = Major::semantic + Minor::undefined;

using Flags = unsigned;
namespace Flag {
constexpr Flags none = 0;
constexpr Flags requireMinimalEncoding = 1 << 0;
} // namespace Flag

template <typename Type>
typename std::enable_if<std::is_unsigned<Type>::value, std::size_t>::type length(Type val) {
    if (val < 24) return 0;
    for (std::size_t i = 1; i <= ((sizeof val) >> 1); i <<= 1) {
        if (!(val >> (i << 3))) return i;
    }
    return sizeof val;
}

template <typename Buffer>
typename std::enable_if<std::is_class<Buffer>::value, std::size_t>::type encodeTagAndAdditional(
    Buffer& buffer, Tag tag, Tag additional) {
    buffer.push_back(static_cast<char>(tag + additional));
    return 1;
}

template <typename InputIterator>
typename std::enable_if<std::is_class<InputIterator>::value, std::size_t>::type decodeTagAndAdditional(
    InputIterator& pos, InputIterator end, Tag& tag, Tag& additional, Flags = Flag::none) {
    if (pos == end) throw Exception("not enough input");
    auto octet = *(pos++);
    tag = octet & Major::mask;
    additional = octet & Minor::mask;
    return 1;
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value && std::is_unsigned<Type>::value, std::size_t>::type encodeTagAndValue(
    Buffer& buffer, Tag tag, const Type t) {
    auto len = length(t);
    buffer.reserve(buffer.size() + len + 1);

    switch (len) {
    case 8:
        encodeTagAndAdditional(buffer, tag, Minor::length8);
        break;
    case 4:
        encodeTagAndAdditional(buffer, tag, Minor::length4);
        break;
    case 2:
        encodeTagAndAdditional(buffer, tag, Minor::length2);
        break;
    case 1:
        encodeTagAndAdditional(buffer, tag, Minor::length1);
        break;
    case 0:
        return encodeTagAndAdditional(buffer, tag, t);
    default:
        throw Exception("too long");
    }

    switch (len) {
    case 8:
        buffer.push_back((t >> 56) & 0xffU);
        buffer.push_back((t >> 48) & 0xffU);
        buffer.push_back((t >> 40) & 0xffU);
        buffer.push_back((t >> 32) & 0xffU);
    case 4:
        buffer.push_back((t >> 24) & 0xffU);
        buffer.push_back((t >> 16) & 0xffU);
    case 2:
        buffer.push_back((t >> 8) & 0xffU);
    case 1:
        buffer.push_back(t & 0xffU);
    }

    return 1 + len;
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && std::is_unsigned<Type>::value, std::size_t>::type decodeTagAndValue(
    InputIterator& pos, InputIterator end, Tag& tag, Type& t, Flags flags = Flag::none) {
    if (pos == end) throw Exception("not enough input");
    auto additional = Minor::undefined;
    auto len = decodeTagAndAdditional(pos, end, tag, additional, flags);
    if (additional < Minor::length1) {
        t = additional;
        return len;
    }
    t = 0u;
    switch (additional) {
    case Minor::length8:
        if (std::distance(pos, end) < 8) throw Exception("not enough input");
        t |= static_cast<Type>(reinterpret_cast<const unsigned char&>(*(pos++))) << 56;
        t |= static_cast<Type>(reinterpret_cast<const unsigned char&>(*(pos++))) << 48;
        t |= static_cast<Type>(reinterpret_cast<const unsigned char&>(*(pos++))) << 40;
        t |= static_cast<Type>(reinterpret_cast<const unsigned char&>(*(pos++))) << 32;
        len += 4;
        if ((flags & Flag::requireMinimalEncoding) && !t) throw Exception("encoding not minimal");
    case Minor::length4:
        if (std::distance(pos, end) < 4) throw Exception("not enough input");
        t |= static_cast<Type>(reinterpret_cast<const unsigned char&>(*(pos++))) << 24;
        t |= static_cast<Type>(reinterpret_cast<const unsigned char&>(*(pos++))) << 16;
        len += 2;
        if ((flags & Flag::requireMinimalEncoding) && !t) throw Exception("encoding not minimal");
    case Minor::length2:
        if (std::distance(pos, end) < 2) throw Exception("not enough input");
        t |= static_cast<Type>(reinterpret_cast<const unsigned char&>(*(pos++))) << 8;
        len++;
        if ((flags & Flag::requireMinimalEncoding) && !t) throw Exception("encoding not minimal");
    case Minor::length1:
        if (std::distance(pos, end) < 1) throw Exception("not enough input");
        t |= static_cast<Type>(reinterpret_cast<const unsigned char&>(*(pos++)));
        len++;
        if ((flags & Flag::requireMinimalEncoding) && t < 24) throw Exception("encoding not minimal");
        return len;
    }
    throw Exception("bad additional value");
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value, std::size_t>::type encodeUnsigned(Buffer& buffer, const Type& t) {
    return encodeTagAndValue(buffer, Major::unsignedInteger, t);
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && std::is_unsigned<Type>::value && !std::is_const<Type>::value,
    std::size_t>::type
decodeUnsigned(InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    auto len = decodeTagAndValue(pos, end, tag, t, flags);
    if (tag != Major::unsignedInteger) throw Exception("not Unsigned");
    return len;
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value, std::size_t>::type encodeNegative(Buffer& buffer, const Type& t) {
    return encodeTagAndValue(buffer, Major::negativeInteger, t);
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && std::is_unsigned<Type>::value && !std::is_const<Type>::value,
    std::size_t>::type
decodeNegative(InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    auto len = decodeTagAndValue(pos, end, tag, t, flags);
    if (tag != Major::negativeInteger) throw Exception("not Unsigned");
    return len;
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value, std::size_t>::type encodeInteger(Buffer& buffer, const Type& t) {
    if (t >= 0) {
        unsigned long long val = t;
        return encodeUnsigned(buffer, val);
    } else {
        unsigned long long val = -t - 1;
        return encodeNegative(buffer, val);
    }
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && std::is_signed<Type>::value && !std::is_const<Type>::value,
    std::size_t>::type
decodeInteger(InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    unsigned long long val;
    auto len = decodeTagAndValue(pos, end, tag, val, flags);
    switch (tag) {
    case Major::unsignedInteger:
        t = val;
        break;
    case Major::negativeInteger:
        t = -1 - static_cast<long long>(val);
        break;
    default:
        throw Exception("not integer");
    }
    return len;
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value && std::is_same<bool, Type>::value, std::size_t>::type encodeBool(
    Buffer& buffer, const Type& t) {
    return encodeTagAndAdditional(buffer, Major::simple, t ? Minor::True : Minor::False);
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && std::is_same<bool, Type>::value && !std::is_const<Type>::value,
    std::size_t>::type
decodeBool(InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    auto value = undefined;
    auto len = decodeTagAndValue(pos, end, tag, value, flags);
    if (tag == Major::simple) {
        if (value == Minor::True) {
            t = true;
            return len;
        } else if (value == Minor::False) {
            t = false;
            return len;
        }
        throw Exception("not Boolean");
    }
    throw Exception("not Simple");
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value, std::size_t>::type encodeBytes(Buffer& buffer, const Type& t) {
    auto len = encodeTagAndValue(buffer, Major::byteString, t.size());
    buffer.insert(std::end(buffer), std::begin(t), std::end(t));
    return len + t.size();
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && !std::is_const<Type>::value, std::size_t>::type decodeBytes(
    InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    auto value = undefined;
    auto len = decodeTagAndValue(pos, end, tag, value, flags);
    if (tag != Major::byteString) throw Exception("not ByteString");

    auto dist = std::distance(pos, end);
    if (dist < static_cast<decltype(dist)>(value)) throw Exception("not enough input");
    t.insert(std::end(t), pos, pos + value);
    std::advance(pos, value);
    return len + value;
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value && std::is_unsigned<Type>::value, std::size_t>::type encodeEncodedBytesPrefix(
    Buffer& buffer, const Type& t) {
    auto len = encodeTagAndValue(buffer, Major::semantic, Minor::cborEncodedData);
    return len + encodeTagAndValue(buffer, Major::byteString, t);
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && !std::is_const<Type>::value, std::size_t>::type
decodeEncodedBytesPrefix(InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    auto value = undefined;
    auto len = decodeTagAndValue(pos, end, tag, value, flags);
    if (tag != Major::semantic || value != Minor::cborEncodedData) {
        throw Exception("not CBOR Encoded Data");
    }
    tag = undefined;
    len += decodeTagAndValue(pos, end, tag, value, flags);
    if (tag != Major::byteString) throw Exception("not ByteString");
    t = value;
    return len;
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value, std::size_t>::type encodeEncodedBytes(Buffer& buffer, const Type& t) {
    auto len = encodeTagAndValue(buffer, Major::semantic, Minor::cborEncodedData);
    return len + encodeBytes(buffer, t);
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && !std::is_const<Type>::value, std::size_t>::type decodeEncodedBytes(
    InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    auto value = undefined;
    auto len = decodeTagAndValue(pos, end, tag, value, flags);
    if (tag != Major::semantic || value != Minor::cborEncodedData) {
        throw Exception("not CBOR Encoded Data");
    }
    return len + decodeBytes(pos, end, t, flags);
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value, std::size_t>::type encodeText(Buffer& buffer, const Type& t) {
    auto len = encodeTagAndValue(buffer, Major::textString, t.size());
    buffer.insert(std::end(buffer), std::begin(t), std::end(t));
    return len + t.size();
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && !std::is_const<Type>::value, std::size_t>::type decodeText(
    InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    auto value = undefined;
    auto len = decodeTagAndValue(pos, end, tag, value, flags);
    if (tag != Major::textString) throw Exception("not TextString");

    auto dist = std::distance(pos, end);
    if (dist < static_cast<decltype(dist)>(value)) throw Exception("not enough input");
    t.insert(std::end(t), pos, pos + value);
    std::advance(pos, value);
    return len + value;
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value && std::is_unsigned<Type>::value, std::size_t>::type encodeArraySize(
    Buffer& buffer, const Type& t) {
    return encodeTagAndValue(buffer, Major::array, t);
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && !std::is_const<Type>::value && std::is_unsigned<Type>::value,
    std::size_t>::type
decodeArraySize(InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    auto value = undefined;
    auto len = decodeTagAndValue(pos, end, tag, value, flags);
    if (tag != Major::array) throw Exception("not Array");
    t = value;
    return len;
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value && std::is_unsigned<Type>::value, std::size_t>::type encodeMapSize(
    Buffer& buffer, const Type& t) {
    return encodeTagAndValue(buffer, Major::map, t);
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && !std::is_const<Type>::value && std::is_unsigned<Type>::value,
    std::size_t>::type
decodeMapSize(InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    auto tag = undefined;
    auto value = undefined;
    auto len = decodeTagAndValue(pos, end, tag, value, flags);
    if (tag != Major::map) throw Exception("not Map");
    t = value;
    return len;
}

//
// codec-fp.h
//

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value && std::is_floating_point<Type>::value, std::size_t>::type encodeSingleFloat(
    Buffer& buffer, const Type& t) {
    static_assert(sizeof(float) == 4, "sizeof(float) expected to be 4");
    auto len = encodeTagAndAdditional(buffer, Major::floatingPoint, Minor::singleFloat);
    const char* p;
    float ft;
    if (sizeof(t) == sizeof(ft)) {
        p = reinterpret_cast<const char*>(&t);
    } else {
        ft = static_cast<decltype(ft)>(t);
        p = reinterpret_cast<char*>(&ft);
    }
#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    for (auto i = 0u; i < sizeof(ft); ++i) {
        buffer.push_back(p[i]);
    }
#else
    for (auto i = 1u; i <= sizeof(ft); ++i) {
        buffer.push_back(p[sizeof(ft) - i]);
    }
#endif
    return len + sizeof(ft);
}

template <typename Buffer, typename Type>
typename std::enable_if<std::is_class<Buffer>::value && std::is_floating_point<Type>::value, std::size_t>::type encodeDoubleFloat(
    Buffer& buffer, const Type& t) {
    static_assert(sizeof(double) == 8, "sizeof(double) expected to be 8");
    auto len = encodeTagAndAdditional(buffer, Major::floatingPoint, Minor::doubleFloat);
    const char* p;
    double ft;
    if (sizeof(t) == sizeof(ft)) {
        p = reinterpret_cast<const char*>(&t);
    } else {
        ft = t;
        p = reinterpret_cast<char*>(&ft);
    }
#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    for (auto i = 0u; i < sizeof(ft); ++i) {
        buffer.push_back(p[i]);
    }
#else
    for (auto i = 1u; i <= sizeof(ft); ++i) {
        buffer.push_back(p[sizeof(ft) - i]);
    }
#endif
    return len + sizeof(ft);
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && std::is_floating_point<Type>::value && !std::is_const<Type>::value,
    std::size_t>::type
decodeSingleFloat(InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    static_assert(sizeof(float) == 4, "sizeof(float) expected to be 4");
    auto tag = undefined;
    auto value = undefined;
    auto len = decodeTagAndAdditional(pos, end, tag, value, flags);
    if (tag != Major::floatingPoint) throw Exception("not floating-point");
    if (value != Minor::singleFloat) throw Exception("not single-precision floating-point");
    if (std::distance(pos, end) < static_cast<int>(sizeof(float))) throw Exception("not enough input");

    char* p;
    float ft;
    if (sizeof(t) == sizeof(ft)) {
        p = reinterpret_cast<char*>(&t);
    } else {
        ft = static_cast<decltype(ft)>(t);
        p = reinterpret_cast<char*>(&ft);
    }

#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    for (auto i = 0u; i < sizeof(ft); ++i) {
        p[i] = *(pos++);
    }
#else
    for (auto i = 1u; i <= sizeof(ft); ++i) {
        p[sizeof(ft) - i] = *(pos++);
    }
#endif
    if (sizeof(t) != sizeof(ft)) t = ft;
    return len + sizeof(ft);
}

template <typename InputIterator, typename Type>
typename std::enable_if<std::is_class<InputIterator>::value && std::is_floating_point<Type>::value && !std::is_const<Type>::value,
    std::size_t>::type
decodeDoubleFloat(InputIterator& pos, InputIterator end, Type& t, Flags flags = Flag::none) {
    static_assert(sizeof(double) == 8, "sizeof(double) expected to be 8");
    auto tag = undefined;
    auto value = undefined;
    auto len = decodeTagAndAdditional(pos, end, tag, value, flags);
    if (tag != Major::floatingPoint) throw Exception("not floating-point");
    if (value != Minor::doubleFloat) throw Exception("not double-precision floating-point");
    if (std::distance(pos, end) < static_cast<int>(sizeof(double))) throw Exception("not enough input");

    char* p;
    double ft;
    if (sizeof(t) == sizeof(ft)) {
        p = reinterpret_cast<char*>(&t);
    } else {
        ft = t;
        p = reinterpret_cast<char*>(&ft);
    }

#if __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__
    for (auto i = 0u; i < sizeof(ft); ++i) {
        p[i] = *(pos++);
    }
#else
    for (auto i = 1u; i <= sizeof(ft); ++i) {
        p[sizeof(ft) - i] = *(pos++);
    }
#endif

    if (sizeof(t) != sizeof(ft)) t = ft;
    return len + sizeof(ft);
}

} // namespace CborLite

#endif // BC_UR_CBOR_LITE_HPP
