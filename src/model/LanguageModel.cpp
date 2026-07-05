// Copyright (c) 2026, The Monero Project
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

#include "LanguageModel.h"

#include <QFile>
#include <QXmlStreamReader>

LanguageModel::LanguageModel(QObject *parent)
    : QAbstractListModel(parent)
{
    QFile file(QStringLiteral(":/lang/languages.xml"));
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning("Could not open the embedded language list: %s", qPrintable(file.errorString()));
        return;
    }

    QXmlStreamReader xml(&file);
    if (!xml.readNextStartElement()) {
        if (xml.hasError())
            qWarning("Could not parse the embedded language list: %s", qPrintable(xml.errorString()));
        else
            qWarning("The embedded language list is empty");
        return;
    }
    if (xml.name() != QStringLiteral("languages")) {
        qWarning("Could not parse the embedded language list: root element must be <languages>");
        return;
    }

    QVector<Language> languages;
    while (xml.readNextStartElement()) {
        if (xml.name() != QStringLiteral("language")) {
            xml.skipCurrentElement();
            continue;
        }

        const auto attributes = xml.attributes();
        Language language{
            attributes.value(QStringLiteral("display_name")).toString(),
            attributes.value(QStringLiteral("locale")).toString(),
            attributes.value(QStringLiteral("wallet_language")).toString(),
            attributes.value(QStringLiteral("flag")).toString()
        };
        if (language.displayName.isEmpty() || language.locale.isEmpty()
                || language.walletLanguage.isEmpty() || language.flag.isEmpty()) {
            qWarning("Ignoring incomplete language entry at line %lld",
                     static_cast<long long>(xml.lineNumber()));
        } else {
            languages.append(language);
        }
        xml.skipCurrentElement();
    }

    if (xml.hasError()) {
        qWarning("Could not parse the embedded language list: %s", qPrintable(xml.errorString()));
        return;
    }
    if (languages.isEmpty())
        qWarning("The embedded language list contains no languages");
    m_languages.swap(languages);
}

int LanguageModel::count() const
{
    return m_languages.size();
}

int LanguageModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_languages.size();
}

QVariant LanguageModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_languages.size())
        return {};

    const auto &language = m_languages.at(index.row());
    switch (role) {
    case DisplayNameRole: return language.displayName;
    case LocaleRole: return language.locale;
    case WalletLanguageRole: return language.walletLanguage;
    case FlagRole: return language.flag;
    default: return {};
    }
}

QHash<int, QByteArray> LanguageModel::roleNames() const
{
    return {
        {DisplayNameRole, "display_name"},
        {LocaleRole, "locale"},
        {WalletLanguageRole, "wallet_language"},
        {FlagRole, "flag"}
    };
}

QVariantMap LanguageModel::get(int row) const
{
    QVariantMap result;
    if (row < 0 || row >= m_languages.size())
        return result;

    const auto roles = roleNames();
    for (auto it = roles.cbegin(); it != roles.cend(); ++it)
        result.insert(QString::fromUtf8(it.value()), data(index(row), it.key()));
    return result;
}
