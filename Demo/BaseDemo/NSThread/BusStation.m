//
//  BusStation.m
//  NSThread
//
//  Created by Tian on 2021/4/15.
//

#import "BusStation.h"

@interface BusStation ()

@property (nonatomic, strong) NSLock *lock;

@end

@implementation BusStation

- (instancetype)init {
    if (self = [super init]) {
        _totalCount = 100;
        _conductor1 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
        _conductor2 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
        _conductor3 = [[NSThread alloc]initWithTarget:self selector:@selector(saleTicket) object:nil];
        _conductor1.name = @"售票员1";
        _conductor2.name = @"售票员2";
        _conductor3.name = @"售票员3";
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)startSale {
    [self.conductor1 start];
    [self.conductor2 start];
    [self.conductor3 start];
}

//都卖了1张票，都说还剩下99张，卖的是同一张？😿
//售票员1 卖出去了 1 张票,还剩下 99 张票
//售票员3 卖出去了 1 张票,还剩下 99 张票
//售票员2 卖出去了 1 张票,还剩下 99 张票
- (void)saleTicket2 {
    NSInteger count = self.totalCount;
    if (count > 0) {
        // 模拟其他耗时任务，便于发现问题
        for (NSInteger i = 0; i < 1000000; i++) {
        }
        self.totalCount = count - 1;
        //卖出去一张票
        NSLog(@"%@ 卖出去了 1 张票,还剩下 %zd 张票", [NSThread currentThread].name, self.totalCount);
    } else {
        NSLog(@"没票啦~");
    }
}

//加锁之后，正常工作了😆
//售票员1 卖出去了 1 张票,还剩下 99 张票
//售票员2 卖出去了 1 张票,还剩下 98 张票
//售票员3 卖出去了 1 张票,还剩下 97 张票
- (void)saleTicket1 {
    @synchronized (self) {
        NSInteger count = self.totalCount;
        if (count > 0) {
            // 模拟其他耗时任务，便于发现问题
            for (NSInteger i = 0; i < 1000000; i++) {
            }
            self.totalCount = count - 1;
            //卖出去一张票
            NSLog(@"%@ 卖出去了 1 张票,还剩下 %zd 张票", [NSThread currentThread].name, self.totalCount);
        } else {
            NSLog(@"没票啦~");
        }
    }
}

//NSLock 加锁，正常工作啦😝
//售票员1 卖出去了 1 张票,还剩下 99 张票
//售票员2 卖出去了 1 张票,还剩下 98 张票
//售票员3 卖出去了 1 张票,还剩下 97 张票
- (void)saleTicket {
    [self.lock lock];
    NSInteger count = self.totalCount;
    if (count > 0) {
        // 模拟其他耗时任务，便于发现问题
        for (NSInteger i = 0; i < 1000000; i++) {
        }
        self.totalCount = count - 1;
        //卖出去一张票
        NSLog(@"%@ 卖出去了 1 张票,还剩下 %zd 张票", [NSThread currentThread].name, self.totalCount);
    } else {
        NSLog(@"没票啦~");
    }
    [self.lock unlock];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
