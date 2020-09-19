//
//  CrashTracker.h
//  CrashSupervisor
//
//  Created by Tian on 2020/9/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashTracker : NSObject

+ (void)registerExceptionHandler;
+ (void)registerSignalHandler;

@end

NS_ASSUME_NONNULL_END
