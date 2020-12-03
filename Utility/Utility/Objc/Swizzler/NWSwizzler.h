//
//  NWSwizzler.h
//  Utility
//
//  Created by Tian on 2020/10/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define MAPTABLE_ID(x) (__bridge id)((void *)x)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

typedef void (^swizzleBlock)();

#pragma clang diagnostic pop


@interface NWSwizzler : NSObject

+ (void)swizzleSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(swizzleBlock)block named:(NSString *)aName;
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName;
+ (void)printSwizzles;

@end

NS_ASSUME_NONNULL_END
