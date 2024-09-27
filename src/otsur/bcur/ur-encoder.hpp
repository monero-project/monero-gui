//
//  ur-encoder.hpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef BC_UR_ENCODER_HPP
#define BC_UR_ENCODER_HPP

#include <string>
#include "ur.hpp"
#include "utils.hpp"
#include "fountain-encoder.hpp"

namespace ur {

class UREncoder final {
public:
    // Encode a single-part UR.
    static std::string encode(const UR& ur);

    // Start encoding a (possibly) multi-part UR.
    UREncoder(const UR& ur, size_t max_fragment_len, uint32_t first_seq_num = 0, size_t min_fragment_len = 10);

    uint32_t seq_num() const { return fountain_encoder_.seq_num(); }
    size_t seq_len() const { return fountain_encoder_.seq_len(); }
    PartIndexes last_part_indexes() const { return fountain_encoder_.last_part_indexes(); }

    // `true` if the minimal number of parts to transmit the message have been
    // generated. Parts generated when this is `true` will be fountain codes
    // containing various mixes of the part data.
    bool is_complete() const { return fountain_encoder_.is_complete(); }

    // `true` if this UR can be contained in a single part. If `true`, repeated
    // calls to `next_part()` will all return the same single-part UR.
    bool is_single_part() const { return fountain_encoder_.is_single_part(); }

    std::string next_part();
    
private:
    UR ur_;
    FountainEncoder fountain_encoder_;

    static std::string encode_part(const std::string& type, const FountainEncoder::Part& part);
    static std::string encode_uri(const std::string& scheme, const StringVector& path_components);
    static std::string encode_ur(const StringVector& path_components);
};

}

#endif // BC_UR_ENCODER_HPP