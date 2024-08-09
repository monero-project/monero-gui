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

#include <unordered_set>

#include <QtCore>
#include <QtGui>
#include <QtMac>
#include "macoshelper.h"

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>
#include <ApplicationServices/ApplicationServices.h>
#include <Availability.h>

#include "ScopeGuard.h"

void MacOSHelper::disableWindowTabbing()
{
#ifdef __MAC_10_12
    if ([NSWindow respondsToSelector:@selector(allowsAutomaticWindowTabbing)])
        [NSWindow setAllowsAutomaticWindowTabbing: NO];
#endif
}

bool MacOSHelper::isCapsLock()
{
#ifdef __MAC_10_12
    NSUInteger flags = [NSEvent modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
    return (flags == NSEventModifierFlagCapsLock);
#else
    NSUInteger flags = [NSEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask;
    return (flags & NSAlphaShiftKeyMask);
#endif
}

bool MacOSHelper::openFolderAndSelectItem(const QUrl &path)
{
    NSURL *nspath = path.toNSURL();
    NSArray *fileURLs = [NSArray arrayWithObjects:nspath, nil];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
    return true;
}

QString MacOSHelper::bundlePath()
{
    NSBundle *main = [NSBundle mainBundle];
    if (!main)
    {
        return {};
    }
    NSString *bundlePathString = [main bundlePath];
    if (!bundlePathString)
    {
        return {};
    }
    return QString::fromCFString(reinterpret_cast<const CFStringRef>(bundlePathString));
}
