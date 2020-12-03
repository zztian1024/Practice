//
//  NSMutableDictionary+Safe.h
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (Safe)

- (void)safe_setObject:(id)anObject forKey:(id <NSCopying>)aKey;

@end

NS_ASSUME_NONNULL_END
