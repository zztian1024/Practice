//
//  main.m
//  Block
//
//  Created by Tian on 2021/5/7.
//

#import <Foundation/Foundation.h>
#import "CycleObj.h"
#import "SomeObject.h"

//void testBlock () {
//    // 不访问栈区的变量（如局部变量），且不访问堆区的变量（alloc 创建的对象），此时的 block 存放在代码区
//    // _NSConcreteClobalBlock
//    void (^block)(void) = ^{
//        printf("----------\n");
//    };
//    block();
//
//    int (^block_ret)() = ^int(){
//        printf("----------\n");
//        return 1;
//    };
//    int c = block_ret();
//
//    // 在 MRC 下是 NSStackBlock 类型，
//    // 但是在 ARC 下会自动将其拷贝到堆区成为 _NSConcreteMallocBlock，
//    // 在 ARC 下只会有 _NSConcreteClobalBlock 和 _NSConcreteMallocBlock
//    // __NSMallocBlock__
//    int abc = 1;
//    void (^block1)(void) = ^{
//        printf("----------%d\n", abc);
//    };
//    block1();
//
//    void (^__weak block_weak)(void) = ^{
//        printf("----------%d\n", abc);
//    };
//    block_weak();
//    NSLog(@"Hello, World!");
//
//
//
//}

//void testCycleRetain() {
//    CycleObj *cyc = [CycleObj new];
//    cyc.name = @"cyc";
//    [cyc test];
//}

void testLocalCapture() {
    __block SomeObject *obj = [[SomeObject alloc] init];
    void (^block1)(void) = ^{
        NSLog(@"----------%@\n", obj);
    };
    block1();
}
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//        testBlock();
//        testCycleRetain();
        testLocalCapture();
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
