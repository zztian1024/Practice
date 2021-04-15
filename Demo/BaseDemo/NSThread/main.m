//
//  main.m
//  NSThread
//
//  Created by Tian on 2020/10/27.
//

#import <Foundation/Foundation.h>
#import "ThreadTest.h"
#import "BusStation.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        [ThreadTest test];
        BusStation *station = [[BusStation alloc] init];
        [station startSale];
        NSLog(@"Hello, World!");
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
