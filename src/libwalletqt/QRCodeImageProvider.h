#include <QImage>
#include <QQuickImageProvider>

class QRCodeImageProvider: public QQuickImageProvider
{
public:
  QRCodeImageProvider(): QQuickImageProvider(QQuickImageProvider::Image) {}

  QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
  static QImage genQrImage(const QString &id, QSize *size);
};

