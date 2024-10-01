//
//  ur-decoder.cpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#include "ur-decoder.hpp"
#include "bytewords.hpp"

using namespace std;

namespace ur {

UR URDecoder::decode(const string& s) {
    auto [type, components] = parse(s);

    if(components.empty()) throw InvalidPathLength();
    auto body = components.front();

    return decode(type, body);
}

URDecoder::URDecoder() { }

UR URDecoder::decode(const std::string& type, const std::string& body) {
    auto cbor = Bytewords::decode(Bytewords::style::minimal, body);
    return UR(type, cbor);
}

pair<string, StringVector> URDecoder::parse(const string& s) {
    // Don't consider case
    auto lowered = to_lowercase(s);

    // Validate URI scheme
    if(!has_prefix(lowered, "ur:")) throw InvalidScheme();
    auto path = drop_first(lowered, 3);

    // Split the remainder into path components
    auto components = split(path, '/');

    // Make sure there are at least two path components
    if(components.size() < 2) throw InvalidPathLength();

    // Validate the type
    auto type = components.front();
    if(!is_ur_type(type)) throw InvalidType();

    auto comps = StringVector(components.begin() + 1, components.end());
    return pair(type, comps);
}

pair<uint32_t, size_t> URDecoder::parse_sequence_component(const string& s) {
    try {
        auto comps = split(s, '-');
        if(comps.size() != 2) throw InvalidSequenceComponent();
        uint32_t seq_num = stoul(comps[0]);
        size_t seq_len = stoul(comps[1]);
        if(seq_num < 1 || seq_len < 1) throw InvalidSequenceComponent();
        return pair(seq_num, seq_len);
    } catch(...) {
        throw InvalidSequenceComponent();
    }
}

bool URDecoder::validate_part(const std::string& type) {
    if(!expected_type_.has_value()) {
        if(!is_ur_type(type)) return false;
        expected_type_ = type;
        return true;
    } else {
        return type == expected_type_;
    }
}

bool URDecoder::receive_part(const std::string& s) {
    try {
        // Don't process the part if we're already done
        if(result_.has_value()) return false;

        // Don't continue if this part doesn't validate
        auto [type, components] = parse(s);
        if(!validate_part(type)) return false;

        // If this is a single-part UR then we're done
        if(components.size() == 1) {
            auto body = components.front();
            result_ = decode(type, body);
            return true;
        }

        // Multi-part URs must have two path components: seq/fragment
        if(components.size() != 2) throw InvalidPathLength();
        auto seq = components[0];
        auto fragment = components[1];

        // Parse the sequence component and the fragment, and
        // make sure they agree.
        auto [seq_num, seq_len] = parse_sequence_component(seq);
        auto cbor = Bytewords::decode(Bytewords::style::minimal, fragment);
        auto part = FountainEncoder::Part(cbor);
        if(seq_num != part.seq_num() || seq_len != part.seq_len()) return false;

        // Process the part
        if(!fountain_decoder.receive_part(part)) return false;

        if(fountain_decoder.is_success()) {
            result_ = UR(type, fountain_decoder.result_message());
        } else if(fountain_decoder.is_failure()) {
            result_ = fountain_decoder.result_error();
        }

        return true;
    } catch(...) {
        return false;
    }
}

}
