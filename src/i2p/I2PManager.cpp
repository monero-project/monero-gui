// Copyright (c) 2025, The Monero Project
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

#include "I2PManager.h"
#include "net/http_client.h"
#include "common/util.h"
#include "qt/utils.h"

#include <QElapsedTimer>
#include <QFile>
#include <QMutexLocker>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QUrl>
#include <QtConcurrent/QtConcurrent>
#include <QApplication>
#include <QProcess>
#include <QCryptographicHash>
#include <QStandardPaths>
#include <QTextStream>
#include <QSettings>
#include <QRegularExpression>

// Detect macOS ARM64
#if defined(Q_OS_MACOS) && defined(__aarch64__) && !defined(Q_OS_MACOS_AARCH64)
#define Q_OS_MACOS_AARCH64
#endif

// i2pd version to download (update as needed)
const QString I2PD_VERSION = "2.54.0";

// Known reliable I2P remote nodes for Monero
// These will be populated with community-verified nodes during development
const QStringList I2PManager::KNOWN_I2P_NODES = {
    // TODO: Add verified I2P Monero nodes
    // Format: "xyz...abc.b32.i2p:18081"
};

I2PManager::I2PManager(QObject *parent)
    : QObject(parent)
    , m_routerStatus(NotInstalled)
    , m_started(false)
    , m_defaultSocksProxy("127.0.0.1:4447")
    , m_inboundPeers(0)
    , m_outboundPeers(0)
    , m_activeTunnels(0)
{
    // Determine i2pd installation path
    // Store in application data directory like p2pool does
#ifdef Q_OS_WIN
    m_i2pdPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/i2pd";
#elif defined(Q_OS_MACOS)
    m_i2pdPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/i2pd";
#else
    // Linux and other Unix-like systems
    m_i2pdPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/i2pd";
#endif

    // Create directory if it doesn't exist
    QDir().mkpath(m_i2pdPath);

    // Set data directory (where I2P router stores its data)
    m_i2pdDataDir = m_i2pdPath + "/data";
    QDir().mkpath(m_i2pdDataDir);

    // Set binary path
    m_i2pdBinary = m_i2pdPath + "/" + getBinaryName();

    // Load auto-start setting from QSettings
    QSettings settings;
    m_autoStartEnabled = settings.value("i2p/autoStart", false).toBool();

    // Setup status check timer - check every 10 seconds
    m_statusCheckTimer = std::make_unique<QTimer>();
    connect(m_statusCheckTimer.get(), &QTimer::timeout, this, &I2PManager::performStatusCheck);

    qDebug() << "I2PManager initialized. Binary path:" << m_i2pdBinary;
    qDebug() << "I2PManager data directory:" << m_i2pdDataDir;
    qDebug() << "I2PManager auto-start enabled:" << m_autoStartEnabled;

    // Check initial installation status
    if (isInstalled()) {
        m_routerStatus = Stopped;
        emit installedChanged();
        qDebug() << "I2PManager: i2pd binary found";
    } else {
        qDebug() << "I2PManager: i2pd binary not found, download required";
    }
}

I2PManager::~I2PManager()
{
    if (m_statusCheckTimer) {
        m_statusCheckTimer->stop();
    }
    stop();
}

bool I2PManager::isInstalled() const
{
    QFileInfo binaryInfo(m_i2pdBinary);
    if (!binaryInfo.isFile()) {
        return false;
    }

#ifndef Q_OS_WIN
    // Check if binary is executable on Unix-like systems
    if (!binaryInfo.isExecutable()) {
        qDebug() << "I2PManager: Binary exists but is not executable";
        return false;
    }
#endif

    return true;
}

QString I2PManager::getBinaryName() const
{
#ifdef Q_OS_WIN
    return "i2pd.exe";
#else
    return "i2pd";
#endif
}

