// Copyright (c) 2014-2023, The Monero Project
//
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include "i2pdaemonmanager.h"
#include <QStandardPaths>
#include <QDir>
#include <QFile>
#include <QProcess>
#include <QCoreApplication>
#include <QDebug>
#include <QApplication>
#include <QFileInfo>
#include <QSettings>
#include <QTimer>
#include <QRegularExpression>
#include <QTcpSocket>
#include <QHostAddress>
#include <QNetworkProxy>

#ifdef Q_OS_WIN
#include <Windows.h>
#endif

// Initialize static instance
I2PDaemonManager* I2PDaemonManager::m_instance = nullptr;

I2PDaemonManager* I2PDaemonManager::instance()
{
    if (!m_instance)
    {
        QMutexLocker locker(&m_mutex);
        if (!m_instance)
        {
            m_instance = new I2PDaemonManager();
        }
    }
    return m_instance;
}

I2PDaemonManager::I2PDaemonManager(QObject *parent)
    : QObject(parent)
    , m_process(new QProcess(this))
    , m_running(false)
    , m_tunnelLength(3)
    , m_status("Not started")
{
    // Connect process signals
    connect(m_process.get(), &QProcess::started, this, [this]() {
        qDebug() << "I2P daemon process started";
        m_running = true;
        m_status = "Running";
        emit runningChanged();
        emit statusChanged();
        emit daemonStarted();
    });
    
    connect(m_process.get(), QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), this, [this](int exitCode, QProcess::ExitStatus exitStatus) {
        qDebug() << "I2P daemon process finished with exit code" << exitCode << "and status" << exitStatus;
        m_running = false;
        m_status = QString("Stopped (exit code: %1)").arg(exitCode);
        emit runningChanged();
        emit statusChanged();
        emit daemonStopped();
    });
    
    connect(m_process.get(), &QProcess::errorOccurred, this, [this](QProcess::ProcessError error) {
        qDebug() << "I2P daemon process error occurred:" << error;
        m_running = false;
        m_status = QString("Error: %1").arg(m_process->errorString());
        emit runningChanged();
        emit statusChanged();
        emit daemonFailed(QString("Process error: %1").arg(error));
    });
    
    connect(m_process.get(), &QProcess::readyReadStandardOutput, this, &I2PDaemonManager::parseProcessOutput);
    connect(m_process.get(), &QProcess::readyReadStandardError, this, &I2PDaemonManager::parseProcessOutput);
    
    // Set up config directories
    QString appDataLocation = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir appDataDir(appDataLocation);
    
    // Create I2P config directory
    if (!appDataDir.exists("i2p")) {
        appDataDir.mkdir("i2p");
    }
    
    m_configDir = appDataDir.absoluteFilePath("i2p").toStdString();
    m_dataDir = m_configDir + "/data";
    
    // Create data directory
    QDir configDir(QString::fromStdString(m_configDir));
    if (!configDir.exists("data")) {
        configDir.mkdir("data");
    }
    
    // Create logs directory
    if (!configDir.exists("logs")) {
        configDir.mkdir("logs");
    }
    
    // Create config files on first run
    createConfigFiles();
}

I2PDaemonManager::~I2PDaemonManager()
{
    stop();
}

