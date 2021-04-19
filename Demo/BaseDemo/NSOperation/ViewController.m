//
//  ViewController.m
//  NSOperation
//
//  Created by Tian on 2021/4/15.
//

#import "ViewController.h"
#import "OperationTest.h"
#import "ImageListViewController.h"

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
    [tester operationQueueSuspending];
//    [tester downloadOptTest];
//    [tester executionBlockTest];
//    [[[OperationTest alloc] init] blockTest];
//    [OperationTest blockTest];
}

//- (void)showImageListPage {
//    ImageListViewController *imageVC = [[ImageListViewController alloc] init];
//    [self.navigationController pushViewController:imageVC animated:YES];
//}

@end
