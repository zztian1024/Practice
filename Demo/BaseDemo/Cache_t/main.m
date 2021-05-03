//
//  main.m
//  Cache_t
//
//  Created by Tian on 2021/5/3.
//

#import <Foundation/Foundation.h>
#import "Person.h"

#import <objc/runtime.h>

typedef uint32_t mask_t;
typedef unsigned long  uintptr_t;


struct zy_bucket_t {
    SEL _sel;
    IMP _imp;
};

struct zy_cache_t {
    struct zy_bucket_t *_buckets;
    mask_t _mask;
    uint16_t _flags;
    uint16_t _occupied;
};

struct zy_class_data_bits_t {
    uintptr_t bits;
};

struct zy_objc_class {
    Class ISA;
    Class superclass;
    struct zy_cache_t cache;             // formerly cache pointer and vtable
    struct zy_class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
};

void showClassCache_t(Class cls) {
    NSLog(@"--------- %@", cls);
    struct zy_objc_class *pCls = (__bridge struct zy_objc_class *)(cls);
    for (mask_t i = 0; i < pCls->cache._mask; i++) {
        struct zy_bucket_t bucket = pCls->cache._buckets[i];
        NSLog(@"%d, %@  %p", i, NSStringFromSelector(bucket._sel), bucket._imp);
    }
    IMP imp = class_getMethodImplementation([Person class], @selector(play));
    NSLog(@"%p", imp);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        Person *p = [Person new];
        showClassCache_t([Person class]);
        [p eat];
        showClassCache_t([Person class]);
        [p sing];
        showClassCache_t([Person class]);
        [p play];
        showClassCache_t([Person class]);
        [p run];
        showClassCache_t([Person class]);
        [Person drink];
        showClassCache_t([Person class]);
    }
    return 0;
}
