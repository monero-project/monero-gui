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

#ifndef _QRSCANTHREAD_H_
#define _QRSCANTHREAD_H_

#include <QThread>
#include <QMutex>
#include <QWaitCondition>
#include <QEvent>
#include <QVideoFrame>
#include <QCamera>
#include <zbar.h>

class QrScanThread : public QThread, public zbar::Image::Handler
{
    Q_OBJECT

public:
    QrScanThread(QObject *parent = Q_NULLPTR);
    void addFrame(const QVideoFrame &frame);
    virtual void stop();

Q_SIGNALS:
    void decoded(int type, const QString &data);
    void notifyError(const QString &error, bool warning = false);

protected:
    virtual void run();
    void processVideoFrame(const QVideoFrame &);
    void processQImage(const QImage &);
    void processZImage(zbar::Image &image);
    virtual void image_callback(zbar::Image &image);
    bool zimageFromQImage(const QImage&, zbar::Image &);

private:
    zbar::ImageScanner m_scanner;
    QSharedPointer<zbar::Image> m_image;
    bool m_running;
    QMutex m_mutex;
    QWaitCondition m_waitCondition;
    QList<QVideoFrame> m_queue;
};
#endif
