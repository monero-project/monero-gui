#include <QBuffer>
#include <QSvgRenderer>
#include <QPainter>
#include <QMap>

#include "UrSender.h"
#include <UrTypes.h>

UrSender::UrSender()
    : QObject()
{
    connect(&m_timer, &QTimer::timeout, this, &UrSender::nextQR);
}

void UrSender::sendClear() {
    m_type = "";
    m_data = "";
    m_timer.stop();
    allParts.clear();
    m_qrcode = nullptr;
    emit isUrCodeChanged();
}

void UrSender::setData(const QString &type, const QByteArray &data) {
    m_type = type;
    m_data = data.toStdString();
    emit isUrCodeChanged();
    
    m_timer.stop();
    allParts.clear();
    emit updateCurrentFrameInfo(0, 0);

    if (m_data.empty())
        return;
    
    ur::ByteVector cbor;
    ur::CborLite::encodeBytes(cbor, ur::string_to_bytes(m_data));
    ur::UR h = ur::UR(m_type.toStdString(), cbor);

    delete m_urencoder;
    m_urencoder = new ur::UREncoder(h, m_fragmentLength);

    for (int i=0; i < m_urencoder->seq_len(); i++) {
        allParts.append(m_urencoder->next_part());
    }
    m_timer.setInterval(m_speed);
    m_timer.start();
}

void UrSender::nextQR() {
    currentIndex = currentIndex % m_urencoder->seq_len();

    std::string data;
    if (m_fountainCodeEnabled) {
        data = m_urencoder->next_part();
    } else {
        data = allParts[currentIndex];
    }
    emit updateCurrentFrameInfo((currentIndex % m_urencoder->seq_len() + 1), m_urencoder->seq_len());
	m_qrcode = new QrCode{QString::fromStdString(data), QrCode::Version::AUTO, QrCode::ErrorCorrectionLevel::MEDIUM};
    emit updateQrCode(*m_qrcode);
    m_currentFrameInfo = QString("%1/%2").arg((currentIndex % m_urencoder->seq_len() + 1)).arg(m_urencoder->seq_len());
	emit currentFrameInfoChanged();
    currentIndex++;
}

void UrSender::onSettingsChanged(int fragmentLength, int speed, bool fountainCodeEnabled) {
    m_fragmentLength = fragmentLength;
    m_speed = speed;
    m_fountainCodeEnabled = fountainCodeEnabled;
}

QImage UrSender::requestImage(const QString &id, QSize *size, const QSize &requestedSize) {
    Q_UNUSED(id)

    QSize actualSize = requestedSize.isValid() ? requestedSize : QSize(300, 300);
    if (size)
        *size = actualSize;

    QImage image(actualSize, QImage::Format_ARGB32);
    image.fill(Qt::white);  // Fill with white background
    if(m_qrcode == nullptr)
        return image;
    if (!m_svg) { // render from Pixmap to image instead via SVG
        image = m_qrcode->toPixmap(4).toImage();
        *size = image.size();
        return image;
    }
    QByteArray currentSvgData;
    QBuffer buffer(&currentSvgData);
    buffer.open(QIODevice::WriteOnly);
    m_qrcode->writeSvg(&buffer, 1, 4);  // Using 1 as DPI, we'll scale in the ImageProvider
    buffer.close();
    QSvgRenderer renderer(currentSvgData);
    QPainter painter(&image);
    renderer.render(&painter);
    return image;
}


void UrSender::sendOutputs(const QByteArray &outputs) {
    setData(XMR_OUTPUT, outputs);
}


void UrSender::sendKeyImages(const QByteArray &keyImages) {
    setData(XMR_KEY_IMAGE, keyImages);
}


void UrSender::sendTxUnsigned(const QByteArray &txUnisgned) {
    setData(XMR_TX_UNSIGNED, txUnisgned);
}


void UrSender::sendTxSigned(const QByteArray &txSigned) {
    setData(XMR_TX_SIGNED, txSigned);
}

void UrSender::sendQrCode(const QString &qr) {
    sendClear();
    m_qrcode = new QrCode{qr, QrCode::Version::AUTO, QrCode::ErrorCorrectionLevel::MEDIUM};
    emit updateQrCode(*m_qrcode);
}

void UrSender::sendTx(const QString &address, const QString &txAmount, const QString &txPaymentId, const QString &recipientName, const QString &txDescription)
{
    const QMap<QString, QString> data = {
        { "tx_amount", txAmount },
        { "tx_payment_id", txPaymentId },
        { "recipient_name", recipientName },
        { "tx_description", txDescription }
    };
    sendQrCode(buildUri("monero", address, data));
}

void UrSender::sendWallet(const QString &address, const QString &spendKey, const QString &viewKey, const QString &mnemonicSeed, const long &height)
{
    const QMap<QString, QString> data = {
        { "spend_key", spendKey },
        { "view_key", viewKey },
        { "mnemonic_seed", mnemonicSeed },
        { "heigth", (height>0)?QString("%1").arg(height):"" }
    };
    sendQrCode(buildUri("monero_wallet", address, data));
}

const QString UrSender::buildUri(const QString &scheme, const QString &address, const QMap<QString, QString> &data)
{
    QString out = QString("%1:%2").arg(scheme, address);
    bool first = true;
    for (const auto& e : data.toStdMap()) {
        if(e.second.size() > 0) {
            out.append(QString("%1%2=%3").arg(first?"?":"&", e.first, e.second));
            first = false;
        }
    }
    return out;
}

UrSender::~UrSender() {
	if(m_urencoder)
		delete m_urencoder;
}
