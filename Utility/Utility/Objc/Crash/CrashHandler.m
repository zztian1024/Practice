//
//  CrashHandler.m
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import "CrashHandler.h"
#import "NSMutableArray+Safe.h"
#import "NSMutableDictionary+Safe.h"
#import "UtilityTools.h"
#import "LibAnalyzer.h"

#import <UIKit/UIDevice.h>
#import <sys/utsname.h>
#include <signal.h>

#define CRASH_PATH_NAME @"crash-logs"
#define MAX_CRASH_LOGS 5

static NSString *directoryPath;
static NSString *mappingTableIdentifier = NULL;
static NSString *directoryPath;
static BOOL _isTurnedOff;

NSString *const kMapingTable = @"mapping_table";
NSString *const kMappingTableIdentifier = @"mapping_table_identifier";
NSString *const kAppVersion = @"app_version";
NSString *const kCallstack = @"callstack";
NSString *const kCrashReason = @"reason";
NSString *const kCrashTimestamp = @"timestamp";
NSString *const kDeviceModel = @"device_model";
NSString *const kDeviceOSVersion = @"device_os_version";

static NSHashTable<id<CrashObserving>> *_observers;
static NSArray<NSDictionary<NSString *, id> *> *_processedCrashLogs;

static const int fatalSignals[] =
{
    SIGBUS,
    SIGFPE,
    SIGILL,
    SIGPIPE,
    SIGSEGV,
    SIGSYS,
    SIGTRAP,
};
static const int fatalSignalsCount = sizeof(fatalSignals) / sizeof(int);
static struct sigaction *previousSignalHandlers = NULL;
static NSUncaughtExceptionHandler *previousExceptionHandler = NULL;

static void installSignalsHandler(void);
static void uninstallSignalsHandler(void);
static void SignalHandler(int signal, siginfo_t *signalInfo, void *userContext);

@implementation CrashHandler

+ (void)initialize {
    NSString *dirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:CRASH_PATH_NAME];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:NULL error:NULL];
    }
    directoryPath = dirPath;
    NSString *identifier = [[NSUUID UUID] UUIDString];
    mappingTableIdentifier = [identifier stringByReplacingOccurrencesOfString:@"-" withString:@""];
    _observers = [[NSHashTable alloc] init];
}

+ (void)addObserver:(id<CrashObserving>)observer {
    if (_isTurnedOff || ![self isSafeToGenerateMapping]) {
        return;
    }
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        [CrashHandler installExceptionsHandler];
        installSignalsHandler();
        _processedCrashLogs = [self getProcessedCrashLogs];
    });
    @synchronized(_observers) {
        if (![_observers containsObject:observer]) {
            [_observers addObject:observer];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
                [self generateMethodMapping:observer];
            });
            [self sendCrashLogs];
        }
    }
}

+ (void)removeObserver:(id<CrashObserving>)observer {
    @synchronized(_observers) {
        if ([_observers containsObject:observer]) {
            [_observers removeObject:observer];
            if (_observers.count == 0) {
                [CrashHandler uninstallExceptionsHandler];
                uninstallSignalsHandler();
            }
        }
    }
}

+ (void)sendCrashLogs {
    for (id<CrashObserving> observer in _observers) {
        if (observer && [observer respondsToSelector:@selector(didReceiveCrashLogs:)]) {
            NSArray<NSDictionary<NSString *, id> *> *filteredCrashLogs = [self filterCrashLogs:observer.prefixes processedCrashLogs:_processedCrashLogs];
            [observer didReceiveCrashLogs:filteredCrashLogs];
        }
    }
}

+ (NSArray<NSDictionary<NSString *, id> *> *)filterCrashLogs:(NSArray<NSString *> *)prefixList
                                          processedCrashLogs:(NSArray<NSDictionary<NSString *, id> *> *)processedCrashLogs {
    NSMutableArray<NSDictionary<NSString *, id> *> *crashLogs = [NSMutableArray array];
    for (NSDictionary<NSString *, id> *crashLog in processedCrashLogs) {
        NSArray<NSString *> *callstack = crashLog[kCallstack];
        if ([self callstack:callstack containsPrefix:prefixList]) {
            [crashLogs safe_addObject:crashLog];
        }
    }
    return crashLogs;
}

+ (BOOL)callstack:(NSArray<NSString *> *)callstack
   containsPrefix:(NSArray<NSString *> *)prefixList {
    NSString *callStackString = [callstack componentsJoinedByString:@""];
    for (NSString *prefix in prefixList) {
        if ([callStackString containsString:prefix]) {
            return YES;
        }
    }
    return NO;
}

