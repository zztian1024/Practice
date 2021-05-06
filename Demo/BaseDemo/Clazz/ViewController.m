//
//  ViewController.m
//  Clazz
//
//  Created by Tian on 2021/5/6.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    Class cls = [Person class];
    void *obj = &cls;
    Person *p = [Person new];
    [(__bridge id)obj sayHello];
    [p sayHello];
}


@end
