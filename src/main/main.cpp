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

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QStandardPaths>
#include <QIcon>
#include <QDebug>
#include <QDesktopServices>
#include <QObject>
#include <QDesktopWidget>
#include <QScreen>
#include <QThread>

#include <version.h>

#include "clipboardAdapter.h"
#include "filter.h"
#include "oscursor.h"
#include "oshelper.h"
#include "WalletManager.h"
#include "Wallet.h"
#include "QRCodeImageProvider.h"
#include "PendingTransaction.h"
#include "UnsignedTransaction.h"
#include "TranslationManager.h"
#include "TransactionInfo.h"
#include "TransactionHistory.h"
#include "model/TransactionHistoryModel.h"
#include "model/TransactionHistorySortFilterModel.h"
#include "AddressBook.h"
#include "model/AddressBookModel.h"
#include "Subaddress.h"
#include "model/SubaddressModel.h"
#include "SubaddressAccount.h"
#include "model/SubaddressAccountModel.h"
#include "Logger.h"
#include "MainApp.h"
#include "qt/downloader.h"
#include "qt/ipc.h"
#include "qt/network.h"
#include "qt/updater.h"
#include "qt/utils.h"
#include "qt/TailsOS.h"
#include "qt/KeysFiles.h"
#include "qt/MoneroSettings.h"
#include "qt/NetworkAccessBlockingFactory.h"
#ifdef Q_OS_MAC
#include "qt/macoshelper.h"
#endif

// IOS exclusions
#ifndef Q_OS_IOS
#include "daemon/DaemonManager.h"
#include "p2pool/P2PoolManager.h"
#endif

#if defined(Q_OS_WIN)
#include <QOpenGLContext>
#elif defined(Q_OS_MACOS)
#include "qt/macoshelper.h"
#endif

#ifdef WITH_SCANNER
#include "QR-Code-scanner/QrCodeScanner.h"
#endif

#ifdef MONERO_GUI_STATIC

#include <QtPlugin>
#if defined(Q_OS_OSX)
  Q_IMPORT_PLUGIN(QCocoaIntegrationPlugin);
#elif defined(Q_OS_WIN)
  Q_IMPORT_PLUGIN(QWindowsIntegrationPlugin);
#elif defined(Q_OS_LINUX)
  Q_IMPORT_PLUGIN(QXcbIntegrationPlugin);
  Q_IMPORT_PLUGIN(QXcbGlxIntegrationPlugin);
#endif
Q_IMPORT_PLUGIN(QSvgIconPlugin)
Q_IMPORT_PLUGIN(QICNSPlugin)
Q_IMPORT_PLUGIN(QICOPlugin)
Q_IMPORT_PLUGIN(QJpegPlugin)
Q_IMPORT_PLUGIN(QSvgPlugin)
Q_IMPORT_PLUGIN(QTgaPlugin)
Q_IMPORT_PLUGIN(QTiffPlugin)
Q_IMPORT_PLUGIN(QWbmpPlugin)
Q_IMPORT_PLUGIN(QWebpPlugin)
Q_IMPORT_PLUGIN(QQmlDebuggerServiceFactory)
Q_IMPORT_PLUGIN(QQmlInspectorServiceFactory)
Q_IMPORT_PLUGIN(QLocalClientConnectionFactory)
Q_IMPORT_PLUGIN(QDebugMessageServiceFactory)
Q_IMPORT_PLUGIN(QQmlNativeDebugConnectorFactory)
Q_IMPORT_PLUGIN(QQmlNativeDebugServiceFactory)
Q_IMPORT_PLUGIN(QQmlProfilerServiceFactory)
Q_IMPORT_PLUGIN(QQuickProfilerAdapterFactory)
Q_IMPORT_PLUGIN(QQmlDebugServerFactory)
Q_IMPORT_PLUGIN(QTcpServerConnectionFactory)
Q_IMPORT_PLUGIN(QGenericEnginePlugin)

