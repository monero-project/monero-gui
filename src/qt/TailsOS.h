#ifndef TAILSOS_H
#define TAILSOS_H

#include <QApplication>


class TailsOS
{
public:
    TailsOS();
    static bool detect();
    static bool detectDataPersistence();
    static bool detectDotPersistence();

    static void showDataPersistenceDisabledWarning();
    static void askPersistence();
    static void persistXdgMime(QString filePath, QString data);

    static bool usePersistence;
    static QString tailsPathData;
};

#endif // TAILSOS_H
