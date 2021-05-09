//
//  ViewController.m
//  Memory
//
//  Created by Tian on 2021/5/9.
//

#import "ViewController.h"

extern uintptr_t objc_debug_taggedpointer_obfuscator;


@interface Person : NSObject
 
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, copy) NSString *name;

@end

@implementation Person
 
@end

@interface ViewController ()

@property (nonatomic, copy) NSString *sign;
@property (nonatomic, strong) NSString *hobby;

@end

@implementation ViewController

static inline uintptr_t
_objc_decodeTaggedPointer(const void * _Nullable ptr)
{
    return (uintptr_t)ptr ^ objc_debug_taggedpointer_obfuscator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sign = @"xxx";
    self.hobby = @"abc";
    
    NSLog(@"%lu", _objc_decodeTaggedPointer(&_sign));
    
    
    
    
    Person *p = [[Person alloc] init];
    p.uid = 20;
    p.name = @"Frank.Tian";
    
    
}


@end
