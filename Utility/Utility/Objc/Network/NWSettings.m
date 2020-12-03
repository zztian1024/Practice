//
//  NWSettings.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWSettings.h"

static BOOL _disableErrorRecovery;
static NSString *_defaultAPIVersion;
static NSString *_userAgentSuffix;
static NSMutableSet<NWLoggingBehavior> *_loggingBehaviors;

NWLoggingBehavior NWLoggingBehaviorDeveloperErrors = @"developer_errors";
NWLoggingBehavior NWLoggingBehaviorAPIDebugWarning = @"api_debug_warning";
NWLoggingBehavior NWLoggingBehaviorAPIDebugInfo = @"api_debug_info";
NWLoggingBehavior NWLoggingBehaviorNetworkRequests = @"network_requests";
NWLoggingBehavior NWLoggingBehaviorAccessTokens = @"include_access_tokens";
NWLoggingBehavior NWLoggingBehaviorInformational = @"informational";

#define SETTINGS_PLIST_CONFIGURATION_SETTING_IMPL(TYPE, PLIST_KEY, GETTER, SETTER, DEFAULT_VALUE, ENABLE_CACHE) \
static TYPE *g_ ## PLIST_KEY = nil; \
+ (TYPE *)GETTER \
{ \
if ((g_ ## PLIST_KEY == nil) && ENABLE_CACHE) { \
g_ ## PLIST_KEY = [[[NSUserDefaults standardUserDefaults] objectForKey:@#PLIST_KEY] copy]; \
} \
if (g_ ## PLIST_KEY == nil) { \
g_ ## PLIST_KEY = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@#PLIST_KEY] copy] ?: DEFAULT_VALUE; \
} \
return g_ ## PLIST_KEY; \
} \
+ (void)SETTER:(TYPE *)value { \
g_ ## PLIST_KEY = [value copy]; \
if (ENABLE_CACHE) { \
if (value != nil) { \
[[NSUserDefaults standardUserDefaults] setObject:value forKey:@#PLIST_KEY]; \
} else { \
[[NSUserDefaults standardUserDefaults] removeObjectForKey:@#PLIST_KEY]; \
} \
} \
[NWSettings _logIfSDKSettingsChanged]; \
}

@implementation NWSettings

#pragma mark - Readonly Configuration Settings

+ (NSString *)sdkVersion {
    return VERSION_STRING;
}

+ (NSString *)defaultAPIVersion {
    return TARGET_PLATFORM_VERSION;
}

+ (void)setAPIVersion:(NSString *)version {
    if (![_defaultAPIVersion isEqualToString:version]) {
        _defaultAPIVersion = version;
    }
}

+ (NSString *)APIVersion {
    return _defaultAPIVersion ?: self.defaultAPIVersion;
}

+ (void)updateAPIDebugBehavior {
    // Enable Warnings everytime Info is enabled
    if ([_loggingBehaviors containsObject:NWLoggingBehaviorAPIDebugInfo]
        && ![_loggingBehaviors containsObject:NWLoggingBehaviorAPIDebugWarning]) {
        [_loggingBehaviors addObject:NWLoggingBehaviorAPIDebugWarning];
    }
}

+ (NSString *)APIDebugParamValue {
    if ([[self loggingBehaviors] containsObject:NWLoggingBehaviorAPIDebugInfo]) {
        return @"info";
    } else if ([[self loggingBehaviors] containsObject:NWLoggingBehaviorAPIDebugWarning]) {
        return @"warning";
    }
    
    return nil;
}

+ (NSSet<NWLoggingBehavior> *)loggingBehaviors {
    if (!_loggingBehaviors) {
        NSArray<NWLoggingBehavior> *bundleLoggingBehaviors = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LoggingBehavior"];
        if (bundleLoggingBehaviors) {
            _loggingBehaviors = [[NSMutableSet alloc] initWithArray:bundleLoggingBehaviors];
        } else {
            _loggingBehaviors = [[NSMutableSet alloc] initWithObjects:NWLoggingBehaviorDeveloperErrors, nil];
        }
    }
    return [_loggingBehaviors copy];
}

+ (void)setLoggingBehaviors:(NSSet<NWLoggingBehavior> *)loggingBehaviors {
    if (![_loggingBehaviors isEqualToSet:loggingBehaviors]) {
        _loggingBehaviors = [loggingBehaviors mutableCopy];
        
        [self updateAPIDebugBehavior];
    }
}

+ (void)enableLoggingBehavior:(NWLoggingBehavior)loggingBehavior {
    if (!_loggingBehaviors) {
        [self loggingBehaviors];
    }
    [_loggingBehaviors addObject:loggingBehavior];
    [self updateAPIDebugBehavior];
}

+ (void)disableLoggingBehavior:(NWLoggingBehavior)loggingBehavior {
    if (!_loggingBehaviors) {
        [self loggingBehaviors];
    }
    [_loggingBehaviors removeObject:loggingBehavior];
    [self updateAPIDebugBehavior];
}

+ (BOOL)isErrorRecoveryEnabled {
    return !_disableErrorRecovery;
}

+ (void)setErrorRecoveryEnabled:(BOOL)errorRecoveryEnabled {
    _disableErrorRecovery = !errorRecoveryEnabled;
}

+ (NSString *)userAgentSuffix {
    return _userAgentSuffix;
}

+ (void)setUserAgentSuffix:(NSString *)suffix {
    if (![_userAgentSuffix isEqualToString:suffix]) {
        _userAgentSuffix = suffix;
    }
}

+ (void)setJPEGCompressionQuality:(CGFloat)JPEGCompressionQuality {
    [self _setJPEGCompressionQualityNumber:@(JPEGCompressionQuality)];
}

+ (CGFloat)JPEGCompressionQuality {
    return [self _JPEGCompressionQualityNumber].floatValue;
}


+ (void)_logIfSDKSettingsChanged {
    //...
}

+ (BOOL)isDataProcessingRestricted {
    NSArray<NSString *> *options = [[NWSettings dataProcessingOptions] objectForKey:DATA_PROCESSING_OPTIONS];
    for (NSString *option in options) {
        if ([@"ldu" isEqualToString:[option lowercaseString]]) {
            return YES;
        }
    }
    return NO;
}
#pragma mark - Plist Configuration Settings

SETTINGS_PLIST_CONFIGURATION_SETTING_IMPL(NSString, AppID, appID, setAppID, nil, NO);
SETTINGS_PLIST_CONFIGURATION_SETTING_IMPL(NSNumber, JpegCompressionQuality, _JPEGCompressionQualityNumber, _setJPEGCompressionQualityNumber, @0.9, NO);
SETTINGS_PLIST_CONFIGURATION_SETTING_IMPL(NSString, UrlSchemeSuffix, appURLSchemeSuffix, setAppURLSchemeSuffix, nil, NO);
SETTINGS_PLIST_CONFIGURATION_SETTING_IMPL(NSString, ClientToken, clientToken, setClientToken, nil, NO);

@end
