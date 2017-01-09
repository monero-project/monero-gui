#include "oshelper.h"
#include <QTemporaryFile>
#include <QDir>
#include <QDebug>
#include <QString>

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

bool OSHelper::removeTemporaryWallet(const QString &fileName) const
{
    // Temporary files should be deleted automatically by default, in case they wouldn't, we delete them manually as well
    bool cache_deleted = QFile::remove(fileName);
    bool address_deleted = QFile::remove(fileName + ".address.txt");
    bool keys_deleted = QFile::remove(fileName +".keys");

    return cache_deleted && address_deleted && keys_deleted;
}

QString OSHelper::temporaryPath() const
{
    return QDir::tempPath();
}
