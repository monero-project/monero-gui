//
//  fountain-encoder.cpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#include "fountain-encoder.hpp"
#include <assert.h>
#include <cmath>
#include <optional>
#include <vector>
#include <limits>
#include "cbor-lite.hpp"

using namespace std;

namespace ur {

size_t FountainEncoder::find_nominal_fragment_length(size_t message_len, size_t min_fragment_len, size_t max_fragment_len) {
    assert(message_len > 0);
    assert(min_fragment_len > 0);
    assert(max_fragment_len >= min_fragment_len);
    auto max_fragment_count = message_len / min_fragment_len;
    optional<size_t> fragment_len;
    for(size_t fragment_count = 1; fragment_count <= max_fragment_count; fragment_count++) {
        fragment_len = size_t(ceil(double(message_len) / fragment_count));
        if(fragment_len <= max_fragment_len) {
            break;
        }
    }
    assert(fragment_len.has_value());
    return *fragment_len;
}

vector<ByteVector> FountainEncoder::partition_message(const ByteVector &message, size_t fragment_len) {
    auto remaining = message;
    vector<ByteVector> fragments;
    while(!remaining.empty()) {
        auto a = split(remaining, fragment_len);
        auto fragment = a.first;
        remaining = a.second;
        auto padding = fragment_len - fragment.size();
        while(padding > 0) {
            fragment.push_back(0);
            padding--;
        }
        fragments.push_back(fragment);
    }
    return fragments;
}

FountainEncoder::Part::Part(const ByteVector& cbor) {
    try {
        auto i = cbor.begin();
        auto end = cbor.end();
        size_t array_size;
        CborLite::decodeArraySize(i, end, array_size);
        if(array_size != 5) { throw InvalidHeader(); }
        
        uint64_t n;
        
        CborLite::decodeUnsigned(i, end, n);
        if(n > std::numeric_limits<decltype(seq_num_)>::max()) { throw InvalidHeader(); }
        seq_num_ = n;
        
        CborLite::decodeUnsigned(i, end, n);
        if(n > std::numeric_limits<decltype(seq_len_)>::max()) { throw InvalidHeader(); }
        seq_len_ = n;
        
        CborLite::decodeUnsigned(i, end, n);
        if(n > std::numeric_limits<decltype(message_len_)>::max()) { throw InvalidHeader(); }
        message_len_ = n;
        
        CborLite::decodeUnsigned(i, end, n);
        if(n > std::numeric_limits<decltype(checksum_)>::max()) { throw InvalidHeader(); }
        checksum_ = n;

        CborLite::decodeBytes(i, end, data_);
    } catch(...) {
        throw InvalidHeader();
    }
}

ByteVector FountainEncoder::Part::cbor() const {
    using namespace CborLite;

    ByteVector result;

    encodeArraySize(result, (size_t)5);
    encodeInteger(result, seq_num());
    encodeInteger(result, seq_len());
    encodeInteger(result, message_len());
    encodeInteger(result, checksum());
    encodeBytes(result, data());

    return result;
}

FountainEncoder::FountainEncoder(const ByteVector& message, size_t max_fragment_len, uint32_t first_seq_num, size_t min_fragment_len) {
    assert(message.size() <= std::numeric_limits<uint32_t>::max());
    message_len_ = message.size();
    checksum_ = crc32_int(message);
    fragment_len_ = find_nominal_fragment_length(message_len_, min_fragment_len, max_fragment_len);
    fragments_ = partition_message(message, fragment_len_);
    seq_num_ = first_seq_num;
}

ByteVector FountainEncoder::mix(const PartIndexes& indexes) const {
    ByteVector result(fragment_len_, 0);
    for(auto index: indexes) { xor_into(result, fragments_[index]); }
    return result;
}

FountainEncoder::Part FountainEncoder::next_part() {
    seq_num_ += 1; // wrap at period 2^32
    auto indexes = choose_fragments(seq_num_, seq_len(), checksum_);
    auto mixed = mix(indexes);
    return Part(seq_num_, seq_len(), message_len_, checksum_, mixed); 
}

string FountainEncoder::Part::description() const {
    return "seqNum:" + to_string(seq_num_) + ", seqLen:" + to_string(seq_len_) + ", messageLen:" + to_string(message_len_) + ", checksum:" + to_string(checksum_) + ", data:" + data_to_hex(data_);
}

}