#if QT_VERSION >= QT_VERSION_CHECK(5, 14, 0)
Q_IMPORT_PLUGIN(QtQmlPlugin)
#endif
Q_IMPORT_PLUGIN(QtQmlModelsPlugin)
Q_IMPORT_PLUGIN(QtQuick2Plugin)
Q_IMPORT_PLUGIN(QtQuickLayoutsPlugin)
Q_IMPORT_PLUGIN(QtGraphicalEffectsPlugin)
Q_IMPORT_PLUGIN(QtGraphicalEffectsPrivatePlugin)
Q_IMPORT_PLUGIN(QtQuick2WindowPlugin)
Q_IMPORT_PLUGIN(QtQuickControls1Plugin)
Q_IMPORT_PLUGIN(QtQuick2DialogsPlugin)
Q_IMPORT_PLUGIN(QmlFolderListModelPlugin)
Q_IMPORT_PLUGIN(QmlSettingsPlugin)
Q_IMPORT_PLUGIN(QtLabsPlatformPlugin)
Q_IMPORT_PLUGIN(QtQuick2DialogsPrivatePlugin)
Q_IMPORT_PLUGIN(QtQuick2PrivateWidgetsPlugin)
Q_IMPORT_PLUGIN(QtQuickControls2Plugin)
Q_IMPORT_PLUGIN(QtQuickTemplates2Plugin)
Q_IMPORT_PLUGIN(QmlXmlListModelPlugin)
#ifdef WITH_SCANNER
Q_IMPORT_PLUGIN(QMultimediaDeclarativeModule)
#endif

#endif

bool isIOS = false;
bool isAndroid = false;
bool isWindows = false;
bool isMac = false;
bool isLinux = false;
bool isTails = false;
bool isDesktop = false;
bool isOpenGL = true;
bool isARM = false;

int main(int argc, char *argv[])
{
    Q_INIT_RESOURCE(translations);

    // platform dependant settings
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    bool isDesktop = true;
#elif defined(Q_OS_ANDROID)
    bool isAndroid = true;
#elif defined(Q_OS_IOS)
    bool isIOS = true;
#endif
#ifdef Q_OS_WIN
    bool isWindows = true;
#elif defined(Q_OS_LINUX)
    bool isLinux = true;
    bool isTails = TailsOS::detect();
#elif defined(Q_OS_MAC)
    bool isMac = true;
#endif
#if defined(__aarch64__)
    bool isARM = true;
#endif

    // detect low graphics mode (start-low-graphics-mode.bat)
    if(qgetenv("QMLSCENE_DEVICE") == "softwarecontext")
        isOpenGL = false;

#ifdef Q_OS_MAC
    // macOS window tabbing is not supported
    MacOSHelper::disableWindowTabbing();
#endif
    // disable "QApplication: invalid style override passed" warning
    if (isDesktop) qputenv("QT_STYLE_OVERRIDE", "fusion");
#ifdef Q_OS_LINUX
    // platform xcb by default
    if (isDesktop && qEnvironmentVariableIsEmpty("QT_QPA_PLATFORM")) qputenv("QT_QPA_PLATFORM", "xcb");
#endif

    // enable High DPI scaling
    qputenv("QT_ENABLE_HIGHDPI_SCALING", "1");

    // Turn off colors in monerod log output.
    qputenv("TERM", "goaway");

#if defined(Q_OS_MACOS)
    QDir::setCurrent(QDir(MacOSHelper::bundlePath() + QDir::separator() + "..").canonicalPath());
#endif

    qputenv("QML_DISABLE_DISK_CACHE", "1");

    for (int i = 0; i < argc; i++) {
        if (QString(argv[i]).contains("platformpluginpath")) {
            qCritical() << "Setting -platformpluginpath as an argument is disabled"; // CVE-2021-3401
            return 1;
        }
    }

    MainApp app(argc, argv);

#if defined(Q_OS_WIN)
    if (isOpenGL)
    {
        QOpenGLContext ctx;
        isOpenGL = ctx.create() && ctx.format().version() >= qMakePair(2, 1);
        if (!isOpenGL) {
            qputenv("QMLSCENE_DEVICE", "softwarecontext");
        }
    }
#endif

    app.setApplicationName("monero-core");
    app.setOrganizationDomain("getmonero.org");
    app.setOrganizationName("monero-project");

    // Ask to enable Tails OS persistence mode, it affects:
    // - Log file location
    // - QML Settings file location (monero-core.conf)
    // - Default wallets path
    // Target directory is: ~/Persistent/Monero
    if (isTails) {
        if (!TailsOS::detectDataPersistence())
            TailsOS::showDataPersistenceDisabledWarning();
        else
            TailsOS::askPersistence();
    }

    QString moneroAccountsDir;
    #if defined(Q_OS_WIN) || defined(Q_OS_IOS)
        QStringList moneroAccountsRootDir = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
    #else
        QStringList moneroAccountsRootDir = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);
    #endif

    if(isTails && TailsOS::usePersistence){
        moneroAccountsDir = QDir::homePath() + "/Persistent/Monero/wallets";
    } else if (!moneroAccountsRootDir.empty()) {
        moneroAccountsDir = moneroAccountsRootDir.at(0) + "/Monero/wallets";
    } else {
        qCritical() << "Error: accounts root directory could not be set";
        return 1;
    }
    moneroAccountsDir = QDir::toNativeSeparators(moneroAccountsDir);

