//
//  ViewController.m
//  Notification
//
//  Created by Tian on 2020/11/15.
//

#import "ViewController.h"

static NSString *kNotificationName = @"testNotification";
static NSString *kNotificationName2 = @"testNotification2";

@interface ViewController ()<NSMachPortDelegate>

/* Threaded notification support. */
@property (nonatomic) NSMutableArray *notifications;
@property (nonatomic) NSThread *notificationThread;
@property (nonatomic) NSLock *notificationLock;
@property (nonatomic) NSMachPort *notificationPort;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"----------addObserver thread: %@", [NSThread currentThread]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:kNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processNotification:) name:kNotificationName2 object:nil];

    self.notifications      = [[NSMutableArray alloc] init];
    self.notificationLock   = [[NSLock alloc] init];
    self.notificationThread = [NSThread currentThread];
 
    self.notificationPort = [[NSMachPort alloc] init];
    [self.notificationPort setDelegate:self];
    [[NSRunLoop currentRunLoop] addPort:self.notificationPort forMode:(__bridge NSString *)kCFRunLoopCommonModes];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"----------postNotification thread: %@", [NSThread currentThread]);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName object:@"hello world"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationName2 object:@"222222222"];
    });
}

- (void)notificationHandler:(NSNotification *)notification {
    NSLog(@"----------handler notification thread: %@", [NSThread currentThread]);
}

- (void)handleMachMessage:(void *)msg {

    [self.notificationLock lock];

    while ([self.notifications count]) {
        NSNotification *notification = [self.notifications objectAtIndex:0];
        [self.notifications removeObjectAtIndex:0];
        [self.notificationLock unlock];
        [self processNotification:notification];
        [self.notificationLock lock];
    };

    [self.notificationLock unlock];
}

- (void)processNotification:(NSNotification *)notification {

    if ([NSThread currentThread] != _notificationThread) {
        // Forward the notification to the correct thread.
        [self.notificationLock lock];
        [self.notifications addObject:notification];
        [self.notificationLock unlock];
        [self.notificationPort sendBeforeDate:[NSDate date]
                                   components:nil
                                         from:nil
                                     reserved:0];
    }
    else {
        // Process the notification here;
        NSLog(@"current thread = %@", [NSThread currentThread]);
        NSLog(@"process notification");
    }
}

@end
