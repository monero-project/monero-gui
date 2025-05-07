#ifndef MONERO_GUI_I2PDAEMONMANAGER_H
#define MONERO_GUI_I2PDAEMONMANAGER_H

#include <QObject>
#include <QProcess>
#include <QTimer>
#include <memory>

class I2PDaemonManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)

public:
    explicit I2PDaemonManager(QObject *parent = nullptr);
    ~I2PDaemonManager();

    bool running() const;
    QString status() const;
    bool ready() const;

    Q_INVOKABLE bool start();
    Q_INVOKABLE bool stop();
    Q_INVOKABLE bool restart();

signals:
    void runningChanged();
    void statusChanged();
    void readyChanged();
    void error(const QString &message);

private slots:
    void handleProcessStarted();
    void handleProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void handleProcessError(QProcess::ProcessError error);
    void handleProcessOutput();
    void checkI2PStatus();

private:
    bool initializeI2PConfig();
    QString getI2PPath() const;
    QString getI2PDataPath() const;
    void updateStatus(const QString &status);

    std::unique_ptr<QProcess> m_process;
    QString m_status;
    bool m_ready;
    QTimer m_statusCheckTimer;
};

#endif // MONERO_GUI_I2PDAEMONMANAGER_H 