#if defined(Q_OS_LINUX)
    if (isDesktop) app.setWindowIcon(QIcon(":/images/appicon.ico"));
#endif

    filter *eventFilter = new filter;
    app.installEventFilter(eventFilter);

    QCommandLineParser parser;
    QCommandLineOption logPathOption(QStringList() << "l" << "log-file",
        QCoreApplication::translate("main", "Log to specified file"),
        QCoreApplication::translate("main", "file"));

    QCommandLineOption verifyUpdateOption("verify-update", "\
Verify update binary using 'shasum'-compatible (SHA256 algo) output signed by two maintainers.\n\
* Requires 'hashes.txt' - signed 'shasum' output \
(i.e. 'gpg -o hashes.txt --clear-sign <shasum_output>') generated by a maintainer.\n\
* Requires 'hashes.txt.sig' - detached signature of 'hashes.txt' \
(i.e. 'gpg -b hashes.txt') generated by another maintainer.", "update-binary");
    parser.addOption(verifyUpdateOption);

    QCommandLineOption disableCheckUpdatesOption("disable-check-updates", "Disable automatic check for updates.");
    parser.addOption(disableCheckUpdatesOption);
    QCommandLineOption socksProxyOption("socks5-proxy", "Enable socks5 proxy. Used for remote node connection (advanced mode), updates downloading and fetching price sources.", "address:port");
    parser.addOption(socksProxyOption);
    QCommandLineOption testQmlOption("test-qml");
    testQmlOption.setFlags(QCommandLineOption::HiddenFromHelp);
    parser.addOption(logPathOption);
    parser.addOption(testQmlOption);
    parser.addHelpOption();
    parser.process(app);

    Monero::Utils::onStartup();

    Logger logger(app, parser.value(logPathOption));

    // loglevel is configured in main.qml. Anything lower than
    // qWarning is not shown here unless MONERO_LOG_LEVEL env var is set
    bool logLevelOk;
    int logLevel = qEnvironmentVariableIntValue("MONERO_LOG_LEVEL", &logLevelOk);
    if (logLevelOk && logLevel >= 0 && logLevel <= Monero::WalletManagerFactory::LogLevel_Max){
        Monero::WalletManagerFactory::setLogLevel(logLevel);
    }

    if (parser.isSet(verifyUpdateOption))
    {
        const QString updateBinaryFullPath = parser.value(verifyUpdateOption);
        const QFileInfo updateBinaryInfo(updateBinaryFullPath);
        const QString updateBinaryDir = QDir::toNativeSeparators(updateBinaryInfo.absolutePath()) + QDir::separator();
        const QString hashesTxt = updateBinaryDir + "hashes.txt";
        const QString hashesTxtSig = hashesTxt + ".sig";
        try
        {
            const QByteArray updateBinaryContents = fileGetContents(updateBinaryFullPath);
            const QPair<QString, QString> signers = Updater().verifySignaturesAndHashSum(
                fileGetContents(hashesTxt),
                fileGetContents(hashesTxtSig),
                updateBinaryInfo.fileName(),
                updateBinaryContents.data(),
                updateBinaryContents.size());
            qCritical() << "successfully verified, signed by" << signers.first << "and" << signers.second;
            return 0;
        }
        catch (const std::exception &e)
        {
            qCritical() << e.what();
        }
        return 1;
    }

    IPC *ipc = new IPC(&app);
    QStringList posArgs = parser.positionalArguments();

    for(int i = 0; i != posArgs.count(); i++){
        QString arg = QString(posArgs.at(i));
        if(arg.isEmpty() || arg.length() >= 512) continue;
        if(arg.contains(reURI)){
            if(!ipc->saveCommand(arg)){
                return 0;
            }
        }
    }

    // start listening
    QTimer::singleShot(0, ipc, SLOT(bind()));

    // screen settings
    // Mobile is designed on 128dpi
    qreal ref_dpi = 128;
    QSize screenAvailableSize = QGuiApplication::primaryScreen()->availableSize();
    QRect rect = QGuiApplication::primaryScreen()->geometry();
    qreal dpi = QGuiApplication::primaryScreen()->logicalDotsPerInch();
    qreal physicalDpi = QGuiApplication::primaryScreen()->physicalDotsPerInch();
    qreal calculated_ratio = physicalDpi/ref_dpi;

    QString GUI_VERSION = "-";
    QFile f(":/version.js");
    if(!f.open(QFile::ReadOnly)) {
        qWarning() << "Could not read qrc:///version.js";
    } else {
        QByteArray contents = f.readAll();
        f.close();

        QRegularExpression re("var GUI_VERSION = \"(.*)\"");
        QRegularExpressionMatch version_match = re.match(contents);
        if (version_match.hasMatch()) {
            GUI_VERSION = version_match.captured(1);  // "v0.13.0.3"
        }
    }

    qWarning().nospace().noquote() << "Qt:" << QT_VERSION_STR << " GUI:" << GUI_VERSION
                                   << " | screen: " << rect.width() << "x" << rect.height()
                                   << " - available: " << screenAvailableSize
                                   << " - dpi: " << dpi << " - ratio:" << calculated_ratio;

    // registering types for QML
    qmlRegisterType<clipboardAdapter>("moneroComponents.Clipboard", 1, 0, "Clipboard");
    qmlRegisterType<Downloader>("moneroComponents.Downloader", 1, 0, "Downloader");
    qmlRegisterType<Network>("moneroComponents.Network", 1, 0, "Network");
    qmlRegisterType<WalletKeysFilesModel>("moneroComponents.WalletKeysFilesModel", 1, 0, "WalletKeysFilesModel");
    qmlRegisterType<WalletManager>("moneroComponents.WalletManager", 1, 0, "WalletManager");

    // Temporary Qt.labs.settings replacement
    qmlRegisterType<MoneroSettings>("moneroComponents.Settings", 1, 0, "MoneroSettings");

    qmlRegisterUncreatableType<Wallet>("moneroComponents.Wallet", 1, 0, "Wallet", "Wallet can't be instantiated directly");


    qmlRegisterUncreatableType<PendingTransaction>("moneroComponents.PendingTransaction", 1, 0, "PendingTransaction",
                                                   "PendingTransaction can't be instantiated directly");

    qmlRegisterUncreatableType<UnsignedTransaction>("moneroComponents.UnsignedTransaction", 1, 0, "UnsignedTransaction",
                                                   "UnsignedTransaction can't be instantiated directly");

    qmlRegisterUncreatableType<TranslationManager>("moneroComponents.TranslationManager", 1, 0, "TranslationManager",
                                                   "TranslationManager can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistoryModel>("moneroComponents.TransactionHistoryModel", 1, 0, "TransactionHistoryModel",
                                                        "TransactionHistoryModel can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistorySortFilterModel>("moneroComponents.TransactionHistorySortFilterModel", 1, 0, "TransactionHistorySortFilterModel",
                                                        "TransactionHistorySortFilterModel can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistory>("moneroComponents.TransactionHistory", 1, 0, "TransactionHistory",
                                                        "TransactionHistory can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionInfo>("moneroComponents.TransactionInfo", 1, 0, "TransactionInfo",
                                                        "TransactionHistory can't be instantiated directly");
