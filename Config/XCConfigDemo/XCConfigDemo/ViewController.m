//
//  ViewController.m
//  XCConfigDemo
//
//  Created by Tian on 2021/5/30.
//

#import "ViewController.h"

//https://xcodebuildsettings.com/

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 读取Info.plist 中的 BASE_URL
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSLog(@"%@", infoDict[@"BASE_URL"]);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self abc];
}
@end
