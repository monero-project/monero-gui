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
#include "macoshelper.h"

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <CoreFoundation/CoreFoundation.h>
#include <ApplicationServices/ApplicationServices.h>
#include <Availability.h>
#include <unistd.h>

#if defined(__MAC_14_0) && __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_14_0
#define MONERO_HAVE_SCREENSHOT_MANAGER 1
#import <ScreenCaptureKit/ScreenCaptureKit.h>
#endif

#include "ScopeGuard.h"

namespace
{

QImage toQImage(CGImageRef cgImage)
{
    const size_t width = CGImageGetWidth(cgImage);
    const size_t height = CGImageGetHeight(cgImage);
    QImage image(static_cast<int>(width), static_cast<int>(height), QImage::Format_ARGB32_Premultiplied);
    if (image.isNull())
    {
        return {};
    }
    image.fill(Qt::transparent);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    CGContextRef context = CGBitmapContextCreate(image.bits(), width, height, 8, image.bytesPerLine(), colorSpace,
        kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
    CGColorSpaceRelease(colorSpace);
    if (!context)
    {
        return {};
    }
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
    CGContextRelease(context);
    return image;
}

#ifdef MONERO_HAVE_SCREENSHOT_MANAGER
// Long enough for ScreenCaptureKit to answer, short enough not to freeze the GUI if it doesn't
const int64_t screenCaptureTimeout = 5 * NSEC_PER_SEC;

API_AVAILABLE(macos(14.0))
QImage captureMainDisplay()
{
    __block SCShareableContent *content = nil;
    __block NSError *contentError = nil;
    dispatch_semaphore_t contentReady = dispatch_semaphore_create(0);
    [SCShareableContent getShareableContentExcludingDesktopWindows:NO
                                               onScreenWindowsOnly:YES
                                                 completionHandler:^(SCShareableContent *result, NSError *error) {
        content = result;
        contentError = error;
        dispatch_semaphore_signal(contentReady);
    }];
    if (dispatch_semaphore_wait(contentReady, dispatch_time(DISPATCH_TIME_NOW, screenCaptureTimeout)) != 0)
    {
        qWarning() << "ScreenCaptureKit: timed out listing shareable content";
        return {};
    }
    if (!content)
    {
        qWarning() << "ScreenCaptureKit: failed to list shareable content:"
                   << QString::fromNSString(contentError.localizedDescription);
        return {};
    }

    const CGDirectDisplayID mainDisplayId = CGMainDisplayID();
    SCDisplay *display = nil;
    for (SCDisplay *candidate in content.displays)
    {
        if (candidate.displayID == mainDisplayId)
        {
            display = candidate;
            break;
        }
    }
    if (!display)
    {
        display = content.displays.firstObject;
    }
    if (!display)
    {
        qWarning() << "ScreenCaptureKit: no display available";
        return {};
    }

    // Leave out our own windows so whatever is behind them (such as a QR code) is visible.
    const pid_t pid = getpid();
    NSMutableArray<SCRunningApplication *> *excludedApps = [NSMutableArray array];
    for (SCRunningApplication *app in content.applications)
    {
        if (app.processID == pid)
        {
            [excludedApps addObject:app];
        }
    }

    SCContentFilter *filter = [[SCContentFilter alloc] initWithDisplay:display
                                                 excludingApplications:excludedApps
                                                      exceptingWindows:@[]];
    SCStreamConfiguration *config = [[SCStreamConfiguration alloc] init];
    const CGFloat scale = filter.pointPixelScale;
    config.width = static_cast<size_t>(filter.contentRect.size.width * scale);
    config.height = static_cast<size_t>(filter.contentRect.size.height * scale);
    config.showsCursor = NO;

    // Held as an ID so the image is released by ARC, even if it arrives after we stopped waiting
    __block id capturedImage = nil;
    __block NSError *captureError = nil;
    dispatch_semaphore_t imageReady = dispatch_semaphore_create(0);
    [SCScreenshotManager captureImageWithFilter:filter
                                  configuration:config
                              completionHandler:^(CGImageRef image, NSError *error) {
        capturedImage = (__bridge id)image;
        captureError = error;
        dispatch_semaphore_signal(imageReady);
    }];
    if (dispatch_semaphore_wait(imageReady, dispatch_time(DISPATCH_TIME_NOW, screenCaptureTimeout)) != 0)
    {
        qWarning() << "ScreenCaptureKit: timed out capturing the display";
        return {};
    }
    if (!capturedImage)
    {
        qWarning() << "ScreenCaptureKit: failed to capture the display:"
                   << QString::fromNSString(captureError.localizedDescription);
        return {};
    }

    return toQImage((__bridge CGImageRef)capturedImage);
}
#endif

} // namespace

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
    return QString::fromNSString(bundlePathString);
}

std::optional<QImage> MacOSHelper::grabMainDisplay()
{
#ifdef MONERO_HAVE_SCREENSHOT_MANAGER
    if (@available(macOS 14.0, *))
    {
        return captureMainDisplay();
    }
#endif
    return std::nullopt;
}
