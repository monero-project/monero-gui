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

#include "QrCodeScanner.h"
#include <QCamera>
#include <QDebug>
#include <QMediaCaptureSession>
#include <QVideoSink>

QrCodeScanner::QrCodeScanner(QObject *parent)
    : QObject(parent)
    , m_processTimerId(-1)
    , m_processInterval(750)
    , m_enabled(true)
{
    m_captureSession = new QMediaCaptureSession(this);
    m_sink = nullptr;
    m_thread = new QrScanThread(this);
    m_thread->start();
    connect(m_thread, &QrScanThread::decoded, this, &QrCodeScanner::decoded);
    connect(m_thread, &QrScanThread::notifyError, this, &QrCodeScanner::notifyError);
}

bool QrCodeScanner::setSource(QObject *camera)
{
    QCamera *qmlCamera = qobject_cast<QCamera *>(camera);
    if (!qmlCamera) {
        qWarning() << "QrCodeScanner: source is not a QCamera";
        m_captureSession->setCamera(nullptr);
        return false;
    }
    m_captureSession->setCamera(qmlCamera);
    return true;
}
bool QrCodeScanner::setVideoOutput(QObject *videoOutput)
{
    m_captureSession->setVideoOutput(videoOutput);
    QVideoSink *sink = m_captureSession->videoSink();
    if (!sink) {
        qWarning() << "QrCodeScanner: video output has no QVideoSink";
        m_captureSession->setVideoOutput(nullptr);
        m_sink = nullptr;
        return false;
    }
    if (m_sink == sink)
        return true;
    if (m_sink)
        disconnect(m_sink, &QVideoSink::videoFrameChanged, this, &QrCodeScanner::processFrame);
    m_sink = sink;
    if (m_sink)
        connect(m_sink, &QVideoSink::videoFrameChanged, this, &QrCodeScanner::processFrame);
    return true;
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

