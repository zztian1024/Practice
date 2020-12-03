//
//  DManager.m
//  TestDealloc
//
//  Created by Tian on 2020/9/25.
//  Copyright © 2020 ziyingtech. All rights reserved.
//

#import "DManager.h"

@implementation DManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static DManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[DManager alloc] init];
        manager.dict = [NSMutableDictionary dictionary];
        manager.arr = [NSMutableArray array];
    });
    return manager;
}

- (void)registe:(id)r {
    NSString *key = [NSString stringWithFormat:@"%@", r];
//    [_dict setValue:r forKey:key];
//    NSLog(@"--- %@", _dict);
        [_arr addObject:r];
    NSLog(@"--- %@", _arr);

}

- (void)unregiste:(id)r {
    NSString *key = [NSString stringWithFormat:@"%@", r];
//    [_dict setValue:nil forKey:key];
//    NSLog(@"--- %@", _dict);
    [_arr removeObject:r];
        NSLog(@"--- %@", _arr);
}
@end
