//
//  NSMutableDictionary+Safe.m
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import "NSMutableDictionary+Safe.h"

@implementation NSMutableDictionary (Safe)

- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
