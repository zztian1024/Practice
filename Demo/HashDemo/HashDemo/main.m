//
//  main.m
//  HashDemo
//
//  Created by Tian on 2021/6/16.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSDate *birthday;

@end

@implementation Person

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[Person class]]) {
        return NO;
    }
    
    return [self isEqualToPerson:(Person *)object];
}

- (BOOL)isEqualToPerson:(Person *)person {
    if (!person) {
        return NO;
    }
    
    BOOL haveEqualNames = (!self.name && !person.name) || [self.name isEqualToString:person.name];
    BOOL haveEqualBirthdays = (!self.birthday && !person.birthday) || [self.birthday isEqualToDate:person.birthday];
    
    return haveEqualNames && haveEqualBirthdays;
}

- (NSUInteger)hash {
    printf("%p, %ld \n", self, (uintptr_t)self);
    return [self.name hash] ^ [self.birthday hash];
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        
        
        int a = 10;
        int b = 10;
        
        printf("a:%d == b:%d : %d \n",a, b, a == b);
        
        Person *p1 = [Person new];
        p1.name = @"p";
        Person *p2 = [Person new];
        p2.name = @"p";
        Person *p3 = p2;
        
        printf("p1:%p == p2:%p : %d \n",p1, p2, p1 == p2);
        printf("p2:%p == p3:%p : %d \n",p2, p3, p2 == p3);
        
        printf("p1:%p isEqual:p2:%p : %d \n",p1, p2, [p1 isEqual:p2]);
        
        printf("p1 hash:%ld, p2 hash:%ld \n", [p1 hash], [p2 hash]);
        
        NSString *abc = @"abc";
        NSString *abc1 = @"abc";
        NSString *def = [NSString stringWithFormat:@"%@", @"abc"];
        NSString *xyz = [NSString stringWithString:@"abc"];
        NSString *uvw = [NSString stringWithCString:"abc" encoding:NSUTF8StringEncoding];
        
        NSMutableSet *set = [NSMutableSet set];
        [set addObject:p1];
        [set addObject:p2];
        printf("set count: %d \n",[set count]);
        
        NSMutableArray *mArr = [NSMutableArray array];
        [mArr addObject:p1];
        [mArr addObject:p2];
        printf("mArr count: %d \n",[mArr count]);
        [mArr containsObject:p1];
        [mArr removeObject:p2];

    }
    return 0;
}
