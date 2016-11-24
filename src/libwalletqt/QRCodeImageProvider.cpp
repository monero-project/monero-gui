#include "QrCode.hpp"

#include "QRCodeImageProvider.h"

QImage QRCodeImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
  using namespace qrcodegen;

  QrCode qrcode = QrCode::encodeText(id.toStdString().c_str(), QrCode::Ecc::MEDIUM);
  QImage img = QImage(qrcode.size, qrcode.size, QImage::Format_Mono);
  for (int y = 0; y < qrcode.size; ++y)
    for (int x = 0; x < qrcode.size; ++x)
      img.setPixel(x, y, qrcode.getModule(x, y));
  if (size)
    *size = QSize(qrcode.size, qrcode.size);
  return img;
}