void I2PDaemonManager::start()
{
    QMutexLocker locker(&m_mutex);
    
    if (m_running) {
        qDebug() << "I2P daemon already running";
        return;
    }
    
    // Check if I2P daemon exists
    if (!checkI2PDaemon()) {
        qDebug() << "I2P daemon executable not found";
        m_status = "Error: I2P daemon executable not found";
        emit statusChanged();
        emit daemonStartFailure();
        return;
    }
    
    // Configure I2P daemon
    configureI2PDaemon();
    
    // Start I2P daemon
    QStringList arguments;
    
    // Add user-provided options if available
    if (!m_options.isEmpty()) {
        for (auto it = m_options.constBegin(); it != m_options.constEnd(); ++it) {
            if (!it.value().isEmpty()) {
                arguments << QString("--%1=%2").arg(it.key(), it.value());
            } else {
                arguments << QString("--%1").arg(it.key());
            }
        }
    } else {
        // Default arguments for I2P daemon
        arguments << "--sam.enabled=true";
        arguments << "--sam.address=127.0.0.1";
        arguments << "--sam.port=7656";
        arguments << "--http.address=127.0.0.1";
        arguments << "--http.port=7070";
        arguments << "--log=file";
        arguments << QString("--log.file=%1").arg(m_logPath);
        arguments << QString("--datadir=%1").arg(m_dataPath);
    }
    
    qDebug() << "Starting I2P daemon with arguments:" << arguments;
    
    m_process->setWorkingDirectory(QFileInfo(m_executablePath).absolutePath());
    m_process->setProcessChannelMode(QProcess::MergedChannels);
    m_process->start(m_executablePath, arguments);
    
    if (!m_process->waitForStarted(5000)) {
        qDebug() << "Failed to start I2P daemon process";
        m_status = "Error: Failed to start I2P daemon";
        emit statusChanged();
        emit daemonStartFailure();
        return;
    }
    
    // Start a timer to check the daemon status periodically
    QTimer::singleShot(5000, this, &I2PDaemonManager::checkDaemonStatus);
}

void I2PDaemonManager::stop()
{
    QMutexLocker locker(&m_mutex);
    
    if (!m_running) {
        qDebug() << "I2P daemon not running";
        return;
    }

    qDebug() << "Stopping I2P daemon";
    
#ifdef Q_OS_WIN
    // On Windows, terminate the process tree to ensure all child processes are killed
    HANDLE hProcess = (HANDLE)m_process->processId();
    if (hProcess) {
        // Terminate process
        if (TerminateProcess(hProcess, 0)) {
            qDebug() << "I2P daemon process terminated successfully";
        } else {
            qDebug() << "Failed to terminate I2P daemon process";
        }
    }
#endif

    // Try normal termination first
    m_process->terminate();
    if (!m_process->waitForFinished(3000)) {
        qDebug() << "I2P daemon did not terminate gracefully, killing...";
        m_process->kill();
    }
    
    m_running = false;
    m_status = "Stopped";
    emit runningChanged();
    emit statusChanged();
    emit daemonStopped();
}

bool I2PDaemonManager::running() const
{
    return m_running;
}

QString I2PDaemonManager::status() const
{
    return m_status;
}

void I2PDaemonManager::setOptions(const QString &options)
{
    QMutexLocker locker(&m_mutex);
    
    if (m_optionsString != options) {
        m_optionsString = options;
        m_options = processOptions(options);
    }
}

QString I2PDaemonManager::getOptions() const
{
    return m_optionsString;
}

QString I2PDaemonManager::daemonPath() const
{
    return m_executablePath;
}

bool I2PDaemonManager::checkSystemI2P() const
{
    // Try to connect to default I2P SAM port to check if external I2P is running
    QTcpSocket socket;
    socket.setProxy(QNetworkProxy::NoProxy);
    socket.connectToHost(QHostAddress::LocalHost, 7656);
    const bool connected = socket.waitForConnected(1000);
    socket.disconnectFromHost();
    return connected;
}

QMap<QString, QString> I2PDaemonManager::processOptions(const QString &options) const
{
    QMap<QString, QString> result;
    
    if (options.isEmpty()) {
        return result;
    }
    
    const QStringList optionsList = options.split(" ", Qt::SkipEmptyParts);
    for (const QString &option : optionsList) {
        // Split by =, first part is key, second part is value
        if (option.contains('=')) {
            const int separatorPos = option.indexOf('=');
            QString key = option.left(separatorPos);
            QString value = option.mid(separatorPos + 1);
            
            // Remove -- prefix if present
            if (key.startsWith("--")) {
                key = key.mid(2);
            }
            
            result[key] = value;
        } else {
            // Option without value
            QString key = option;
            
            // Remove -- prefix if present
            if (key.startsWith("--")) {
                key = key.mid(2);
            }
            
            result[key] = QString();
        }
    }
    
    return result;
}

