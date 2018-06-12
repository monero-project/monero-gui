#ifndef SYSTEMTRAY_H
#define SYSTEMTRAY_H

#include <QObject>
#include <QSystemTrayIcon>
#include <QMenu>

class SystemTray : public QObject
{
    Q_OBJECT

public:
    explicit SystemTray(QObject *parent = nullptr);
    ~SystemTray();

public slots:
    void toggleIcon(const bool visible);
    void disableActionHide(const bool hidden);
    void showNotification(const QString message);
    void showActionHide(const bool hidden);

signals:
    void signalPageRequested(QString page) const;
    void signalToggle() const;
    void signalClose() const;

private slots:
    void showAppWindow(const bool visible);

private:
    QSystemTrayIcon *m_trayIcon;
    QAction *m_pageTransfer;
    QAction *m_pageReceive;
    QAction *m_pageHistory;
    QAction *m_pageSettings;
    QAction *m_actionHide;
    QAction *m_actionShow;
    QAction *m_actionClose;
    QMenu *m_trayMenu;
};

#endif // SYSTEMTRAY_H
