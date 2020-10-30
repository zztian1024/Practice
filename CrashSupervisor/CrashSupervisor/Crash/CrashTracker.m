//
//  CrashTracker.m
//  CrashSupervisor
//
//  Created by Tian on 2020/9/19.
//

#import "CrashTracker.h"
#include <mach-o/dyld.h>
#include <execinfo.h>
#include <signal.h>
#import <UIKit/UIKit.h>

static NSUncaughtExceptionHandler *myExceptionHandler;
static NSUncaughtExceptionHandler *oldhandler;
static BOOL dismissed;

static const int fatalSignals[] =
{
    SIGBUS,
    SIGFPE,
    SIGILL,
    SIGPIPE,
    SIGSEGV,
    SIGSYS,
    SIGTRAP,
    SIGABRT,
};
static const int fatalSignalsCount = sizeof(fatalSignals) / sizeof(int);
static struct sigaction *previousSignalHandlers = NULL;
static void installSignalsHandler(void);
static void uninstallSignalsHandler(void);
static void SignalHandler(int signal, siginfo_t *signalInfo, void *userContext);

@implementation CrashTracker

+ (void)registerExceptionHandler {
    if (NSGetUncaughtExceptionHandler() != myExceptionHandler) {
        oldhandler = NSGetUncaughtExceptionHandler();
    }
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}

+ (void)registerSignalHandler {
    //     signal(SIGHUP, SignalExceptionHandler);
    previousSignalHandlers = malloc(sizeof(*previousSignalHandlers) * (unsigned)fatalSignalsCount);
    struct sigaction action = {{0}, 0, 0};
    action.sa_flags = SA_SIGINFO | SA_ONSTACK;
    sigemptyset(&action.sa_mask);
    for (size_t i = 0; i < fatalSignalsCount; i++) {
        sigaddset(&action.sa_mask, fatalSignals[i]);
    }
    action.sa_sigaction = &SignalHandler;
    
    for (int i = 0; i < fatalSignalsCount; i++) {
        sigaction(fatalSignals[i], &action, &previousSignalHandlers[i]);
    }
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
            
            /**
             *  在指定的模式下运行当前线程的runloop， runloop能够被递归调用，你能够在当前线程的调用栈激活子runloop。你能在你可使用的模式激活任意runloop。
             *  @parma   mode: 指定模式，可以是任意CFString类型的字符串（即：可以隐式创建一个模式）但是一个模式必须至少包括一个source或者timer才能运行。
             *  不必具体说明 runloop运行在commonModes中的哪个mode,runloop会在一个特定的模式运行。 只有当你注册一个observer时希望observer运行在不止一个模式的时候需要具体说明
             *  @parma   seconds: 指定runloop运行时间. 如果为0，在runloop返回前会被执行一次；\
             *  忽略returnAfterSourceHandled的值， 如果有多个sources或者timers已准备好立刻运行，仅有一个能被执行(除非sources中有source0)。
             *  @parma   returnAfterSourceHandled: 判断运行了一个source之后runloop是否退出。如果为false，runloop继续执行事件直到第二次调遣结束
             *  @return  runloop退出的原因：
                         kCFRunLoopRunFinished：runloop中已经没有sources和timers
                         kCFRunLoopRunStopped：runloop通过 CFRunLoopStop(_:)方法停止
                         kCFRunLoopRunTimedOut：runloop设置的时间已到
                         kCFRunLoopRunHandledSource：当returnAfterSourceHandled值为ture时，一个source被执行完
             */
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
    
    
    if(oldhandler) {
        oldhandler(exception);
    }
    NSLog(@"-----");
    [CrashTracker performSelector:@selector(handleException:) withObject:fullInfo];
}

static void SignalHandler(int sig, siginfo_t *signalInfo, void *userContext) {
    uninstallSignalsHandler();
    NSMutableArray<NSString *> *callStack = [[NSThread callStackSymbols] mutableCopy];
    if (callStack) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        if (callStack.count > 2 && [callStack objectsAtIndexes:indexSet]) {
            [callStack removeObjectsAtIndexes:indexSet];
        }
    }
    [CrashTracker saveSignal:sig withCallStack:callStack];
}

static void uninstallSignalsHandler() {
    for (int i = 0; i < fatalSignalsCount; i++) {
        sigaction(fatalSignals[i], &previousSignalHandlers[i], NULL);
    }
}

+ (void)saveSignal:(int)signal withCallStack:(NSArray<NSString *> *)callStack {
    if (callStack) {
        NSString *signalDescription = [NSString stringWithCString:strsignal(signal) encoding:NSUTF8StringEncoding] ?: [NSString stringWithFormat:@"SIGNUM(%i)", signal];
        // TODO:
        NSLog(@"%@", callStack);
        
        [CrashTracker performSelector:@selector(handleException:) withObject:[NSException exceptionWithName:@"signal" reason:signalDescription userInfo:nil]];
    }
}

@end
