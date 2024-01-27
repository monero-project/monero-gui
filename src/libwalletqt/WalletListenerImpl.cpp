// Copyright (c) 2014-2024, The Monero Project
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

#include "WalletListenerImpl.h"
#include "Wallet.h"

WalletListenerImpl::WalletListenerImpl(Wallet * w)
    : m_wallet(w)
    , m_phelper(w)
{

}

void WalletListenerImpl::moneySpent(const std::string &txId, uint64_t amount)
{
    qDebug() << __FUNCTION__;
    emit m_wallet->moneySpent(QString::fromStdString(txId), amount);
}

void WalletListenerImpl::moneyReceived(const std::string &txId, uint64_t amount)
{
    qDebug() << __FUNCTION__;
    emit m_wallet->moneyReceived(QString::fromStdString(txId), amount);
}

void WalletListenerImpl::unconfirmedMoneyReceived(const std::string &txId, uint64_t amount)
{
    qDebug() << __FUNCTION__;
    emit m_wallet->unconfirmedMoneyReceived(QString::fromStdString(txId), amount);
}

void WalletListenerImpl::newBlock(uint64_t height)
{
    // qDebug() << __FUNCTION__;
    emit m_wallet->newBlock(height, m_wallet->daemonBlockChainTargetHeight());
}

void WalletListenerImpl::updated()
{
    emit m_wallet->updated();
}

// called when wallet refreshed by background thread or explicitly
void WalletListenerImpl::refreshed()
{
    qDebug() << __FUNCTION__;
    emit m_wallet->refreshed();
}

void WalletListenerImpl::onDeviceButtonRequest(uint64_t code)
{
    qDebug() << __FUNCTION__;
    emit m_wallet->deviceButtonRequest(code);
}

void WalletListenerImpl::onDeviceButtonPressed()
{
    qDebug() << __FUNCTION__;
    emit m_wallet->deviceButtonPressed();
}

void WalletListenerImpl::onPassphraseEntered(const QString &passphrase, bool enter_on_device, bool entry_abort)
{
    qDebug() << __FUNCTION__;
    m_phelper.onPassphraseEntered(passphrase, enter_on_device, entry_abort);
}

Monero::optional<std::string> WalletListenerImpl::onDevicePassphraseRequest(bool & on_device)
{
    qDebug() << __FUNCTION__;
    return m_phelper.onDevicePassphraseRequest(on_device);
}