QUrl I2PManager::getDownloadUrl() const
{
    QString urlBase = "https://github.com/PurpleI2P/i2pd/releases/download/" + I2PD_VERSION + "/";

#ifdef Q_OS_WIN
    // Windows x64 MinGW
    return QUrl(urlBase + "i2pd_" + I2PD_VERSION + "_win64_mingw.zip");
#elif defined(Q_OS_LINUX)
    // Linux x64 (Debian package - most compatible)
    return QUrl(urlBase + "i2pd_" + I2PD_VERSION + "-1_amd64.deb");
#elif defined(Q_OS_MACOS)
    // macOS (universal binary for both Intel and Apple Silicon)
    return QUrl(urlBase + "i2pd_" + I2PD_VERSION + "_osx.tar.gz");
#else
    return QUrl(); // Unsupported platform
#endif
}

QString I2PManager::getExpectedHash() const
{
    // SHA256 hashes for i2pd v2.54.0
    // Verified from official GitHub releases on 2025-10-17
    // Obtain from: https://github.com/PurpleI2P/i2pd/releases/tag/2.54.0

#ifdef Q_OS_WIN
    return "abf203d9976d405815b238411cb8ded48b0b85d1d9885b92a26b5c897a1d43bc"; // Windows MinGW x64
#elif defined(Q_OS_LINUX)
    return "ebbdc2bc4090ed5bcbe83e6ab735e93932e8ce9eece294b500f2b6e049764390"; // Linux amd64 deb
#elif defined(Q_OS_MACOS)
    return "ae0c75962c3f525c1a661b9c69ff31842cf31c73f3e03ca5291208f2edfe656a"; // macOS universal binary
#else
    return "";
#endif
}

