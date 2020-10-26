//
//  Person.m
//  KVCDemo
//
//  Created by Tian on 2020/10/11.
//

#import "Person.h"

@implementation Toy


@end

@interface Person () {
    int _money;
}


@end

@implementation Person {
    float _salary;
}

- (void)print {
    NSLog(@"%@ %d %.2f %@", _name, _money, _salary, _toy.name);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@" value: %@, key: %@", value, key);
}

@end

