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
//(lldb) po [NSRunLoop currentRunLoop]
//<CFRunLoop 0x2804dc200 [0x1f864db20]>{wakeup port = 0x1a03, stopped = false, ignoreWakeUps = true,
//current mode = (none),
//common modes = <CFBasicHash 0x2836968b0 [0x1f864db20]>{type = mutable set, count = 2,
//entries =>
//    0 : <CFString 0x1f8ad27c0 [0x1f864db20]>{contents = "UITrackingRunLoopMode"}
//    2 : <CFString 0x1f882bd90 [0x1f864db20]>{contents = "kCFRunLoopDefaultMode"}
//}
//,
//common mode items = <CFBasicHash 0x283696a60 [0x1f864db20]>{type = mutable set, count = 10,
//entries =>
//    0 : <CFRunLoopSource 0x280dd8240 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x0, callout = <redacted> (0x1bdcc93bc)}}
//    1 : <CFRunLoopSource 0x280dd8480 [0x1f864db20]>{signalled = Yes, valid = Yes, order = 0, context = <CFRunLoopSource context>{version = 0, info = 0x281cd2580, callout = <redacted> (0x1b635c374)}}
//    2 : <CFRunLoopSource 0x280ddc0c0 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 1, info = 0x3103, callout = <redacted> (0x1bdcc93c4)}}
//    3 : <CFRunLoopObserver 0x2809dd360 [0x1f864db20]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 1999000, callout = <redacted> (0x1a98843c4), context = <CFRunLoopObserver context 0x104c048e0>}
//    4 : <CFRunLoopObserver 0x2809dd220 [0x1f864db20]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = <redacted> (0x1a938425c), context = (
//)}
//    5 : <CFRunLoopObserver 0x2809dd180 [0x1f864db20]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = <redacted> (0x1a938425c), context = (
//)}
//    6 : <CFRunLoopSource 0x280ddc6c0 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x2803dc1a0, callout = <redacted> (0x1a98f09ec)}}
//    8 : <CFRunLoopObserver 0x2809dd2c0 [0x1f864db20]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2001000, callout = <redacted> (0x1a9884438), context = <CFRunLoopObserver context 0x104c048e0>}
//    11 : <CFRunLoopSource 0x280ddc240 [0x1f864db20]>{signalled = No, valid = Yes, order = -2, context = <CFRunLoopSource context>{version = 0, info = 0x28368c0f0, callout = <redacted> (0x1a98f0a60)}}
//    12 : <CFRunLoopObserver 0x2809dc320 [0x1f864db20]>{valid = Yes, activities = 0x20, repeats = Yes, order = 0, callout = <redacted> (0x1a93d1f50), context = <CFRunLoopObserver context 0x2813dc540>}
//}
//,
//modes = <CFBasicHash 0x283696850 [0x1f864db20]>{type = mutable set, count = 3,
//entries =>
//    0 : <CFRunLoopMode 0x2803d8340 [0x1f864db20]>{name = UITrackingRunLoopMode, port set = 0x1d03, queue = 0x2816ddd80, source = 0x2816dde80 (not fired), timer port = 0x2a03,
//    sources0 = <CFBasicHash 0x283696ac0 [0x1f864db20]>{type = mutable set, count = 4,
//entries =>
//    0 : <CFRunLoopSource 0x280dd8240 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x0, callout = <redacted> (0x1bdcc93bc)}}
//    1 : <CFRunLoopSource 0x280ddc6c0 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x2803dc1a0, callout = <redacted> (0x1a98f09ec)}}
//    4 : <CFRunLoopSource 0x280dd8480 [0x1f864db20]>{signalled = Yes, valid = Yes, order = 0, context = <CFRunLoopSource context>{version = 0, info = 0x281cd2580, callout = <redacted> (0x1b635c374)}}
//    5 : <CFRunLoopSource 0x280ddc240 [0x1f864db20]>{signalled = No, valid = Yes, order = -2, context = <CFRunLoopSource context>{version = 0, info = 0x28368c0f0, callout = <redacted> (0x1a98f0a60)}}
//}
//,
//    sources1 = <CFBasicHash 0x283696af0 [0x1f864db20]>{type = mutable set, count = 1,
//entries =>
//    1 : <CFRunLoopSource 0x280ddc0c0 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 1, info = 0x3103, callout = <redacted> (0x1bdcc93c4)}}
//}
//,
//    observers = (
//    "<CFRunLoopObserver 0x2809dd220 [0x1f864db20]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = <redacted> (0x1a938425c), context = (\n)}",
//    "<CFRunLoopObserver 0x2809dc320 [0x1f864db20]>{valid = Yes, activities = 0x20, repeats = Yes, order = 0, callout = <redacted> (0x1a93d1f50), context = <CFRunLoopObserver context 0x2813dc540>}",
//    "<CFRunLoopObserver 0x2809dd360 [0x1f864db20]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 1999000, callout = <redacted> (0x1a98843c4), context = <CFRunLoopObserver context 0x104c048e0>}",
//    "<CFRunLoopObserver 0x2809dd2c0 [0x1f864db20]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2001000, callout = <redacted> (0x1a9884438), context = <CFRunLoopObserver context 0x104c048e0>}",
//    "<CFRunLoopObserver 0x2809dd180 [0x1f864db20]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = <redacted> (0x1a938425c), context = (\n)}"
//),
//    timers = (null),
//    currently 642904849 (8700918755565) / soft deadline in: 7.68613974e+11 sec (@ -1) / hard deadline in: 7.68613974e+11 sec (@ -1)
//},
//
//    1 : <CFRunLoopMode 0x2803d8410 [0x1f864db20]>{name = GSEventReceiveRunLoopMode, port set = 0x2b03, queue = 0x2816ddf00, source = 0x2816de000 (not fired), timer port = 0x2c03,
//    sources0 = <CFBasicHash 0x283696b80 [0x1f864db20]>{type = mutable set, count = 1,
//entries =>
//    0 : <CFRunLoopSource 0x280dd8240 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x0, callout = <redacted> (0x1bdcc93bc)}}
//}
//,
//    sources1 = <CFBasicHash 0x283696bb0 [0x1f864db20]>{type = mutable set, count = 1,
//entries =>
//    1 : <CFRunLoopSource 0x280ddc180 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 1, info = 0x3103, callout = <redacted> (0x1bdcc93c4)}}
//}
//,
//    observers = (null),
//    timers = (null),
//    currently 642904849 (8700918807255) / soft deadline in: 7.68613974e+11 sec (@ -1) / hard deadline in: 7.68613974e+11 sec (@ -1)
//},
//
//    2 : <CFRunLoopMode 0x2803d8270 [0x1f864db20]>{name = kCFRunLoopDefaultMode, port set = 0x2103, queue = 0x2816ddb80, source = 0x2816ddc80 (not fired), timer port = 0x2003,
//    sources0 = <CFBasicHash 0x283696b20 [0x1f864db20]>{type = mutable set, count = 4,
//entries =>
//    0 : <CFRunLoopSource 0x280dd8240 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x0, callout = <redacted> (0x1bdcc93bc)}}
//    1 : <CFRunLoopSource 0x280ddc6c0 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 0, info = 0x2803dc1a0, callout = <redacted> (0x1a98f09ec)}}
//    4 : <CFRunLoopSource 0x280dd8480 [0x1f864db20]>{signalled = Yes, valid = Yes, order = 0, context = <CFRunLoopSource context>{version = 0, info = 0x281cd2580, callout = <redacted> (0x1b635c374)}}
//    5 : <CFRunLoopSource 0x280ddc240 [0x1f864db20]>{signalled = No, valid = Yes, order = -2, context = <CFRunLoopSource context>{version = 0, info = 0x28368c0f0, callout = <redacted> (0x1a98f0a60)}}
//}
//,
//    sources1 = <CFBasicHash 0x283696b50 [0x1f864db20]>{type = mutable set, count = 1,
//entries =>
//    1 : <CFRunLoopSource 0x280ddc0c0 [0x1f864db20]>{signalled = No, valid = Yes, order = -1, context = <CFRunLoopSource context>{version = 1, info = 0x3103, callout = <redacted> (0x1bdcc93c4)}}
//}
//,
//    observers = (
//    "<CFRunLoopObserver 0x2809dd220 [0x1f864db20]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = <redacted> (0x1a938425c), context = (\n)}",
//    "<CFRunLoopObserver 0x2809dc320 [0x1f864db20]>{valid = Yes, activities = 0x20, repeats = Yes, order = 0, callout = <redacted> (0x1a93d1f50), context = <CFRunLoopObserver context 0x2813dc540>}",
//    "<CFRunLoopObserver 0x2809dd360 [0x1f864db20]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 1999000, callout = <redacted> (0x1a98843c4), context = <CFRunLoopObserver context 0x104c048e0>}",
//    "<CFRunLoopObserver 0x2809dd2c0 [0x1f864db20]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2001000, callout = <redacted> (0x1a9884438), context = <CFRunLoopObserver context 0x104c048e0>}",
//    "<CFRunLoopObserver 0x2809dd180 [0x1f864db20]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = <redacted> (0x1a938425c), context = (\n)}"
//),
//    timers = <CFArray 0x281cd2d60 [0x1f864db20]>{type = mutable-small, count = 1, values = (
//    0 : <CFRunLoopTimer 0x280dd83c0 [0x1f864db20]>{valid = Yes, firing = No, interval = 0, tolerance = 0, next fire date = 642904834 (-14.424505 @ 8700572696778), callout = (Delayed Perform) UIApplication _accessibilitySetUpQuickSpeak (0x1a82c5664 / 0x1a8d2ea58) (/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore), context = <CFRunLoopTimer context 0x282de6d40>}
//)},
//    currently 642904849 (8700918809098) / soft deadline in: 7.68614336e+11 sec (@ 8700572696778) / hard deadline in: 7.68614336e+11 sec (@ 8700572696778)
//},
//
//}
//}

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