void I2PManager::download()
{
    qDebug() << "I2PManager: Starting download...";

    m_scheduler.run([this] {
        QUrl url = getDownloadUrl();

        if (!url.isValid()) {
            qDebug() << "I2PManager: Unsupported platform";
            emit i2pDownloadFailure(UnsupportedPlatform);
            return;
        }

        QString fileName = m_i2pdPath + "/" + url.fileName();
        QString expectedHash = getExpectedHash();

        qDebug() << "I2PManager: Downloading from" << url.toString();
        qDebug() << "I2PManager: Saving to" << fileName;

        // Use Monero's HTTP client for downloading
        epee::net_utils::http::http_simple_client httpClient;
        const epee::net_utils::http::http_response_info* response = nullptr;
        std::string userAgent = randomUserAgent().toStdString();
        std::chrono::milliseconds timeout = std::chrono::seconds(30);

        httpClient.set_server(url.host().toStdString(), "443", {});

        bool success = httpClient.invoke_get(
            url.path().toStdString(),
            timeout,
            {},
            std::addressof(response),
            {{"User-Agent", userAgent}}
        );

        // Handle redirects
        if (success && response->m_response_code == 302) {
            epee::net_utils::http::fields_list fields = response->m_header_info.m_etc_fields;
            for (const auto& field : fields) {
                if (field.first == "Location") {
                    url = QString::fromStdString(field.second);
                    httpClient.set_server(url.host().toStdString(), "443", {});
                    std::string query = url.query(QUrl::FullyEncoded).toStdString();
                    std::string path = url.path().toStdString();
                    if (!query.empty()) {
                        path += "?" + query;
                    }
                    httpClient.wipe_response();
                    success = httpClient.invoke_get(path, timeout, {}, std::addressof(response), {{"User-Agent", userAgent}});
                }
            }
        }

        if (!success) {
            qDebug() << "I2PManager: Download failed - connection issue";
            emit i2pDownloadFailure(ConnectionIssue);
            return;
        }

        if (response->m_response_code == 404) {
            qDebug() << "I2PManager: Download failed - binary not available";
            emit i2pDownloadFailure(BinaryNotAvailable);
            return;
        }

        // Get downloaded data
        std::string stringData = response->m_body;
        QByteArray data(stringData.c_str(), stringData.length());

        // Verify hash
        QByteArray hashData = QCryptographicHash::hash(data, QCryptographicHash::Sha256);
        QString hash = hashData.toHex();

        // Verify hash matches expected value (security critical!)
        if (hash != expectedHash) {
            qDebug() << "I2PManager: Hash verification failed";
            qDebug() << "Expected:" << expectedHash;
            qDebug() << "Got:" << hash;
            emit i2pDownloadFailure(HashVerificationFailed);
            return;
        }
        
        qDebug() << "I2PManager: Hash verification passed";

        // Save archive
        QFile file(fileName);
        if (!file.open(QIODevice::WriteOnly)) {
            qDebug() << "I2PManager: Failed to open file for writing:" << fileName;
            emit i2pDownloadFailure(InstallationFailed);
            return;
        }

        file.write(data);
        file.close();

        qDebug() << "I2PManager: File downloaded successfully, extracting...";

        // Extract archive
#ifdef Q_OS_WIN
        // For Windows, we need to extract .zip
        // Using PowerShell's Expand-Archive or a similar method
        QProcess extractProcess;
        extractProcess.start("powershell", {
            "-Command",
            "Expand-Archive",
            "-Path", fileName,
            "-DestinationPath", m_i2pdPath,
            "-Force"
        });
        extractProcess.waitForFinished();
        if (extractProcess.exitCode() != 0) {
            qDebug() << "I2PManager: Extraction failed:" << extractProcess.readAllStandardError();
            emit i2pDownloadFailure(InstallationFailed);
            return;
        }
#else
        // For Linux/macOS, extract .tar.gz
        QProcess::execute("tar", {"-xzf", fileName, "-C", m_i2pdPath, "--strip-components=1"});
#endif

        // Clean up archive
        QFile::remove(fileName);

        // Set executable permissions on Unix
#ifndef Q_OS_WIN
        QFile::setPermissions(m_i2pdBinary,
                             QFile::ReadOwner | QFile::WriteOwner | QFile::ExeOwner |
                             QFile::ReadGroup | QFile::ExeGroup |
                             QFile::ReadOther | QFile::ExeOther);
#endif

        // Verify installation
        if (isInstalled()) {
            qDebug() << "I2PManager: Installation successful";
            m_routerStatus = Stopped;
            emit i2pDownloadSuccess();
            emit installedChanged();
        } else {
            qDebug() << "I2PManager: Installation verification failed";
            emit i2pDownloadFailure(InstallationFailed);
        }
    });
}

void I2PManager::writeConfig(const QString &socksProxy)
{
    QString configPath = m_i2pdDataDir + "/i2pd.conf";
    QFile configFile(configPath);

    if (!configFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "I2PManager: Failed to create config file:" << configPath;
        return;
    }

    QTextStream out(&configFile);

    // Basic configuration
    out << "# i2pd configuration for Monero GUI\n";
    out << "# Auto-generated - do not edit manually\n\n";

    // Network settings
    out << "[network]\n";
    out << "bandwidth = P  # P = unlimited, L/M/N/O for lower limits\n";
    out << "enableipv4 = true\n";
    out << "enableipv6 = false\n\n";

    // Logging
    out << "[log]\n";
    out << "loglevel = info\n";
    out << "logfile = " << m_i2pdDataDir.toStdString().c_str() << "/i2pd.log\n\n";

    // Daemon settings
    out << "[daemon]\n";
    out << "service = false\n";
    out << "daemon = false\n\n";

    // Data directory
    out << "datadir = " << m_i2pdDataDir.toStdString().c_str() << "\n\n";

    // SOCKS proxy (for connecting to I2P)
    QStringList proxyParts = socksProxy.split(":");
    QString proxyHost = proxyParts.size() > 0 ? proxyParts[0] : "127.0.0.1";
    QString proxyPort = proxyParts.size() > 1 ? proxyParts[1] : "4447";

    out << "[socks]\n";
    out << "enabled = true\n";
    out << "address = " << proxyHost.toStdString().c_str() << "\n";
    out << "port = " << proxyPort.toStdString().c_str() << "\n\n";

    // HTTP proxy (optional, for browsing I2P sites)
    out << "[http]\n";
    out << "enabled = true\n";
    out << "address = 127.0.0.1\n";
    out << "port = 4444\n\n";

    // Disable unnecessary features to reduce overhead
    out << "[httpproxy]\n";
    out << "enabled = false\n\n";

    out << "[sam]\n";
    out << "enabled = false\n\n";

    out << "[bob]\n";
    out << "enabled = false\n\n";

    out << "[i2cp]\n";
    out << "enabled = false\n\n";

    out << "[i2pcontrol]\n";
    out << "enabled = false\n\n";

    out << "[upnp]\n";
    out << "enabled = true  # Try to use UPnP for NAT traversal\n\n";

    out << "[precomputation]\n";
    out << "elgamal = true  # Precompute tables for better performance\n\n";

    out << "[reseed]\n";
    out << "verify = true  # Verify reseed data\n\n";

    configFile.close();
    qDebug() << "I2PManager: Configuration file written to" << configPath;
}

