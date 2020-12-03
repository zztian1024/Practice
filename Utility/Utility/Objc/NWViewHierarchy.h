//
//  NWViewHierarchy.h
//  Utility
//
//  Created by Tian on 2020/10/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern void nw_dispatch_on_main_thread(dispatch_block_t block);
extern void nw_dispatch_on_default_thread(dispatch_block_t block);

@interface NWViewHierarchy : NSObject

+ (nullable NSObject *)getParent:(nullable NSObject *)obj;
+ (nullable NSArray<NSObject *> *)getChildren:(NSObject *)obj;
+ (nullable NSArray<NSObject *> *)getPath:(NSObject *)obj;

@end

NS_ASSUME_NONNULL_END
