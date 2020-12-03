//
//  NSMutableArray+Safe.h
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Safe)

- (nullable id)safe_objectAtIndex:(NSUInteger)index;

@end

@interface NSMutableArray (Safe)

- (void)safe_addObject:(id)object;
- (void)safe_addObject:(nullable id)object atIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