bool I2PManager::start(const QString &socksProxy)
{
    QMutexLocker locker(&m_i2pdMutex);

    if (!isInstalled()) {
        qDebug() << "I2PManager: Cannot start - not installed";
        emit i2pStartFailure("I2P router not installed");
        return false;
    }

    if (processRunning()) {
        qDebug() << "I2PManager: Already running";
        return true;
    }

    qDebug() << "I2PManager: Starting i2pd...";

    // Write configuration
    writeConfig(socksProxy);

    // Create process
    m_i2pdProcess = std::make_unique<QProcess>();

    // Set working directory
    m_i2pdProcess->setWorkingDirectory(m_i2pdPath);

    // Connect signals
    connect(m_i2pdProcess.get(), &QProcess::readyReadStandardOutput, this, [this]() {
        QString output = m_i2pdProcess->readAllStandardOutput();
        for (const QString &line : output.split('\n')) {
            if (!line.trimmed().isEmpty()) {
                parseLogLine(line);
            }
        }
    });

    connect(m_i2pdProcess.get(), &QProcess::readyReadStandardError, this, [this]() {
        QString error = m_i2pdProcess->readAllStandardError();
        qDebug() << "I2PManager stderr:" << error;
    });

    connect(m_i2pdProcess.get(), QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode, QProcess::ExitStatus exitStatus) {
        qDebug() << "I2PManager: Process finished with code" << exitCode;
        m_started = false;
        m_routerStatus = Stopped;
        emit runningChanged();
        emit statusChanged();
    });

    // Start process with config file
    QStringList args;
    args << "--conf=" + m_i2pdDataDir + "/i2pd.conf";

    m_i2pdProcess->start(m_i2pdBinary, args);

    if (!m_i2pdProcess->waitForStarted(5000)) {
        qDebug() << "I2PManager: Failed to start process";
        emit i2pStartFailure("Failed to start I2P router process");
        return false;
    }

    m_started = true;
    m_routerStatus = Starting;

    // Start status monitoring timer
    if (m_statusCheckTimer) {
        m_statusCheckTimer->start(10000); // Check every 10 seconds
    }

    emit runningChanged();
    emit statusChanged();
    emit i2pStatusChanged(Starting, "I2P router starting...");

    qDebug() << "I2PManager: Process started successfully";
    return true;
}

