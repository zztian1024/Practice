//
//  CycleObj.m
//  Block
//
//  Created by Tian on 2021/5/7.
//

#import "CycleObj.h"

@implementation CycleObj

//形成了循环引用
- (void)test1 {
    //__weak CycleObj *weakSelf = self;
    self.block = ^() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"========== %@", self.name);
        });
    };
}
//在 Block 内部使用 weakSelf 弱引用 self
//如果block内部嵌套block，需要同时使用__weak 和 __strong
- (void)test2 {
    __weak CycleObj *weakSelf = self;
    self.block = ^() {
        NSLog(@"==========1 %@", weakSelf.name);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"==========2 %@", weakSelf.name);
        });
    };
}

//__block修饰对象，需要注意的是在 block 内部需要置空对象，而且block必须调用
- (void)test3 {
    __block CycleObj *slf = self;
    self.block = ^() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"========== %@", slf.name);
            slf = nil;
        });
    };
}

//如果block内部嵌套block，需要同时使用__weak 和 __strong
- (void)test4 {
    __weak CycleObj *weakSelf = self;
    self.block = ^() {
        // 持有 不能是一个永久持有 - 临时的
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"========== %@", strongSelf.name);
        });
    };
}

- (void)test5 {
    self.block1 = ^(CycleObj *obj) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"========== %@", obj.name);
        });
    };
}

- (void)test {
//    [self test2];
//    [self test3];
//    [self test4];
//    self.block();
    
    [self test5];
    self.block1(self);
}

- (void)dealloc {
    NSLog(@"dealloc 来了");
    // self - 变量都会发送 release
}
@end
