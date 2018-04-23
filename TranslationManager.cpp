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

