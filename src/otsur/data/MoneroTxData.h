#ifndef MONEROTXDATA_H
#define MONEROTXDATA_H

#include <QObject>

class MoneroTxData : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString address READ address WRITE setAddress FINAL)
    Q_PROPERTY(QString txPaymentId READ txPaymentId WRITE setTxPaymentId FINAL)
    Q_PROPERTY(QString recipientName READ recipientName WRITE setRecipientName FINAL)
    Q_PROPERTY(QString txAmount READ txAmount WRITE setTxAmount FINAL)
    Q_PROPERTY(QString txDescription READ txDescription WRITE setTxDescription FINAL)
    Q_PROPERTY(bool isValid READ isValid CONSTANT FINAL)

public:
    MoneroTxData(
        const QString &address = "",
        const QString &tx_payment_id = "",
        const QString &recipient_name = "",
        const QString &tx_amount = "",
        const QString &tx_description = ""
        ) : m_address(address)
        , m_tx_payment_id(tx_payment_id)
        , m_recipient_name(recipient_name)
        , m_tx_amount(tx_amount)
        , m_tx_description(tx_description)
    {}

    QString address() { return m_address; }
    void setAddress(const QString value) { m_address = value; }
    QString txPaymentId() { return m_tx_payment_id; }
    void setTxPaymentId(const QString value) { m_tx_payment_id = value; }
    QString recipientName() { return m_recipient_name; }
    void setRecipientName(const QString value) { m_recipient_name = value; }
    QString txAmount() { return m_tx_amount; }
    void setTxAmount(const QString value) { m_tx_amount = value; }
    QString txDescription() { return m_tx_description; }
    void setTxDescription(const QString value) { m_tx_description = value; }
    bool isValid() { return !m_address.isEmpty(); }

protected:
    QString m_address;
    QString m_tx_payment_id;
    QString m_recipient_name;
    QString m_tx_amount;
    QString m_tx_description;
};

#endif // MONEROTXDATA_H
