//
//  ur.hpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef BC_UR_UR_HPP
#define BC_UR_UR_HPP

#include <string>
#include <exception>
#include "utils.hpp"

namespace ur {

class UR final {
private:
    std::string type_;
    ByteVector cbor_;
public:
    class invalid_type: public std::exception { };

    const std::string& type() const { return type_; }
    const ByteVector& cbor() const { return cbor_; }

    UR(const std::string& type, const ByteVector& cbor);
};

bool operator==(const UR& lhs, const UR& rhs);

}

#endif // BC_UR_UR_HPP