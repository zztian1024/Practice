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
    if(self.isCancelled){
        return;
    }
    
    sleep(5);
    NSLog(@"%s ---%@", __func__, [NSThread currentThread]); // 打印当前线程
    
    // set state
    self.executing = NO;
    self.finished = YES;
    NSLog(@"Finish executing %@", NSStringFromSelector(_cmd));
}

// Operation 入口
- (void)start {
    
    // 无需 call super
    // [super start];
    
    if (self.isCancelled) {
        self.finished = YES;
        return;
    }

    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    self.executing = YES;
}

- (void)setFinished:(BOOL)finished {
//    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
//    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
//    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
//    [self didChangeValueForKey:@"isExecuting"];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