#ifndef Q_OS_IOS
    qmlRegisterUncreatableType<DaemonManager>("moneroComponents.DaemonManager", 1, 0, "DaemonManager",
                                                   "DaemonManager can't be instantiated directly");
    qmlRegisterUncreatableType<P2PoolManager>("moneroComponents.P2PoolManager", 1, 0, "P2PoolManager",
                                                   "P2PoolManager can't be instantiated directly");
#endif
    qmlRegisterUncreatableType<AddressBookModel>("moneroComponents.AddressBookModel", 1, 0, "AddressBookModel",
                                                        "AddressBookModel can't be instantiated directly");

    qmlRegisterUncreatableType<AddressBook>("moneroComponents.AddressBook", 1, 0, "AddressBook",
                                                        "AddressBook can't be instantiated directly");

    qmlRegisterUncreatableType<SubaddressModel>("moneroComponents.SubaddressModel", 1, 0, "SubaddressModel",
                                                        "SubaddressModel can't be instantiated directly");

    qmlRegisterUncreatableType<Subaddress>("moneroComponents.Subaddress", 1, 0, "Subaddress",
                                                        "Subaddress can't be instantiated directly");

    qmlRegisterUncreatableType<SubaddressAccountModel>("moneroComponents.SubaddressAccountModel", 1, 0, "SubaddressAccountModel",
                                                        "SubaddressAccountModel can't be instantiated directly");

    qmlRegisterUncreatableType<SubaddressAccount>("moneroComponents.SubaddressAccount", 1, 0, "SubaddressAccount",
                                                        "SubaddressAccount can't be instantiated directly");

    qRegisterMetaType<PendingTransaction::Priority>();
    qRegisterMetaType<TransactionInfo::Direction>();
    qRegisterMetaType<TransactionHistoryModel::TransactionInfoRole>();

    qRegisterMetaType<NetworkType::Type>();
    qmlRegisterType<NetworkType>("moneroComponents.NetworkType", 1, 0, "NetworkType");

