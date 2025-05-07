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

#include "wallet_manager.h"
#include "wallet.h"
#include "common_defines.h"
#include "common/util.h"
#include "net/http_client.h"
#include "net/http.h"
#include "p2p/net_node.h"
#include "cryptonote_basic/cryptonote_basic_impl.h"
#include "cryptonote_basic/account.h"
#include "mnemonics/electrum-words.h"
#include "common/dns_utils.h"
#include "common/updates.h"

#include <boost/filesystem.hpp>
#include <boost/regex.hpp>

namespace fs = boost::filesystem;

namespace Monero {

WalletManager * WalletManagerFactory::getWalletManager()
{
    static WalletManagerImpl * g_walletManager = nullptr;

    if (!g_walletManager) {
        g_walletManager = new WalletManagerImpl();
    }

    return g_walletManager;
}

void WalletManagerFactory::setLogLevel(int level)
{
    WalletManagerImpl::setLogLevel(level);
}

void WalletManagerFactory::setLogCategories(const std::string &categories)
{
    WalletManagerImpl::setLogCategories(categories);
}

Wallet *WalletManagerImpl::createWallet(const std::string &path, const std::string &password, const std::string &language, bool testnet)
{
    WalletImpl * wallet = new WalletImpl(testnet);
    wallet->create(path, password, language);
    return wallet;
}

Wallet *WalletManagerImpl::openWallet(const std::string &path, const std::string &password, bool testnet)
{
    WalletImpl * wallet = new WalletImpl(testnet);
    wallet->open(path, password);
    return wallet;
}

Wallet *WalletManagerImpl::recoveryWallet(const std::string &path, const std::string &password, const std::string &mnemonic, bool testnet, uint64_t restoreHeight)
{
    WalletImpl * wallet = new WalletImpl(testnet);
    wallet->recover(path, password, mnemonic, restoreHeight);
    return wallet;
}

Wallet *WalletManagerImpl::createWalletFromKeys(const std::string &path, const std::string &password, const std::string &language, bool testnet, uint64_t restoreHeight, const std::string &addressString, const std::string &viewKeyString, const std::string &spendKeyString)
{
    WalletImpl * wallet = new WalletImpl(testnet);
    wallet->createWalletFromKeys(path, password, language, restoreHeight, addressString, viewKeyString, spendKeyString);
    return wallet;
}

Wallet *WalletManagerImpl::createDeterministicWallet(const std::string &path, const std::string &password, const std::string &language, bool testnet)
{
    WalletImpl * wallet = new WalletImpl(testnet);
    wallet->createDeterministicWallet(path, password, language);
    return wallet;
}

bool WalletManagerImpl::closeWallet(Wallet *wallet, bool store)
{
    WalletImpl * wallet_ = dynamic_cast<WalletImpl*>(wallet);
    if (!wallet_)
        return false;
    bool result = wallet_->close(store);
    if (result) {
        delete wallet_;
    }
    return result;
}

bool WalletManagerImpl::walletExists(const std::string &path)
{
    bool keys_file_exists;
    bool wallet_file_exists;
    tools::wallet2::wallet_exists(path, keys_file_exists, wallet_file_exists);
    if(keys_file_exists){
        return true;
    }
    return false;
}

bool WalletManagerImpl::verifyWalletPassword(const std::string &keys_file_name, const std::string &password, bool no_spend_key, uint64_t kdf_rounds) const
{
    return tools::wallet2::verify_password(keys_file_name, password, no_spend_key, kdf_rounds);
}

std::vector<std::string> WalletManagerImpl::findWallets(const std::string &path)
{
    std::vector<std::string> result;
    boost::regex wallet_rx("(.*)\\.(keys)$"); // searching for <wallet_name>.keys files
    boost::filesystem::recursive_directory_iterator end_itr; // Default ctor yields past-the-end
    for (boost::filesystem::recursive_directory_iterator itr(path); itr != end_itr; ++itr) {
        // Skip if not a file
        if (!boost::filesystem::is_regular_file(itr->status()))
            continue;
        boost::smatch what;
        std::string filename = itr->path().filename().string();
        boost::regex_match(filename, what, wallet_rx);
        if (what.size() != 0) {
            result.push_back(itr->path().string());
        }
    }
    return result;
}

std::string WalletManagerImpl::errorString() const
{
    return std::string("error: ") + m_errorString;
}

void WalletManagerImpl::setDaemonAddress(const std::string &address)
{
    m_daemonAddress = address;
}

// I2P methods implementation
bool WalletManagerImpl::isI2PEnabled(const Wallet &wallet) const
{
    const WalletImpl * wallet_ = dynamic_cast<const WalletImpl*>(&wallet);
    if (!wallet_) {
        m_errorString = "Wallet pointer is invalid";
        return false;
    }
    return wallet_->isI2PEnabled();
}

void WalletManagerImpl::setI2PEnabled(Wallet &wallet, bool enabled)
{
    WalletImpl * wallet_ = dynamic_cast<WalletImpl*>(&wallet);
    if (!wallet_) {
        m_errorString = "Wallet pointer is invalid";
        return;
    }
    wallet_->setI2PEnabled(enabled);
}

void WalletManagerImpl::setI2POptions(Wallet &wallet, const std::string &options)
{
    WalletImpl * wallet_ = dynamic_cast<WalletImpl*>(&wallet);
    if (!wallet_) {
        m_errorString = "Wallet pointer is invalid";
        return;
    }
    wallet_->setI2POptions(options);
}

std::string WalletManagerImpl::getI2POptions(const Wallet &wallet) const
{
    const WalletImpl * wallet_ = dynamic_cast<const WalletImpl*>(&wallet);
    if (!wallet_) {
        m_errorString = "Wallet pointer is invalid";
        return "";
    }
    return wallet_->getI2POptions();
}

void WalletManagerImpl::setLogLevel(int level)
{
    tools::wallet2::set_default_log_level(level);
}

void WalletManagerImpl::setLogCategories(const std::string &categories)
{
    tools::wallet2::set_default_log_categories(categories.c_str());
}

std::string WalletManagerImpl::resolveOpenAlias(const std::string &address, bool &dnssec_valid) const
{
    tools::dns_utils::address_parse_info info;
    if (tools::dns_utils::parse_address_from_txt_record(address, info))
    {
        dnssec_valid = info.dnssec_valid;
        return info.address;
    }
    return "";
}

std::string WalletManagerImpl::getDefaultDataDir() const
{
    return tools::get_default_data_dir();
}

bool WalletManagerImpl::connected(uint32_t *version)
{
    try {
        m_wallet = new tools::wallet2();
        return true;
    } catch (const std::exception &e) {
        m_errorString = e.what();
        return false;
    }
}

uint64_t WalletManagerImpl::blockchainHeight()
{
    return 0;
}

uint64_t WalletManagerImpl::blockchainTargetHeight()
{
    return 0;
}

uint64_t WalletManagerImpl::networkDifficulty()
{
    return 0;
}

double WalletManagerImpl::miningHashRate()
{
    return 0.0;
}

uint64_t WalletManagerImpl::blockTarget()
{
    return 0;
}

bool WalletManagerImpl::isMining()
{
    return false;
}

bool WalletManagerImpl::startMining(const std::string &address, uint32_t threads, bool background_mining, bool ignore_battery)
{
    return false;
}

bool WalletManagerImpl::stopMining()
{
    return false;
}

} // namespace Monero 