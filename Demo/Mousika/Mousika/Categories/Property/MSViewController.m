//
//  MSViewController.m
//  Mousika
//
//  Created by Tian on 2021/5/28.
//

#import "MSViewController.h"

@interface MSViewController ()

@end

@implementation MSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.delegate respondsToSelector:@selector(viewControllerDidDoSomethingSuccess:)]) {
        [self.delegate viewControllerDidDoSomethingSuccess:self];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
