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

#include "QZBarThread.h"
#include <QDebug>

//Function that was in qandroidmultimediautils.cpp, removed in qt 5.3
void qt_convert_NV21_to_ARGB32(const uchar *yuv, quint32 *rgb, int width, int height)
{
    const int frameSize = width * height;

    int a = 0;
    for (int i = 0, ci = 0; i < height; ++i, ci += 1) {
        for (int j = 0, cj = 0; j < width; ++j, cj += 1) {
            int y = (0xff & ((int) yuv[ci * width + cj]));
            int v = (0xff & ((int) yuv[frameSize + (ci >> 1) * width + (cj & ~1) + 0]));
            int u = (0xff & ((int) yuv[frameSize + (ci >> 1) * width + (cj & ~1) + 1]));
            y = y < 16 ? 16 : y;

            int r = (int) (1.164f * (y - 16) + 1.596f * (v - 128));
            int g = (int) (1.164f * (y - 16) - 0.813f * (v - 128) - 0.391f * (u - 128));
            int b = (int) (1.164f * (y - 16) + 2.018f * (u - 128));

            r = qBound(0, r, 255);
            g = qBound(0, g, 255);
            b = qBound(0, b, 255);

            rgb[a++] = 0xff000000 | (r << 16) | (g << 8) | b;
        }
    }
}

QZBarThread::QZBarThread (QObject *parent)
      : QThread(parent)
       ,running(true)
{
    scanner.set_handler(*this);
}

void QZBarThread::image_callback(zbar::Image &image)
{
    qDebug() << "image_callback :  Found Code ! " ;
    for(zbar::Image::SymbolIterator sym = image.symbol_begin();
        sym != image.symbol_end();
        ++sym)
        if(!sym->get_count()) {
            QString data = QString::fromStdString(sym->get_data());
            emit decoded(sym->get_type(), data);
        }
}

void QZBarThread::processImage(zbar::Image &image)
{
    scanner.recycle_image(image);
    zbar::Image tmp = image.convert(*(long*)"Y800");
    scanner.scan(tmp);
    image.set_symbols(tmp.get_symbols());
}
void QZBarThread::scanImageEvent(ScanImageEvent *e)
{
    try {
        image = QSharedPointer<QZBarImage>(new QZBarImage(e->image));
        processImage(*image);
    }
    catch(std::exception &e) {
        qDebug() << "ERROR: " << e.what();
        emit notifyError(e.what());
    }
}
void QZBarThread::scanVideoEvent(ScanVideoEvent *e)
{
    QVideoFrame frame = e->frame;
    frame.map(QAbstractVideoBuffer::ReadOnly);

    QImage img;
    if(frame.pixelFormat() == QVideoFrame::Format_NV21) {
        img = QImage(frame.size(), QImage::Format_ARGB32);
        qt_convert_NV21_to_ARGB32(frame.bits(), (quint32 *)img.bits(), frame.width(), frame.height() ) ;
    } else {
        QImage::Format imageFormat = QVideoFrame::imageFormatFromPixelFormat(frame.pixelFormat());
        if( imageFormat == QImage::Format_Invalid){
            QString serror = QString("Failed to convert pixel format \"%1\" to \"%2\" ! ").arg(frame.pixelFormat()).arg(imageFormat);
            emit notifyError(serror);
            return;
        }
        img = QImage(frame.bits(), frame.width(), frame.height(), frame.bytesPerLine(), imageFormat);
        if(img.isNull()){
             QString serror = QString("Failed to convert pixel format \"%1\" to \"%2\" ! ").arg(frame.pixelFormat()).arg(imageFormat);
             emit notifyError(serror);
             return;
        }
    }
    try{
        image = QSharedPointer<QZBarImage>(new QZBarImage(img));
        processImage(*image);
    }
    catch(std::exception &e) {
        qDebug() << "ERROR: " << e.what();
        emit notifyError(e.what());
    }
}
bool QZBarThread::event(QEvent *e)
{
    switch((EventType)e->type()) {
    case ScanImage:
        scanImageEvent((ScanImageEvent*)e);
        break;
    case ScanVideo:
        scanVideoEvent((ScanVideoEvent*)e);
        break;
    case Exit:
        running = false;
        break;
    default:
        return(false);
    }
    return(true);
}

void QZBarThread::run()
{
    QEvent *e = NULL;
    while(running) {
        QMutexLocker locker(&mutex);
        while(queue.isEmpty())
            newEvent.wait(&mutex);
        e = queue.takeFirst();

        if(e) {
            event(e);
            delete e;
            e = NULL;
        }
    }
}

