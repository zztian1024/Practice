//
//  CrashMaker.h
//  CrashSupervisor
//
//  Created by Tian on 2020/9/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CrashMaker : NSObject

+ (void)outOfBounds;

+ (void)signalCrash;

@end

NS_ASSUME_NONNULL_END
