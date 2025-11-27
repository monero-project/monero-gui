#pragma once

#include <QObject>
#include <QProcess>
#include <QStringList>
#include <QNetworkAccessManager>
<<<<<<< HEAD
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QNetworkProxy>
=======
>>>>>>> 94bf7222 (Extend I2PManager with proxy and status methods)

class I2PManager : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(QString connectionMode READ connectionMode WRITE setConnectionMode NOTIFY connectionModeChanged)
    Q_PROPERTY(QStringList trustedNodes READ trustedNodes NOTIFY trustedNodesChanged)

public:
    explicit I2PManager(QObject *parent = nullptr);

    // getter/setter
    bool enabled() const { return m_enabled; }
    void setEnabled(bool enabled);

    bool connected() const { return m_connected; }
    QString status() const { return m_status; }

    QString connectionMode() const { return m_connectionMode; }
    void setConnectionMode(const QString &mode);

    QStringList trustedNodes() const { return m_trustedNodes; }

    // callable from QML
    Q_INVOKABLE void refreshStatus();
    Q_INVOKABLE void startCreateNode();
    Q_INVOKABLE void cancelCreateNode();
    Q_INVOKABLE void providePassword(const QString &pw);
    Q_INVOKABLE bool i2pStatus() const;
    Q_INVOKABLE void setProxyForI2p();
<<<<<<< HEAD

=======
>>>>>>> 94bf7222 (Extend I2PManager with proxy and status methods)
signals:
    void enabledChanged();
    void connectedChanged();
    void statusChanged();
    void connectionModeChanged();
    void trustedNodesChanged();
    void nodeCreationStarted();
    void nodeCreationFinished(bool ok, const QString &message);
    void passwordRequested(const QString &reason);
    void proxyAddressRequested(const QString &address);

private slots:
    void handleProcessOutput();
    void handleProcessFinished(int exitCode, QProcess::ExitStatus status);
    void handleProcessError(QProcess::ProcessError error);

private:
    void startScript();
    void stopScript();
    void setStatus(const QString &s);

    bool m_enabled = false;
    bool m_connected = false;
    QNetworkAccessManager *m_networkManager = nullptr;
    QNetworkReply *m_statusReply = nullptr;
    QString m_i2pAddress;
    QString m_status;
    QString m_connectionMode;
    QStringList m_trustedNodes;
    QProcess *m_process = nullptr;
    bool m_waitingForPassword = false;
    QNetworkAccessManager *m_networkManager = nullptr;
};
