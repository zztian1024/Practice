//
//  ViewController.m
//  Event
//
//  Created by Tian on 2021/5/16.
//

#import "ViewController.h"
#import "RedView.h"
#import "GreenView.h"

@interface ViewController ()

@property (nonatomic, strong) RedView *redView;
@property (nonatomic, strong) GreenView *greenView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addSubViews];
}

- (void)addSubViews {
    RedView *redView = [RedView new];
    redView.frame = CGRectMake(20, 100, 300, 300);
    redView.backgroundColor = [UIColor redColor];
    self.redView = redView;
    [self.view addSubview:self.redView];
    
    GreenView *greenView = [GreenView new];
    greenView.frame = CGRectMake(50, 50, 200, 200);
    greenView.backgroundColor = [UIColor greenColor];
    self.greenView = greenView;
    [self.redView addSubview:self.greenView];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 8.1
//      * frame #0: 0x0000000104511fe0 Event`-[ViewController touchesBegan:withEvent:](self=0x0000000104b0b580, _cmd="touchesBegan:withEvent:", touches=1 element, event=0x00000002836c00c0) at ViewController.m:23:1
//        frame #1: 0x00000001a9887998 UIKitCore`forwardTouchMethod + 316
//        frame #2: 0x00000001a9887848 UIKitCore`-[UIResponder touchesBegan:withEvent:] + 60
//        frame #3: 0x00000001a9895964 UIKitCore`-[UIWindow _sendTouchesForEvent:] + 640
//        frame #4: 0x00000001a98974e8 UIKitCore`-[UIWindow sendEvent:] + 3824
//        frame #5: 0x00000001a9872b0c UIKitCore`-[UIApplication sendEvent:] + 744
//        frame #6: 0x00000001a98f5078 UIKitCore`__dispatchPreprocessedEventFromEventQueue + 1032
//        frame #7: 0x00000001a98f9818 UIKitCore`__processEventQueue + 6440
//        frame #8: 0x00000001a98f0afc UIKitCore`__eventFetcherSourceCallback + 156
//        frame #9: 0x00000001a6f69bf0 CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 24
//        frame #10: 0x00000001a6f69af0 CoreFoundation`__CFRunLoopDoSource0 + 204
//        frame #11: 0x00000001a6f68e38 CoreFoundation`__CFRunLoopDoSources0 + 256
//        frame #12: 0x00000001a6f633e0 CoreFoundation`__CFRunLoopRun + 776
//        frame #13: 0x00000001a6f62ba0 CoreFoundation`CFRunLoopRunSpecific + 572
//        frame #14: 0x00000001bdcc8598 GraphicsServices`GSEventRunModal + 160
//        frame #15: 0x00000001a98542f4 UIKitCore`-[UIApplication _run] + 1052
//        frame #16: 0x00000001a9859874 UIKitCore`UIApplicationMain + 164
//        frame #17: 0x0000000104512268 Event`main(argc=1, argv=0x000000016b8f38b0) at main.m:17:12
//        frame #18: 0x00000001a6c41568 libdyld.dylib`start + 4

}
@end
