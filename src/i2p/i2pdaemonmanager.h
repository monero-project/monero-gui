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

#ifndef I2PDAEMONMANAGER_H
#define I2PDAEMONMANAGER_H

#include <QObject>
#include <QProcess>
#include <QMap>
#include <QString>
#include <QTemporaryDir>
#include <QMutex>
#include <memory>

/**
 * @brief Manages the bundled I2P daemon process
 * 
 * This class is responsible for starting, stopping, and monitoring
 * the bundled I2P daemon. It creates the necessary configuration
 * files and manages the daemon process lifecycle.
 */
class I2PDaemonManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(QString status READ status NOTIFY statusChanged)

public:
    /**
     * @brief Get the singleton instance
     * @return Pointer to the singleton instance
     */
    static I2PDaemonManager* instance();
    
    /**
     * @brief Start the I2P daemon
     * @return true if daemon started successfully
     */
    Q_INVOKABLE void start();
    
    /**
     * @brief Stop the I2P daemon
     * @return true if daemon stopped successfully
     */
    Q_INVOKABLE void stop();
    
    /**
     * @brief Check if the I2P daemon is running
     * @return true if daemon is running
     */
    Q_INVOKABLE bool running() const;
    
    /**
     * @brief Get the current status of the I2P daemon
     * @return The current status of the I2P daemon
     */
    Q_INVOKABLE QString status() const;
    
    /**
     * @brief Configure the I2P daemon with custom options
     * @param options The I2P options string
     */
    Q_INVOKABLE void setOptions(const QString &options);
    
    /**
     * @brief Get the current I2P options string
     * @return The current I2P options string
     */
    Q_INVOKABLE QString getOptions() const;
    
    /**
     * @brief Get the path to the I2P daemon executable
     * @return The path to the I2P daemon executable
     */
    Q_INVOKABLE QString daemonPath() const;
    
    /**
     * @brief Check if the I2P daemon is already available on the system
     * @return true if the I2P daemon is already available on the system
     */
    Q_INVOKABLE bool checkSystemI2P() const;
    
    /**
     * @brief Get the I2P daemon version
     * @return The I2P daemon version
     */
    Q_INVOKABLE QString version() const;
    
    /**
     * @brief Get the I2P daemon data directory
     * @return The I2P daemon data directory
     */
    Q_INVOKABLE QString dataDir() const;
    
    /**
     * @brief Configure the I2P daemon with the given settings
     * @param address The I2P address
     * @param port The I2P port
     * @param tunnelLength The tunnel length value (2-7)
     * @return true if the configuration was successful
     */
    Q_INVOKABLE bool configure(const QString &address, int port, int tunnelLength);
    
    /**
     * @brief Get the configuration directory path
     * @return Path to the I2P configuration directory
     */
    QString getConfigDir() const;
    
    /**
     * @brief Get the data directory path
     * @return Path to the I2P data directory
     */
    QString getDataDir() const;
    
    /**
     * @brief Set the tunnel length for the I2P router
     * @param length The tunnel length value (2-7)
     * @return true if the value was set successfully
     */
    bool setTunnelLength(int length);
    
    /**
     * @brief Get the tunnel length setting
     * @return The current tunnel length setting
     */
    int getTunnelLength() const;

signals:
    void daemonStarted();
    void daemonStopped();
    void daemonStartFailure();
    void runningChanged();
    void statusChanged();
    void daemonFailed(const QString &errorMessage);

private:
    /**
     * @brief Constructor
     * @param parent The parent QObject
     */
    explicit I2PDaemonManager(QObject *parent = nullptr);
    
    /**
     * @brief Destructor
     */
    ~I2PDaemonManager();
    
    // Process the I2P options string into a map of arguments
    QMap<QString, QString> processOptions(const QString &options) const;
    
    // Extract I2P daemon executable from resources
    bool extractI2PDaemon();
    
    // Configure the I2P daemon with default settings
    void configureI2PDaemon();
    
    // Check if the I2P daemon is installed and available
    bool checkI2PDaemon() const;
    
    // Check if the daemon process is still running
    void checkDaemonStatus();
    
    // Process error handling
    void handleProcessError(QProcess::ProcessError error);
    
    // Parse the process output for status updates
    void parseProcessOutput();
    
    static I2PDaemonManager* m_instance;
    static QMutex m_mutex;
    
    QProcess m_process;
    QTemporaryDir m_tempDir;
    QString m_executablePath;
    QString m_configPath;
    QString m_dataPath;
    QString m_logPath;
    QString m_optionsString;
    QMap<QString, QString> m_options;
    bool m_running;
    QString m_status;
    
    QString m_address;
    int m_port;
    int m_tunnelLength;
    
    QString m_configDir;
    QString m_dataDir;
    
    // Prevent copying
    I2PDaemonManager(const I2PDaemonManager&) = delete;
    I2PDaemonManager& operator=(const I2PDaemonManager&) = delete;
};

#endif // I2PDAEMONMANAGER_H 