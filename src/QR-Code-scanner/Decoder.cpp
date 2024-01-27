// Copyright (c) 2020-2024, The Monero Project
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

#include "Decoder.h"

#include <limits>

#include "quirc.h"

QrDecoder::QrDecoder()
    : m_qr(quirc_new())
{
    if (m_qr == nullptr)
    {
        throw std::runtime_error("QUIRC: failed to allocate memory");
    }
}

QrDecoder::~QrDecoder()
{
    quirc_destroy(m_qr);
}

std::vector<std::string> QrDecoder::decode(const QImage &image)
{
    if (image.format() == QImage::Format_Grayscale8)
    {
        return decodeGrayscale8(image);
    }
    return decodeGrayscale8(image.convertToFormat(QImage::Format_Grayscale8));
}

std::vector<std::string> QrDecoder::decodeGrayscale8(const QImage &image)
{
    if (quirc_resize(m_qr, image.width(), image.height()) < 0)
    {
        throw std::runtime_error("QUIRC: failed to allocate video memory");
    }

    uint8_t *rawImage = quirc_begin(m_qr, nullptr, nullptr);
    if (rawImage == nullptr)
    {
        throw std::runtime_error("QUIRC: failed to get image buffer");
    }
#if QT_VERSION >= QT_VERSION_CHECK(5, 10, 0)
    std::copy(image.constBits(), image.constBits() + image.sizeInBytes(), rawImage);
#else
    std::copy(image.constBits(), image.constBits() + image.byteCount(), rawImage);
#endif
    quirc_end(m_qr);

    const int count = quirc_count(m_qr);
    if (count < 0)
    {
        throw std::runtime_error("QUIRC: failed to get the number of recognized QR-codes");
    }

    std::vector<std::string> result;
    result.reserve(static_cast<size_t>(count));
    for (int index = 0; index < count; ++index)
    {
        quirc_code code;
        quirc_extract(m_qr, index, &code);

        quirc_data data;
        const quirc_decode_error_t err = quirc_decode(&code, &data);
        if (err == QUIRC_SUCCESS)
        {
            result.emplace_back(&data.payload[0], &data.payload[data.payload_len]);
        }
    }

    return result;
}
