// SPDX-License-Identifier: BSD-3-Clause
// SPDX-FileCopyrightText: 2020-2024 The Monero Project

#include "ScanThread.h"

#include <ZXing/ReadBarcode.h>

ScanThread::ScanThread(QObject *parent)
    : QThread(parent)
    , m_running(true)
{
}

void ScanThread::processQImage(const QImage &qimg)
{
    const auto hints = ZXing::ReaderOptions()
            .setFormats(ZXing::BarcodeFormat::QRCode)
            .setTryHarder(true)
            .setMaxNumberOfSymbols(1);

    const auto result = ScanThread::ReadBarcode(qimg, hints);

    if (result.isValid()) {
        emit decoded(result.text());
    }
}

void ScanThread::stop()
{
    m_running = false;
    m_waitCondition.wakeOne();
}

void ScanThread::start() 
{
    m_queue.clear();
    m_running = true;
    m_waitCondition.wakeOne();
    QThread::start();
}

void ScanThread::addImage(const QImage &img)
{
    QMutexLocker locker(&m_mutex);
    if (m_queue.length() > 100) {
        return;
    }
    m_queue.append(img);
    m_waitCondition.wakeOne();
}

void ScanThread::run()
{
    while (m_running) {
        QMutexLocker locker(&m_mutex);
        while (m_queue.isEmpty() && m_running) {
            m_waitCondition.wait(&m_mutex);
        }
        if (!m_queue.isEmpty()) {
            processQImage(m_queue.takeFirst());
        }
    }
}

ScanResult ScanThread::ReadBarcode(const QImage& img, const ZXing::ReaderOptions& hints)
{
    auto ImgFmtFromQImg = [](const QImage& img){
        switch (img.format()) {
            case QImage::Format_ARGB32:
            case QImage::Format_RGB32:
#if Q_BYTE_ORDER == Q_LITTLE_ENDIAN
                return ZXing::ImageFormat::BGRX;
#else
                return ZXing::ImageFormat::XRGB;
#endif

            case QImage::Format_RGB888: 
                return ZXing::ImageFormat::RGB;

            case QImage::Format_RGBX8888:

            case QImage::Format_RGBA8888: 
                return ZXing::ImageFormat::RGBX;

            case QImage::Format_Grayscale8: 
                return ZXing::ImageFormat::Lum;

            default: 
                return ZXing::ImageFormat::None;
        }
    };

    auto exec = [&](const QImage& img){
        auto res = ZXing::ReadBarcode({ img.bits(), img.width(), img.height(), ImgFmtFromQImg(img) }, hints);
        return ScanResult(res.text(), res.isValid());
    };

    try {
        if (ImgFmtFromQImg(img) == ZXing::ImageFormat::None) {
            return exec(img.convertToFormat(QImage::Format_RGBX8888));
        } else {
            return exec(img);
        }
    }
    catch (...) {
        return ScanResult("", false);
    }
}


QString ScanThread::scanImage(const QImage &img) {
    const auto hints = ZXing::ReaderOptions()
            .setFormats(ZXing::BarcodeFormat::QRCode | ZXing::BarcodeFormat::DataMatrix)
            .setTryHarder(true)
            .setBinarizer(ZXing::Binarizer::FixedThreshold);
    const auto result = ReadBarcode(img, hints);
    return result.text();
}
