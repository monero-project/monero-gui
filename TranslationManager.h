#ifndef TRANSLATIONMANAGER_H
#define TRANSLATIONMANAGER_H

#include <QObject>

class QTranslator;
class TranslationManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString emptyString READ emptyString  NOTIFY languageChanged)
public:
    Q_INVOKABLE bool setLanguage(const QString &language);
    static TranslationManager *instance();

    QString emptyString();

signals:
    void languageChanged();

private:
    explicit TranslationManager(QObject *parent = 0);

private:
    static TranslationManager * m_instance;
    QTranslator * m_translator;

};

#endif // TRANSLATIONMANAGER_H
