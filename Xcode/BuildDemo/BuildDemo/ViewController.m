//
//  ViewController.m
//  BuildDemo
//
//  Created by Tian on 2020/10/26.
//

#import "ViewController.h"

typedef void(^Callback)(void);

@interface ViewController ()

@property (nonatomic, strong) dispatch_queue_t sendQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sendQueue = dispatch_queue_create("com.nvwa.room.send", DISPATCH_QUEUE_SERIAL);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    
    for (int i = 0; i < 20; i++) {
        NSLog(@"%d", i);

        dispatch_async(self.sendQueue, ^{
            NSLog(@"- %d - %@", i, [NSThread currentThread]);
            [self test:i callback:^{
                NSLog(@"done --- %d", i);
            }];
        });
    }
}

- (void)test:(int)i callback:(Callback)callback {
    float a = arc4random() % 5;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(a * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (callback) {
            callback();
        }
    });
}

@end
