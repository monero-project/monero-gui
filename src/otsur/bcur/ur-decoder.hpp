//
//  ur-decoder.hpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef BC_UR_DECODER_HPP
#define BC_UR_DECODER_HPP

#include <string>
#include <exception>
#include <utility>
#include <optional>

#include "ur.hpp"
#include "fountain-decoder.hpp"

namespace ur {

class URDecoder final {
public:
    typedef std::optional<std::variant<UR, std::exception> > Result;

    class InvalidScheme: public std::exception { };
    class InvalidType: public std::exception { };
    class InvalidPathLength: public std::exception { };
    class InvalidSequenceComponent: public std::exception { };
    class InvalidFragment: public std::exception { };

    // Decode a single-part UR.
    static UR decode(const std::string& string);

    // Start decoding a (possibly) multi-part UR.
    URDecoder();

    const std::optional<std::string>& expected_type() const { return expected_type_; }
    size_t expected_part_count() const { return fountain_decoder.expected_part_count(); }
    const PartIndexes& received_part_indexes() const { return fountain_decoder.received_part_indexes(); }
    const PartIndexes& last_part_indexes() const { return fountain_decoder.last_part_indexes(); }
    size_t processed_parts_count() const { return fountain_decoder.processed_parts_count(); }
    double estimated_percent_complete() const { return fountain_decoder.estimated_percent_complete(); }
    const Result& result() const { return result_; }
    bool is_success() const { return result() && std::holds_alternative<UR>(result().value()); }
    bool is_failure() const { return result() && std::holds_alternative<std::exception>(result().value()); }
    bool is_complete() const { return result().has_value(); }
    const UR& result_ur() const { return std::get<UR>(result().value()); }
    const std::exception& result_error() const { return std::get<std::exception>(result().value()); }

    bool receive_part(const std::string& s);

private:
    FountainDecoder fountain_decoder;

    std::optional<std::string> expected_type_;
    Result result_;

    static std::pair<std::string, StringVector> parse(const std::string& string);
    static std::pair<uint32_t, size_t> parse_sequence_component(const std::string& string);
    static UR decode(const std::string& type, const std::string& body);
    bool validate_part(const std::string& type);
};

}

#endif // BC_UR_DECODER_HPP