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

#include <string>
#include <vector>
#include <list>
#include <set>
#include <ctime>
#include <functional>
#include <iostream>

namespace Monero {

    /**
     * @brief Transaction-like interface for sending money
     */
    struct PendingTransaction
    {
        enum Status {
            Status_Ok,
            Status_Error,
            Status_Critical
        };

        enum Priority {
            Priority_Default = 0,
            Priority_Low = 1,
            Priority_Medium = 2,
            Priority_High = 3,
            Priority_Last
        };

        virtual ~PendingTransaction() = 0;
        virtual int status() const = 0;
        virtual std::string errorString() const = 0;
        virtual bool commit() = 0;
        virtual uint64_t amount() const = 0;
        virtual uint64_t dust() const = 0;
        virtual uint64_t fee() const = 0;
        virtual std::vector<std::string> txid() const = 0;
        virtual size_t txCount() const = 0;
        virtual std::string unsignedTxToBin() const = 0;
        virtual std::string unsignedTxToBase64() const = 0;
        virtual std::vector<std::string> signedTxToHex() const = 0;
        virtual PendingTransaction::Priority priority() const = 0;
        virtual std::string multisigSignData() const = 0;
        virtual void signMultisigTx() = 0;
        virtual std::vector<std::string> signersKeys() const = 0;
    };

    /**
     * @brief The Wallet struct
     */
    struct Wallet
    {
        enum Status {
            Status_Ok,
            Status_Error,
            Status_Critical
        };

        enum ConnectionStatus {
            ConnectionStatus_Disconnected,
            ConnectionStatus_Connecting,
            ConnectionStatus_Connected,
            ConnectionStatus_WrongVersion
        };

        virtual ~Wallet() = 0;
        virtual std::string seed() const = 0;
        virtual std::string getSeedLanguage() const = 0;
        virtual void setSeedLanguage(const std::string &arg) = 0;
        //! returns wallet status (Status_Ok | Status_Error)
        virtual int status() const = 0;
        //! in case error status, returns error string
        virtual std::string errorString() const = 0;
        virtual bool setPassword(const std::string &password) = 0;
        virtual std::string address(uint32_t accountIndex = 0, uint32_t addressIndex = 0) const = 0;
        virtual std::string path() const = 0;
        virtual bool testnet() const = 0;
        virtual bool hardForkInfo(uint8_t &version, uint64_t &earliest_height) const = 0;
        virtual std::string publicViewKey() const = 0;
        virtual std::string privateViewKey() const = 0;
        virtual std::string publicSpendKey() const = 0;
        virtual std::string privateSpendKey() const = 0;
        virtual std::string publicMultisigSignerKey() const = 0;
        virtual std::string getMultisigInfo() const = 0;
        virtual std::string makeMultisig(const std::vector<std::string>& info, uint32_t threshold) = 0;
        virtual std::string exchangeMultisigKeys(const std::vector<std::string> &info) = 0;
        virtual bool finalizeMultisig(const std::vector<std::string>& extraMultisigInfo) = 0;
        virtual bool exportMultisigImages(std::string& images) = 0;
        virtual size_t importMultisigImages(const std::vector<std::string>& images) = 0;
        virtual bool hasMultisigPartialKeyImages() const = 0;
        virtual PendingTransaction* restoreMultisigTransaction(const std::string& signData) = 0;
        virtual PendingTransaction* createTransaction(const std::string &dst_addr, const std::string &payment_id,
                                                      optional<uint64_t> amount, uint32_t mixin_count,
                                                      PendingTransaction::Priority priority = PendingTransaction::Priority_Low,
                                                      uint32_t subaddr_account = 0,
                                                      std::set<uint32_t> subaddr_indices = std::set<uint32_t>()) = 0;
        virtual bool submitTransaction(const std::string &fileName) = 0;
        virtual void disposeTransaction(PendingTransaction * t) = 0;
        virtual uint64_t balance(uint32_t accountIndex = 0) const = 0;
        virtual uint64_t unlockedBalance(uint32_t accountIndex = 0) const = 0;
        virtual uint64_t blockChainHeight() const = 0;
        virtual uint64_t approximateBlockChainHeight() const = 0;
        virtual uint64_t daemonBlockChainHeight() const = 0;
        virtual uint64_t daemonBlockChainTargetHeight() const = 0;
        virtual bool synchronized() const = 0;
        virtual bool refresh() = 0;
        virtual void refreshAsync() = 0;
        virtual void setAutoRefreshInterval(int millis) = 0;
        virtual int autoRefreshInterval() const = 0;
        virtual void setRefreshFromBlockHeight(uint64_t refresh_from_block_height) = 0;
        virtual uint64_t getRefreshFromBlockHeight() const = 0;
        virtual void setRecoveringFromSeed(bool recoveringFromSeed) = 0;
        virtual bool connectToDaemon() = 0;
        virtual ConnectionStatus connected() const = 0;
        virtual void setTrustedDaemon(bool arg) = 0;
        virtual bool trustedDaemon() const = 0;
        virtual uint64_t defaultMixin() const = 0;
        virtual void setDefaultMixin(uint64_t arg) = 0;
        virtual bool setUserNote(const std::string &txid, const std::string &note) = 0;
        virtual std::string getUserNote(const std::string &txid) const = 0;
        virtual std::string getTxKey(const std::string &txid) const = 0;
        virtual bool checkTxKey(const std::string &txid, std::string tx_key, const std::string &address, uint64_t &received, bool &in_pool, uint64_t &confirmations) = 0;
        virtual std::string getTxProof(const std::string &txid, const std::string &address, const std::string &message) const = 0;
        virtual bool checkTxProof(const std::string &txid, const std::string &address, const std::string &message, const std::string &signature, bool &good, uint64_t &received, bool &in_pool, uint64_t &confirmations) = 0;
        virtual std::string getSpendProof(const std::string &txid, const std::string &message) const = 0;
        virtual bool checkSpendProof(const std::string &txid, const std::string &message, const std::string &signature, bool &good) const = 0;
        virtual std::string signMessage(const std::string &message) = 0;
        virtual bool verifySignedMessage(const std::string &message, const std::string &address, const std::string &signature, bool &good) const = 0;
        virtual void startRefresh() = 0;
        virtual void pauseRefresh() = 0;
        virtual bool isOffline() const = 0;
        
