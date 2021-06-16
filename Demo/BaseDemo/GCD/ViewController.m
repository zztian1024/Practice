//
//  ViewController.m
//  GCD
//
//  Created by Tian on 2021/4/15.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self testAsyncQueue];
//    [self testPerformAndQueue];
//    [self testApply];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self testBarrier];
//    });
//    [self testGroup2];
//    [self testGroup3];
//    [self testSemaphore];
//    [self testSemaphore2];
}

- (void)testAsyncQueue {
    dispatch_queue_t queue = dispatch_queue_create("testqueue", NULL);
    dispatch_async(queue, ^{
        NSLog(@"___dispatch_async 1");
    });
    dispatch_async(queue, ^{
        NSLog(@"___dispatch_async 2");
    });
    dispatch_async(queue, ^{
        NSLog(@"___dispatch_async 3");
    });
}

- (void)testPerformAndQueue {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"___ dispatch_get_main_queue");
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"___dispatch_async dispatch_get_global_queue");
    });
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"___dispatch_sync dispatch_get_global_queue");
    });
    dispatch_queue_t queue = dispatch_queue_create("testqueue", NULL);
    dispatch_async(queue, ^{
        NSLog(@"___dispatch_async dispatch_queue_create");
    });
    dispatch_sync(queue, ^{
        NSLog(@"___dispatch_sync dispatch_queue_create");
    });
}

- (void)testApply {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_apply(100, queue, ^(size_t index) {
        NSLog(@"____ %ld ____ %@", index, [NSThread currentThread]);
    });
}

- (void)testBarrier {
    // 栅栏函数不能使用全局并发队列
    //dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_queue_t queue = dispatch_queue_create("barrier.queue", DISPATCH_QUEUE_CONCURRENT);
    static NSInteger flag = 0;
    dispatch_async(queue, ^{
        NSLog(@"___ read1 ___ %ld", flag);
    });
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"___ read2 ___ %ld", flag);
    });
    
    dispatch_async(queue, ^{
        NSLog(@"___ read22 ___ %ld", flag);
    });
    NSLog(@"-----------before-------------");
    dispatch_barrier_sync(queue, ^{
        flag = 1;
        sleep(4);
        NSLog(@"___ write ___ flag:%ld", flag);
    });
    NSLog(@"-----------after-------------");
    dispatch_sync(queue, ^{
        NSLog(@"___ sync___ %ld", flag);
    });
    dispatch_async(queue, ^{
        NSLog(@"___ read3 ___ %ld", flag);
    });
    dispatch_async(queue, ^{
        NSLog(@"___ read4 ___ %ld", flag);
    });
    NSLog(@"-----------finish-------------");
}


//17:23:21.460217+0800 GCDDemo[31593:3657267] ___ 1-0 ___
//17:23:21.460417+0800 GCDDemo[31593:3657267] ___ 2-0 ___
//17:23:21.460581+0800 GCDDemo[31593:3657267] ___ 3-0 ___
//17:23:22.460666+0800 GCDDemo[31593:3657198] ___ 2-1 ___
//17:23:23.656436+0800 GCDDemo[31593:3657198] ___ 3-1 ___
//17:23:24.751434+0800 GCDDemo[31593:3657198] ___ 1-1 ___
//17:23:24.752171+0800 GCDDemo[31593:3657267] ___ finish ___
- (void)testGroup {

    dispatch_group_t group = dispatch_group_create();
    // DISPATCH_QUEUE_SERIAL , DISPATCH_QUEUE_CONCURRENT
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        NSLog(@"___ 1-0 ___");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"___ 1-1 ___");
            dispatch_group_leave(group);
        });
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        NSLog(@"___ 2-0 ___");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"___ 2-1 ___");
            dispatch_group_leave(group);
        });
    });
    dispatch_group_enter(group);
    dispatch_group_async(group, queue, ^{
        NSLog(@"___ 3-0 ___");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"___ 3-1 ___");
            dispatch_group_leave(group);
        });
    });
     
    dispatch_group_notify(group, queue, ^{
        NSLog(@"___ finish ___");
    });
}

//18:33:14.735730+0800 GCD[5365:381747] __ notify before __
//18:33:14.736143+0800 GCD[5365:381747] __ notify after __
//18:33:14.736460+0800 GCD[5365:381765] __ 1 __
//18:33:17.474928+0800 GCD[5365:381765] __ 2 __
//18:33:17.475136+0800 GCD[5365:381813] __ 全部执行完 __
- (void)testGroup2 {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_group_async(group, queue, ^{
        NSLog(@"__ 1 __");
    });
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i< 1000000000; i++) {
             
        }
        NSLog(@"__ 2 __");
    });
    NSLog(@"__ notify before __");
    dispatch_group_notify(group, queue, ^{
        NSLog(@"__ 全部执行完 __");
    });
    NSLog(@"__ notify after __");
}

// 18:34:06.034265+0800 GCD[5372:382276] __ wait before __
// 18:34:06.034590+0800 GCD[5372:382284] __ 1 __
// 18:34:08.769659+0800 GCD[5372:382289] __ 2 __
// 18:34:08.769787+0800 GCD[5372:382276] __ wait after __
// 18:34:08.769838+0800 GCD[5372:382276] __ 全部执行完 __
- (void)testGroup3 {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_group_async(group, queue, ^{
        NSLog(@"__ 1 __");
    });
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i< 1000000000; i++) {
             
        }
        NSLog(@"__ 2 __");
    });
    NSLog(@"__ wait before __");
    long result = dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"__ wait after __");
    if (result == 0) {
        NSLog(@"__ 全部执行完 __");
    } else {
        NSLog(@"__ 某一部分还在执行中 __");
    }
}

// 18:39:13.308487+0800 GCD[5394:383595] 任务1:<NSThread: 0x280c1d7c0>{number = 8, name = (null)}
// 18:39:13.309662+0800 GCD[5394:383564] 任务2:<NSThread: 0x280c05b40>{number = 5, name = (null)}
// 18:39:14.315594+0800 GCD[5394:383564] 任务3:<NSThread: 0x280c05b40>{number = 5, name = (null)}
- (void)testSemaphore {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
     
    dispatch_async(queue, ^{
        NSLog(@"任务1:%@",[NSThread currentThread]);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:20];
            dispatch_semaphore_signal(sem);
        });
    });
     
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
     
    dispatch_async(queue, ^{
        NSLog(@"任务2:%@",[NSThread currentThread]);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:5];
            dispatch_semaphore_signal(sem);
        });
    });
     
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_async(queue, ^{
        NSLog(@"任务3:%@",[NSThread currentThread]);
    });
}
- (void)testSemaphore2 {
    // A,b,c, 异步执行，A B 之后 d, ABC 之后 E
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"任务A:%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:3];
        dispatch_semaphore_signal(sem);
    });
    dispatch_async(queue, ^{
        NSLog(@"任务B:%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:10];
        dispatch_semaphore_signal(sem);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_async(queue, ^{
        NSLog(@"任务D:%@",[NSThread currentThread]);
        //[NSThread sleepForTimeInterval:3];
    });
    dispatch_async(queue, ^{
        NSLog(@"任务C:%@",[NSThread currentThread]);
        [NSThread sleepForTimeInterval:3];
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_async(queue, ^{
        NSLog(@"任务E:%@",[NSThread currentThread]);
        //[NSThread sleepForTimeInterval:3];
    });
}

@end
