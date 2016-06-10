#include "oshelper.h"
#include <QTemporaryFile>
#include <QDir>

OSHelper::OSHelper(QObject *parent) : QObject(parent)
{

}

QString OSHelper::temporaryFilename() const
{
    QString tempFileName;
    {
        QTemporaryFile f;
        f.open();
        tempFileName = f.fileName();
    }
    return tempFileName;
}

QString OSHelper::temporaryPath() const
{
    return QDir::tempPath();
}