bool I2PDaemonManager::extractI2PDaemon()
{
    QString appPath = QApplication::applicationDirPath();
    
#ifdef Q_OS_WIN
    m_executablePath = appPath + "/i2pd.exe";
#else
    m_executablePath = appPath + "/i2pd";
#endif
    
    // Initialize paths
    m_dataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/i2pd";
    m_logPath = m_dataPath + "/i2pd.log";
    
    QDir dataDir(m_dataPath);
    if (!dataDir.exists()) {
        dataDir.mkpath(".");
    }
    
    qDebug() << "I2P daemon paths:" 
             << "Executable:" << m_executablePath
             << "Data directory:" << m_dataPath
             << "Log file:" << m_logPath;
    
    return QFileInfo::exists(m_executablePath);
}

void I2PDaemonManager::configureI2PDaemon()
{
    // Nothing to configure for now, we pass command line arguments
}

bool I2PDaemonManager::checkI2PDaemon() const
{
    return QFileInfo::exists(m_executablePath) && QFileInfo(m_executablePath).isExecutable();
}

void I2PDaemonManager::checkDaemonStatus()
{
    if (!m_running) {
        return;
    }

    // Try to connect to I2P HTTP console to verify it's running
    QTcpSocket socket;
    socket.setProxy(QNetworkProxy::NoProxy);
    socket.connectToHost(QHostAddress::LocalHost, 7070);
    const bool connected = socket.waitForConnected(1000);
    socket.disconnectFromHost();
    
    if (connected) {
        m_status = "Running";
        emit statusChanged();
    } else {
        // Check if process is still running
        if (m_process->state() == QProcess::Running) {
            m_status = "Starting...";
            emit statusChanged();
            // Try again later
            QTimer::singleShot(5000, this, &I2PDaemonManager::checkDaemonStatus);
        } else {
            m_running = false;
            m_status = "Error: Process exited unexpectedly";
            emit runningChanged();
            emit statusChanged();
            emit daemonStopped();
        }
    }
}

void I2PDaemonManager::parseProcessOutput()
{
    const QByteArray output = m_process->readAllStandardOutput();
    if (!output.isEmpty()) {
        QString outputString = QString::fromUtf8(output);
        
        // Look for specific status messages
        if (outputString.contains("SAM accepting")) {
            m_status = "Running - SAM enabled";
            emit statusChanged();
        }
        else if (outputString.contains("error", Qt::CaseInsensitive)) {
            m_status = "Warning: Error detected in I2P output";
            emit statusChanged();
        }
    }
}

bool I2PDaemonManager::setTunnelLength(int length)
{
    if (length < 1 || length > 7) {
        qDebug() << "Invalid tunnel length:" << length;
        return false;
    }
    
    if (isRunning())
    {
        qDebug() << "Updating tunnel length requires restart";
        updateTunnelConfig();
    }
    
    m_tunnelLength = length;
    
    return true;
}

int I2PDaemonManager::getTunnelLength() const
{
    return m_tunnelLength;
}

