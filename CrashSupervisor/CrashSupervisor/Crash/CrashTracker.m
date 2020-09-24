//
//  CrashTracker.m
//  CrashSupervisor
//
//  Created by Tian on 2020/9/19.
//

#import "CrashTracker.h"
#include <mach-o/dyld.h>
#include <execinfo.h>

static NSUncaughtExceptionHandler *myExceptionHandler;
static NSUncaughtExceptionHandler *oldhandler;
static BOOL dismissed;

@implementation CrashTracker

+ (void)registerExceptionHandler {
    if (NSGetUncaughtExceptionHandler() != myExceptionHandler) {
        oldhandler = NSGetUncaughtExceptionHandler();
    }
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

+ (void)registerSignalHandler {
    signal(SIGHUP, SignalExceptionHandler);
    signal(SIGINT, SignalExceptionHandler);
    signal(SIGQUIT, SignalExceptionHandler);
    signal(SIGABRT, SignalExceptionHandler);
    signal(SIGILL, SignalExceptionHandler);
    signal(SIGSEGV, SignalExceptionHandler);
    signal(SIGFPE, SignalExceptionHandler);
    signal(SIGBUS, SignalExceptionHandler);
    signal(SIGPIPE, SignalExceptionHandler);
}

+ (void)handleException:(NSException *)exception {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"---------upload--------");
        dismissed = YES;
    });
    
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    NSLog(@"---------done--------");
}

#pragma mark - Internal

/// 获取基地址
uintptr_t getLoadAddress(void) {
    const struct mach_header *exe_header = NULL;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const struct mach_header *header = _dyld_get_image_header(i);
        if (header->filetype == MH_EXECUTE) {
            exe_header = header;
            break;
        }
    }
    
    return (uintptr_t)exe_header;
}

/// 获取偏移地址
uintptr_t getSlideAddress(void) {
    uintptr_t vmaddr_slide = NULL;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const struct mach_header *header = _dyld_get_image_header(i);
        if (header->filetype == MH_EXECUTE) {
            vmaddr_slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    
    return (uintptr_t)vmaddr_slide;
}

void UncaughtExceptionHandler(NSException *exception) {
    NSArray *stackArray = [exception callStackSymbols];
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"%@", [stackArray componentsJoinedByString:@"\n"]];
    NSDictionary *fullInfo = @{
        @"name": name,
        @"reason": reason,
        @"loadAdd": @(getLoadAddress()),
        @"slideAdd": @(getSlideAddress()),
        @"callStackSymbols": exceptionInfo,
    };
    
    [CrashTracker performSelector:@selector(handleException:) withObject:fullInfo];
    
    if(oldhandler) {
        oldhandler(exception);
    }
}

void SignalExceptionHandler(int signal) {
    NSMutableString *signalStr = [[NSMutableString alloc] init];
    [signalStr appendString:@"Stack:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [signalStr appendFormat:@"%s\n", strs[i]];
    }
    
    NSLog(@"%@", signalStr);
}

@end
