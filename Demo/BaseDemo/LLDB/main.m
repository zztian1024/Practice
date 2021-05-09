//
//  main.m
//  LLDB
//
//  Created by Tian on 2021/4/25.
//

#import <Foundation/Foundation.h>
#import <malloc/malloc.h>
#import <objc/runtime.h>
static int abc = 100;

@interface Man : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) NSInteger gender;

@end
@implementation Man

@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        Man *m = [[Man alloc] init];
        m.age = 20;
        m.name = @"Frank.Tian";
        m.height = 180.5;
        m.gender = 2;
        NSLog(@"%zd", malloc_size((__bridge const void*)m)); // 48
        NSLog(@"%zd", class_getInstanceSize([Man class])); // 40
        NSLog(@"%p", m);
        NSLog(@"%p", &m);
        NSLog(@"%@", m);
        NSLog(@"%p", abc);
        NSLog(@"%p", &abc);
    }
    return 0;
}
