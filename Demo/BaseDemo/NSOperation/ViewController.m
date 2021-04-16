//
//  ViewController.m
//  NSOperation
//
//  Created by Tian on 2021/4/15.
//

#import "ViewController.h"
#import "OperationTest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    OperationTest *tester = [[OperationTest alloc] init];
//    [tester operationQueueTest];
//    [tester downloadOptTest];
    [tester executionBlockTest];
//    [[[OperationTest alloc] init] blockTest];
//    [OperationTest blockTest];
}

@end
