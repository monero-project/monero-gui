#include "systemtray.h"
#include <QDebug>

namespace {
    static const QString title = "Monero GUI";
}


SystemTray::SystemTray(QObject *parent) : QObject(parent)
{
    m_trayIcon = new QSystemTrayIcon;
    m_trayMenu = new QMenu;

    // actions for switching pages
    m_pageTransfer = new QAction(tr("Transfer"), m_trayIcon);
    m_pageReceive = new QAction(tr("Receive"), m_trayIcon);
    m_pageHistory = new QAction(tr("History"), m_trayIcon);
    m_pageSettings = new QAction(tr("Settings"), m_trayIcon);

    // misc actions
    m_actionHide = new QAction(tr("Hide window"), m_trayIcon);
    m_actionShow = new QAction(tr("Show window"), m_trayIcon);
    m_actionClose = new QAction(tr("Close") + " " + title, m_trayIcon);

    // add actions to menu
    m_trayMenu->addAction(m_pageTransfer);
    m_trayMenu->addAction(m_pageReceive);
    m_trayMenu->addAction(m_pageHistory);
    m_trayMenu->addAction(m_pageSettings);
    m_trayMenu->addSeparator();
    m_trayMenu->addAction(m_actionHide);
    m_trayMenu->addAction(m_actionClose);

    // set m_trayMenu as contextual menu of m_trayIcon
    m_trayIcon->setContextMenu(m_trayMenu);

    // set icon for m_trayIcon
    m_trayIcon->setIcon(QIcon(":/images/moneroIcon-28x28.png"));

    /* Connect systray with qml application */
    connect(m_actionHide, &QAction::triggered, [&](){
        showAppWindow(false);
    });

    connect(m_actionShow, &QAction::triggered, [&](){
        showAppWindow(true);
    });

    connect(m_actionClose, &QAction::triggered, [&](){
        emit signalClose();
    });

    connect(m_pageTransfer, &QAction::triggered, [&](){
        emit signalPageRequested("Transfer");
    });

    connect(m_pageReceive, &QAction::triggered, [&](){
        emit signalPageRequested("Receive");
    });

    connect(m_pageHistory, &QAction::triggered, [&](){
        emit signalPageRequested("History");
    });

    connect(m_pageSettings, &QAction::triggered, [&](){
        emit signalPageRequested("Settings");
    });
 }

SystemTray::~SystemTray()
 {
     // QObject without parent.
     delete m_trayIcon;
     delete m_trayMenu;
 }

void SystemTray::toggleIcon(const bool visible)
{
    // slot to toggle systray icon features from qml.
    m_trayIcon->setVisible(visible);
}

void SystemTray::disableActionHide(const bool hidden)
{
    // slot to toggle hide action
    m_actionHide->setDisabled(hidden);
}

void SystemTray::showNotification(const QString message)
{
    // slot to show notifications
    m_trayIcon->showMessage(title, message, QSystemTrayIcon::Information);
}

void SystemTray::showAppWindow(const bool visible)
{
    showActionHide(visible);
    emit signalToggle();
}

void SystemTray::showActionHide(const bool hidden)
{
    if (hidden) {
        m_trayMenu->removeAction(m_actionHide);
        m_trayMenu->removeAction(m_actionClose);
        m_trayMenu->addAction(m_actionShow);
        m_trayMenu->addAction(m_actionClose);
    } else {
        m_trayMenu->removeAction(m_actionShow);
        m_trayMenu->removeAction(m_actionClose);
        m_trayMenu->addAction(m_actionHide);
        m_trayMenu->addAction(m_actionClose);
    }
}


