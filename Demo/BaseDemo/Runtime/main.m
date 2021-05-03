//
//  main.m
//  Rumtime
//
//  Created by Tian on 2020/10/18.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "User.h"

/// Runtime 知识点
/// 1、消息机制
/// 2、方法交换
/// 3、动态添加方法
/// 4、动态添加属性
/// 5、自动生成属性
/// 6、字典转模型KVC
///

void getInstanceMethod(Class cls) {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    
    for (unsigned int i = 0; i < count; i++) {
        Method const method = methods[i];
        NSString *key = NSStringFromSelector(method_getName(method));
        NSLog(@"%@\n", key);
    }
    free(methods);
}

void getClassMethod(Class cls) {
    getInstanceMethod(object_getClass(cls));
}

void geIMPMetaClass(Class cls) {
    const char *clsName = class_getName(cls);
    // 其实直接传入 类对象，用object_getClass 方法得到的即是元类对象
    Class metaCls = objc_getMetaClass(clsName);
    SEL sayHello = @selector(sayHello);
    IMP sayHelloImp = class_getMethodImplementation(metaCls, sayHello);
    BOOL (* sayHelloFunc)(id, SEL) = (void *)sayHelloImp;
    sayHelloFunc(metaCls, sayHello);

    id user = [cls new];
    SEL run = @selector(run);
    IMP runImp = class_getMethodImplementation(cls, run);
    BOOL (* runFunc)(id, SEL) = (void *)runImp;
    runFunc(user, run);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        getInstanceMethod(User.class);
        printf("-------------\n");
        getClassMethod(User.class);
        printf("-------------\n");
        geIMPMetaClass(User.class);
        
        User *user = [[User alloc] init];
        User *user2 = [User new];
        [user2 run];
        [user run];
        [User sayHello];
        
        [User singSong];
        // 调用方法
        objc_msgSend(user, @selector(run));
        objc_msgSend(user, sel_registerName("run"));
        objc_msgSend(objc_getClass("User"), sel_registerName("sayHello"));
        
        printf("-------objc_msgSendSuper------\n");
        // objc_msgSendSuper
        struct objc_super objSuper;
        objSuper.receiver = user;
        objSuper.super_class = [User class];
        objc_msgSendSuper(&objSuper, sel_registerName("run"));
    }
    return 0;
}
