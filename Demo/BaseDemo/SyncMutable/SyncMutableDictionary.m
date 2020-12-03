//
//  SyncMutableDictionary.m
//  SyncMutable
//
//  Created by Tian on 2020/10/27.
//

#import "SyncMutableDictionary.h"

@implementation SyncMutableDictionary

- (instancetype)init {
    if (self = [super init]) {
        _dictionary = [NSMutableDictionary dictionary];
        _dispatchQueue = dispatch_queue_create("com.test.sycmutabledictionary", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSArray *)allKeys {
    __block NSArray *allKeys = nil;
    dispatch_sync(self.dispatchQueue, ^{
        allKeys = [self.dictionary allKeys];
    });
    return allKeys;
}

- (id)objectForKey:(id)aKey {
    __block id obj = nil;
    dispatch_sync(self.dispatchQueue, ^{
        obj = [self.dictionary objectForKey:aKey];
    });

    return obj;
}

- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey {
    dispatch_sync(self.dispatchQueue, ^{
        if (anObject && aKey) {
            [self.dictionary setObject:anObject forKey:aKey];
            NSLog(@"set:%@ %@",anObject, [NSThread currentThread]);
        }
    });
}

- (void)removeObjectForKey:(id)aKey {
    dispatch_sync(self.dispatchQueue, ^{
        NSLog(@"remove:%@ %@",aKey, [NSThread currentThread]);
        [self.dictionary removeObjectForKey:aKey];
    });
}
@end
