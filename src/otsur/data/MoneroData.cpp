#include "MoneroData.h"
#include <QUrl>
#include <QUrlQuery>
#include <QJsonObject>
#include <QJsonDocument>

MoneroData::MoneroData(QObject *parent) : QObject(parent) {}

MoneroData::~MoneroData() {}

MoneroTxData *MoneroData::parseTxData(const QString &data)
{
    return parseTxDataUri(data);
}

MoneroWalletData *MoneroData::parseWalletData(const QString &data, bool fallbackToJson)
{
    MoneroWalletData* out = parseWalletDataUri(data);
    if(out == nullptr && fallbackToJson)
        out = parseWalletDataJson(data);
    return out;
}

MoneroTxData* MoneroData::parseTxDataUri(const QString &uri) {
    QUrl url(uri);
    if (url.scheme()!= "monero")
        return nullptr; // invalid scheme
    MoneroTxData* data = new MoneroTxData();
    data->setAddress(url.path());
    QUrlQuery query(url.query());
    data->setTxPaymentId(query.queryItemValue(URI_TX_PARAM_PAYMENT_ID));
    data->setRecipientName(query.queryItemValue(URI_TX_PARAM_RECIPIENT_NAME));
    data->setTxAmount(query.queryItemValue(URI_TX_PARAM_TX_AMOUNT));
    data->setTxDescription(query.queryItemValue(URI_TX_PARAM_TX_DESCRIPTION));
    return data;
}

MoneroWalletData* MoneroData::parseWalletDataUri(const QString &uri) {
    QUrl url(uri.trimmed().replace(URI_WALLET_CURRENT_BAD_SCHEME, URI_WALLET_CORRECT_SCHEME)); // fix broken monero_wallet scheme, us trimmed to get a non-const QString for replace. Even if it get's corrected it would need to stay for backward compability.
    if (url.scheme()!= URI_WALLET_CORRECT_SCHEME)
        return nullptr; // invalid scheme
    MoneroWalletData* data = new MoneroWalletData();
    data->setAddress(url.path());
    QUrlQuery query(url.query());
    data->setSpendKey(query.queryItemValue(URI_WALLET_PARAM_SPEND_KEY));
    data->setViewKey(query.queryItemValue(URI_WALLET_PARAM_VIEW_KEY));
    data->setMnemonicSeed(query.queryItemValue(URI_WALLET_PARAM_MNEMONIC_SEED));
    data->setHeight(query.queryItemValue(URI_WALLET_PARAM_HEIGHT).toInt());
    return data;
}

QString MoneroData::buildTxDataUri(MoneroTxData &data) {
    QUrl url;
    url.setScheme(URI_TX_SCHEME);
    url.setPath(data.address());
    QUrlQuery query;
    if (!data.txPaymentId().isEmpty())
        query.addQueryItem(URI_TX_PARAM_PAYMENT_ID, data.txPaymentId());
    if (!data.recipientName().isEmpty())
        query.addQueryItem(URI_TX_PARAM_RECIPIENT_NAME, data.recipientName());
    if (!data.txAmount().isEmpty())
        query.addQueryItem(URI_TX_PARAM_TX_AMOUNT, data.txAmount());
    if (!data.txDescription().isEmpty())
        query.addQueryItem(URI_TX_PARAM_TX_DESCRIPTION, data.txDescription());
    url.setQuery(query);
    return url.toString();
}

QString MoneroData::buildWalletDataUri(MoneroWalletData &data, bool correctedScheme) {
    QUrl url;
    url.setScheme(correctedScheme?URI_WALLET_CORRECT_SCHEME:URI_WALLET_CURRENT_BAD_SCHEME);
    url.setPath(data.address());
    QUrlQuery query;
    if (!data.spendKey().isEmpty())
        query.addQueryItem(URI_WALLET_PARAM_SPEND_KEY, data.spendKey());
    if (!data.viewKey().isEmpty())
        query.addQueryItem(URI_WALLET_PARAM_VIEW_KEY, data.viewKey());
    if (!data.mnemonicSeed().isEmpty())
        query.addQueryItem(URI_WALLET_PARAM_MNEMONIC_SEED, data.mnemonicSeed());
    if (data.height()!= 0)
        query.addQueryItem(URI_WALLET_PARAM_HEIGHT, QString::number(data.height()));
    url.setQuery(query);
    return url.toString();
}

MoneroWalletData* MoneroData::parseWalletDataJson(const QString &json) {
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
    if (doc.isNull() || !doc.isObject())
        return nullptr; // invalid JSON
    QJsonObject obj = doc.object();
    MoneroWalletData* data = new MoneroWalletData();
    data->setAddress(obj[JSON_WALLET_ADDRESS].toString());
    data->setSpendKey(obj[JSON_WALLET_SPEND_KEY].toString());
    data->setViewKey(obj[JSON_WALLET_VIEW_KEY].toString());
    data->setHeight(obj[JSON_WALLET_HEIGHT].toInt());
    return data;
}

QString MoneroData::buildWalletDataJson(MoneroWalletData &data) {
    QJsonObject obj;
    obj[JSON_WALLET_ADDRESS] = data.address();
    if (!data.spendKey().isEmpty())
        obj[JSON_WALLET_SPEND_KEY] = data.spendKey();
    if (!data.viewKey().isEmpty())
        obj[JSON_WALLET_VIEW_KEY] = data.viewKey();
    if (data.height() != 0)
        obj[JSON_WALLET_HEIGHT] = data.height();
    QJsonDocument doc(obj);
    return QString(doc.toJson(QJsonDocument::Compact));
}
