//
//  SyncMutableDictionary.h
//  SyncMutable
//
//  Created by Tian on 2020/10/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SyncMutableDictionary : NSObject

@property (nonatomic, strong) NSMutableDictionary *dictionary;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

- (id)objectForKey:(id)aKey;
- (NSArray *)allKeys;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (void)removeObjectForKey:(id)aKey;

@end

NS_ASSUME_NONNULL_END
