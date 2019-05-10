#ifndef PRICES_H
#define PRICES_H

#include <QCoreApplication>
#include <QtNetwork>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QDebug>

class Prices : public QObject
{
Q_OBJECT
public:
    Prices(QNetworkAccessManager *networkAccessManager, QObject *parent = nullptr);

public slots:
    Q_INVOKABLE void getJSON(const QString url);
    void gotJSON();
    void gotError();
    void gotError(const QString &message);
signals:
    void priceJsonReceived(QVariantMap document);
    void priceJsonError(QString message);

private:
    mutable QPointer<QNetworkReply> m_reply;
    QNetworkAccessManager *m_networkAccessManager;
};

#endif // PRICES_H
