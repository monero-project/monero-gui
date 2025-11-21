#ifndef I2PNODEMANAGER_H
#define I2PNODEMANAGER_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <QtGlobal>

class I2PNodeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(bool isMobile READ isMobile CONSTANT)

public:
    explicit I2PNodeManager(QObject *parent = nullptr);
    
    Q_INVOKABLE void startNodeCreation(const QString &password);
    Q_INVOKABLE void stopNodeCreation();
    
    bool isRunning() const;
    bool isMobile() const;

signals:
    void isRunningChanged();
    void nodeCreated();
    void errorOccurred(const QString &error);
    void progressUpdate(const QString &status);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void onReadyReadStandardOutput();
    void onReadyReadStandardError();

private:
    QProcess *m_process;
    bool m_isRunning;
};

#endif // I2PNODEMANAGER_H
