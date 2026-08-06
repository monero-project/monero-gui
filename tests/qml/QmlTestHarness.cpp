// Copyright (c) 2026, The Monero Project
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

#include "QmlTestHarness.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QQmlContext>
#include <QQmlEngine>
#include <QSettings>
#include <QTemporaryDir>
#include <QVector>
#include <QtQml>
#include <QtQuickTest>

#include "TranslationManager.h"
#include "libwalletqt/Wallet.h"
#include "libwalletqt/WalletManager.h"
#include "main/clipboardAdapter.h"
#include "main/oshelper.h"
#include "qt/KeysFiles.h"
#include "qt/PortableSettings.h"

class QmlTestSetup : public QObject
{
    Q_OBJECT

public:
    QmlTestSetup() : m_accountsDir(QDir::tempPath() + QStringLiteral("/monero-gui-qml-test-XXXXXX"))
    {
        QDir::setCurrent(m_accountsDir.path());
    }

    Q_INVOKABLE bool writeSetting(const QString &path, const QString &key, const QVariant &value)
    {
        QSettings settings(path, QSettings::IniFormat);
        settings.setValue(key, value);
        settings.sync();
        return settings.status() == QSettings::NoError;
    }

    Q_INVOKABLE QVariant readSetting(const QString &path, const QString &key)
    {
        QSettings settings(path, QSettings::IniFormat);
        return settings.value(key);
    }

    Q_INVOKABLE bool containsSetting(const QString &path, const QString &key)
    {
        QSettings settings(path, QSettings::IniFormat);
        return settings.contains(key);
    }

    Q_INVOKABLE bool fileExists(const QString &path)
    {
        return QFile::exists(path);
    }

public slots:
    void qmlEngineAvailable(QQmlEngine *engine)
    {
        qmlRegisterType<clipboardAdapter>("moneroComponents.Clipboard", 1, 0, "Clipboard");
        qmlRegisterType<WalletKeysFilesModel>("moneroComponents.WalletKeysFilesModel", 1, 0, "WalletKeysFilesModel");
        qmlRegisterType<WalletManager>("moneroComponents.WalletManager", 1, 0, "WalletManager");
        qmlRegisterType<PortableSettings>("moneroComponents.Settings", 1, 0, "PortableSettings");
        qmlRegisterUncreatableType<Wallet>("moneroComponents.Wallet", 1, 0, "Wallet", "Wallet can't be instantiated directly");
        qmlRegisterType<NetworkType>("moneroComponents.NetworkType", 1, 0, "NetworkType");

        engine->addImportPath(QStringLiteral(":/fonts"));
#ifdef Q_OS_WIN
        engine->addImportPath(QCoreApplication::applicationDirPath() + QStringLiteral("/qml"));
#endif
        engine->rootContext()->setContextProperty(QStringLiteral("translationManager"), TranslationManager::instance());
        engine->rootContext()->setContextProperty(QStringLiteral("oshelper"), &m_osHelper);
        engine->rootContext()->setContextProperty(
            QStringLiteral("moneroAccountsDir"),
            QDir(m_accountsDir.path()).filePath(QStringLiteral("Monero/wallets")));
        engine->rootContext()->setContextProperty(QStringLiteral("moneroTestRoot"), m_accountsDir.path());
        engine->rootContext()->setContextProperty(QStringLiteral("settingsTestHelper"), this);
        engine->rootContext()->setContextProperty(QStringLiteral("defaultAccountName"), QStringLiteral("qml-test-wallet"));
        engine->rootContext()->setContextProperty(QStringLiteral("isAndroid"), false);
        engine->rootContext()->setContextProperty(QStringLiteral("isIOS"), false);
        engine->rootContext()->setContextProperty(QStringLiteral("isLinux"), false);
        engine->rootContext()->setContextProperty(QStringLiteral("isMac"), false);
        engine->rootContext()->setContextProperty(QStringLiteral("isWindows"), false);
        engine->rootContext()->setContextProperty(QStringLiteral("isTails"), false);
        engine->rootContext()->setContextProperty(QStringLiteral("qtRuntimeVersion"), QString::fromLatin1(qVersion()));
    }

private:
    OSHelper m_osHelper;
    QTemporaryDir m_accountsDir;
};

bool runQmlTestsIfRequested(int argc, char *argv[], int &result)
{
    bool requested = false;
    QVector<char *> testArgv;
    testArgv.reserve(argc);

    for (int i = 0; i < argc; ++i) {
        if (QString::fromLocal8Bit(argv[i]) == QStringLiteral("--test-qml")) {
            requested = true;
        } else {
            testArgv.append(argv[i]);
        }
    }

    if (!requested)
        return false;

    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE"))
        qputenv("QT_QUICK_CONTROLS_STYLE", "Fusion");

    int testArgc = testArgv.size();
    QmlTestSetup setup;
    result = quick_test_main_with_setup(
        testArgc, testArgv.data(), "monero-gui-qml-tests", QML_TEST_SOURCE_DIR, &setup);
    return true;
}

#include "QmlTestHarness.moc"
