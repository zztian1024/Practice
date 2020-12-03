//
//  NWSwizzlerTest.m
//  Utility
//
//  Created by Tian on 2020/11/1.
//

#import "NWSwizzlerTest.h"
#import "NWSwizzler.h"

@implementation NWSwizzlerClass

- (void)method1 {
    NSLog(@" %s invoked！", __func__);
}

- (void)method2:(NSString *)param {
    NSLog(@" %s invoked！", __func__);
}

- (BOOL)method3:(NSString *)param param2:(NSString *)param2 {
    NSLog(@" %s invoked！", __func__);
    return YES;
}

+ (void)method4 {
    NSLog(@" %s invoked！", __func__);
}

@end

@implementation NWSwizzlerTest

+ (void)addSwizzler {
    void (^block)(id, SEL, id, id) = ^(id target, SEL command, NSString *param, NSString *param2) {
        NSLog(@"--- %@ -- %@", param, param2);
    };
    [NWSwizzler swizzleSelector:@selector(method3:param2:)
                        onClass:[NWSwizzlerClass class]
                      withBlock:block
                          named:@"event"];
    void (^block2)(id, SEL) = ^(id target, SEL command) {
        NSLog(@"--- method4 -- ");
    };
    [NWSwizzler swizzleSelector:@selector(method4)
                        onClass:[NWSwizzlerClass class]
                      withBlock:block2
                          named:@"eee"];
}

@end
