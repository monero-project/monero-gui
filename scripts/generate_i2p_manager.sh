#!/bin/bash

OUTPUT_DIR="src/libwalletqt"

mkdir -p "$OUTPUT_DIR"

echo "Creating $OUTPUT_DIR/I2PNodeManager.h..."
cat > "$OUTPUT_DIR/I2PNodeManager.h" << 'EOF'
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
EOF

echo "Creating $OUTPUT_DIR/I2PNodeManager.cpp..."
cat > "$OUTPUT_DIR/I2PNodeManager.cpp" << 'EOF'
#include "I2PNodeManager.h"
#include <QDebug>
#include <QCoreApplication>
#include <QStandardPaths>
#include <QDir>

I2PNodeManager::I2PNodeManager(QObject *parent) : QObject(parent), m_isRunning(false)
{
    m_process = new QProcess(this);
    connect(m_process, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(onProcessFinished(int, QProcess::ExitStatus)));
    connect(m_process, &QProcess::readyReadStandardOutput, this, &I2PNodeManager::onReadyReadStandardOutput);
    connect(m_process, &QProcess::readyReadStandardError, this, &I2PNodeManager::onReadyReadStandardError);
}

bool I2PNodeManager::isMobile() const
{
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS)
    return true;
#else
    return false;
#endif
}

void I2PNodeManager::startNodeCreation(const QString &password)
{
    if (m_isRunning) return;
    
    if (isMobile()) {
        emit errorOccurred("Mobile devices cannot host Docker nodes. Please connect to a Remote Node.");
        return;
    }

    m_isRunning = true;
    emit isRunningChanged();
    emit progressUpdate("Optimizing for Apple M3 / Host Architecture...");

    QString appDir = QCoreApplication::applicationDirPath();
    
    QString dockerImageName = "monero-local-node-m3";
    
    QString buildCmd = QString("docker build -t %1 -f %2/../docker/Dockerfile.i2pnode %2/../docker").arg(dockerImageName).arg(appDir);
    
    QString runCmd = QString("docker run -d --restart=unless-stopped --name monero-node-instance -p 18081:18081 %1").arg(dockerImageName);

    QString fullCommand = QString("%1 && %2").arg(buildCmd).arg(runCmd);

    QString program = "/bin/bash";
    QStringList arguments;
    arguments << "-c" << fullCommand;

    qDebug() << "Executing GENIUS node sequence:" << fullCommand;

    m_process->start(program, arguments);

    if (!password.isEmpty()) {
    }
}

void I2PNodeManager::stopNodeCreation()
{
    if (m_process->state() != QProcess::NotRunning) {
        m_process->kill();
    }
    QProcess::execute("docker stop monero-node-instance");
}

bool I2PNodeManager::isRunning() const
{
    return m_isRunning;
}

void I2PNodeManager::onProcessFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    m_isRunning = false;
    emit isRunningChanged();

    if (exitStatus == QProcess::CrashExit || exitCode != 0) {
        QString errorLog = m_process->readAllStandardError();
        
        if (errorLog.contains("is already in use")) {
             emit nodeCreated();
             emit progressUpdate("Node is already running! Connecting...");
             return;
        }
        
        emit errorOccurred("Process failed. Ensure Docker Desktop is running.");
    } else {
        emit nodeCreated();
        emit progressUpdate("Node Active. Privacy Layer: ON.");
    }
}

void I2PNodeManager::onReadyReadStandardOutput()
{
    QString output = m_process->readAllStandardOutput();
    
    if (output.contains("load build definition")) emit progressUpdate("Reading M3 Configuration...");
    if (output.contains("transferring context")) emit progressUpdate("Sending Payload to Docker...");
    if (output.contains("fetch")) emit progressUpdate("Downloading ARM64 Binaries...");
    if (output.contains("naming to")) emit progressUpdate("Build Complete. Launching...");
    
    qDebug() << "Docker:" << output;
}

void I2PNodeManager::onReadyReadStandardError()
{
    QString error = m_process->readAllStandardError();
    qDebug() << "Docker Log:" << error;
}
EOF

echo "Done. Files created in $OUTPUT_DIR"
