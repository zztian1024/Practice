//
//  CrashObserver.h
//  Utility
//
//  Created by Tian on 2020/10/28.
//

#import <Foundation/Foundation.h>
#import "CrashHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface CrashObserver : NSObject <CrashObserving>

+ (void)enable;

@end

NS_ASSUME_NONNULL_END
