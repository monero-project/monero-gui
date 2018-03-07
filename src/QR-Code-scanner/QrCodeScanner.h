// Copyright (c) 2014-2018, The Monero Project
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

#ifndef QRCODESCANNER_H_
#define QRCODESCANNER_H_

#include <QImage>
#include <QVideoFrame>
#include "QrScanThread.h"

class QVideoProbe;
class QCamera;

class QrCodeScanner : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    QrCodeScanner(QObject *parent = Q_NULLPTR);
    ~QrCodeScanner();
    void setSource(QCamera*);

    bool enabled() const;
    void setEnabled(bool enabled);

public Q_SLOTS:
    void processCode(int type, const QString &data);
    void processFrame(QVideoFrame);

Q_SIGNALS:
    void enabledChanged();

    void decoded(const QString &address, const QString &payment_id, const QString &amount, const QString &tx_description, const QString &recipient_name, const QVariantMap &extra_parameters);
    void decode(int type, const QString &data);
    void notifyError(const QString &error, bool warning = false);

protected:
    void timerEvent(QTimerEvent *);
    QrScanThread *m_thread;
    int m_processTimerId;
    int m_processInterval;
    int m_enabled;
    QVideoFrame m_curFrame;
    QVideoProbe *m_probe;
};

#endif

