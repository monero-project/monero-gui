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

#include "SystemEvents.h"

#include <QDebug>
#include <QMetaMethod>

#import <AppKit/AppKit.h>
#include <IOKit/IOMessage.h>
#include <IOKit/pwr_mgt/IOPMLib.h>

namespace
{
// macOS waits at most 30s.
constexpr int sleepAcknowledgeTimeoutMs = 20000;
}

struct SystemEvents::Platform
{
    static void powerCallback(void *refcon, io_service_t service, natural_t messageType, void *messageArgument);

    io_connect_t rootPort = MACH_PORT_NULL;
    IONotificationPortRef notificationPort = nullptr;
    io_object_t notifier = IO_OBJECT_NULL;
    id sessionObserver = nil;
    id screenLockObserver = nil;
    intptr_t pendingSleep = 0;
    bool sleepPending = false;
};

void SystemEvents::Platform::powerCallback(void *refcon, io_service_t, natural_t messageType, void *messageArgument)
{
    auto *self = static_cast<SystemEvents *>(refcon);
    const auto notificationId = reinterpret_cast<intptr_t>(messageArgument);
    switch (messageType)
    {
    case kIOMessageCanSystemSleep:
        IOAllowPowerChange(self->m_platform->rootPort, notificationId);
        break;
    case kIOMessageSystemWillSleep:
        self->beginSleep(notificationId);
        break;
    default:
        break;
    }
}

SystemEvents::SystemEvents(QObject *parent)
    : QObject(parent)
    , m_platform(std::make_unique<Platform>())
{
    m_sleepTimeout.setSingleShot(true);
    m_sleepTimeout.setInterval(sleepAcknowledgeTimeoutMs);
    connect(&m_sleepTimeout, &QTimer::timeout, this, [this]() {
        qWarning() << "Timed out preparing for sleep, letting the system sleep";
        allowSleep();
    });

    m_platform->rootPort = IORegisterForSystemPower(this, &m_platform->notificationPort,
        &Platform::powerCallback, &m_platform->notifier);
    if (m_platform->rootPort == MACH_PORT_NULL)
    {
        qWarning() << "IORegisterForSystemPower failed, the wallet won't be saved before sleep";
    }
    else
    {
        CFRunLoopAddSource(CFRunLoopGetMain(), IONotificationPortGetRunLoopSource(m_platform->notificationPort),
            kCFRunLoopCommonModes);
    }

    SystemEvents *self = this;
    void (^onScreenLocked)(NSNotification *) = ^(NSNotification *notification) {
        Q_UNUSED(notification);
        Q_EMIT self->screenLocked();
    };
    m_platform->sessionObserver = [[[NSWorkspace sharedWorkspace] notificationCenter]
        addObserverForName:NSWorkspaceSessionDidResignActiveNotification
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:onScreenLocked];
    m_platform->screenLockObserver = [[NSDistributedNotificationCenter defaultCenter]
        addObserverForName:@"com.apple.screenIsLocked"
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:onScreenLocked];
}

SystemEvents::~SystemEvents()
{
    if (m_platform->sessionObserver)
    {
        [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:m_platform->sessionObserver];
    }
    if (m_platform->screenLockObserver)
    {
        [[NSDistributedNotificationCenter defaultCenter] removeObserver:m_platform->screenLockObserver];
    }

    allowSleep();

    if (m_platform->rootPort != MACH_PORT_NULL)
    {
        CFRunLoopRemoveSource(CFRunLoopGetMain(), IONotificationPortGetRunLoopSource(m_platform->notificationPort),
            kCFRunLoopCommonModes);
        IODeregisterForSystemPower(&m_platform->notifier);
        IOServiceClose(m_platform->rootPort);
        IONotificationPortDestroy(m_platform->notificationPort);
    }
}

void SystemEvents::allowSleep()
{
    if (!m_platform->sleepPending)
    {
        return;
    }
    m_platform->sleepPending = false;
    m_sleepTimeout.stop();
    IOAllowPowerChange(m_platform->rootPort, m_platform->pendingSleep);
}

void SystemEvents::beginSleep(intptr_t notificationId)
{
    allowSleep();

    m_platform->pendingSleep = notificationId;
    m_platform->sleepPending = true;

    if (!isSignalConnected(QMetaMethod::fromSignal(&SystemEvents::systemWillSleep)))
    {
        allowSleep();
        return;
    }

    m_sleepTimeout.start();
    Q_EMIT systemWillSleep();
}