void I2PManager::stop()
{
    QMutexLocker locker(&m_i2pdMutex);

    // Stop status monitoring timer
    if (m_statusCheckTimer) {
        m_statusCheckTimer->stop();
    }

    if (!processRunning()) {
        return;
    }

    qDebug() << "I2PManager: Stopping i2pd...";

    // Terminate gracefully
    m_i2pdProcess->terminate();

    // Wait for termination
    if (!m_i2pdProcess->waitForFinished(10000)) {
        qDebug() << "I2PManager: Graceful shutdown timeout, killing process";
        m_i2pdProcess->kill();
        m_i2pdProcess->waitForFinished();
    }

    m_started = false;
    m_routerStatus = Stopped;

    // Reset stats
    m_inboundPeers = 0;
    m_outboundPeers = 0;
    m_activeTunnels = 0;

    emit runningChanged();
    emit statusChanged();
    emit i2pStatusChanged(Stopped, "I2P router stopped");

    qDebug() << "I2PManager: Process stopped";
}

bool I2PManager::processRunning() const
{
    return m_i2pdProcess && m_i2pdProcess->state() == QProcess::Running;
}

bool I2PManager::isRunning() const
{
    return m_started && processRunning();
}

QString I2PManager::getStatus() const
{
    switch (m_routerStatus) {
    case NotInstalled:
        return "Not installed";
    case Stopped:
        return "Stopped";
    case Starting:
        return "Starting...";
    case Bootstrapping:
        return "Connecting to I2P network...";
    case Ready:
        return "Ready";
    case Running:
        return "Running";
    case Error:
        return "Error: " + m_statusMessage;
    default:
        return "Unknown";
    }
}

QString I2PManager::getVersion() const
{
    return I2PD_VERSION;
}

void I2PManager::getStatus()
{
    // This is called from QML to update status
    emit statusChanged();
}

void I2PManager::parseLogLine(const QString &logLine)
{
    // Parse i2pd log output to determine router status
    // i2pd log format: timestamp [level] message

    if (logLine.contains("Loaded") && logLine.contains("routers")) {
        m_routerStatus = Bootstrapping;
        emit statusChanged();
        emit i2pStatusChanged(Bootstrapping, "Loading router information...");
    }
    else if (logLine.contains("Router started with")) {
        m_routerStatus = Ready;
        emit statusChanged();
        emit i2pStatusChanged(Ready, "Router ready");
        emit i2pRouterReady();
    }
    else if (logLine.contains("Accepting tunnels")) {
        m_routerStatus = Running;
        emit statusChanged();
        emit i2pStatusChanged(Running, "Router running");
    }
    else if (logLine.contains("error", Qt::CaseInsensitive) ||
             logLine.contains("failed", Qt::CaseInsensitive)) {
        m_statusMessage = logLine;
        m_routerStatus = Error;
        emit statusChanged();
        emit i2pStatusChanged(Error, logLine);
    }

    // Update network stats from log
    updateStatsFromLog(logLine);

    // Log for debugging
    qDebug() << "I2PManager:" << logLine;
}

void I2PManager::setAutoStart(bool enable)
{
    if (m_autoStartEnabled == enable) {
        return; // No change
    }

    m_autoStartEnabled = enable;

    // Persist setting to QSettings
    QSettings settings;
    settings.setValue("i2p/autoStart", enable);
    settings.sync();

    qDebug() << "I2PManager: Auto-start" << (enable ? "enabled" : "disabled");
}

bool I2PManager::isAutoStartEnabled() const
{
    return m_autoStartEnabled;
}

bool I2PManager::tryAutoStart()
{
    if (!m_autoStartEnabled) {
        qDebug() << "I2PManager: Auto-start is disabled";
        return false;
    }

    if (!isInstalled()) {
        qDebug() << "I2PManager: Cannot auto-start - i2pd not installed";
        return false;
    }

    if (isRunning()) {
        qDebug() << "I2PManager: Already running";
        return true;
    }

    qDebug() << "I2PManager: Attempting auto-start...";
    bool started = start(m_defaultSocksProxy);

    if (started) {
        qDebug() << "I2PManager: Auto-start successful";
        emit i2pStatusChanged(Starting, "I2P router auto-started");
    } else {
        qDebug() << "I2PManager: Auto-start failed";
        emit i2pStartFailure("Auto-start of I2P router failed");
    }

    return started;
}

