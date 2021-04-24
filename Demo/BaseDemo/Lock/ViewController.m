//
//  ViewController.m
//  Lock
//
//  Created by Tian on 2021/4/19.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSLock *lock1;
@property (nonatomic, assign) NSInteger money;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lock1 = [[NSLock alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self nslockTest];
}


- (void)nslockTest {
    self.money = 1000;
    for (int i = 0; i < 10; i++) {
        if (i % 2 == 0) {
            [NSThread detachNewThreadSelector:@selector(saveMoney) toTarget:self withObject:nil];
        } else {
            [NSThread detachNewThreadSelector:@selector(withdrawMoney) toTarget:self withObject:nil];
        }
    }
}

- (void)saveMoney {
    
    [self.lock1 lock];// 加锁
    @synchronized (self) {
       
        // 模拟其他耗时任务，便于发现问题
        for (NSInteger i = 0; i < 1000000; i++) {
            self.money += 10;
        }
        NSLog(@"存钱结束, 余额：%ld, %@", self.money, [NSThread currentThread]);
        
    }
    [self.lock1 unlock];// 解锁
}

- (void)withdrawMoney{
    
    [self.lock1 lock]; // 加锁
    if (self.money - 10 > 0) {
        // 模拟其他耗时任务，便于发现问题
        for (NSInteger i = 0; i < 1000000; i++) {
            self.money -= 10;
        }
        NSLog(@"取钱结束，余额：%ld, %@", self.money, [NSThread currentThread]);
    } else {
        NSLog(@"余额不足~");
    }

    [self.lock1 unlock];// 解锁
}

@end
