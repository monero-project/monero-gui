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

#include "QrCodeScanner.h"
#include <WalletManager.h>
#include <QVideoProbe>
#include <QCamera>

QrCodeScanner::QrCodeScanner(QObject *parent)
    : QObject(parent)
    , m_processTimerId(-1)
    , m_processInterval(750)
    , m_enabled(true)
{
    m_probe = new QVideoProbe(this);
    m_thread = new QrScanThread(this);
    m_thread->start();
    QObject::connect(m_thread, SIGNAL(decoded(int,QString)), this, SLOT(processCode(int,QString)));
    QObject::connect(m_thread, SIGNAL(notifyError(const QString &, bool)), this, SIGNAL(notifyError(const QString &, bool)));
    connect(m_probe, SIGNAL(videoFrameProbed(QVideoFrame)), this, SLOT(processFrame(QVideoFrame)));
}
void QrCodeScanner::setSource(QCamera *camera)
{
    m_probe->setSource(camera);
}
void QrCodeScanner::processCode(int type, const QString &data)
{
    if (! m_enabled) return;
    qDebug() << "decoded - type: " << type << " data: " << data;
    QString address, payment_id, tx_description, recipient_name, error;
    QVector<QString> unknown_parameters;
    uint64_t amount(0);
    if( ! WalletManager::instance()->parse_uri(data, address, payment_id, amount, tx_description, recipient_name, unknown_parameters, error) )
    {
        qDebug() << "Failed to parse_uri : " << error;
        emit notifyError(error);
        return;
    }
    QVariantMap parsed_unknown_parameters;
    if(unknown_parameters.size() > 0)
    {
        qDebug() << "unknown parameters " << unknown_parameters;
        foreach(const QString &item, unknown_parameters )
        {
            QStringList parsed_item = item.split("=");
            if(parsed_item.size() == 2) {
                parsed_unknown_parameters.insert(parsed_item[0], parsed_item[1]);
            }
        }
        emit notifyError(error, true);
    }
    qDebug() << "Parsed URI : " << address << " " << payment_id << " " << amount << " " << tx_description << " " << recipient_name << " " << error;
    QString s_amount = WalletManager::instance()->displayAmount(amount);
    qDebug() << "Amount passed " << s_amount ;
    emit decoded(address, payment_id, s_amount, tx_description, recipient_name, parsed_unknown_parameters);
}
void QrCodeScanner::processFrame(QVideoFrame frame)
{
    if(frame.isValid()){
        m_curFrame = frame;
    }
}
bool QrCodeScanner::enabled() const
{
    return m_enabled;
}
void QrCodeScanner::setEnabled(bool enabled)
{
    m_enabled = enabled;
    if(!enabled && (m_processTimerId != -1) )
    {
        this->killTimer(m_processTimerId);
        m_processTimerId = -1;
    }
    else if (enabled && (m_processTimerId == -1) )
    {
        m_processTimerId = this->startTimer(m_processInterval);
    }
    emit enabledChanged();
}
void QrCodeScanner::timerEvent(QTimerEvent *event)
{
    if( (event->timerId() == m_processTimerId) ){
        m_thread->addFrame(m_curFrame);
    }
}

QrCodeScanner::~QrCodeScanner()
{
    m_thread->stop();
    m_thread->quit();
    if(!m_thread->wait(5000))
    {
        m_thread->terminate();
        m_thread->wait();
    }

}

