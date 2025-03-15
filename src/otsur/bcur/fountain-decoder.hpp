//
//  fountain-decoder.hpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef BC_UR_FOUNTAIN_DECODER_HPP
#define BC_UR_FOUNTAIN_DECODER_HPP

#include "utils.hpp"
#include "fountain-encoder.hpp"
#include <map>
#include <exception>
#include <deque>
#include <optional>
#include <variant>

namespace ur {

class FountainDecoder final {
public:
    typedef std::optional<std::variant<ByteVector, std::exception> > Result;

    class InvalidPart: public std::exception { };
    class InvalidChecksum: public std::exception { };

    FountainDecoder();

    size_t expected_part_count() const { return _expected_part_indexes.value().size(); }
    const PartIndexes& received_part_indexes() const { return received_part_indexes_; }
    const PartIndexes& last_part_indexes() const { return last_part_indexes_.value(); }
    size_t processed_parts_count() const { return processed_parts_count_; }
    const Result& result() const { return result_; }
    bool is_success() const { return result() && std::holds_alternative<ByteVector>(result().value()); }
    bool is_failure() const { return result() && std::holds_alternative<std::exception>(result().value()); }
    bool is_complete() const { return result().has_value(); }
    const ByteVector& result_message() const { return std::get<ByteVector>(result().value()); }
    const std::exception& result_error() const { return std::get<std::exception>(result().value()); }

    double estimated_percent_complete() const;
    bool receive_part(FountainEncoder::Part& encoder_part);

    // Join all the fragments of a message together, throwing away any padding
    static const ByteVector join_fragments(const std::vector<ByteVector>& fragments, size_t message_len);

private:
    class Part {
    private:
        PartIndexes indexes_;
        ByteVector data_;

    public:
        explicit Part(const FountainEncoder::Part& p);
        Part(PartIndexes& indexes, ByteVector& data);

        const PartIndexes& indexes() const { return indexes_; }
        const ByteVector& data() const { return data_; }
        bool is_simple() const { return indexes_.size() == 1; }
        size_t index() const { return *indexes_.begin(); }
    };

    PartIndexes received_part_indexes_;
    std::optional<PartIndexes> last_part_indexes_;
    size_t processed_parts_count_ = 0;

    Result result_;

    typedef std::map<PartIndexes, Part> PartDict;

    std::optional<PartIndexes> _expected_part_indexes;
    std::optional<size_t> _expected_fragment_len;
    std::optional<size_t> _expected_message_len;
    std::optional<uint32_t> _expected_checksum;

    PartDict _simple_parts;
    PartDict _mixed_parts;
    std::deque<Part> _queued_parts;

    void enqueue(const Part &p);
    void enqueue(Part &&p);
    void process_queue_item();
    void reduce_mixed_by(const Part& p);
    Part reduce_part_by_part(const Part& a, const Part& b) const;
    void process_simple_part(Part& p);
    void process_mixed_part(const Part& p);
    bool validate_part(const FountainEncoder::Part& p);

    // debugging
    static std::string indexes_to_string(const PartIndexes& indexes);
    std::string result_description() const;

    // cppcheck-suppress unusedPrivateFunction
    void print_part(const Part& p) const;
    // cppcheck-suppress unusedPrivateFunction
    void print_part_end() const;
    // cppcheck-suppress unusedPrivateFunction
    void print_state() const;
};

}

#endif // BC_UR_FOUNTAIN_DECODER_HPP
