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

#ifndef MACOSTRAYICON_H
#define MACOSTRAYICON_H

#include <memory>

#include <QObject>
#include <QString>

class MacOSTrayIcon : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool visible READ isVisible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(QString toolTip READ toolTip WRITE setToolTip NOTIFY toolTipChanged)
    Q_PROPERTY(QString showText READ showText WRITE setShowText NOTIFY textChanged)
    Q_PROPERTY(QString hideText READ hideText WRITE setHideText NOTIFY textChanged)
    Q_PROPERTY(QString quitText READ quitText WRITE setQuitText NOTIFY textChanged)

public:
    explicit MacOSTrayIcon(QObject *parent = nullptr);
    ~MacOSTrayIcon() override;

    bool isVisible() const;
    void setVisible(bool visible);

    QString toolTip() const;
    void setToolTip(const QString &toolTip);

    QString showText() const;
    void setShowText(const QString &text);
    QString hideText() const;
    void setHideText(const QString &text);
    QString quitText() const;
    void setQuitText(const QString &text);

signals:
    void visibleChanged();
    void toolTipChanged();
    void textChanged();
    void quitRequested();

private:
    void showApp();
    void hideApp();

    struct Private;
    std::unique_ptr<Private> d;
};

#endif // MACOSTRAYICON_H
