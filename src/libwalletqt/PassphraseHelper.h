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

#ifndef MONERO_GUI_PASSPHRASEHELPER_H
#define MONERO_GUI_PASSPHRASEHELPER_H

#include <QtGlobal>
#include <wallet/api/wallet2_api.h>
#include <QMutex>
#include <QPointer>
#include <QWaitCondition>
#include <QMutex>

/**
 * Implements component responsible for showing entry prompt to the user,
 * typically Wallet / Wallet manager.
 */
class PassprasePrompter {
public:
    virtual void onWalletPassphraseNeeded(bool onDevice) = 0;
};

/**
 * Implements receiver of the passphrase responsible for passing it back to the wallet,
 * typically wallet listener.
 */
class PassphraseReceiver {
public:
    virtual void onPassphraseEntered(const QString &passphrase, bool enter_on_device, bool entry_abort) = 0;
};

class PassphraseHelper {
public:
    PassphraseHelper(PassprasePrompter * prompter=nullptr): m_prompter(prompter) {};
    PassphraseHelper(const PassphraseHelper & h): PassphraseHelper(h.m_prompter) {};
    Monero::optional<std::string> onDevicePassphraseRequest(bool & on_device);
    void onPassphraseEntered(const QString &passphrase, bool enter_on_device, bool entry_abort);

private:
    PassprasePrompter * m_prompter;
    QWaitCondition m_cond_pass;
    QMutex m_mutex_pass;
    QString m_passphrase;
    bool m_passphrase_abort;
    bool m_passphrase_on_device;

};

#endif //MONERO_GUI_PASSPHRASEHELPER_H
