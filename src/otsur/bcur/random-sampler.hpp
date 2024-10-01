//
//  random-sampler.hpp
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef BC_UR_RANDOM_SAMPLER_HPP
#define BC_UR_RANDOM_SAMPLER_HPP

#include <vector>
#include <functional>

// Random-number sampling using the Walker-Vose alias method,
// as described by Keith Schwarz (2011)
// http://www.keithschwarz.com/darts-dice-coins

// Based on C implementation:
// https://jugit.fz-juelich.de/mlz/ransampl

// Translated to C++ by Wolf McNally

namespace ur {

class RandomSampler final {
public:
    explicit RandomSampler(std::vector<double> probs);

    int next(std::function<double()> rng);

private:
    std::vector<double> probs_;
    std::vector<int> aliases_;
};

}

#endif // BC_UR_RANDOM_SAMPLER_HPP
