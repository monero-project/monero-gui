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

#ifndef MONERO_GUI_PAIRINGCODEHELPER_H
#define MONERO_GUI_PAIRINGCODEHELPER_H

#include <QtGlobal>
#include <wallet/api/wallet2_api.h>
#include <QMutex>
#include <QString>
#include <QWaitCondition>

/**
 * THP CodeEntry pairing code helper.  The wallet's worker thread blocks
 * inside onDevicePairingCodeRequest waiting for the user to type the
 * 6-digit code shown on the Trezor.  The QML side displays a modal,
 * collects the code, and calls onPairingCodeEntered to wake the worker.
 *
 * Mirrors the existing PassphraseHelper pattern.
 */
class PairingCodePrompter {
public:
    virtual void onWalletPairingCodeNeeded() = 0;
    virtual ~PairingCodePrompter() = default;
};

class PairingCodeReceiver {
public:
    virtual void onPairingCodeEntered(const QString &code, bool entry_abort) = 0;
    virtual ~PairingCodeReceiver() = default;
};

class PairingCodeHelper {
public:
    PairingCodeHelper(PairingCodePrompter *prompter = nullptr): m_prompter(prompter) {}
    PairingCodeHelper(const PairingCodeHelper &h): PairingCodeHelper(h.m_prompter) {}

    // Blocks until onPairingCodeEntered is called.  Returns the code as
    // a UTF-8 string (ASCII digits in practice).  Returns an empty
    // string on user cancel.
    Monero::optional<std::string> onDevicePairingCodeRequest();

    void onPairingCodeEntered(const QString &code, bool entry_abort);

private:
    PairingCodePrompter *m_prompter;
    QWaitCondition m_cond;
    QMutex m_mutex;
    QString m_code;
    bool m_abort = false;
    bool m_answered = false;
};

#endif // MONERO_GUI_PAIRINGCODEHELPER_H
