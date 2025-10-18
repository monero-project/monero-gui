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

#ifndef I2PMANAGER_H
#define I2PMANAGER_H

#include <memory>
#include <QMutex>
#include <QObject>
#include <QUrl>
#include <QProcess>
#include "qt/FutureScheduler.h"

/**
 * @brief The I2PManager class manages the I2P router binary (i2pd) lifecycle
 *
 * This class handles downloading, installing, starting, and stopping the i2pd binary.
 * It provides a QML-friendly interface for managing I2P routing in the Monero GUI.
 *
 * Key responsibilities:
 * - Download and verify i2pd binary from official GitHub releases
 * - Start/stop i2pd process with appropriate configuration
 * - Monitor i2pd status and health
 * - Provide connection statistics
 *
 * Usage pattern (from QML):
 *   if (!i2pManager.isInstalled()) {
 *       i2pManager.download();
 *   }
 *   i2pManager.start("127.0.0.1:4447"); // SOCKS proxy address
 */
class I2PManager : public QObject
{
    Q_OBJECT

    // QML properties for data binding
    Q_PROPERTY(bool installed READ isInstalled NOTIFY installedChanged)
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(QString status READ getStatus NOTIFY statusChanged)
    Q_PROPERTY(QString version READ getVersion NOTIFY versionChanged)

public:
    explicit I2PManager(QObject *parent = nullptr);
    ~I2PManager();

    /**
     * @brief Start the i2pd router process
     * @param socksProxy The SOCKS proxy address (default: 127.0.0.1:4447)
     * @return true if started successfully, false otherwise
     */
    Q_INVOKABLE bool start(const QString &socksProxy = "127.0.0.1:4447");

    /**
     * @brief Stop the i2pd router process gracefully
     */
    Q_INVOKABLE void stop();

    /**
     * @brief Check if i2pd binary is installed
     * @return true if binary exists and is valid
     */
    Q_INVOKABLE bool isInstalled() const;

    /**
     * @brief Get the current installation status
     * Updates the status and emits statusChanged signal
     */
    Q_INVOKABLE void getStatus();

    /**
     * @brief Download and install i2pd binary
     * Downloads from official i2pd GitHub releases, verifies hash, and installs
     */
    Q_INVOKABLE void download();

    /**
     * @brief Test connection to an I2P remote node
     * @param remoteNode The .b32.i2p address to test
     * @return true if connection successful
     */
    Q_INVOKABLE bool testConnection(const QString &remoteNode);

    /**
     * @brief Get list of known reliable I2P remote nodes
     * @return QStringList of verified .b32.i2p addresses
     */
    Q_INVOKABLE QStringList getKnownNodes() const;

    // Property getters
    bool isRunning() const;
    QString getStatus() const;
    QString getVersion() const;

    /**
     * @brief Error codes for download failures
     */
    enum DownloadError {
        BinaryNotAvailable,     ///< Binary not found on GitHub
        ConnectionIssue,        ///< Network connection failed
        HashVerificationFailed, ///< Downloaded file hash mismatch
        InstallationFailed,     ///< Failed to extract or install binary
        UnsupportedPlatform     ///< OS/architecture not supported
    };
    Q_ENUM(DownloadError)

    /**
     * @brief Status codes for i2pd router
     */
    enum RouterStatus {
        NotInstalled,   ///< Binary not installed
        Stopped,        ///< Router stopped
        Starting,       ///< Router starting up
        Bootstrapping,  ///< Router connecting to I2P network
        Ready,          ///< Router ready for connections
        Running,        ///< Router fully operational
        Error           ///< Router in error state
    };
    Q_ENUM(RouterStatus)

signals:
    /**
     * @brief Emitted when i2pd start fails
     * @param error Error message
     */
    void i2pStartFailure(const QString &error) const;

    /**
     * @brief Emitted when i2pd download fails
     * @param errorCode Error code from DownloadError enum
     */
    void i2pDownloadFailure(int errorCode) const;

    /**
     * @brief Emitted when i2pd download succeeds
     */
    void i2pDownloadSuccess() const;

    /**
     * @brief Emitted during download progress
     * @param percent Progress percentage (0-100)
     */
    void i2pDownloadProgress(int percent) const;

    /**
     * @brief Emitted when router status changes
     * @param status Status code from RouterStatus enum
     * @param message Human-readable status message
     */
    void i2pStatusChanged(int status, const QString &message) const;

    /**
     * @brief Emitted when router is ready for connections
     */
    void i2pRouterReady() const;

    // Property change signals
    void installedChanged() const;
    void runningChanged() const;
    void statusChanged() const;
    void versionChanged() const;

private:
    /**
     * @brief Check if i2pd process is running
     * @return true if process is alive
     */
    bool processRunning() const;

    /**
     * @brief Get the platform-specific binary name
     * @return Binary name (e.g., "i2pd.exe" on Windows)
     */
    QString getBinaryName() const;

    /**
     * @brief Get the download URL for current platform
     * @return QUrl to i2pd release on GitHub
     */
    QUrl getDownloadUrl() const;

    /**
     * @brief Get the expected hash for current platform binary
     * @return SHA256 hash as hex string
     */
    QString getExpectedHash() const;

    /**
     * @brief Parse i2pd log output for status information
     * @param logLine Line from i2pd log
     */
    void parseLogLine(const QString &logLine);

    /**
     * @brief Generate i2pd configuration file
     * @param socksProxy SOCKS proxy address
     */
    void writeConfig(const QString &socksProxy);

    // Process management
    std::unique_ptr<QProcess> m_i2pdProcess;
    QMutex m_i2pdMutex;

    // Path management
    QString m_i2pdBinary;     ///< Full path to i2pd binary
    QString m_i2pdPath;       ///< Directory containing i2pd
    QString m_i2pdDataDir;    ///< I2P data directory

    // State tracking
    RouterStatus m_routerStatus;
    QString m_statusMessage;
    QString m_version;
    bool m_started;

    // Async operations
    mutable FutureScheduler m_scheduler;

    // Known I2P remote nodes (fallback list)
    static const QStringList KNOWN_I2P_NODES;
};

#endif // I2PMANAGER_H
