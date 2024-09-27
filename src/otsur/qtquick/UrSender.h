#ifndef URSENDER_H
#define URSENDER_H

#include <QTimer>
#include <QrCode.h>
#include <bc-ur.hpp>

class UrSender : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString currentFrameInfo READ currentFrameInfo NOTIFY currentFrameInfoChanged)
    Q_PROPERTY(bool isUrCode READ isUrCode NOTIFY isUrCodeChanged)

public:
	explicit UrSender();
	~UrSender();
    QString currentFrameInfo() const { return m_currentFrameInfo; }
	QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
    Q_INVOKABLE bool isUrCode() { return !m_data.empty(); }
    Q_INVOKABLE void sendClear();
    Q_INVOKABLE void sendOutputs(const QByteArray &outputs);
    Q_INVOKABLE void sendKeyImages(const QByteArray &keyImages);
    Q_INVOKABLE void sendTxUnsigned(const QByteArray &txUnisgned);
    Q_INVOKABLE void sendTxSigned(const QByteArray &txSigned);
    Q_INVOKABLE void sendQrCode(const QString &qr);
    Q_INVOKABLE void sendTx(
        const QString &address,
        const QString &txAmount = "",
        const QString &txPaymentId = "",
        const QString &recipientName = "",
        const QString &txDescription = ""
    );
    Q_INVOKABLE void sendWallet(
        const QString &address,
        const QString &spendKey = "",
        const QString &viewKey = "",
        const QString &mnemonicSeed = "",
        const long &height = 0
    );

signals:
    void updateQrCode(const QrCode &qrCode);
    void updateCurrentFrameInfo(int current, int total);
    void currentFrameInfoChanged();
    void noFrameInfo();
    void isUrCodeChanged();

public slots:
    void onSettingsChanged(int fragmentLength, int speed, bool fountainCodeEnabled);
    void setData(const QString &type, const QByteArray &data);

private slots:
    void nextQR();

private:
    bool m_svg = true; // use SVG for reandering TODO: need to profile both methods
    QTimer m_timer;
    ur::UREncoder *m_urencoder = nullptr;
    QList<std::string> allParts;
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    qsizetype currentIndex = 0;
#else
    int currentIndex = 0;
#endif
    
    const QString buildUri(const QString &scheme, const QString &address, const QMap<QString, QString> &data);
    QrCode *m_qrcode = nullptr;
    std::string m_data;
    QString m_type;
    int m_fragmentLength = 150;
    int m_speed = 80;
    bool m_fountainCodeEnabled = false;
	QString m_currentFrameInfo;
};
#endif // URSENDER_H
