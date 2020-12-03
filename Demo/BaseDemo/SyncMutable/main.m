//
//  main.m
//  SyncMutable
//
//  Created by Tian on 2020/10/27.
//

#import <Foundation/Foundation.h>
#import "SyncMutableDictionary.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        SyncMutableDictionary *mgr = [SyncMutableDictionary new];

        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, dispatch_get_main_queue(), ^{
            for (int i = 0; i < 100; i++) {
                dispatch_group_enter(group);
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    dispatch_group_leave(group);
                    NSLog(@"%d%@", i, [NSThread currentThread]);
                    [mgr setObject:@(i) forKey:@(i)];
                    [mgr removeObjectForKey:@(i-2)];
                });
            }
        });
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            for (NSNumber *key in mgr.allKeys) {
                NSLog(@"----%@", key);
            }
        });
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
