#include "QrCodeScanner.h"
#include <WalletManager.h>
#include <QVideoProbe>

QrCodeScanner::QrCodeScanner(QObject *parent) 
    : QObject(parent), 
      _processTimerId(-1),
      _processInterval(750), 
      _enabled(true), 
      _readerThread( new QZBarThread(this) ),
      _probe( new QVideoProbe(this) )
{ 
    _readerThread->start(); 
 
    QObject::connect(_readerThread, SIGNAL(decodedText(QString)), this, SIGNAL(decode(QString))); 
    QObject::connect(_readerThread, SIGNAL(decoded(int,QString)), this, SLOT(processCode(int,QString))); 
    QObject::connect(_readerThread, SIGNAL(notifyError(const QString &, bool)), this, SIGNAL(notifyError(const QString &, bool)));

    connect(_probe, SIGNAL(videoFrameProbed(QVideoFrame)), this, SLOT(processFrame(QVideoFrame)));
} 
void QrCodeScanner::setSource(QCamera *camera)
{
    _probe->setSource(camera);
}
void QrCodeScanner::processCode(int type, const QString &data)
{
    if (_enabled) {
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
        if(unknown_parameters.size() > 0)
        {
            qDebug() << "unknown parameters " << unknown_parameters;
            emit notifyError(error, true);
        }
        qDebug() << "Parsed URI : " << address << " " << payment_id << " " << amount << " " << tx_description << " " << recipient_name << " " << error;
        QString s_amount = WalletManager::instance()->displayAmount(amount);
        qDebug() << "Amount passed " << s_amount ;
        emit decoded(address, payment_id, s_amount, tx_description, recipient_name);
    }
}
void QrCodeScanner::processFrame(QVideoFrame frame)
{
    if(frame.isValid()){
        _curFrame = frame;
    }
}
bool QrCodeScanner::enabled() const
{
    return _enabled;
}
void QrCodeScanner::setEnabled(bool enabled)
{
    _enabled = enabled;
    if(!enabled && (_processTimerId != -1) )
    {
        this->killTimer(_processTimerId);
        _processTimerId = -1;
    }
    else if (enabled && (_processTimerId == -1) )
    {
        _processTimerId = this->startTimer(_processInterval);
    }
    emit enabledChanged();
}
void QrCodeScanner::timerEvent(QTimerEvent *event)
{
    if (!_enabled)
        return;
    if(event->timerId() == _processTimerId && _curFrame.isValid()){
        _readerThread->pushEvent(new QZBarThread::ScanVideoEvent(_curFrame));
    }
}

