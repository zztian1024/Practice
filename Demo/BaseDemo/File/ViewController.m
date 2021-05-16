//
//  ViewController.m
//  File
//
//  Created by Tian on 2021/5/13.
//

#import "ViewController.h"
#import <pthread/pthread.h>

@interface ViewController ()
{
    pthread_rwlock_t _rwlock;
    dispatch_queue_t _queue;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    pthread_rwlock_init(&_rwlock, NULL);
    _queue = dispatch_queue_create("com.file.test", DISPATCH_QUEUE_CONCURRENT);
}

- (id)getArray {
    int a = 10;
    return [NSArray arrayWithObjects:^{
        NSLog(@"%d", a);
    },^{
        NSLog(@"%d", a);
    }, nil];
}

- (void)testBlock {
    NSArray *arr = [self getArray];
    void (^block)(void) = [arr objectAtIndex:1];
    block();
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (IBAction)testFileRead:(id)sender {
    
//    [self testPthread];
//    [self testBarri];
}

- (void)testPthread {
    for (int i = 0; i < 100; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (i % 5 == 0) {
                [self writeFile];
            } else {
                [self readFile];
            }
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (i % 5 == 0) {
                [self writeFile];
            } else {
                [self readFile];
            }
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (i % 5 == 0) {
                [self writeFile];
            } else {
                [self readFile];
            }
        });
    }
}

- (void)testBarri {
    for (int i = 0; i < 100; i++) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (i % 5 == 0) {
                [self writeFile];
            } else {
                [self readFile];
            }
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (i % 5 == 0) {
                [self writeFile];
            } else {
                [self readFile];
            }
        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (i % 5 == 0) {
                [self writeFile];
            } else {
                [self readFile];
            }
        });
    }
}

- (void)readFile1 {
    dispatch_async(_queue, ^{
        NSLog(@"---- read file1: %@", [NSThread currentThread]);
    });
}

- (void)writeFile1 {
    dispatch_barrier_async(_queue, ^{
        NSLog(@"write file: %@", [NSThread currentThread]);
    });
}

- (void)readFile {
    pthread_rwlock_rdlock(&_rwlock);
    NSLog(@"---- read file: %@", [NSThread currentThread]);
    pthread_rwlock_unlock(&_rwlock);
}

- (void)writeFile {
    pthread_rwlock_wrlock(&_rwlock);
    NSLog(@"write file: %@", [NSThread currentThread]);
    sleep(1);
    pthread_rwlock_unlock(&_rwlock);
}
@end
