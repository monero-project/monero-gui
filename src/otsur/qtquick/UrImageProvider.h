#ifndef URIMAGEPROVIDER_H
#define URIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QObject>

class UrSender;

class UrImageProvider : public QQuickImageProvider
{
public:
    explicit UrImageProvider();
    ~UrImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
    void setSender(UrSender *sender);
    UrSender* sender() const { return m_sender; }

private:
    UrSender *m_sender;
};

#endif // URIMAGEPROVIDER_H
