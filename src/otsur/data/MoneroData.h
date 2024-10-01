#ifndef MONERO_DATA_H
#define MONERO_DATA_H

#include <QObject>
#include "MoneroTxData.h"
#include "MoneroWalletData.h"

#define URI_TX_SCHEME "monero"
#define URI_TX_PARAM_PAYMENT_ID "tx_payment_id"
#define URI_TX_PARAM_RECIPIENT_NAME "recipient_name"
#define URI_TX_PARAM_TX_AMOUNT "tx_amount"
#define URI_TX_PARAM_TX_DESCRIPTION "tx_description"

#define URI_WALLET_CURRENT_BAD_SCHEME "monero_wallet"
#define URI_WALLET_CORRECT_SCHEME "monero-wallet"
#define URI_WALLET_PARAM_SPEND_KEY "spend_key"
#define URI_WALLET_PARAM_VIEW_KEY "view_key"
#define URI_WALLET_PARAM_MNEMONIC_SEED "mnemonic_seed"
#define URI_WALLET_PARAM_HEIGHT "height"

#define JSON_WALLET_ADDRESS "primaryAddress"
#define JSON_WALLET_SPEND_KEY "privateSpendKey"
#define JSON_WALLET_VIEW_KEY "privateViewKey"
#define JSON_WALLET_HEIGHT "restoreHeight"

class MoneroData : public QObject {
    Q_OBJECT

public:
    MoneroData(QObject *parent = nullptr);
    ~MoneroData();
    Q_INVOKABLE static MoneroTxData* parseTxData(const QString &data);
    Q_INVOKABLE static MoneroWalletData* parseWalletData(const QString &data, bool fallbackToJson = true);
    Q_INVOKABLE static MoneroTxData* parseTxDataUri(const QString &uri);
    Q_INVOKABLE static MoneroWalletData* parseWalletDataUri(const QString &uri);
    Q_INVOKABLE static MoneroWalletData* parseWalletDataJson(const QString &json); // for ANONERO and feather
    Q_INVOKABLE static QString buildTxDataUri(MoneroTxData &data);
    Q_INVOKABLE static QString buildWalletDataUri(MoneroWalletData &data, bool correctedScheme = false);
    Q_INVOKABLE static QString buildWalletDataJson(MoneroWalletData &data); // for ANONERO and feather
};
#endif // MONERO_DATA_H
