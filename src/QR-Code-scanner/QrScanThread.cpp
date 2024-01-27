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

#include "QrScanThread.h"
#include <QtGlobal>
#include <QDebug>

#if QT_VERSION < QT_VERSION_CHECK(5, 15, 0)
extern QImage qt_imageFromVideoFrame(const QVideoFrame &f);
#endif

QrScanThread::QrScanThread(QObject *parent)
      : QThread(parent)
       ,m_running(true)
{
}

void QrScanThread::processQImage(const QImage &qimg)
{
    try {
        for (const std::string &code : m_decoder.decode(qimg))
        {
            emit decoded(QString::fromStdString(code));
        }
    }
    catch(std::exception &e) {
        qDebug() << "ERROR: " << e.what();
        emit notifyError(e.what());
    }
}

void QrScanThread::processVideoFrame(const QVideoFrame &frame)
{
#if QT_VERSION < QT_VERSION_CHECK(5, 15, 0)
    processQImage( qt_imageFromVideoFrame(frame) );
#else
    processQImage(frame.image());
#endif
}

void QrScanThread::stop()
{
    m_running = false;
    m_waitCondition.wakeOne();
}

void QrScanThread::addFrame(const QVideoFrame &frame)
{
    QMutexLocker locker(&m_mutex);
    m_queue.append(frame);
    m_waitCondition.wakeOne();
}

void QrScanThread::run()
{
    QVideoFrame frame;
    while(m_running) {
        QMutexLocker locker(&m_mutex);
        while(m_queue.isEmpty() && m_running)
            m_waitCondition.wait(&m_mutex);
        if(!m_queue.isEmpty())
            processVideoFrame(m_queue.takeFirst());
    }
}