        // I2P methods
        virtual bool isI2PEnabled() const = 0;
        virtual void setI2PEnabled(bool enabled) = 0;
        virtual void setI2POptions(const std::string &options) = 0;
        virtual std::string getI2POptions() const = 0;

        virtual std::string getFilename() const = 0;
        virtual std::string keysFilename() const = 0;
    };

    struct WalletManager
    {
        virtual ~WalletManager() = 0;
        virtual Wallet * createWallet(const std::string &path, const std::string &password, const std::string &language, bool testnet = false) = 0;
        virtual Wallet * openWallet(const std::string &path, const std::string &password, bool testnet = false) = 0;
        virtual Wallet * recoveryWallet(const std::string &path, const std::string &password, const std::string &mnemonic,
                                       bool testnet = false, uint64_t restoreHeight = 0) = 0;
        virtual Wallet * createWalletFromKeys(const std::string &path, const std::string &password, const std::string &language,
                                                bool testnet = false, uint64_t restoreHeight = 0, const std::string &addressString = "",
                                                const std::string &viewKeyString = "", const std::string &spendKeyString = "") = 0;
        virtual Wallet * createDeterministicWallet(const std::string &path, const std::string &password, const std::string &language,
                                                bool testnet = false) = 0;
        virtual bool closeWallet(Wallet *wallet, bool store = true) = 0;
        virtual bool walletExists(const std::string &path) = 0;
        virtual bool verifyWalletPassword(const std::string &keys_file_name, const std::string &password, bool no_spend_key, uint64_t kdf_rounds = 1) const = 0;
        virtual std::vector<std::string> findWallets(const std::string &path) = 0;
        virtual std::string errorString() const = 0;
        virtual void setDaemonAddress(const std::string &address) = 0;
        virtual bool connected(uint32_t *version = NULL) = 0;
        virtual uint64_t blockchainHeight() = 0;
        virtual uint64_t blockchainTargetHeight() = 0;
        virtual uint64_t networkDifficulty() = 0;
        virtual double miningHashRate() = 0;
        virtual uint64_t blockTarget() = 0;
        virtual bool isMining() = 0;
        virtual bool startMining(const std::string &address, uint32_t threads = 1, bool background_mining = false, bool ignore_battery = true) = 0;
        virtual bool stopMining() = 0;
        
        // I2P methods
        virtual bool isI2PEnabled(const Wallet &wallet) const = 0;
        virtual void setI2PEnabled(Wallet &wallet, bool enabled) = 0;
        virtual void setI2POptions(Wallet &wallet, const std::string &options) = 0;
        virtual std::string getI2POptions(const Wallet &wallet) const = 0;

        virtual void setLogLevel(int level) = 0;
        virtual void setLogCategories(const std::string &categories) = 0;
        virtual std::string resolveOpenAlias(const std::string &address, bool &dnssec_valid) const = 0;
        virtual std::string getDefaultDataDir() const = 0;
    };

} 