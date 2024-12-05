#include <QMessageBox>
#include <QPixmap>
#include <QTranslator>

#include "TailsOS.h"
#include "utils.h"

bool TailsOS::usePersistence = false;
QString TailsOS::tailsPathData = QString("/live/persistence/TailsData_unlocked/");

bool TailsOS::detect()
{
    if (!fileExists("/etc/os-release"))
        return false;

    QByteArray data = fileOpen("/etc/os-release");
    QRegularExpression re("NAME=\"Tails\"");
    QRegularExpressionMatch os_match = re.match(data);
    bool matched = os_match.hasMatch();

#ifdef QT_DEBUG
    if (matched)
        qDebug() << "Tails OS detected";
#endif

    return matched;
}

bool TailsOS::detectDataPersistence()
{
    return QDir(QDir::homePath() + "/Persistent").exists();
}

bool TailsOS::detectDotPersistence()
{
    return QDir(tailsPathData + "dotfiles").exists();
}

void TailsOS::showDataPersistenceDisabledWarning()
{
    QMessageBox msgBox;
    msgBox.setText(QObject::tr("Warning: persistence disabled"));
    msgBox.setWindowTitle(QObject::tr("Warning: persistence disabled"));
    msgBox.setInformativeText(
        QObject::tr("Monero GUI has detected that Tails persistence is "
                     "currently disabled. Any configurations you make inside "
                     "the Monero GUI will not be saved."
                     "\n\n"
                     "In addition, make sure to not save your wallet on the "
                     "filesystem, as it will be lost at shutdown."
                     "\n\n"
                     "To enable Tails persistence, setup an encrypted volume "
                     "and restart Tails. To gain a startup menu item, "
                     "enable the Tails \"dotfiles\" feature."));

    msgBox.setStandardButtons(QMessageBox::Ok);
    msgBox.setDefaultButton(QMessageBox::Ok);
    msgBox.setIconPixmap(QPixmap(":/images/tails-grey.png"));
    msgBox.exec();
}

void TailsOS::askPersistence()
{
    QMessageBox msgBox;
    msgBox.setWindowTitle(QObject::tr("Monero GUI"));
    msgBox.setText(QObject::tr("Use Tails persistence?"));
    msgBox.setInformativeText(
        QObject::tr("Persist wallet files and configuration on the encrypted volume?"
                    "\n\n"
                    "In addition, you can enable Tails dotfiles persistence "
                    "to gain a start menu entry.\n"));

    msgBox.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    msgBox.setDefaultButton(QMessageBox::Yes);
    msgBox.setIconPixmap(QPixmap(":/images/tails-grey.png"));
    TailsOS::usePersistence = (msgBox.exec() == QMessageBox::Yes);
}

void TailsOS::persistXdgMime(QString filePath, QString data)
{
    QFileInfo file(filePath);
    QString tailsPath = tailsPathData + "dotfiles/.local/share/applications/";

    // write to persistent volume
#ifdef QT_DEBUG
    qDebug() << "Writing xdg mime: " << tailsPath + file.fileName();
#endif

    QDir().mkpath(tailsPath);  // ensure directory exists
    fileWrite(tailsPath + file.fileName(), data);

    // write to current session
#ifdef QT_DEBUG
    qDebug() << "Writing xdg mime: " << file.filePath();
#endif

    QDir().mkpath(file.path());  // ensure directory exists
    fileWrite(file.filePath(), data);
}
