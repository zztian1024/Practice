//
//  NSMutableArray+Safe.m
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import "NSMutableArray+Safe.h"

@implementation NSArray (Safe)

- (nullable id)safe_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}

@end

@implementation NSMutableArray (Safe)

- (void)safe_addObject:(id)object {
    if (object) {
        [self addObject:object];
    }
}

- (void)safe_addObject:(id)object atIndex:(NSUInteger)index {
    if (object) {
        if (index < self.count) {
            [self insertObject:object atIndex:index];
        } else if (index == self.count) {
            [self addObject:object];
        }
    }
}

@end
