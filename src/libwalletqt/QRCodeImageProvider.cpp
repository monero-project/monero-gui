#include "QrCode.hpp"

#include "QRCodeImageProvider.h"

QImage QRCodeImageProvider::genQrImage(const QString &id, QSize *size)
{
  using namespace qrcodegen;

  QrCode qrcode = QrCode::encodeText(id.toStdString().c_str(), QrCode::Ecc::MEDIUM);
  unsigned int black = 0;
  unsigned int white = 1;
  unsigned int borderSize = 4;
  unsigned int imageSize = qrcode.size + (2 * borderSize);
  QImage img = QImage(imageSize, imageSize, QImage::Format_Mono);

  for (unsigned int y = 0; y < imageSize; ++y)
    for (unsigned int x = 0; x < imageSize; ++x)
      if ((x < borderSize) || (x >= imageSize - borderSize) || (y < borderSize) || (y >= imageSize - borderSize))
        img.setPixel(x, y, white);
      else
        img.setPixel(x, y, qrcode.getModule(x - borderSize, y - borderSize) ? black : white);
  if (size)
    *size = QSize(imageSize, imageSize);

  return img;
}

QImage QRCodeImageProvider::requestImage(const QString &id, QSize *size, const QSize &/* requestedSize */)
{
  return genQrImage(id, size);
}
