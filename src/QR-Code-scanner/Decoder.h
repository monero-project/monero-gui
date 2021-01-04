#include <QImage>

struct quirc;

class QrDecoder
{
public:
    QrDecoder(const QrDecoder &) = delete;
    QrDecoder &operator=(const QrDecoder &) = delete;

    QrDecoder();
    ~QrDecoder();

    std::vector<std::string> decode(const QImage &image);

private:
    std::vector<std::string> decodeGrayscale8(const QImage &image);

private:
    quirc *m_qr;
};
