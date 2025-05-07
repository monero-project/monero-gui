// Copyright (c) 2014-2023, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Parts of this file are originally copyright (c) 2012-2013 The Cryptonote developers

#include "wallet.h"
#include "wallet/wallet2_api.h"
#include <string>
#include <iostream>

namespace Monero {

class WalletImpl : public Wallet
{
public:
    WalletImpl(wallet2* w): m_wallet(w) {}
    ~WalletImpl() { delete m_wallet; }

    // I2P methods
    bool isI2PEnabled() const
    {
        return m_wallet->i2p_enabled();
    }

    void setI2PEnabled(bool enabled)
    {
        m_wallet->set_i2p_enabled(enabled);
    }

    void setI2POptions(const std::string &options)
    {
        m_wallet->set_i2p_options(options);
    }

    std::string getI2POptions() const
    {
        return m_wallet->get_i2p_options();
    }

private:
    wallet2* m_wallet;
};

/* Implementation of pending transaction */
class PendingTransactionImpl : public PendingTransaction
{
public:
    PendingTransactionImpl() {}
    ~PendingTransactionImpl() {}

    // PendingTransaction implementation
    int status() const { return 0; }
    std::string errorString() const { return ""; }
    bool commit() { return true; }
    uint64_t amount() const { return 0; }
    uint64_t dust() const { return 0; }
    uint64_t fee() const { return 0; }
    std::vector<std::string> txid() const { return {}; }
    size_t txCount() const { return 0; }
    std::string unsignedTxToBin() const { return ""; }
    std::string unsignedTxToBase64() const { return ""; }
    std::vector<std::string> signedTxToHex() const { return {}; }
    PendingTransaction::Priority priority() const { return Priority_Default; }
    std::string multisigSignData() const { return ""; }
    void signMultisigTx() {}
    std::vector<std::string> signersKeys() const { return {}; }
};

/* Implementation of I2P-related methods */
bool WalletImpl::isI2PEnabled() const
{
    return m_wallet->i2p_enabled();
}

void WalletImpl::setI2PEnabled(bool enabled)
{
    m_wallet->set_i2p_enabled(enabled);
}

void WalletImpl::setI2POptions(const std::string &options)
{
    m_wallet->set_i2p_options(options);
}

std::string WalletImpl::getI2POptions() const
{
    return m_wallet->get_i2p_options();
}

} 