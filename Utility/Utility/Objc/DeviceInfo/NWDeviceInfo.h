//
//  NWDeviceInfo.h
//  Utility
//
//  Created by Tian on 2020/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWDeviceInfo : NSObject

+ (NSString *)getCarrier;
+ (NSNumber *)getRemainingDiskSpace;
+ (NSNumber *)getTotalDiskSpace;

@end

NS_ASSUME_NONNULL_END
