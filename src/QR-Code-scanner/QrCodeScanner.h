#ifndef QRCODESCANNER_H_
#define QRCODESCANNER_H_

#include "QZBarThread.h"

class QVideoProbe;

class QrCodeScanner : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    QrCodeScanner(QObject *parent = Q_NULLPTR);

    void setSource(QCamera*);

    bool enabled() const;
    void setEnabled(bool enabled);

public Q_SLOTS:
    void processCode(int type, const QString &data);
    void processFrame(QVideoFrame);

Q_SIGNALS:
    void enabledChanged();

    void decoded(const QString &address, const QString &payment_id, const QString &amount, const QString &tx_description, const QString &recipient_name);
    void decode(int type, const QString &data);
    void notifyError(const QString &error, bool warning = false);

protected:
    void timerEvent(QTimerEvent *);

    int _processTimerId;
    int _processInterval;
    int _enabled;
    QImage _currentFrame;
    QVideoFrame _curFrame;
    QZBarThread *_readerThread;
    QVideoProbe *_probe;
};

#endif

