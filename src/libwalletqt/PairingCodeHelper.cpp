// Copyright (c) 2026, The Monero Project
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

#include "PairingCodeHelper.h"
#include <QDebug>
#include <QMutexLocker>

Monero::optional<std::string> PairingCodeHelper::onDevicePairingCodeRequest()
{
    qDebug() << __FUNCTION__;
    QMutexLocker locker(&m_mutex);
    m_abort = false;
    m_answered = false;
    m_code.clear();

    if (m_prompter != nullptr) {
        m_prompter->onWalletPairingCodeNeeded();
    }

    while (!m_answered) {
        m_cond.wait(&m_mutex);
    }

    if (m_abort) {
        return Monero::optional<std::string>(std::string{});
    }
    auto result = m_code.toStdString();
    m_code.clear();
    return Monero::optional<std::string>(result);
}

void PairingCodeHelper::onPairingCodeEntered(const QString &code, bool entry_abort)
{
    qDebug() << __FUNCTION__;
    QMutexLocker locker(&m_mutex);
    m_code = code;
    m_abort = entry_abort;
    m_answered = true;
    m_cond.wakeAll();
}
