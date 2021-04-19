//
//  DownloadOperation.m
//  NSOperation
//
//  Created by Tian on 2021/4/16.
//

#import "DownloadOperation.h"

@interface DownloadOperation ()

@property (nonatomic, assign, getter=isExecuting) BOOL executing;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

@end

@implementation DownloadOperation
// 合成实例变量，用来重写
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)init {
    if (self = [super init]) {
        _executing = NO;
        _finished = NO;
    }
    return self;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)main {
    
    // 支持取消的 Operation
//    if(self.isCancelled){
//        return;
//    }
//
//    sleep(5);
//    NSLog(@"%s ---%@", __func__, [NSThread currentThread]); // 打印当前线程
//

    NSURL *url = [NSURL URLWithString:self.url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *imgae = [UIImage imageWithData:data];
    NSLog(@"--%@--",[NSThread currentThread]);
    // set state
//    self.executing = NO;
//    self.finished = YES;
    NSLog(@"Finish executing %@", NSStringFromSelector(_cmd));
    
    // 图片下载完毕后，通知代理
    if ([self.delegate respondsToSelector:@selector(downloadOperation:didFishedDownLoad:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate downloadOperation:self didFishedDownLoad:imgae];
        });
    }
}

// Operation 入口
/**
- (void)start {
    
    // 无需 call super
    // [super start];
    
//    if (self.isCancelled) {
//        self.finished = YES;
//        return;
//    }
//
//    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
//    self.executing = YES;
    // Always check for cancellation before launching the task.
    
    
    if ([self isCancelled]) {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    // If the operation is not canceled, begin executing the task.
//    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
//    _executing = YES;
//    [self didChangeValueForKey:@"isExecuting"];
}
 */

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
