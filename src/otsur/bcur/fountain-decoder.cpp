//
//  fountain-decoder.cpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#include "fountain-decoder.hpp"
#include <utility>
#include <algorithm>
#include <iostream>
#include <string>
#include <cmath>
#include <numeric>
#include <assert.h>

using namespace std;

namespace ur {

FountainDecoder::FountainDecoder() { }

FountainDecoder::Part::Part(const FountainEncoder::Part& p)
    : indexes_(choose_fragments(p.seq_num(), p.seq_len(), p.checksum()))
    , data_(p.data())
{
}

FountainDecoder::Part::Part(PartIndexes& indexes, ByteVector& data)
    : indexes_(indexes)
    , data_(data)
{
}

const ByteVector FountainDecoder::join_fragments(const vector<ByteVector>& fragments, size_t message_len) {
    auto message = join(fragments);
    return take_first(message, message_len);
}

double FountainDecoder::estimated_percent_complete() const {
    if(is_complete()) return 1;
    if(!_expected_part_indexes.has_value()) return 0;
    auto estimated_input_parts = expected_part_count() * 1.75;
    return min(0.99, processed_parts_count_ / estimated_input_parts);
}

bool FountainDecoder::receive_part(FountainEncoder::Part& encoder_part) {
    // Don't process the part if we're already done
    if(is_complete()) return false;

    // Don't continue if this part doesn't validate
    if(!validate_part(encoder_part)) return false;

    // Add this part to the queue
    auto p = Part(encoder_part);
    last_part_indexes_ = p.indexes();
    enqueue(p);

    // Process the queue until we're done or the queue is empty
    while(!is_complete() && !_queued_parts.empty()) {
        process_queue_item();
    }

    // Keep track of how many parts we've processed
    processed_parts_count_ += 1;

    //print_part_end();

    return true;
}

void FountainDecoder::enqueue(Part &&p) {
    _queued_parts.push_back(p);
}

void FountainDecoder::enqueue(const Part &p) {
    _queued_parts.push_back(p);
}

void FountainDecoder::process_queue_item() {
    auto part = _queued_parts.front();
    //print_part(part);
    _queued_parts.pop_front();
    if(part.is_simple()) {
        process_simple_part(part);
    } else {
        process_mixed_part(part);
    }
    //print_state();
}

void FountainDecoder::reduce_mixed_by(const Part& p) {
    // Reduce all the current mixed parts by the given part
    vector<Part> reduced_parts;
    for(auto i = _mixed_parts.begin(); i != _mixed_parts.end(); i++) {
        reduced_parts.push_back(reduce_part_by_part(i->second, p));
    }

    // Collect all the remaining mixed parts
    PartDict new_mixed;
    for(auto reduced_part: reduced_parts) {
        // If this reduced part is now simple
        if(reduced_part.is_simple()) {
            // Add it to the queue
            enqueue(reduced_part);
        } else {
            // Otherwise, add it to the list of current mixed parts
            new_mixed.insert(pair(reduced_part.indexes(), reduced_part));
        }
    }
    _mixed_parts = new_mixed;
}

FountainDecoder::Part FountainDecoder::reduce_part_by_part(const Part& a, const Part& b) const {
    // If the fragments mixed into `b` are a strict (proper) subset of those in `a`...
    if(is_strict_subset(b.indexes(), a.indexes())) {
        // The new fragments in the revised part are `a` - `b`.
        auto new_indexes = set_difference(a.indexes(), b.indexes());
        // The new data in the revised part are `a` XOR `b`
        auto new_data = xor_with(a.data(), b.data());
        return Part(new_indexes, new_data);
    } else {
        // `a` is not reducable by `b`, so return a
        return a;
    }
}

void FountainDecoder::process_simple_part(Part& p) {
    // Don't process duplicate parts
    auto fragment_index = p.index();
    if(contains(received_part_indexes_, fragment_index)) return;

    // Record this part
    _simple_parts.insert(pair(p.indexes(), p));
    received_part_indexes_.insert(fragment_index);

    // If we've received all the parts
    if(received_part_indexes_ == _expected_part_indexes) {
        // Reassemble the message from its fragments
        vector<Part> sorted_parts;
        transform(_simple_parts.begin(), _simple_parts.end(), back_inserter(sorted_parts), [&](auto elem) { return elem.second; });
        sort(sorted_parts.begin(), sorted_parts.end(),
            [](const Part& a, const Part& b) -> bool {
                return a.index() < b.index();
            }
        );
        vector<ByteVector> fragments;
        transform(sorted_parts.begin(), sorted_parts.end(), back_inserter(fragments), [&](auto part) { return part.data(); });
        auto message = join_fragments(fragments, *_expected_message_len);

        // Verify the message checksum and note success or failure
        auto checksum = crc32_int(message);
        if(checksum == _expected_checksum) {
            result_ = message;
        } else {
            result_ = InvalidChecksum();
        }
    } else {
        // Reduce all the mixed parts by this part
        reduce_mixed_by(p);
    }
}

void FountainDecoder::process_mixed_part(const Part& p) {
    // Don't process duplicate parts
    if(any_of(_mixed_parts.begin(), _mixed_parts.end(), [&](auto r) { return r.first == p.indexes(); })) {
        return;
    }

    // Reduce this part by all the others
    auto p2 = accumulate(_simple_parts.begin(), _simple_parts.end(), p, [&](auto p, auto r) { return reduce_part_by_part(p, r.second); });
    p2 = accumulate(_mixed_parts.begin(), _mixed_parts.end(), p2, [&](auto p, auto r) { return reduce_part_by_part(p, r.second); });

    // If the part is now simple
    if(p2.is_simple()) {
        // Add it to the queue
        enqueue(p2);
    } else {
        // Reduce all the mixed parts by this one
        reduce_mixed_by(p2);
        // Record this new mixed part
        _mixed_parts.insert(pair(p2.indexes(), p2));
    }
}

bool FountainDecoder::validate_part(const FountainEncoder::Part& p) {
    // If this is the first part we've seen
    if(!_expected_part_indexes.has_value()) {
        // Record the things that all the other parts we see will have to match to be valid.
        _expected_part_indexes = PartIndexes();
        for(size_t i = 0; i < p.seq_len(); i++) { _expected_part_indexes->insert(i); }
        _expected_message_len = p.message_len();
        _expected_checksum = p.checksum();
        _expected_fragment_len = p.data().size();
    } else {
        // If this part's values don't match the first part's values, throw away the part
        if(expected_part_count() != p.seq_len()) return false;
        if(_expected_message_len != p.message_len()) return false;
        if(_expected_checksum != p.checksum()) return false;
        if(_expected_fragment_len != p.data().size()) return false;
    }
    // This part should be processed
    return true;
}

string FountainDecoder::indexes_to_string(const PartIndexes& indexes) {
    auto i = vector<size_t>(indexes.begin(), indexes.end());
    sort(i.begin(), i.end());
    StringVector s;
    transform(i.begin(), i.end(), back_inserter(s), [](size_t a) { return to_string(a); });
    return "[" + join(s, ", ") + "]";
}

void FountainDecoder::print_part(const Part& p) const {
    cout << "part indexes: " << indexes_to_string(p.indexes()) << endl;
}

void FountainDecoder::print_part_end() const {
    auto expected = _expected_part_indexes.has_value() ? to_string(expected_part_count()) : "nil";
    auto percent = int(round(estimated_percent_complete() * 100));
    cout << "processed: " << processed_parts_count_ << ", expected: " << expected << ", received: " << received_part_indexes_.size() << ", percent: " << percent << "%" << endl;
}

string FountainDecoder::result_description() const {
    string desc;
    if(!result_.has_value()) {
        desc = "nil";
    } else {
        auto r = *result_;
        if(holds_alternative<ByteVector>(r)) {
            desc = to_string(get<ByteVector>(r).size()) + " bytes";
        } else if(holds_alternative<exception>(r)) {
            desc = get<exception>(r).what();
        } else {
            assert(false);
        }
    }
    return desc;
}

void FountainDecoder::print_state() const {
    auto parts = _expected_part_indexes.has_value() ? to_string(expected_part_count()) : "nil";
    auto received = indexes_to_string(received_part_indexes_);
    StringVector mixed;
    transform(_mixed_parts.begin(), _mixed_parts.end(), back_inserter(mixed), [](const pair<const PartIndexes, Part>& p) { 
        return indexes_to_string(p.first);
    });
    auto mixed_s = "[" + join(mixed, ", ") + "]";
    auto queued = _queued_parts.size();
    auto res = result_description();
    cout << "parts: " << parts << ", received: " << received << ", mixed: " << mixed_s << ", queued: " << queued << ", result: " << res << endl;
}

}
