//
//  Person.m
//  Message
//
//  Created by Tian on 2021/5/3.
//

#import "Person.h"
#import <objc/runtime.h>

@implementation Person

//+ (BOOL)resolveInstanceMethod:(SEL)sel {
//    if (sel == @selector(playGames)) {
//        IMP imp = class_getMethodImplementation(self, @selector(watchTV));
//        Method method = class_getInstanceMethod(self, @selector(watchTV));
//        const char *type = method_getTypeEncoding(method);
//        return class_addMethod(self, sel, imp, type);
//    }
//    return [super resolveInstanceMethod:sel];
//}
//
//+ (BOOL)resolveClassMethod:(SEL)sel {
//    if (sel == @selector(nationality)) {
//        // objc_getMetaClass("Person");
//        Class metaCls = object_getClass([self class]);
//        IMP imp = class_getMethodImplementation(self, @selector(watchTV));
//        Method method = class_getInstanceMethod(self, @selector(watchTV));
//        const char *type = method_getTypeEncoding(method);
//        return class_addMethod(metaCls, sel, imp, type);
//    }
//    return [super resolveInstanceMethod:sel];
//}
//
- (void)watchTV {
    NSLog(@"---------- watching TV");
}

//- (id)forwardingTargetForSelector:(SEL)aSelector {
//    return [XXX new];
//}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    Method method = class_getInstanceMethod(self, @selector(watchTV));
//    const char *type = method_getTypeEncoding(method);
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)aSelector {
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    //
    NSLog(@"=====anInvocation=======, 无需处理");
}
@end