void I2PManager::performStatusCheck()
{
    // This method is called every 10 seconds via timer
    // Check process health, update stats from logs
    
    if (!isRunning()) {
        return;
    }

    // In a real implementation, we would:
    // 1. Query i2pd's HTTP console or control API
    // 2. Parse peer lists
    // 3. Get tunnel information
    // For now, we rely on log parsing which is triggered by parseLogLine

    qDebug() << "I2PManager: Status check - In:" << m_inboundPeers 
             << "Out:" << m_outboundPeers 
             << "Tunnels:" << m_activeTunnels;
}

void I2PManager::updateStatsFromLog(const QString &logLine)
{
    // Parse i2pd log lines for network statistics
    // Example log patterns (i2pd format varies by version):
    // "peers: 10 inbound, 8 outbound"
    // "tunnels: 5 active, 0 failed"
    // "Established inbound: X"
    // "Established outbound: X"

    if (logLine.contains("peers:") && (logLine.contains("inbound") || logLine.contains("outbound"))) {
        // Try to extract peer counts
        QRegularExpression inboundRx("(\\d+)\\s+inbound");
        QRegularExpression outboundRx("(\\d+)\\s+outbound");
        
        QRegularExpressionMatch inboundMatch = inboundRx.match(logLine);
        QRegularExpressionMatch outboundMatch = outboundRx.match(logLine);
        
        if (inboundMatch.hasMatch()) {
            int newInbound = inboundMatch.captured(1).toInt();
            if (newInbound != m_inboundPeers) {
                m_inboundPeers = newInbound;
                emit statusChanged();
            }
        }
        
        if (outboundMatch.hasMatch()) {
            int newOutbound = outboundMatch.captured(1).toInt();
            if (newOutbound != m_outboundPeers) {
                m_outboundPeers = newOutbound;
                emit statusChanged();
            }
        }
    }

    if (logLine.contains("tunnel", Qt::CaseInsensitive) && logLine.contains("active", Qt::CaseInsensitive)) {
        // Try to extract active tunnel count
        QRegularExpression tunnelRx("(\\d+)\\s+active");
        QRegularExpressionMatch match = tunnelRx.match(logLine);
        
        if (match.hasMatch()) {
            int newTunnels = match.captured(1).toInt();
            if (newTunnels != m_activeTunnels) {
                m_activeTunnels = newTunnels;
                emit statusChanged();
            }
        }
    }

    // Also check for explicit inbound/outbound established messages
    if (logLine.contains("Established inbound", Qt::CaseInsensitive)) {
        QRegularExpression rx("(\\d+)");
        QRegularExpressionMatch match = rx.match(logLine);
        if (match.hasMatch()) {
            m_inboundPeers = match.captured(1).toInt();
            emit statusChanged();
        }
    }

    if (logLine.contains("Established outbound", Qt::CaseInsensitive)) {
        QRegularExpression rx("(\\d+)");
        QRegularExpressionMatch match = rx.match(logLine);
        if (match.hasMatch()) {
            m_outboundPeers = match.captured(1).toInt();
            emit statusChanged();
        }
    }
}

QString I2PManager::getNetworkHealth() const
{
    // Determine overall network health based on peer and tunnel counts
    int totalPeers = m_inboundPeers + m_outboundPeers;

    if (totalPeers == 0) {
        return "Unknown";
    }

    if (totalPeers >= 10 && m_activeTunnels >= 3) {
        return "Good";
    }

    if (totalPeers >= 5) {
        return "Fair";
    }

    return "Poor";
}

bool I2PManager::testConnection(const QString &remoteNode)
{
    // TODO: Implement connection testing
    // This would attempt to connect to the remote node via I2P SOCKS proxy
    Q_UNUSED(remoteNode);
    return false;
}

QStringList I2PManager::getKnownNodes() const
{
    return KNOWN_I2P_NODES;
}