bool I2PDaemonManager::generateConfig()
{
    QDir dir(QString::fromStdString(m_dataDir));
    if (!dir.exists())
    {
        dir.mkpath(".");
    }
    
    // Generate i2pd.conf
    QFile i2pdConf(QString::fromStdString(m_configDir + "/i2pd.conf"));
    if (i2pdConf.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        QTextStream out(&i2pdConf);
        out << "[http]\n";
        out << "enabled = true\n";
        out << "address = 127.0.0.1\n";
        out << "port = 7070\n\n";
        
        out << "[httpproxy]\n";
        out << "enabled = false\n\n";
        
        out << "[socksproxy]\n";
        out << "enabled = false\n\n";
        
        out << "[sam]\n";
        out << "enabled = true\n";
        out << "address = 127.0.0.1\n";
        out << "port = 7656\n\n";
        
        out << "[upnp]\n";
        out << "enabled = false\n\n";
        
        out << "[precomputation]\n";
        out << "elgamal = true\n\n";
        
        out << "[limits]\n";
        out << "transittunnels = 10\n";
        out << "openfiles = 0\n\n";
        
        out << "[trust]\n";
        out << "enabled = true\n";
        out << "family = monero\n\n";
        
        out << "[exploratory]\n";
        out << "inbound.length = 3\n";
        out << "outbound.length = 3\n";
        out << "inbound.quantity = 2\n";
        out << "outbound.quantity = 2\n\n";
        
        i2pdConf.close();
    }
    else
    {
        qDebug() << "Failed to write i2pd.conf";
        return false;
    }
    
    // Generate tunnels.conf
    QFile tunnelsConf(QString::fromStdString(m_configDir + "/tunnels.conf"));
    if (tunnelsConf.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        QTextStream out(&tunnelsConf);
        out << "[monero]\n";
        out << "type = client\n";
        out << "address = 127.0.0.1\n";
        out << "port = 18081\n";
        out << "destination = monero.i2p\n";
        out << "inbound.length = " << m_tunnelLength << "\n";
        out << "outbound.length = " << m_tunnelLength << "\n";
        out << "inbound.quantity = 3\n";
        out << "outbound.quantity = 3\n";
        out << "i2cp.leaseSetType = 3\n";
        out << "i2cp.leaseSetEncType = 0,4\n";
        
        tunnelsConf.close();
    }
    else
    {
        qDebug() << "Failed to write tunnels.conf";
        return false;
    }
    
    return true;
}

bool I2PDaemonManager::updateTunnelConfig()
{
    QString tunnelsConfPath = QString::fromStdString(m_configDir + "/tunnels.conf");
    qDebug() << "Updating I2P tunnel configuration:" << tunnelsConfPath;
    
    QFile tunnelsConf(tunnelsConfPath);
    if (tunnelsConf.open(QIODevice::WriteOnly | QIODevice::Text)) {
        tunnelsConf.write(
            "[monero]\n"
            "type = client\n"
            "address = 127.0.0.1\n"
            "port = 18081\n"
            "destination = monero.i2p\n"
            "inbound.length = " + QByteArray::number(m_tunnelLength) + "\n"
            "outbound.length = " + QByteArray::number(m_tunnelLength) + "\n"
            "inbound.quantity = 3\n"
            "outbound.quantity = 3\n"
            "i2cp.leaseSetType = 3\n"
            "i2cp.leaseSetEncType = 0,4\n"
        );
        tunnelsConf.close();
        return true;
    } else {
        qDebug() << "Failed to update I2P tunnel configuration:" << tunnelsConfPath;
        return false;
    }
}

QString I2PDaemonManager::version() const
{
    // Implementation of version retrieval from running daemon
    if (m_running) {
        // Try to get version from running daemon via HTTP API
        QTcpSocket socket;
        socket.connectToHost(QHostAddress("127.0.0.1"), 7070);
        
        if (socket.waitForConnected(1000)) {
            // Send HTTP request to get version info
            QString request = "GET /api/version HTTP/1.1\r\n"
                              "Host: 127.0.0.1:7070\r\n"
                              "Connection: close\r\n\r\n";
            
            socket.write(request.toUtf8());
            socket.waitForBytesWritten();
            
            if (socket.waitForReadyRead(2000)) {
                QString response = QString::fromUtf8(socket.readAll());
                QRegularExpression versionRegex("\"version\":\"([0-9\\.]+)\"");
                QRegularExpressionMatch match = versionRegex.match(response);
                
                if (match.hasMatch()) {
                    return match.captured(1);
                }
            }
            
            socket.disconnectFromHost();
        }
    }
    
    // If we couldn't get the version dynamically, return the version the binary was built with
    return "2.45.1"; // Default version should match the downloaded binary version
}

QString I2PDaemonManager::dataDir() const
{
    // Use app data location + "i2pd" subfolder
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/i2pd";
}

bool I2PDaemonManager::configure(const QString &address, int port, int tunnelLength)
{
    if (isRunning())
    {
        qDebug() << "Cannot configure I2P daemon while it's running";
        return false;
    }
    
    m_tunnelLength = qBound(2, tunnelLength, 7); // Clamp tunnel length between 2 and 7
    
    return generateConfig();
} 