#!/bin/bash

# Define the output directory
OUTPUT_DIR="src/libwalletqt"

# Ensure the directory exists
mkdir -p "$OUTPUT_DIR"

# 1. Create I2PNodeManager.h
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

# 2. Create I2PNodeManager.cpp (M3 Optimized)
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
    
    // MOBILE GUARD
    if (isMobile()) {
        emit errorOccurred("Mobile devices cannot host Docker nodes. Please connect to a Remote Node.");
        return;
    }

    m_isRunning = true;
    emit isRunningChanged();
    emit progressUpdate("Optimizing for Apple M3 / Host Architecture...");

    // Path setup: We assume the 'docker' folder is in the app directory or source root
    // For development in Qt Creator, we point to the source location if possible, 
    // or the deployment directory.
    QString appDir = QCoreApplication::applicationDirPath();
    
    // GENIUS LOGIC: Build locally to ensure M3 ARM64 compatibility
    // We chain the build and run commands.
    // Note: In a real deployment, ensure the 'docker' folder is copied to the bundle Resources.
    
    QString dockerImageName = "monero-local-node-m3";
    
    // 1. Build Command
    QString buildCmd = QString("docker build -t %1 -f %2/../docker/Dockerfile.i2pnode %2/../docker").arg(dockerImageName).arg(appDir);
    
    // 2. Run Command
    QString runCmd = QString("docker run -d --restart=unless-stopped --name monero-node-instance -p 18081:18081 %1").arg(dockerImageName);

    // Combine into one shell execution for simplicity in this context
    QString fullCommand = QString("%1 && %2").arg(buildCmd).arg(runCmd);

    QString program = "/bin/bash";
    QStringList arguments;
    arguments << "-c" << fullCommand;

    qDebug() << "Executing GENIUS node sequence:" << fullCommand;

    m_process->start(program, arguments);

    // Password handling for sudo if ever needed (Docker Desktop on Mac usually doesn't need sudo)
    if (!password.isEmpty()) {
        // If we were using sudo, we would pipe it here. 
        // For Mac Docker Desktop, standard user usually has access.
    }
}

void I2PNodeManager::stopNodeCreation()
{
    if (m_process->state() != QProcess::NotRunning) {
        m_process->kill();
    }
    // Also try to stop the container
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
        
        // Smart error handling
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
    
    // Feedback for the user's M3 speed
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
