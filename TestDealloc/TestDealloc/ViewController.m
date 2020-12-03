//
//  ViewController.m
//  TestDealloc
//
//  Created by Tian on 2020/9/25.
//  Copyright © 2020 ziyingtech. All rights reserved.
//

#import "ViewController.h"
#import "DViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DViewController *vc = [[DViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
