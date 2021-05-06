//
//  ViewController.m
//  AOP
//
//  Created by Tian on 2020/12/3.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "UIControl+ClickInterval.h"

@interface ViewController ()

@end

@implementation ViewController

- (instancetype)init {
    if (self = [super init]) {
        //...
    }
    NSLog(@"---------init");
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        //...
    }
    NSLog(@"---------initWithCoder");
    return self;
}

+ (void)load {
    NSLog(@"---------load");
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = [self class];
        
        SEL originalSelector = @selector(viewDidLoad);
        SEL swizzledSelector = @selector(viewDidLoad_swizzle);
        
        Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
        BOOL didAddMethod = class_addMethod(aClass,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
                                            method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(aClass,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
        NSLog(@"---------onceToken");
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"---------viewDidLoad");
}

- (void)viewDidLoad_swizzle {
    NSLog(@"---------viewDidLoad_swizzle");
    [self viewDidLoad_swizzle];
    [UIControl ci_exchangeClickMethod];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}
@end
