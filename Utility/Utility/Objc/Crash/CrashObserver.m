//
//  CrashObserver.m
//  Utility
//
//  Created by Tian on 2020/10/28.
//

#import "CrashObserver.h"
#import "UtilityTools.h"

@implementation CrashObserver
@synthesize prefixes, frameworks;


- (instancetype)init {
    if ((self = [super init])) {
        prefixes = @[@"XX", @"_XX"];
        frameworks = @[@"CoreKit",
                       @"LoginKit",
                       @"ShareKit",
                       @"GamingServicesKit",
                       @"TVOSKit"];
    }
    return self;
}

+ (void)enable {
    [CrashHandler addObserver:[CrashObserver sharedInstance]];
}

+ (CrashObserver *)sharedInstance {
    static CrashObserver *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (void)didReceiveCrashLogs:(NSArray<NSDictionary<NSString *, id> *> *)processedCrashLogs {
    if (0 == processedCrashLogs.count) {
        [CrashHandler clearCrashReportFiles];
        return;
    }
    NSData *jsonData = [UtilityTools dataWithJSONObject:processedCrashLogs options:0 error:nil];
    if (jsonData) {
        NSString *crashReports = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        // Do something..
    }
    // ...
}
@end
