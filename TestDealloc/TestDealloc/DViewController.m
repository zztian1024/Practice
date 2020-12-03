//
//  DViewController.m
//  TestDealloc
//
//  Created by Tian on 2020/9/25.
//  Copyright © 2020 ziyingtech. All rights reserved.
//

#import "DViewController.h"
#import "DManager.h"

@interface DViewController ()

@end

@implementation DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [[DManager shareManager] unregiste:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"-------- DViewController touchesBegan --------");
    [[DManager shareManager] registe:self];
}

- (void)dealloc {
    NSLog(@"-------- dealloc --------");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
