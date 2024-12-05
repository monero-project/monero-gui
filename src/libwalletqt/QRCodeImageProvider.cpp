// Copyright (c) 2014-2024, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "QrCode.hpp"

#include "QRCodeImageProvider.h"

QImage QRCodeImageProvider::genQrImage(const QString &id, QSize *size)
{
  using namespace qrcodegen;

  QrCode qrcode = QrCode::encodeText(id.toStdString().c_str(), QrCode::Ecc::MEDIUM);
  unsigned int black = 0;
  unsigned int white = 1;
  unsigned int borderSize = 4;
  unsigned int imageSize = qrcode.getSize() + (2 * borderSize);
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
