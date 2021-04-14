//
//  main.m
//  NSThread
//
//  Created by Tian on 2020/10/27.
//

#import <Foundation/Foundation.h>
#import "ThreadTest.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        [ThreadTest test];
        NSLog(@"Hello, World!");
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
