//
//  bytewords.hpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef BC_UR_BYTEWORDS_HPP
#define BC_UR_BYTEWORDS_HPP

#include <string>
#include "utils.hpp"

namespace ur {

class Bytewords final {
public:
    enum style {
        standard,
        uri,
        minimal
    };

    static std::string encode(style style, const ByteVector& bytes);
    static ByteVector decode(style style, const std::string& string);
};

}

#endif // BC_UR_BYTEWORDS_HPP
