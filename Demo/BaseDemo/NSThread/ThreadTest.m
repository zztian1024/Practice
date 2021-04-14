//
//  ThreadTest.m
//  NSThread
//
//  Created by Tian on 2021/4/14.
//

#import "ThreadTest.h"
#import "DownloadThread.h"

@implementation ThreadTest

+ (void)test {
    NSThread *thread1 = [[DownloadThread alloc] initWithTarget:self selector:@selector(action) object:nil];
    NSThread *thread2 = [[DownloadThread alloc] initWithBlock:^{
        NSLog(@"thread2");
    }];
    [thread1 start];
    [thread2 start];
    
//    [NSThread detachNewThreadWithBlock:^{
//        NSLog(@"detachNewThreadWithBlock");
//    }];
//    [NSThread detachNewThreadSelector:@selector(action1) toTarget:self withObject:nil];
//    
    [DownloadThread detachNewThreadWithBlock:^{
        NSLog(@"DownloadThread detachNewThreadWithBlock");
    }];
}

+ (void)action1 {
    NSLog(@"detachNewThreadSelector");
}

+ (void)action {
    NSLog(@"thread1, %@", [NSThread currentThread]);
    NSLog(@"thread, %@", [NSThread mainThread]);
}
@end