#ifdef WITH_SCANNER
    qmlRegisterType<QrCodeScanner>("moneroComponents.QRCodeScanner", 1, 0, "QRCodeScanner");
#endif

    QQmlApplicationEngine engine;

#if QT_VERSION >= QT_VERSION_CHECK(5, 12, 0)
    engine.setNetworkAccessManagerFactory(new NetworkAccessBlockingFactory);
#endif
    OSCursor cursor;
    engine.rootContext()->setContextProperty("globalCursor", &cursor);
    OSHelper osHelper;
    engine.rootContext()->setContextProperty("oshelper", &osHelper);

    engine.addImportPath(":/fonts");

    engine.rootContext()->setContextProperty("moneroAccountsDir", moneroAccountsDir);

    engine.rootContext()->setContextProperty("translationManager", TranslationManager::instance());

    engine.addImageProvider(QLatin1String("qrcode"), new QRCodeImageProvider());

    engine.rootContext()->setContextProperty("logger", &logger);

    engine.rootContext()->setContextProperty("mainApp", &app);

    engine.rootContext()->setContextProperty("IPC", ipc);

    engine.rootContext()->setContextProperty("qtRuntimeVersion", qVersion());

    engine.rootContext()->setContextProperty("tailsUsePersistence", TailsOS::usePersistence);

// Exclude daemon manager from IOS
#ifndef Q_OS_IOS
    DaemonManager daemonManager;
    P2PoolManager p2poolManager;
    engine.rootContext()->setContextProperty("daemonManager", &daemonManager);
    engine.rootContext()->setContextProperty("p2poolManager", &p2poolManager);
