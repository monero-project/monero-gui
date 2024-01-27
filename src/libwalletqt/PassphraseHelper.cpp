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

#include "PassphraseHelper.h"
#include <QMutexLocker>
#include <QDebug>

Monero::optional<std::string> PassphraseHelper::onDevicePassphraseRequest(bool & on_device)
{
    qDebug() << __FUNCTION__;
    QMutexLocker locker(&m_mutex_pass);
    m_passphrase_on_device = true;
    m_passphrase_abort = false;

    if (m_prompter != nullptr){
        m_prompter->onWalletPassphraseNeeded(on_device);
    }

    m_cond_pass.wait(&m_mutex_pass);

    if (m_passphrase_abort)
    {
        throw std::runtime_error("Passphrase entry abort");
    }

    on_device = m_passphrase_on_device;
    if (!on_device) {
        auto tmpPass = m_passphrase.toStdString();
        m_passphrase = QString();
        return Monero::optional<std::string>(tmpPass);
    } else {
        return Monero::optional<std::string>();
    }
}

void PassphraseHelper::onPassphraseEntered(const QString &passphrase, bool enter_on_device, bool entry_abort)
{
    qDebug() << __FUNCTION__;
    QMutexLocker locker(&m_mutex_pass);
    m_passphrase = passphrase;
    m_passphrase_abort = entry_abort;
    m_passphrase_on_device = enter_on_device;

    m_cond_pass.wakeAll();
}
