//
//  DownloadThread.m
//  NSThread
//
//  Created by Tian on 2021/4/14.
//

#import "DownloadThread.h"

@implementation DownloadThread

- (void)main {
    NSLog(@"----------- DownloadThread main ---------");
    [self performSelector:@selector(doSomething)];
//    [self performSelector:@selector(doSomething) withObject:nil afterDelay:3];
//    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
//    [runloop addPort:[NSPort port] forMode:NSRunLoopCommonModes];
//    [runloop run];
}
 
- (void)doSomething {
    NSLog(@"%s", __func__);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
