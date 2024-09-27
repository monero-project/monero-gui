#ifndef MONEROWALLETDATA_H
#define MONEROWALLETDATA_H

#include <QObject>

class MoneroWalletData : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString address READ address WRITE setAddress FINAL)
    Q_PROPERTY(QString spendKey READ spendKey WRITE setSpendKey FINAL)
    Q_PROPERTY(QString viewKey READ viewKey WRITE setViewKey FINAL)
    Q_PROPERTY(QString mnemonicSeed READ mnemonicSeed WRITE setMnemonicSeed FINAL)
    Q_PROPERTY(int height READ height WRITE setHeight FINAL)
    Q_PROPERTY(bool isWallet READ isWallet CONSTANT FINAL)
    Q_PROPERTY(bool isViewOnly READ isViewOnly CONSTANT FINAL)
    Q_PROPERTY(bool isSeed READ isSeed CONSTANT FINAL)
    Q_PROPERTY(bool isValid READ isValid CONSTANT FINAL)

public:
    MoneroWalletData(
        const QString &address = "",
        const QString &spend_key = "",
        const QString &view_key = "",
        const QString &mnemonic_seed = "",
        int height = 0
        ) : m_address(address)
        , m_spend_key(spend_key)
        , m_view_key(view_key)
        , m_mnemonic_seed(mnemonic_seed)
        , m_height(height)
    {}

    QString address() { return m_address; }
    void setAddress(const QString value) { m_address = value; }

    QString spendKey() { return m_spend_key; }
    void setSpendKey(const QString value) { m_spend_key = value; }

    QString viewKey() { return m_view_key; }
    void setViewKey(const QString value) { m_view_key = value; }

    QString mnemonicSeed() { return m_mnemonic_seed; }
    void setMnemonicSeed(const QString value) { m_mnemonic_seed = value; }

    int height() { return m_height; }
    void setHeight(int value) { m_height = value; }

    bool isWallet() { return !m_address.isEmpty() && !m_spend_key.isEmpty() && !m_view_key.isEmpty(); }
    bool isViewOnly() { return m_spend_key.isEmpty() && !m_view_key.isEmpty() && !m_address.isEmpty(); }
    bool isSeed() { return !m_mnemonic_seed.isEmpty() && m_spend_key.isEmpty() && m_view_key.isEmpty(); }
    bool isValid() { return isWallet() || isViewOnly() || isSeed(); }
    Q_INVOKABLE QStringList seedWords() { return m_mnemonic_seed.split(" "); }

protected:
    QString m_address;
    QString m_spend_key;
    QString m_view_key;
    QString m_mnemonic_seed;
    int m_height;
};

#endif // MONEROWALLETDATA_H
