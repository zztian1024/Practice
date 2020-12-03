//
//  NWSwizzlerTest.h
//  Utility
//
//  Created by Tian on 2020/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWSwizzlerClass : NSObject

- (void)method1;
- (void)method2:(NSString *)param;
- (BOOL)method3:(NSString *)param param2:(NSString *)param2;
+ (void)method4;

@end

@interface NWSwizzlerTest : NSObject

+ (void)addSwizzler;

@end

NS_ASSUME_NONNULL_END
