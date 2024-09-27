#include <QImage>
#include "UrImageProvider.h"
#include "UrSender.h"

UrImageProvider::UrImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image), m_sender(nullptr)
{
}

QImage UrImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize) {
    if (m_sender)
        return m_sender->requestImage(id, size, requestedSize);
    
    QSize actualSize = requestedSize.isValid() ? requestedSize : QSize(300, 300);
    if (size)
        *size = actualSize;

    QImage image(actualSize, QImage::Format_ARGB32);
    image.fill(Qt::red);  // Fill with red background as a fallback
    return image;
}

void UrImageProvider::setSender(UrSender *sender) {
    m_sender = sender;
}

UrImageProvider::~UrImageProvider() {
    // UrSender is not owned by UrImageProvider, so we don't delete it here
}
