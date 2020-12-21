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