+ (void)disable {
    _isTurnedOff = YES;
    [CrashHandler uninstallExceptionsHandler];
    uninstallSignalsHandler();
    _observers = nil;
}

#pragma mark - Storage

+ (void)saveException:(NSException *)exception {
    if (exception.callStackSymbols && exception.name) {
        NSArray<NSString *> *stackSymbols = [NSArray arrayWithArray:exception.callStackSymbols];
        [self saveCrashLog:@{
            kCallstack : stackSymbols,
            kCrashReason : exception.name,
        }];
    }
}

+ (void)saveSignal:(int)signal withCallStack:(NSArray<NSString *> *)callStack {
    if (callStack) {
        NSString *signalDescription = [NSString stringWithCString:strsignal(signal) encoding:NSUTF8StringEncoding] ?: [NSString stringWithFormat:@"SIGNUM(%i)", signal];
        [self saveCrashLog:@{
            kCallstack : callStack,
            kCrashReason : signalDescription,
        }];
    }
}

+ (NSArray<NSDictionary<NSString *, id> *> *)getProcessedCrashLogs {
    NSArray<NSDictionary<NSString *, id> *> *crashLogs = [self loadCrashLogs];
    if (0 == crashLogs.count) {
        [self clearCrashReportFiles];
        return nil;
    }
    NSMutableArray<NSDictionary<NSString *, id> *> *processedCrashLogs = [NSMutableArray array];
    
    for (NSDictionary<NSString *, id> *crashLog in crashLogs) {
        NSArray<NSString *> *callstack = crashLog[kCallstack];
        NSData *data = [self loadLibData:crashLog];
        if (!data) {
            continue;
        }
        NSDictionary<NSString *, id> *methodMapping = [UtilityTools JSONObjectWithData:data
                                                                               options:kNilOptions
                                                                                 error:nil];
        NSArray<NSString *> *symbolicatedCallstack = [LibAnalyzer symbolicateCallstack:callstack methodMapping:methodMapping];
        NSMutableDictionary<NSString *, id> *symbolicatedCrashLog = [NSMutableDictionary dictionaryWithDictionary:crashLog];
        if (symbolicatedCallstack) {
            [symbolicatedCrashLog safe_setObject:symbolicatedCallstack forKey:kCallstack];
            [symbolicatedCrashLog removeObjectForKey:kMappingTableIdentifier];
            [processedCrashLogs safe_addObject:symbolicatedCrashLog];
        }
    }
    return processedCrashLogs;
}

