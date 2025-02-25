// SPDX-License-Identifier: BSD-3-Clause
// SPDX-FileCopyrightText: 2020-2024 The Monero Project

#ifndef SCANTHREAD_H
#define SCANTHREAD_H

#include <QThread>
#include <QMutex>
#include <QWaitCondition>
#include <QEvent>
#include <QImage>
#include <QString>

#include "ScanResult.h"
#include <ZXing/ReadBarcode.h>

class ScanThread : public QThread
{
    Q_OBJECT

public:
    explicit ScanThread(QObject *parent = nullptr);
    void addImage(const QImage &img);
    
    virtual void stop();
    virtual void start();
    
signals:
    void decoded(const QString &data);

protected:
    void run() override;
    void processQImage(const QImage &);

private:
    bool m_running;
    QMutex m_mutex;
    QWaitCondition m_waitCondition;
    QList<QImage> m_queue;
    static QString scanImage(const QImage &img);
    static ScanResult ReadBarcode(const QImage& img, const ZXing::ReaderOptions& hints = { });
};
#endif
