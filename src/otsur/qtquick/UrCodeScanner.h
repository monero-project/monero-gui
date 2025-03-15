#ifndef URCODESCANNER_h
#define URCODESCANNER_h

#define QR_WALLET "wallet"
#define QR_TX_DATA "txdata"
#define QR_ANY ""
#define MODE_QR false
#define MODE_UR true

#include <UrTypes.h>
#include <MoneroData.h>
#include <QImage>
#include <QVideoFrame>
#include <string>

#include "ScanThread.h"
#include <bc-ur.hpp>
#include <ur-decoder.hpp>

class QVideoProbe;
class QCamera;

class UrCodeScanner: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QCamera* source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool fallbackToJson READ fallbackToJson WRITE setFallbackToJson NOTIFY fallbackToJsonChanged)

public:
    UrCodeScanner();
    ~UrCodeScanner() override;
    void init();

    QCamera* source() { return m_camera; }
    
    Q_INVOKABLE void reset(); // reset scanner because data was invalid
    Q_INVOKABLE void stop(); // stop scanning
    Q_INVOKABLE void startCapture(bool scan_ur = MODE_QR, const QString &data_type = QR_ANY);
    Q_INVOKABLE void scanOutputs() { startCapture(MODE_UR, XMR_OUTPUT); }
    Q_INVOKABLE void scanKeyImages() { startCapture(MODE_UR, XMR_KEY_IMAGE); }
    Q_INVOKABLE void scanUnsignedTx() { startCapture(MODE_UR, XMR_TX_UNSIGNED); }
    Q_INVOKABLE void scanSignedTx() { startCapture(MODE_UR, XMR_TX_SIGNED); }
    Q_INVOKABLE void scanWallet() { startCapture(MODE_QR, "wallet"); }
    Q_INVOKABLE void scanTxData() { startCapture(MODE_QR, "txdata"); }
    Q_INVOKABLE void qr() { startCapture(MODE_QR, QR_ANY); }
    bool fallbackToJson() { return m_fallbackToJson; }
    void setFallbackToJson(bool on) { m_fallbackToJson = on; emit fallbackToJsonChanged(); }
    void setSource(QCamera *source);

signals:
    void outputs(const QByteArray &outputs);
    void keyImages(const QByteArray &keyImages);
    void unsignedTx(const QByteArray &unsignedTx);
    void signedTx(const QByteArray &signedTx);
    void wallet(MoneroWalletData* walletData);
    void txData(MoneroTxData* txData);
    void qrDataReceived(const QString &data);
    void urDataReceived(const QString &type, const QByteArray &data);
    void urDataFailed(const QString &errorMsg);
    void decodedFrame(const QString &data);
    void receivedFrames(int count);
    void expectedFrames(int total);
    void scannedFrames(int count, int total);
    void estimatedCompletedPercentage(float complete);
    void unexpectedUrType(const QString &ur_type);

    void urCaptureStarted(const QString &type);
    void qrCaptureStarted();

    void sourceChanged();
    void fallbackToJsonChanged();
    void notifyError(const QString &error, bool warning = false);

public slots:
    void onFrameCaptured(const QVideoFrame &videoFrame);
    void onImage(const QImage &image);

private slots:
    void onDecoded(const QString &data);

private:
    bool m_scan_ur = false;
    QString m_data_type = QR_ANY;
    bool m_done = false;
    ScanThread *m_thread;
    ur::URDecoder m_decoder;

    QImage videoFrameToImage(const QVideoFrame &videoFrame);
    std::string getURData();
    QString getURType();
    QString getURError();
protected:
    static QString extractUrType(const QString& qrFrame);
    bool m_fallbackToJson = true;
    bool m_handleFrames = true;
    QVideoProbe *m_probe;
    QCamera *m_camera = nullptr;
};
#endif // URCODESCANNER_h
