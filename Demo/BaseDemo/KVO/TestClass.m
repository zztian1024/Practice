//
//  TestClass.m
//  KVO
//
//  Created by Tian on 2020/10/18.
//

#import "TestClass.h"

@implementation Person

@end

@implementation TestClass

- (void)test {
    Person *p = [Person new];
    [p addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    p.name = @"Li";
    p.name = @"Tian";
    p.name = @"Wang";
}

/// 监听属性值发生改变
/// @param keyPath 属性
/// @param object 属性的对象
/// @param change 改变的内容
/// @param context 上下文
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@ -- %@ -- %@", keyPath, object, change);
}

@end
