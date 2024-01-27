// Copyright (c) 2014-2024, The Monero Project
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

#include "TranslationManager.h"

#include <QApplication>
#include <QTranslator>
#include <QDir>
#include <QDebug>
#include <QFileInfo>


TranslationManager * TranslationManager::m_instance = nullptr;


TranslationManager::TranslationManager(QObject *parent) : QObject(parent)
{
    m_translator = new QTranslator(this);
}

bool TranslationManager::setLanguage(const QString &language)
{
    qDebug() << __FUNCTION__ << " " << language;
    // if language is "en", remove translator
    if (language.toLower() == "en") {
        qApp->removeTranslator(m_translator);
        emit languageChanged();
        return true;
    }

    QString dir = qApp->applicationDirPath() + "/translations";
    QString filename = "monero-core_" + language;

    qDebug("%s: loading translation file '%s' from '%s'",
           __FUNCTION__, qPrintable(filename), qPrintable(dir));

    if (m_translator->load(filename, dir)) {
        qDebug("%s: translation for language '%s' loaded successfully",
               __FUNCTION__, qPrintable(language));
        // TODO: apply locale?
        qApp->installTranslator(m_translator);
        emit languageChanged();
        return true;
    }

    qDebug("%s: couldn't load translation file '%s' from '%s'",
           __FUNCTION__, qPrintable(filename), qPrintable(dir));
    qDebug("%s: loading embedded translation file '%s'",
           __FUNCTION__, qPrintable(filename));

    if (m_translator->load(filename, ":")) {
        qDebug("%s: embedded translation for language '%s' loaded successfully",
               __FUNCTION__, qPrintable(language));
        qApp->installTranslator(m_translator);
        emit languageChanged();
        return true;
    }

    qCritical("%s: error loading translation for language '%s'",
              __FUNCTION__, qPrintable(language));
    return false;
}

TranslationManager *TranslationManager::instance()
{
    if (!m_instance) {
        m_instance = new TranslationManager();
    }
    return m_instance;
}

QString TranslationManager::emptyString()
{
    return "";
}

