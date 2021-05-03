//
//  main.m
//  Objc
//
//  Created by Tian on 2021/4/22.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Person.h"

struct class_rw_t {
    
};

struct my_objc_object {
    
};


struct my_objc_class {
    Class isa;
    Class superclass;
};

void test_isa() {
    Person *p = [[Person alloc] init];
    Man *m = [[Man alloc] init];
    Class pCls = [Person class];
    Class mCls = [Man class];
    struct my_objc_class *personCls = (__bridge struct my_objc_class *)([Person class]);
    struct my_objc_class *manCls = (__bridge struct my_objc_class *)([Man class]);
    NSLog(@"%p", personCls);
    NSLog(@"%p", manCls);
    struct my_objc_class *pCls2 = (__bridge struct my_objc_class *)([Person class]);
    struct my_objc_class *mCls1 = (__bridge struct my_objc_class *)([Man class]);

}

void test_superclass() {
    Class objtCls = [NSObject class];
    Class pCls = [Person class];
    Class mCls = [Person class];
    Class personMetaClass = object_getClass([Person class]);
    struct my_objc_class *personMetaClass1 = (__bridge struct my_objc_class *)(personMetaClass);
    NSLog(@"%p", personMetaClass);
    Class objectMetaClass = object_getClass([NSObject class]);
    struct my_objc_class *objectMetaClass1 = (__bridge struct my_objc_class *)(objectMetaClass);
    NSLog(@"%p", objectMetaClass);
    struct my_objc_class *pc = (__bridge struct my_objc_class *)([Person class]);
    
}

void test_class() {
    NSObject *obj = [[NSObject alloc] init];
    NSLog(@"%@", obj);
}

void test_pointer() {
    int a = 20;    /* 实际变量的声明 */
    int *b;        /* 指针变量的声明 */
    b = &a;         /* 在指针变量中存储 a 的地址 */
    printf("a 变量的地址: %p\n", &a  );
    
    // 普通
    int x = 10;
    int y = x;
    NSLog(@"%d ----- %p", x, &x);
    NSLog(@"%d ----- %p", y, &y);
    
    // 对象指针
    NSObject *obj1 = [[NSObject alloc] init];
    NSObject *obj2 = obj1;
    NSLog(@"%@ ----- %p", obj1, &obj1);
    NSLog(@"%@ ----- %p", obj2, &obj2);
    
    // 数组指针
    int arr[4] = {1, 2, 3, 4};
    int *arr2 = arr;
    NSLog(@"%p ==== %p ==== %p", &arr, &arr[0], &arr[1]);
    
    // 偏移
    for (int i = 0; i < 4; i++) {
        int val = *(arr2 + i);
        NSLog(@"---- %d", val);
    }
    
    
}

void isKindofClass_memberOfClass() {
    BOOL res1 = [[NSObject class] isKindOfClass:[NSObject class]];      // 1: 1, 元类 vs 类
    BOOL res2 = [[NSObject class] isMemberOfClass:[NSObject class]];    // 2: 0,
    BOOL res3 = [[Man class] isKindOfClass:[Person class]];             // 3: 0, 元类 vs 类
    BOOL res4 = [[Man class] isMemberOfClass:[Person class]];           // 4: 0,
    
    Man *man = [Man new];
    NSObject *obj = [NSObject new];
    BOOL res5 = [obj isKindOfClass:[NSObject class]];                   // 5: 1, 同类
    BOOL res6 = [obj isMemberOfClass:[NSObject class]];                 // 6: 1, 同类
    BOOL res7 = [man isMemberOfClass:[Person class]];                   // 7: 0, 子类
    BOOL res8 = [man isKindOfClass:[Person class]];                     // 8: 1, 子类
    BOOL res9 = [man isMemberOfClass:[Man class]];                      // 9: 1, 同类
    NSLog(@"1: %d", res1);
    NSLog(@"2: %d", res2);
    NSLog(@"3: %d", res3);
    NSLog(@"4: %d", res4);
    NSLog(@"5: %d", res5);
    NSLog(@"6: %d", res6);
    NSLog(@"7: %d", res7);
    NSLog(@"8: %d", res8);
    NSLog(@"9: %d", res9);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        isKindofClass_memberOfClass();
        test_pointer();
        test_class();
        // class
        Person *p = [[Person alloc] init];
        NSLog(@"%@ %p", [p class], [p class]);
        NSLog(@"%@ %p", object_getClass(p), object_getClass(p));
        NSLog(@"%@ %p", [Person class], [Person class]);
        
        // meta class
        Class personMetaClass = object_getClass([Person class]);
        NSLog(@"%p %p", [Person class], personMetaClass);
        Class objectMetaClass = object_getClass([NSObject class]);
        Class objectMetaClass2 = object_getClass([NSObject class]);
        NSLog(@"%p %p", [NSObject class], objectMetaClass);
        NSLog(@"%p %p", [NSObject class], objectMetaClass2);
        
        // 断是否是元类
        NSLog(@"%d", class_isMetaClass([NSObject class]));  // 0
        NSLog(@"%d", class_isMetaClass(object_getClass([NSObject class]))); // 1
        
        // encode
        char *buf1 = @encode(int);
        char *buf11 = @encode(NSInteger);
        char *buf2 = @encode(float);
        char *buf22 = @encode(CGFloat);
        char *buf3 = @encode(NSString *);
        char *buf33 = @encode(NSObject *);
        NSLog(@"%s %s", buf1, buf11);
        NSLog(@"%s %s", buf2, buf22);
        NSLog(@"%s %s", buf3, buf33);
        
        test_isa();
        test_superclass();
    }
    return 0;
}