+ (NSArray<NSDictionary<NSString *, id> *> *)loadCrashLogs {
    NSArray<NSString *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
    NSArray<NSString *> *fileNames = [[self getCrashLogFileNames:files] sortedArrayUsingComparator:^NSComparisonResult (id _Nonnull obj1, id _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    NSMutableArray<NSDictionary<NSString *, id> *> *crashLogArray = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < MIN(fileNames.count, MAX_CRASH_LOGS); i++) {
        NSData *data = [self loadCrashLog:[fileNames safe_objectAtIndex:i]];
        if (!data) {
            continue;
        }
        NSDictionary<NSString *, id> *crashLog = [UtilityTools JSONObjectWithData:data
                                                                          options:kNilOptions
                                                                            error:nil];
        if (crashLog) {
            [crashLogArray safe_addObject:crashLog];
        }
    }
    return [crashLogArray copy];
}

+ (nullable NSData *)loadCrashLog:(NSString *)fileName
{
    return [NSData dataWithContentsOfFile:[directoryPath stringByAppendingPathComponent:fileName] options:NSDataReadingMappedIfSafe error:nil];
}

+ (void)clearCrashReportFiles
{
    NSArray<NSString *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    
    for (NSUInteger i = 0; i < files.count; i++) {
        // remove all crash related files except for the current mapping table
        if ([[files safe_objectAtIndex:i] hasPrefix:@"crash_"] && ![[files safe_objectAtIndex:i] containsString:mappingTableIdentifier]) {
            [[NSFileManager defaultManager] removeItemAtPath:[directoryPath stringByAppendingPathComponent:[files safe_objectAtIndex:i]] error:nil];
        }
    }
}

+ (NSArray<NSString *> *)getCrashLogFileNames:(NSArray<NSString *> *)files {
    NSMutableArray<NSString *> *fileNames = [NSMutableArray array];
    
    for (NSString *fileName in files) {
        if ([fileName hasPrefix:@"crash_log_"] && [fileName hasSuffix:@".json"]) {
            [fileNames safe_addObject:fileName];
        }
    }
    
    return fileNames;
}

+ (void)saveCrashLog:(NSDictionary<NSString *, id> *)crashLog
{
    NSMutableDictionary<NSString *, id> *completeCrashLog = [NSMutableDictionary dictionaryWithDictionary:crashLog];
    NSString *currentTimestamp = [NSString stringWithFormat:@"%.0lf", [[NSDate date] timeIntervalSince1970]];
    
    [completeCrashLog safe_setObject:currentTimestamp forKey:kCrashTimestamp];
    [completeCrashLog safe_setObject:mappingTableIdentifier forKey:kMappingTableIdentifier];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *version = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *build = [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    [completeCrashLog safe_setObject:[NSString stringWithFormat:@"%@(%@)", version, build] forKey:kAppVersion];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    [completeCrashLog safe_setObject:@(systemInfo.machine) forKey:kDeviceModel];
    
    [completeCrashLog safe_setObject:[UIDevice currentDevice].systemVersion forKey:kDeviceOSVersion];
    
    NSData *data = [UtilityTools dataWithJSONObject:completeCrashLog options:0 error:nil];
    
    [data writeToFile:[self getPathToCrashFile:currentTimestamp]
           atomically:YES];
}

+ (void)generateMethodMapping:(id<CrashObserving>)observer
{
    if (observer.prefixes.count == 0) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:mappingTableIdentifier forKey:kMappingTableIdentifier];
    NSDictionary<NSString *, NSString *> *methodMapping = [LibAnalyzer getMethodsTable:observer.prefixes
                                                                            frameworks:observer.frameworks];
    if (methodMapping.count > 0) {
        NSData *data = [UtilityTools dataWithJSONObject:methodMapping options:0 error:nil];
        [data writeToFile:[self getPathToLibDataFile:mappingTableIdentifier]
               atomically:YES];
    }
}

+ (nullable NSData *)loadLibData:(NSDictionary<NSString *, id> *)crashLog {
    NSString *identifier = [crashLog objectForKey:kMappingTableIdentifier];
    return [NSData dataWithContentsOfFile:[self getPathToLibDataFile:identifier] options:NSDataReadingMappedIfSafe error:nil];
}

+ (BOOL)isSafeToGenerateMapping {
#if TARGET_OS_SIMULATOR
    return YES;
#else
    NSString *identifier = [[NSUserDefaults standardUserDefaults] objectForKey:kMappingTableIdentifier];
    // first app start
    if (!identifier) {
        return YES;
    }
    
    return [[NSFileManager defaultManager] fileExistsAtPath:[self getPathToLibDataFile:identifier]];
#endif
}

+ (NSString *)getPathToCrashFile:(NSString *)timestamp {
    return [directoryPath stringByAppendingPathComponent:
            [NSString stringWithFormat:@"crash_log_%@.json", timestamp]];
}

+ (NSString *)getPathToLibDataFile:(NSString *)identifier {
    return [directoryPath stringByAppendingPathComponent:
            [NSString stringWithFormat:@"crash_data_%@.json", identifier]];
}

+ (NSString *)getSDKVersion {
    return @"version_xxx";
}

# pragma mark handler function

+ (void)installExceptionsHandler {
    NSUncaughtExceptionHandler *currentHandler = NSGetUncaughtExceptionHandler();
    
    if (currentHandler != ExceptionHandler) {
        previousExceptionHandler = currentHandler;
        NSSetUncaughtExceptionHandler(&ExceptionHandler);
    }
}

+ (void)uninstallExceptionsHandler {
    NSSetUncaughtExceptionHandler(previousExceptionHandler);
    previousExceptionHandler = nil;
}

static void ExceptionHandler(NSException *exception) {
    [CrashHandler saveException:exception];
    if (previousExceptionHandler) {
        previousExceptionHandler(exception);
    }
}

static void installSignalsHandler() {
    previousSignalHandlers = malloc(sizeof(*previousSignalHandlers) * (unsigned)fatalSignalsCount);
    struct sigaction action = {{0}, 0, 0};
    action.sa_flags = SA_SIGINFO | SA_ONSTACK;
#if defined(__LP64__) && __LP64__
    action.sa_flags |= SA_64REGSET;
#endif
    sigemptyset(&action.sa_mask);
    for (size_t i = 0; i < fatalSignalsCount; i++) {
        sigaddset(&action.sa_mask, fatalSignals[i]);
    }
    action.sa_sigaction = &SignalHandler;
    
    for (int i = 0; i < fatalSignalsCount; i++) {
        sigaction(fatalSignals[i], &action, &previousSignalHandlers[i]);
    }
}

static void uninstallSignalsHandler() {
    for (int i = 0; i < fatalSignalsCount; i++) {
        sigaction(fatalSignals[i], &previousSignalHandlers[i], NULL);
    }
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
    [CrashHandler saveSignal:sig withCallStack:callStack];
}

@end
