//
//  User.m
//  Rumtime
//
//  Created by Tian on 2021/5/3.
//

#import "User.h"
#import <objc/runtime.h>

@implementation User

- (id)copyWithZone:(NSZone *)zone {
    unsigned int count;
    Class Cls = [self class];
    id obj = [[Cls allocWithZone:zone] init];
    
    while (Cls != [NSObject class]) {
        objc_property_t *properties = class_copyPropertyList(Cls, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = properties[i];
            const char *name = property_getName(property);
            NSString *key = [NSString stringWithUTF8String:name];
            id value = [self valueForKey:key];
            if ([value respondsToSelector:@selector(copyWithZone:)]) {
                [obj setValue:[value copy] forKey:key];
            }else{
                [obj setValue:value forKey:key];
            }
        }
        if (properties){
           free(properties);
        }
        Cls = class_getSuperclass(Cls);
    }

    return obj;
}

- (void)run {
    NSLog(@"----------- run");
}
+ (void)sayHello {
    NSLog(@"----------- hello");
}
@end
