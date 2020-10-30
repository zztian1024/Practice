//
//  Setting.m
//  Property
//
//  Created by Tian on 2020/10/30.
//

#import "Setting.h"

static NSString *_defaultAPIVersion;
static NSString *_defaultName = @"AppName";

@implementation Setting

+ (NSString *)name {
    return _defaultName;
}

+ (NSString *)APIVersion {
    return _defaultAPIVersion;
}

+ (void)setAPIVersion:(NSString *)APIVersion {
    if (![_defaultAPIVersion isEqualToString:APIVersion]) {
        _defaultAPIVersion = APIVersion;
    }
}

@end
