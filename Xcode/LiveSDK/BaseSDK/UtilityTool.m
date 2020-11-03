//
//  UtilityTool.m
//  BaseSDK
//
//  Created by Tian on 2020/11/2.
//

#import "UtilityTool.h"

@implementation UtilityTool

+ (void)initialize {
    [self trackSDK];
    
}

// 获取运行时依赖库信息
// 埋点上报信息
// 支持用户Uid、AppVersion、xxxx
+ (void)trackSDK {
    NSLog(@"--------start---------");
    
    // 异步获取动态下发检查类名？
    // 数据信息采集之后，进行埋点上报
    Class liveSDKService = NSClassFromString(@"LiveSDKService");
    if (liveSDKService) {
        SEL sel = NSSelectorFromString(@"sdkVersion");
        if ([liveSDKService respondsToSelector:sel]) {
            NSLog(@"LiveSDK %@", [liveSDKService performSelector:sel]);
        }
    } else {
        NSLog(@"没有集成 LiveSDK");
    }
    
    NSLog(@"--------end---------");
}

@end
