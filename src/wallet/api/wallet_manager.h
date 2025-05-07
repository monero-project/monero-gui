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

#pragma once

#include "wallet/wallet2_api.h"
#include <string>

namespace Monero {

class WalletManagerImpl : public WalletManager
{
public:
    Wallet * createWallet(const std::string &path, const std::string &password, const std::string &language, bool testnet = false) override;
    Wallet * openWallet(const std::string &path, const std::string &password, bool testnet = false) override;
    Wallet * recoveryWallet(const std::string &path, const std::string &password, const std::string &mnemonic,
                            bool testnet = false, uint64_t restoreHeight = 0) override;
    Wallet * createWalletFromKeys(const std::string &path, const std::string &password, const std::string &language,
                                    bool testnet = false, uint64_t restoreHeight = 0, const std::string &addressString = "",
                                    const std::string &viewKeyString = "", const std::string &spendKeyString = "") override;
    Wallet * createDeterministicWallet(const std::string &path, const std::string &password, const std::string &language,
                                    bool testnet = false) override;
    bool closeWallet(Wallet *wallet, bool store = true) override;
    bool walletExists(const std::string &path) override;
    bool verifyWalletPassword(const std::string &keys_file_name, const std::string &password, bool no_spend_key = false, uint64_t kdf_rounds = 1) const override;
    std::vector<std::string> findWallets(const std::string &path) override;
    std::string errorString() const override;
    void setDaemonAddress(const std::string &address) override;
    bool connected(uint32_t *version = nullptr) override;
    uint64_t blockchainHeight() override;
    uint64_t blockchainTargetHeight() override;
    uint64_t networkDifficulty() override;
    double miningHashRate() override;
    uint64_t blockTarget() override;
    bool isMining() override;
    bool startMining(const std::string &address, uint32_t threads = 1, bool background_mining = false, bool ignore_battery = true) override;
    bool stopMining() override;

    // I2P methods
    bool isI2PEnabled(const Wallet &wallet) const override;
    void setI2PEnabled(Wallet &wallet, bool enabled) override;
    void setI2POptions(Wallet &wallet, const std::string &options) override;
    std::string getI2POptions(const Wallet &wallet) const override;

    void setLogLevel(int level) override;
    void setLogCategories(const std::string &categories) override;
    std::string resolveOpenAlias(const std::string &address, bool &dnssec_valid) const override;
    std::string getDefaultDataDir() const override;
};

} // namespace Monero 