#endif

    engine.rootContext()->setContextProperty("isWindows", isWindows);
    engine.rootContext()->setContextProperty("isMac", isMac);
    engine.rootContext()->setContextProperty("isLinux", isLinux);
    engine.rootContext()->setContextProperty("isIOS", isIOS);
    engine.rootContext()->setContextProperty("isAndroid", isAndroid);
    engine.rootContext()->setContextProperty("isOpenGL", isOpenGL);
    engine.rootContext()->setContextProperty("isTails", isTails);
    engine.rootContext()->setContextProperty("isARM", isARM);

    engine.rootContext()->setContextProperty("screenAvailableWidth", screenAvailableSize.width());
    engine.rootContext()->setContextProperty("screenAvailableHeight", screenAvailableSize.height());

#ifndef Q_OS_IOS
    const QString desktopFolder = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    if (!desktopFolder.isEmpty())
        engine.rootContext()->setContextProperty("desktopFolder", desktopFolder);
#endif

    // Get default account name
    QString accountName = qgetenv("USER"); // mac/linux
    if (accountName.isEmpty())
        accountName = qgetenv("USERNAME"); // Windows
    if (accountName.isEmpty())
        accountName = "My monero Account";

    engine.rootContext()->setContextProperty("defaultAccountName", accountName);
    engine.rootContext()->setContextProperty("homePath", QDir::homePath());
    engine.rootContext()->setContextProperty("applicationDirectory", QApplication::applicationDirPath());
    engine.rootContext()->setContextProperty("idealThreadCount", QThread::idealThreadCount());
#ifdef WITH_UPDATER
    engine.rootContext()->setContextProperty("disableCheckUpdatesFlag", parser.isSet(disableCheckUpdatesOption));
#else
    engine.rootContext()->setContextProperty("disableCheckUpdatesFlag", true);
#endif
    engine.rootContext()->setContextProperty("socksProxyFlag", parser.value(socksProxyOption));
    engine.rootContext()->setContextProperty("socksProxyFlagSet", parser.isSet(socksProxyOption));

    bool builtWithScanner = false;
#ifdef WITH_SCANNER
    builtWithScanner = true;
#endif
    engine.rootContext()->setContextProperty("builtWithScanner", builtWithScanner);

    bool builtWithDesktopEntry = false;
#ifdef WITH_DESKTOP_ENTRY
    builtWithDesktopEntry = true;
#endif
    engine.rootContext()->setContextProperty("builtWithDesktopEntry", builtWithDesktopEntry);

    engine.rootContext()->setContextProperty("moneroVersion", MONERO_VERSION_FULL);

    // Load main window (context properties needs to be defined obove this line)
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
    if (engine.rootObjects().isEmpty())
    {
        qCritical() << "Error: no root objects";
        return 1;
    }
    QObject *rootObject = engine.rootObjects().first();
    if (!rootObject)
    {
        qCritical() << "Error: no root objects";
        return 1;
    }

    // QML loaded successfully.
    if (parser.isSet(testQmlOption))
        return 0;

#ifdef WITH_SCANNER
    QObject *qmlCamera = rootObject->findChild<QObject*>("qrCameraQML");
    if (qmlCamera)
    {
        qWarning() << "QrCodeScanner : object found";
        QCamera *camera_ = qvariant_cast<QCamera*>(qmlCamera->property("mediaObject"));
        QObject *qmlFinder = rootObject->findChild<QObject*>("QrFinder");
        qobject_cast<QrCodeScanner*>(qmlFinder)->setSource(camera_);
    }
    else
        qCritical() << "QrCodeScanner : something went wrong !";
#endif

    QObject::connect(eventFilter, SIGNAL(sequencePressed(QVariant,QVariant)), rootObject, SLOT(sequencePressed(QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(sequenceReleased(QVariant,QVariant)), rootObject, SLOT(sequenceReleased(QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(mousePressed(QVariant,QVariant,QVariant)), rootObject, SLOT(mousePressed(QVariant,QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(mouseReleased(QVariant,QVariant,QVariant)), rootObject, SLOT(mouseReleased(QVariant,QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(userActivity()), rootObject, SLOT(userActivity()));
    QObject::connect(eventFilter, SIGNAL(uriHandler(QUrl)), ipc, SLOT(parseCommand(QUrl)));
    return app.exec();
}
