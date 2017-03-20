#ifndef OSHELPER_H
#define OSHELPER_H

#include <QObject>
/**
 * @brief The OSHelper class - exports to QML some OS-related functions
 */
class OSHelper : public QObject
{
    Q_OBJECT
public:
    explicit OSHelper(QObject *parent = 0);

    Q_INVOKABLE QString temporaryFilename() const;
    Q_INVOKABLE QString temporaryPath() const;
    Q_INVOKABLE bool removeTemporaryWallet(const QString &walletName) const;

signals:

public slots:
};

#endif // OSHELPER_H
