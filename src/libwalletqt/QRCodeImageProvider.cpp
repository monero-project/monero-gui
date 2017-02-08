#include "QrCode.hpp"

#include "QRCodeImageProvider.h"

QImage QRCodeImageProvider::genQrImage(const QString &id, QSize *size)
{
  using namespace qrcodegen;

  QrCode qrcode = QrCode::encodeText(id.toStdString().c_str(), QrCode::Ecc::MEDIUM);
  QImage img = QImage(qrcode.size, qrcode.size, QImage::Format_Mono);
  for (int y = 0; y < qrcode.size; ++y)
    for (int x = 0; x < qrcode.size; ++x)
      img.setPixel(x, y, !qrcode.getModule(x, y)); // 1 is black, not "255/white"
  if (size)
    *size = QSize(qrcode.size, qrcode.size);
  return img;
}

QImage QRCodeImageProvider::requestImage(const QString &id, QSize *size, const QSize &/* requestedSize */)
{
  return genQrImage(id, size);
}
