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

#include "macostrayicon.h"

#include <QByteArray>
#include <QFile>

#import <AppKit/AppKit.h>

static const CGFloat kTrayIconSize = 18.0;

@interface MacOSTrayIconTarget : NSObject <NSMenuDelegate>
@property (nonatomic, copy) void (^menuWillOpenHandler)(void);
@property (nonatomic, copy) void (^toggleHandler)(void);
@property (nonatomic, copy) void (^quitHandler)(void);
- (void)toggleApp:(id)sender;
- (void)quitApp:(id)sender;
@end

@implementation MacOSTrayIconTarget

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    if (self.menuWillOpenHandler)
        self.menuWillOpenHandler();
}

- (void)toggleApp:(id)sender
{
    if (self.toggleHandler)
        self.toggleHandler();
}

- (void)quitApp:(id)sender
{
    if (self.quitHandler)
        self.quitHandler();
}

@end

namespace
{
    NSString *toNSString(const QString &string)
    {
        return [NSString stringWithUTF8String:string.toUtf8().constData()];
    }

    NSImage *loadTemplateImage()
    {
        NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(kTrayIconSize, kTrayIconSize)];
        const char *resources[] = {":/images/trayIconTemplate.png", ":/images/trayIconTemplate@2x.png"};
        for (const char *resource : resources)
        {
            QFile file(QString::fromLatin1(resource));
            if (!file.open(QIODevice::ReadOnly)) continue;
            const QByteArray bytes = file.readAll();
            NSData *data = [NSData dataWithBytes:bytes.constData() length:(NSUInteger)bytes.size()];
            NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:data];
            if (!rep) continue;
            [rep setSize:NSMakeSize(kTrayIconSize, kTrayIconSize)];
            [image addRepresentation:rep];
        }
        if ([[image representations] count] == 0) return nil;
        [image setTemplate:YES];
        return image;
    }

    void activateApp()
    {
        const SEL activate = NSSelectorFromString(@"activate");
        if ([NSApp respondsToSelector:activate])
        {
            const IMP imp = [NSApp methodForSelector:activate];
            reinterpret_cast<void (*)(id, SEL)>(imp)(NSApp, activate);
        }
        else
        {
            [NSApp activateIgnoringOtherApps:YES];
        }
    }

    bool isAppShowing()
    {
        if (![NSApp isActive] || [NSApp isHidden]) return false;
        for (NSWindow *window in [NSApp windows])
        {
            if ([window canBecomeMainWindow] && [window isVisible] && ![window isMiniaturized])
                return true;
        }
        return false;
    }
}

struct MacOSTrayIcon::Private
{
    bool visible = false;
    QString toolTip;
    QString showText = QStringLiteral("Show");
    QString hideText = QStringLiteral("Hide");
    QString quitText = QStringLiteral("Quit");

    NSStatusItem *statusItem = nil;
    NSMenuItem *toggleItem = nil;
    NSMenuItem *quitItem = nil;
    MacOSTrayIconTarget *target = nil;

    void remove()
    {
        if (statusItem) [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
        statusItem.menu.delegate = nil;
        statusItem = nil;
        toggleItem = nil;
        quitItem = nil;
        target.menuWillOpenHandler = nil;
        target.toggleHandler = nil;
        target.quitHandler = nil;
        target = nil;
    }
};

MacOSTrayIcon::MacOSTrayIcon(QObject *parent)
    : QObject(parent)
    , d(new Private)
{
}

MacOSTrayIcon::~MacOSTrayIcon()
{
    d->remove();
}

bool MacOSTrayIcon::isVisible() const
{
    return d->visible;
}

void MacOSTrayIcon::setVisible(bool visible)
{
    if (d->visible == visible) return;
    d->visible = visible;

    if (visible)
    {
        MacOSTrayIconTarget *target = [[MacOSTrayIconTarget alloc] init];
        target.menuWillOpenHandler = ^{
            d->toggleItem.title = toNSString(isAppShowing() ? d->hideText : d->showText);
        };
        target.toggleHandler = ^{
            if (isAppShowing()) hideApp();
            else showApp();
        };
        target.quitHandler = ^{
            showApp();
            emit quitRequested();
        };

        NSMenu *menu = [[NSMenu alloc] init];
        menu.delegate = target;
        d->toggleItem = [menu addItemWithTitle:toNSString(d->showText) action:@selector(toggleApp:) keyEquivalent:@""];
        d->toggleItem.target = target;
        [menu addItem:[NSMenuItem separatorItem]];
        d->quitItem = [menu addItemWithTitle:toNSString(d->quitText) action:@selector(quitApp:) keyEquivalent:@""];
        d->quitItem.target = target;

        d->statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
#ifdef __MAC_10_12
        if ([d->statusItem respondsToSelector:@selector(setAutosaveName:)])
            d->statusItem.autosaveName = @"org.monero-project.monero-wallet-gui.status-item";
#endif
        NSStatusBarButton *button = d->statusItem.button;
        button.image = loadTemplateImage();
        if (!button.image) button.title = @"XMR";
        button.toolTip = toNSString(d->toolTip);
        [button setAccessibilityLabel:toNSString(d->toolTip)];
        d->statusItem.menu = menu;
        d->target = target;
    }
    else
    {
        d->remove();
    }

    emit visibleChanged();
}

QString MacOSTrayIcon::toolTip() const
{
    return d->toolTip;
}

void MacOSTrayIcon::setToolTip(const QString &toolTip)
{
    if (d->toolTip == toolTip) return;
    d->toolTip = toolTip;
    if (d->statusItem)
    {
        d->statusItem.button.toolTip = toNSString(toolTip);
        [d->statusItem.button setAccessibilityLabel:toNSString(toolTip)];
    }
    emit toolTipChanged();
}

QString MacOSTrayIcon::showText() const
{
    return d->showText;
}

void MacOSTrayIcon::setShowText(const QString &text)
{
    if (d->showText == text) return;
    d->showText = text;
    emit textChanged();
}

QString MacOSTrayIcon::hideText() const
{
    return d->hideText;
}

void MacOSTrayIcon::setHideText(const QString &text)
{
    if (d->hideText == text) return;
    d->hideText = text;
    emit textChanged();
}

QString MacOSTrayIcon::quitText() const
{
    return d->quitText;
}

void MacOSTrayIcon::setQuitText(const QString &text)
{
    if (d->quitText == text) return;
    d->quitText = text;
    if (d->quitItem) d->quitItem.title = toNSString(text);
    emit textChanged();
}

void MacOSTrayIcon::showApp()
{
    [NSApp unhide:nil];

    for (NSWindow *window in [NSApp windows])
    {
        if ([window canBecomeMainWindow] && [window isMiniaturized]) [window deminiaturize:nil];
    }

    activateApp();
}

void MacOSTrayIcon::hideApp()
{
    [NSApp hide:nil];
}
