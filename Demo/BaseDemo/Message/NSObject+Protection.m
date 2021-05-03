//
//  NSObject+Protection.m
//  Objc
//
//  Created by Tian on 2021/5/3.
//

#import "NSObject+Protection.h"
#import <objc/runtime.h>

@implementation NSObject (Protection)
/*
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(playGames)) {
        IMP imp = class_getMethodImplementation(self, @selector(watchTV));
        Method method = class_getInstanceMethod(self, @selector(watchTV));
        const char *type = method_getTypeEncoding(method);
        return class_addMethod(self, sel, imp, type);
    } else if (sel == @selector(nationality)) {
        // objc_getMetaClass("Person");
        Class metaCls = object_getClass([self class]);
        IMP imp = class_getMethodImplementation(self, @selector(watchTV));
        Method method = class_getInstanceMethod(self, @selector(watchTV));
        const char *type = method_getTypeEncoding(method);
        return class_addMethod(metaCls, sel, imp, type);
    }
    // return [super resolveInstanceMethod:sel];
    return NO;
}

- (void)watchTV {
    NSLog(@"NSObject (Protection):---------- watching TV ------");
}
*/
@end
