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
#include <QTimer>
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
    Q_PROPERTY(int inboundPeers READ getInboundPeers NOTIFY statusChanged)
    Q_PROPERTY(int outboundPeers READ getOutboundPeers NOTIFY statusChanged)
    Q_PROPERTY(int activeTunnels READ getActiveTunnels NOTIFY statusChanged)
    Q_PROPERTY(QString networkHealth READ getNetworkHealth NOTIFY statusChanged)

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

    /**
     * @brief Enable or disable auto-start on application launch
     * @param enable true to auto-start, false to disable
     */
    Q_INVOKABLE void setAutoStart(bool enable);

    /**
     * @brief Check if auto-start is enabled
     * @return true if auto-start is enabled
     */
    Q_INVOKABLE bool isAutoStartEnabled() const;

    /**
     * @brief Attempt to auto-start i2pd if enabled and not already running
     * Called automatically when application starts
     * @return true if started or already running, false if auto-start disabled
     */
    Q_INVOKABLE bool tryAutoStart();

    /**
     * @brief Generate monerod command line flags for I2P connectivity
     * When I2P is enabled and running, returns flags to configure monerod SOCKS proxy
     * @return Space-separated monerod flags (e.g., "--proxy 127.0.0.1:4447 --proxy-allow-dns-leaks")
     */
    Q_INVOKABLE QString getMonerodProxyFlags() const;

    /**
     * @brief Check if I2P is properly configured and ready for monerod integration
     * @return true if I2P is running and proxy is accessible
     */
    Q_INVOKABLE bool isProxyReady() const;

    /**
     * @brief Get the SOCKS proxy address for monerod configuration
     * @return Proxy address in format "127.0.0.1:port" or empty string if not available
     */
    Q_INVOKABLE QString getProxyAddress() const;

    /**
     * @brief Check if an update is available for i2pd
     * @return true if newer version is available on GitHub
     */
    Q_INVOKABLE void checkForUpdates();

    /**
     * @brief Get the latest available i2pd version from GitHub
     * @return Version string (e.g., "2.55.0")
     */
    Q_INVOKABLE QString getLatestVersion() const;

    /**
     * @brief Check if an update is pending after download
     * @return true if update has been downloaded but not installed
     */
    Q_INVOKABLE bool isUpdatePending() const;

    /**
     * @brief Install a pending update and restart i2pd
     * Backs up current binary before installing new version
     * @return true if update succeeds, false otherwise
     */
    Q_INVOKABLE bool applyPendingUpdate();

    /**
     * @brief Cancel a pending update
     * Removes downloaded update and restores previous state
     */
    Q_INVOKABLE void cancelUpdate();

    // Property getters
    bool isRunning() const;
    QString getStatus() const;
    QString getVersion() const;

    /**
     * @brief Get the number of inbound peers connected to this node
     * @return Number of inbound peers
     */
    int getInboundPeers() const { return m_inboundPeers; }

    /**
     * @brief Get the number of outbound peers this node is connected to
     * @return Number of outbound peers
     */
    int getOutboundPeers() const { return m_outboundPeers; }

    /**
     * @brief Get the number of active I2P tunnels
     * @return Number of active tunnels
     */
    int getActiveTunnels() const { return m_activeTunnels; }

    /**
     * @brief Get the overall network health status
     * @return "Good", "Fair", "Poor", or "Unknown"
     */
    QString getNetworkHealth() const;

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

    /**
     * @brief Emitted when checking for updates
     * @param isChecking true when starting check, false when complete
     */
    void checkingForUpdates(bool isChecking) const;

    /**
     * @brief Emitted when a new version is available
     * @param version New version string
     */
    void updateAvailable(const QString &version) const;

    /**
     * @brief Emitted when update status changes
     * @param isPending true if update is downloaded and ready to install
     */
    void updateStatusChanged(bool isPending) const;

    /**
     * @brief Emitted during update installation
     * @param percent Progress percentage (0-100)
     */
    void updateProgress(int percent) const;

    /**
     * @brief Emitted when update installation completes
     * @param success true if update succeeded
     * @param message Status message
     */
    void updateFinished(bool success, const QString &message) const;

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
    bool m_autoStartEnabled;       ///< Auto-start setting
    QString m_defaultSocksProxy;   ///< Default SOCKS proxy address

    // Network stats tracking
    int m_inboundPeers;            ///< Number of inbound peers
    int m_outboundPeers;           ///< Number of outbound peers
    int m_activeTunnels;           ///< Number of active tunnels

    // Status monitoring
    std::unique_ptr<QTimer> m_statusCheckTimer;  ///< Timer for periodic status checks

    /**
     * @brief Perform periodic status check
     * Updates peer counts and tunnel info
     */
    void performStatusCheck();

    /**
     * @brief Parse i2pd logs for network stats
     * @param logLine Log line to parse
     */
    void updateStatsFromLog(const QString &logLine);

    // Update management
    QString m_latestVersion;           ///< Latest available version from GitHub
    bool m_updatePending;              ///< True if update downloaded but not installed
    QString m_updateFilePath;          ///< Path to downloaded update file
    QString m_backupBinaryPath;        ///< Path to backup of current binary

    /**
     * @brief Download latest i2pd release from GitHub
     * Internal method called by checkForUpdates()
     */
    void performUpdateCheck();

    /**
     * @brief Extract and install downloaded update file
     * @param updateFilePath Path to downloaded archive
     * @return true if installation succeeds
     */
    bool installUpdate(const QString &updateFilePath);

    // Async operations
    mutable FutureScheduler m_scheduler;

    // Known I2P remote nodes (fallback list)
    static const QStringList KNOWN_I2P_NODES;
};

#endif // I2PMANAGER_H
