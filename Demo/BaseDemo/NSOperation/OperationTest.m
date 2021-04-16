//
//  OperationTest.m
//  NSOperation
//
//  Created by Tian on 2021/4/16.
//

#import "OperationTest.h"
#import "DownloadOperation.h"

@interface OperationTest ()

@property (nonatomic, strong) NSBlockOperation *blk;
@end

@implementation OperationTest

- (void)blockTest {
    int a = nil;
    NSLog(@"--A");
    _blk = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@---------- %s", [NSThread currentThread], __func__);
    }];
    NSLog(@"--B");
    NSBlockOperation *blk1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@---------- %s", [NSThread currentThread], __func__);
        //sleep(10);
    }];
    NSLog(@"--C");
    _blk.completionBlock = ^{
        NSLog(@"blk.completionBlock：%@---------- %s", [NSThread currentThread], __func__);
    };
    blk1.completionBlock = ^{
        NSLog(@"blk1.completionBlock：%@---------- %s", [NSThread currentThread], __func__);
    };
//    [blk addDependency:blk1];
    [blk1 addObserver:self forKeyPath:@"ready" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [blk1 addObserver:self forKeyPath:@"executing" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [blk1 addObserver:self forKeyPath:@"finished" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [blk1 addObserver:self forKeyPath:@"cancelled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//    [blk cancel];
    
//    [blk1 start];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [_blk start];
    });
    
    NSLog(@"%ld, %ld, %ld", blk1.isCancelled, blk1.isFinished, blk1.isExecuting);
}

// 通过测试，> 7 个addExecutionBlock 任务，会造成blockOperationWithBlock 的默认执行线程
// 但并不是每次都出现
//
- (void)executionBlockTest {
    NSBlockOperation *blk = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 4; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%@blockOperationWithBlock: %s", [NSThread currentThread], __func__);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-1---%@", [NSThread currentThread]);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-2---%@", [NSThread currentThread]);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-3---%@", [NSThread currentThread]);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-4---%@", [NSThread currentThread]);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-5---%@", [NSThread currentThread]);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-6---%@", [NSThread currentThread]);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-7---%@", [NSThread currentThread]);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-8---%@", [NSThread currentThread]);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-0---%@", [NSThread currentThread]);
        }
    }];
    [blk addExecutionBlock:^{
        for (int i = 0; i < 5; i++) {
            [NSThread sleepForTimeInterval:2];
            NSLog(@"addExecutionBlock-10---%@", [NSThread currentThread]);
        }
    }];
    [blk start];
}

- (void)invocationTest {
    
    // 1.create
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(invocationAction) object:self];
    
    // 2.start
    [op start];
}

- (void)invocationAction {
    NSLog(@"%@---------- %s", [NSThread currentThread], __func__);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"----------%@ %@",keyPath, change);
}

- (void)downloadOptTest {
    DownloadOperation *opt = [[DownloadOperation alloc] init];
    [opt addObserver:self forKeyPath:@"ready" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [opt addObserver:self forKeyPath:@"executing" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [opt addObserver:self forKeyPath:@"finished" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [opt addObserver:self forKeyPath:@"cancelled" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    [opt start];
}

- (void)operationQueueTest {
    NSBlockOperation *blk1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@ | %s", [NSThread currentThread], __func__);
        //sleep(10);
    }];
    NSBlockOperation *blk2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"%@ | %s", [NSThread currentThread], __func__);
        //sleep(10);
    }];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [queue addOperation:blk1];
    [queue addOperation:blk2];
}

@end
