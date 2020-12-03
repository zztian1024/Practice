//
//  DManager.h
//  TestDealloc
//
//  Created by Tian on 2020/9/25.
//  Copyright © 2020 ziyingtech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DManager : NSObject

@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, strong) NSMutableDictionary *dict;
+ (instancetype)shareManager;

- (void)registe:(id)r;
- (void)unregiste:(id)r;

@end

NS_ASSUME_NONNULL_END
