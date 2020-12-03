//
//  NWErrorReport.m
//  Utility
//
//  Created by Tian on 2020/10/30.
//

#import "NWErrorReport.h"
#import "NWLogger.h"
#import "NWError.h"
#import "NWSettings.h"
#import "UtilityTools.h"
#import "NWRequest.h"
#import "NSMutableArray+Safe.h"
#import "NSMutableDictionary+Safe.h"

#define FBSDK_MAX_ERROR_REPORT_LOGS 1000

@implementation NWErrorReport

static NSString *ErrorReportStorageDirName = @"instrument/";
static NSString *directoryPath;

NSString *const kFBSDKErrorCode = @"error_code";
NSString *const kFBSDKErrorDomain = @"domain";
NSString *const kFBSDKErrorTimestamp = @"timestamp";

# pragma mark - Class Methods

+ (void)enable {
    NSString *dirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:ErrorReportStorageDirName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:NULL error:NULL]) {
            [NWLogger singleShotLogEntry:NWLoggingBehaviorInformational formatString:@"Failed to create library at %@", dirPath];
        }
    }
    directoryPath = dirPath;
    [self uploadError];
    [NWError enableErrorReport];
}

+ (void)uploadError {
    if ([NWSettings isDataProcessingRestricted]) {
        return;
    }
    NSArray<NSDictionary<NSString *, id> *> *errorReports = [self loadErrorReports];
    if ([errorReports count] == 0) {
        return [self clearErrorInfo];
    }
    NSData *jsonData = [UtilityTools dataWithJSONObject:errorReports options:0 error:nil];
    if (!jsonData) {
        return;
    }
    NSString *errorData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NWRequest *request = [[NWRequest alloc] initWithPath:[NSString stringWithFormat:@"%@/instruments", [NWSettings appID]]
                                              parameters:@{@"error_reports" : errorData ?: @""}
                                              HTTPMethod:NWHTTPMethodPOST];
    
    [request startWithCompletionHandler:^(NWRequestConnection *connection, id result, NSError *error) {
        if (!error && [result isKindOfClass:[NSDictionary class]] && result[@"success"]) {
            [self clearErrorInfo];
        }
    }];
}

+ (void)saveError:(NSInteger)errorCode
      errorDomain:(NSErrorDomain)errorDomain
          message:(nullable NSString *)message {
    NSString *timestamp = [NSString stringWithFormat:@"%.0lf", [[NSDate date] timeIntervalSince1970]];
    [self saveErrorInfoToDisk:@{
        kFBSDKErrorCode : @(errorCode),
        kFBSDKErrorDomain : errorDomain,
        kFBSDKErrorTimestamp : timestamp,
    }];
}

+ (NSArray<NSDictionary<NSString *, id> *> *)loadErrorReports {
    NSMutableArray<NSDictionary<NSString *, id> *> *errorReportArr = [NSMutableArray array];
    NSArray<NSString *> *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:NULL];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL (id _Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
        NSString *str = (NSString *)evaluatedObject;
        return [str hasPrefix:@"error_report_"] && [str hasSuffix:@".json"];
    }];
    fileNames = [fileNames filteredArrayUsingPredicate:predicate];
    fileNames = [fileNames sortedArrayUsingComparator:^NSComparisonResult (id _Nonnull obj1, id _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    if (fileNames.count > 0) {
        fileNames = [fileNames subarrayWithRange:NSMakeRange(0, MIN(fileNames.count, FBSDK_MAX_ERROR_REPORT_LOGS))];
        for (NSUInteger i = 0; i < fileNames.count; i++) {
            NSData *data = [NSData dataWithContentsOfFile:[directoryPath stringByAppendingPathComponent:[fileNames safe_objectAtIndex:i]]
                                                  options:NSDataReadingMappedIfSafe
                                                    error:nil];
            if (data) {
                NSDictionary<NSString *, id> *errorReport = [UtilityTools JSONObjectWithData:data
                                                                                     options:0
                                                                                       error:nil];
                if (errorReport) {
                    [errorReportArr safe_addObject:errorReport];
                }
            }
        }
    }
    return [errorReportArr copy];
}

+ (void)clearErrorInfo {
    NSArray<NSString *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSUInteger i = 0; i < files.count; i++) {
        if ([[files safe_objectAtIndex:i] hasPrefix:@"error_report"]) {
            [[NSFileManager defaultManager] removeItemAtPath:[directoryPath stringByAppendingPathComponent:[files safe_objectAtIndex:i]] error:nil];
        }
    }
}

#pragma mark - disk operations

+ (void)saveErrorInfoToDisk:(NSDictionary<NSString *, id> *)errorInfo {
    if (errorInfo.count > 0) {
        NSData *data = [UtilityTools dataWithJSONObject:errorInfo options:0 error:nil];
        [data writeToFile:[self pathToErrorInfoFile]
               atomically:YES];
    }
}

+ (NSString *)pathToErrorInfoFile {
    NSString *timestamp = [NSString stringWithFormat:@"%.0lf", [[NSDate date] timeIntervalSince1970]];
    return [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"error_report_%@.json", timestamp]];
}

@end
