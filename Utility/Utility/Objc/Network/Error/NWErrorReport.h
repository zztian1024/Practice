//
//  NWErrorReport.h
//  Utility
//
//  Created by Tian on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWErrorReport : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (void)enable;
+ (void)saveError:(NSInteger)errorCode
      errorDomain:(NSErrorDomain)errorDomain
          message:(nullable NSString *)message;

@end
NS_ASSUME_NONNULL_END
