// Copyright (c) 2014-2016, The Monero Project
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
//
// Parts of this file are originally Copyright 2008-2009 (c) Jeff Brown <spadix@users.sourceforge.net> (ZBar)

#ifndef _QZBARTHREAD_H_
#define _QZBARTHREAD_H_

#include <QThread>
#include <QMutex>
#include <QWaitCondition>
#include <QEvent>
#include <QVideoFrame>
#include <zbar.h>
#include <QCamera>
#include <QCameraImageCapture>
#include <QMediaRecorder>
#include <QAbstractVideoSurface>

#ifndef zbar_fourcc
#define zbar_fourcc(a, b, c, d)                 \
        ((unsigned long)(a) |                   \
         ((unsigned long)(b) << 8) |            \
         ((unsigned long)(c) << 16) |           \
         ((unsigned long)(d) << 24))
#endif


class QZBarImage : public zbar::Image
{
public:

    /// construct a zbar library image based on an existing QImage.
    QZBarImage (const QImage &qimg) : qimg(qimg)
    {
        QImage::Format fmt = qimg.format();
        if(fmt != QImage::Format_RGB32 &&
           fmt != QImage::Format_ARGB32 &&
           fmt != QImage::Format_ARGB32_Premultiplied)
            throw zbar::FormatError();

        unsigned bpl = qimg.bytesPerLine();
        unsigned width = bpl / 4;
        unsigned height = qimg.height();
        set_size(width, height);
        set_format(zbar_fourcc('B','G','R','4'));
        unsigned long datalen = qimg.byteCount();
        set_data(qimg.bits(), datalen);

        if((width * 4 != bpl) || (width * height * 4 > datalen))
            throw zbar::FormatError();
    }

private:
    QImage qimg;
};

class QZBarThread : public QThread, public zbar::Image::Handler
{
    Q_OBJECT

public:
    enum EventType {
        ScanImage = QEvent::User,
        ScanVideo,
        Exit = QEvent::MaxUser
    };

    class ScanImageEvent : public QEvent {
    public:
        ScanImageEvent (const QImage &image)
            : QEvent((QEvent::Type)ScanImage),
              image(image)
        { }
        const QImage image;
    };

    class ScanVideoEvent : public QEvent {
    public:
        ScanVideoEvent (const QVideoFrame &frame)
            : QEvent((QEvent::Type)ScanVideo),
              frame(frame)
        { }
        const QVideoFrame frame;
    };

    QMutex mutex;
    QWaitCondition newEvent;
    QList<QEvent*> queue;

    QZBarThread(QObject *parent = Q_NULLPTR);

    void pushEvent (QEvent *e)
    {
        QMutexLocker locker(&mutex);
        queue.append(e);
        newEvent.wakeOne();
    }

Q_SIGNALS:
    void decoded(int type, const QString &data);
    void notifyError(const QString &error, bool warning = false);

protected:
    virtual void run();

    virtual void image_callback(zbar::Image &image);
    void processImage(zbar::Image &image);

    virtual bool event(QEvent *e);
    virtual void scanImageEvent(ScanImageEvent *event);
    virtual void scanVideoEvent(ScanVideoEvent *event);

private:
    zbar::ImageScanner scanner;
    QSharedPointer<QZBarImage> image;
    bool running;
};

#endif
