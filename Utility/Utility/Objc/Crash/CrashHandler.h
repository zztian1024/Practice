//
//  CrashHandler.h
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CrashObserving <NSObject>

@property (nonatomic, copy) NSArray<NSString *> *prefixes;
@property (nullable, nonatomic, copy) NSArray<NSString *> *frameworks;

@optional
- (void)didReceiveCrashLogs:(NSArray<NSDictionary<NSString *, id> *> *)crashLogs;

@end

@interface CrashHandler : NSObject

+ (void)disable;
+ (void)addObserver:(id<CrashObserving>)observer;
+ (void)removeObserver:(id<CrashObserving>)observer;
+ (void)clearCrashReportFiles;
+ (NSString *)getSDKVersion;

@end

NS_ASSUME_NONNULL_END
