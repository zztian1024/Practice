//
//  Person.m
//  Clazz
//
//  Created by Tian on 2021/5/6.
//

#import "Person.h"

@implementation Person

- (void)sayHello {
    NSLog(@"my name is: %@ ---------- %s",self.nickName, __func__);
}
@end
