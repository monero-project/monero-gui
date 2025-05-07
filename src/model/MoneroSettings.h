#ifndef MONERO_SETTINGS_H
#define MONERO_SETTINGS_H

#include <QObject>
#include <QSettings>

class MoneroSettings : public QObject
{
    Q_OBJECT
    
    // I2P properties
    Q_PROPERTY(bool useI2P READ useI2P WRITE setUseI2P NOTIFY useI2PChanged)
    Q_PROPERTY(bool useBuiltInI2P READ useBuiltInI2P WRITE setUseBuiltInI2P NOTIFY useBuiltInI2PChanged)
    Q_PROPERTY(QString i2pAddress READ i2pAddress WRITE setI2pAddress NOTIFY i2pAddressChanged)
    Q_PROPERTY(int i2pPort READ i2pPort WRITE setI2pPort NOTIFY i2pPortChanged)
    Q_PROPERTY(bool i2pMixedMode READ i2pMixedMode WRITE setI2pMixedMode NOTIFY i2pMixedModeChanged)
    Q_PROPERTY(int i2pTunnelLength READ i2pTunnelLength WRITE setI2pTunnelLength NOTIFY i2pTunnelLengthChanged)

public:
    explicit MoneroSettings(QObject *parent = nullptr);
    ~MoneroSettings() override;

    static MoneroSettings* instance();

    // I2P getters
    bool useI2P() const;
    bool useBuiltInI2P() const;
    QString i2pAddress() const;
    int i2pPort() const;
    bool i2pMixedMode() const;
    int i2pTunnelLength() const;

    // I2P setters
    void setUseI2P(bool useI2P);
    void setUseBuiltInI2P(bool useBuiltInI2P);
    void setI2pAddress(const QString &address);
    void setI2pPort(int port);
    void setI2pMixedMode(bool mixedMode);
    void setI2pTunnelLength(int length);

signals:
    // I2P signals
    void useI2PChanged();
    void useBuiltInI2PChanged();
    void i2pAddressChanged();
    void i2pPortChanged();
    void i2pMixedModeChanged();
    void i2pTunnelLengthChanged();

private:
    QSettings m_settings;
    
    // I2P settings
    bool m_useI2P;
    bool m_useBuiltInI2P;
    QString m_i2pAddress;
    int m_i2pPort;
    bool m_i2pMixedMode;
    int m_i2pTunnelLength;
};

#endif // MONERO_SETTINGS_H 