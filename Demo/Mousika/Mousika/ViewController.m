//
//  ViewController.m
//  Mousika
//
//  Created by Tian on 2021/5/28.
//

#import "ViewController.h"
#import "MSViewController.h"
static NSInteger abc = 100;
const NSInteger  def = 100;
@interface ViewController ()<MSViewControllerDelegate>

@property (nonatomic, strong) MSViewController *msViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.msViewController = [MSViewController new];
    self.msViewController.delegate = self;
    
//    NSMutableArray * arr = [NSMutableArray arrayWithObjects:@"1",@"2", nil];
//    void(^block)(void) = ^{
//        NSLog(@"%@",arr);//局部变量
//        [arr addObject:@"4"];
//    };
//    [arr addObject:@"3"];
//    arr = nil;
//    block();
    //    int a = 10;
    //    void (^blk)(void) = ^{
    ////        NSLog(@"%@", self.view);
    //        NSLog(@"%d", a++);
    //    };
    //    blk();
    //    NSLog(@"%d", a);
    [self testBlock];
}
- (id)getArray {
    int a = 10;
    return [[NSArray alloc] initWithObjects:^{
        NSLog(@"%d", a);
    },^{
        NSLog(@"%d", a);
    }, nil];
}
- (void)testBlock {
    id obj = [self getArray];
    typedef void (^blk_t)(void);
    blk_t blk = [obj objectAtIndex:0];
    blk();
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self presentViewController:self.msViewController animated:YES completion:^{
        
    }];
}

- (void)viewControllerDidDoSomethingSuccess:(MSViewController *)vc {
    NSLog(@"%@", vc);
}

@end
