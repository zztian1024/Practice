//
//  UtilityTools.m
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import "UtilityTools.h"
#import "NSString+URL.h"
#import "NSData+JSON.h"
#import "NSMutableArray+Safe.h"
#import "NSMutableDictionary+Safe.h"
#import "NWApplicationDelegate.h"
#import "NWSettings.h"
#import "NWLogger.h"
#import "NWError.h"

#import <sys/time.h>

@implementation UtilityTools

+ (NSString *)URLEncode:(NSString *)value {
    return [value URLEncode];
}

+ (NSString *)URLDecode:(NSString *)value {
    return [value URLDecode];
}

+ (BOOL)isValidJSONObject:(id)obj {
    return [NSJSONSerialization isValidJSONObject:obj];
}

+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError *__autoreleasing _Nullable *)error {
    return [NSData dataWithJSONObject:obj options:opt error:error];
}

+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError *__autoreleasing _Nullable *)error {
    return [NSData JSONObjectWithData:data options:opt error:error];
}

+ (id)objectForJSONString:(NSString *)string error:(NSError *__autoreleasing *)errorRef
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        if (errorRef != NULL) {
            *errorRef = nil;
        }
        return nil;
    }
    return [UtilityTools JSONObjectWithData:data options:NSJSONReadingAllowFragments error:errorRef];
}

+ (NSData *)gzip:(NSData *)data {
    return [data gzipData];
}

+ (NSString *)SHA256Hash:(NSObject *)input {
    return [NSString SHA256Hash:input];
}

+ (dispatch_source_t)startGCDTimerWithInterval:(double)interval block:(dispatch_block_t)block {
    dispatch_source_t timer = dispatch_source_create(
                                                     DISPATCH_SOURCE_TYPE_TIMER, // source type
                                                     0, // handle
                                                     0, // mask
                                                     dispatch_get_main_queue()
                                                     ); // queue
    
    dispatch_source_set_timer(
                              timer, // dispatch source
                              dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), // start
                              interval * NSEC_PER_SEC, // interval
                              0 * NSEC_PER_SEC
                              ); // leeway
    
    dispatch_source_set_event_handler(timer, block);
    
    dispatch_resume(timer);
    
    return timer;
}

+ (void)stopGCDTimer:(dispatch_source_t)timer {
    if (timer) {
        dispatch_source_cancel(timer);
    }
}

+ (NSBundle *)bundleForStrings {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *stringsBundlePath = [[NSBundle bundleForClass:[NWApplicationDelegate class]]
                                       pathForResource:@"SDKStrings"
                                       ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:stringsBundlePath] ?: [NSBundle mainBundle];
    });
    return bundle;
}

+ (uint64_t)currentTimeInMilliseconds {
    struct timeval time;
    gettimeofday(&time, NULL);
    return ((uint64_t)time.tv_sec * 1000) + (time.tv_usec / 1000);
}

+ (NSURL *)URLWithHostPrefix:(NSString *)hostPrefix path:(NSString *)path queryParameters:(NSDictionary<NSString *,NSString *> *)queryParameters defaultVersion:(NSString *)defaultVersion error:(NSError *__autoreleasing  _Nullable *)errorRef {
    if (hostPrefix.length && ![hostPrefix hasSuffix:@"."]) {
        hostPrefix = [hostPrefix stringByAppendingString:@"."];
    }
    
    NSString *host = @"xxx.com";
    host = [NSString stringWithFormat:@"%@%@", hostPrefix ?: @"", host ?: @""];
    
    NSString *version = (defaultVersion.length > 0) ? defaultVersion : [NWSettings APIVersion];
    if (version.length) {
        version = [@"/" stringByAppendingString:version];
    }
    
    if (path.length) {
        NSScanner *versionScanner = [[NSScanner alloc] initWithString:path];
        if ([versionScanner scanString:@"/v" intoString:NULL]
            && [versionScanner scanInteger:NULL]
            && [versionScanner scanString:@"." intoString:NULL]
            && [versionScanner scanInteger:NULL]) {
            [NWLogger singleShotLogEntry:NWLoggingBehaviorDeveloperErrors
                                logEntry:[NSString stringWithFormat:@"Invalid Graph API version:%@, assuming %@ instead",
                                          version,
                                          [NWSettings APIVersion]]];
            version = nil;
        }
        if (![path hasPrefix:@"/"]) {
            path = [@"/" stringByAppendingString:path];
        }
    }
    path = [[NSString alloc] initWithFormat:@"%@%@", version ?: @"", path ?: @""];
    
    return [self URLWithScheme:@"https"
                          host:host
                          path:path
               queryParameters:queryParameters
                         error:errorRef];
}

+ (BOOL)isOSRunTimeVersionAtLeast:(NSOperatingSystemVersion)version {
    return ([self _compareOperatingSystemVersion:[self operatingSystemVersion] toVersion:version] != NSOrderedAscending);
}

+ (NSOperatingSystemVersion)operatingSystemVersion
{
    static NSOperatingSystemVersion operatingSystemVersion = {
        .majorVersion = 0,
        .minorVersion = 0,
        .patchVersion = 0,
    };
    static dispatch_once_t getVersionOnce;
    dispatch_once(&getVersionOnce, ^{
        if ([NSProcessInfo instancesRespondToSelector:@selector(operatingSystemVersion)]) {
            operatingSystemVersion = [NSProcessInfo processInfo].operatingSystemVersion;
        } else {
            NSArray *components = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
            switch (components.count) {
                default:
                case 3:
                    operatingSystemVersion.patchVersion = [[components safe_objectAtIndex:2] integerValue];
                    // fall through
                case 2:
                    operatingSystemVersion.minorVersion = [[components safe_objectAtIndex:1] integerValue];
                    // fall through
                case 1:
                    operatingSystemVersion.majorVersion = [[components safe_objectAtIndex:0] integerValue];
                    break;
            }
        }
    });
    return operatingSystemVersion;
}

+ (NSURL *)URLWithScheme:(NSString *)scheme
                    host:(NSString *)host
                    path:(NSString *)path
         queryParameters:(NSDictionary *)queryParameters
                   error:(NSError *__autoreleasing *)errorRef
{
    if (![path hasPrefix:@"/"]) {
        path = [@"/" stringByAppendingString:path ?: @""];
    }
    
    NSString *queryString = nil;
    if (queryParameters.count) {
        NSError *queryStringError;
        queryString = [@"?" stringByAppendingString:[NSString queryStringWithDictionary:queryParameters
                                                                                  error:&queryStringError
                                                                   invalidObjectHandler:NULL]];
        if (!queryString) {
            if (errorRef != NULL) {
                *errorRef = [NWError invalidArgumentErrorWithName:@"queryParameters"
                                                            value:queryParameters
                                                          message:nil
                                                  underlyingError:queryStringError];
            }
            return nil;
        }
    }
    
    NSURL *const URL = [NSURL URLWithString:[NSString stringWithFormat:
                                             @"%@://%@%@%@",
                                             scheme ?: @"",
                                             host ?: @"",
                                             path ?: @"",
                                             queryString ?: @""]];
    if (errorRef != NULL) {
        if (URL) {
            *errorRef = nil;
        } else {
            *errorRef = [NWError unknownErrorWithMessage:@"Unknown error building URL."];
        }
    }
    return URL;
}

+ (void)deleteAppCookies
{
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *appCookies = [cookies cookiesForURL:[self URLWithHostPrefix:@"m."
                                                                    path:@"/dialog/"
                                                         queryParameters:@{}
                                                          defaultVersion:@""
                                                                   error:NULL]];
    
    for (NSHTTPCookie *cookie in appCookies) {
        [cookies deleteCookie:cookie];
    }
}

static NSMapTable *_transientObjects;

+ (void)registerTransientObject:(id)object
{
    NSAssert([NSThread isMainThread], @"Must be called from the main thread!");
    if (!_transientObjects) {
        _transientObjects = [[NSMapTable alloc] init];
    }
    NSUInteger count = ((NSNumber *)[_transientObjects objectForKey:object]).unsignedIntegerValue;
    [_transientObjects setObject:@(count + 1) forKey:object];
}

+ (void)unregisterTransientObject:(__weak id)object
{
    if (!object) {
        return;
    }
    NSAssert([NSThread isMainThread], @"Must be called from the main thread!");
    NSUInteger count = ((NSNumber *)[_transientObjects objectForKey:object]).unsignedIntegerValue;
    if (count == 1) {
        [_transientObjects removeObjectForKey:object];
    } else if (count != 0) {
        [_transientObjects setObject:@(count - 1) forKey:object];
    } else {
        [NWLogger singleShotLogEntry:NWLoggingBehaviorDeveloperErrors
                        formatString:@"unregisterTransientObject:%@ count is 0. This may indicate a bug in the FBSDK. Please"
         " file a report to developers.facebook.com/bugs if you encounter any problems. Thanks!", [object class]];
    }
}

+ (UIViewController *)viewControllerForView:(UIView *)view
{
    UIResponder *responder = view.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    }
    return nil;
}

+ (BOOL)isAppInstalled {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UtilityTools checkRegisteredCanOpenURLScheme:NW_CANOPENURL_APP];
    });
    return [self _canOpenURLScheme:NW_CANOPENURL_APP];
}

#pragma mark - Helper Methods

+ (NSComparisonResult)_compareOperatingSystemVersion:(NSOperatingSystemVersion)version1
                                           toVersion:(NSOperatingSystemVersion)version2
{
    if (version1.majorVersion < version2.majorVersion) {
        return NSOrderedAscending;
    } else if (version1.majorVersion > version2.majorVersion) {
        return NSOrderedDescending;
    } else if (version1.minorVersion < version2.minorVersion) {
        return NSOrderedAscending;
    } else if (version1.minorVersion > version2.minorVersion) {
        return NSOrderedDescending;
    } else if (version1.patchVersion < version2.patchVersion) {
        return NSOrderedAscending;
    } else if (version1.patchVersion > version2.patchVersion) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

+ (BOOL)_canOpenURLScheme:(NSString *)scheme
{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = scheme;
    components.path = @"/";
    return [[UIApplication sharedApplication] canOpenURL:components.URL];
}

+ (void)validateAppID
{
    if (![NWSettings appID]) {
        NSString *reason = @"App ID not found. Add a string value with your app ID for the key "
        @"FacebookAppID to the Info.plist or call [FBSDKSettings setAppID:].";
        @throw [NSException exceptionWithName:@"InvalidOperationException" reason:reason userInfo:nil];
    }
}

+ (NSString *)validateRequiredClientAccessToken
{
    if (![NWSettings clientToken]) {
        NSString *reason = @"ClientToken is required to be set for this operation. "
        @"Set the ClientToken in the Info.plist or call [NWSettings setClientToken:]. "
        @"You can find your client token in your App Settings -> Advanced.";
        @throw [NSException exceptionWithName:@"InvalidOperationException" reason:reason userInfo:nil];
    }
    return [NSString stringWithFormat:@"%@|%@", [NWSettings appID], [NWSettings clientToken]];
}

+ (void)validateURLSchemes
{
    [self validateAppID];
    NSString *defaultUrlScheme = [NSString stringWithFormat:@"fb%@%@", [NWSettings appID], [NWSettings appURLSchemeSuffix] ?: @""];
    if (![self isRegisteredURLScheme:defaultUrlScheme]) {
        NSString *reason = [NSString stringWithFormat:@"%@ is not registered as a URL scheme. Please add it in your Info.plist", defaultUrlScheme];
        @throw [NSException exceptionWithName:@"InvalidOperationException" reason:reason userInfo:nil];
    }
}

+ (void)validateFacebookReservedURLSchemes
{
    for (NSString *fbUrlScheme in @[NW_CANOPENURL_APP, NW_CANOPENURL_MESSENGER, NW_CANOPENURL_FBAPI, NW_CANOPENURL_SHARE_EXTENSION]) {
        if ([self isRegisteredURLScheme:fbUrlScheme]) {
            NSString *reason = [NSString stringWithFormat:@"%@ is registered as a URL scheme. Please move the entry from CFBundleURLSchemes in your Info.plist to LSApplicationQueriesSchemes. If you are trying to resolve \"canOpenURL: failed\" warnings, those only indicate that the Facebook app is not installed on your device or simulator and can be ignored.", fbUrlScheme];
            @throw [NSException exceptionWithName:@"InvalidOperationException" reason:reason userInfo:nil];
        }
    }
}

+ (UIWindow *)findWindow
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIWindow *topWindow = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop
    if (topWindow == nil || topWindow.windowLevel < UIWindowLevelNormal) {
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window.windowLevel >= topWindow.windowLevel && !window.isHidden) {
                topWindow = window;
            }
        }
    }
    
    if (topWindow != nil) {
        return topWindow;
    }
    
    // Find active key window from UIScene
    if (@available(iOS 13.0, tvOS 13, *)) {
        NSSet *scenes = [[UIApplication sharedApplication] valueForKey:@"connectedScenes"];
        for (id scene in scenes) {
            id activationState = [scene valueForKeyPath:@"activationState"];
            BOOL isActive = activationState != nil && [activationState integerValue] == 0;
            if (isActive) {
                Class WindowScene = NSClassFromString(@"UIWindowScene");
                if ([scene isKindOfClass:WindowScene]) {
                    NSArray<UIWindow *> *windows = [scene valueForKeyPath:@"windows"];
                    for (UIWindow *window in windows) {
                        if (window.isKeyWindow) {
                            return window;
                        } else if (window.windowLevel >= topWindow.windowLevel && !window.isHidden) {
                            topWindow = window;
                        }
                    }
                }
            }
        }
    }
    
    if (topWindow == nil) {
        [NWLogger singleShotLogEntry:NWLoggingBehaviorDeveloperErrors
                        formatString:@"Unable to find a valid UIWindow", nil];
    }
    return topWindow;
}

+ (UIViewController *)topMostViewController
{
    UIWindow *keyWindow = [self findWindow];
    // SDK expects a key window at this point, if it is not, make it one
    if (keyWindow != nil && !keyWindow.isKeyWindow) {
        [NWLogger singleShotLogEntry:NWLoggingBehaviorDeveloperErrors
                        formatString:@"Unable to obtain a key window, marking %@ as keyWindow", keyWindow.description];
        [keyWindow makeKeyWindow];
    }
    
    UIViewController *topController = keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

#if !TARGET_OS_TV
+ (UIInterfaceOrientation)statusBarOrientation
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        return [self findWindow].windowScene.interfaceOrientation;
    } else {
        return UIInterfaceOrientationUnknown;
    }
#else
    return UIApplication.sharedApplication.statusBarOrientation;
#endif
}

#endif

+ (NSString *)hexadecimalStringFromData:(NSData *)data
{
    NSUInteger dataLength = data.length;
    if (dataLength == 0) {
        return nil;
    }
    
    const unsigned char *dataBuffer = data.bytes;
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for (int i = 0; i < dataLength; ++i) {
        [hexString appendFormat:@"%02x", dataBuffer[i]];
    }
    return [hexString copy];
}

+ (BOOL)isRegisteredURLScheme:(NSString *)urlScheme
{
    static dispatch_once_t fetchBundleOnce;
    static NSArray *urlTypes = nil;
    
    dispatch_once(&fetchBundleOnce, ^{
        urlTypes = [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleURLTypes"];
    });
    for (NSDictionary *urlType in urlTypes) {
        NSArray *urlSchemes = [urlType valueForKey:@"CFBundleURLSchemes"];
        if ([urlSchemes containsObject:urlScheme]) {
            return YES;
        }
    }
    return NO;
}

+ (void)checkRegisteredCanOpenURLScheme:(NSString *)urlScheme
{
    static dispatch_once_t initCheckedSchemesOnce;
    static NSMutableSet *checkedSchemes = nil;
    
    dispatch_once(&initCheckedSchemesOnce, ^{
        checkedSchemes = [NSMutableSet set];
    });
    
    @synchronized(self) {
        if ([checkedSchemes containsObject:urlScheme]) {
            return;
        } else {
            [checkedSchemes addObject:urlScheme];
        }
    }
    
    if (![self isRegisteredCanOpenURLScheme:urlScheme]) {
        NSString *reason = [NSString stringWithFormat:@"%@ is missing from your Info.plist under LSApplicationQueriesSchemes and is required.", urlScheme];
        [NWLogger singleShotLogEntry:NWLoggingBehaviorDeveloperErrors logEntry:reason];
    }
}

+ (BOOL)isRegisteredCanOpenURLScheme:(NSString *)urlScheme
{
    static dispatch_once_t fetchBundleOnce;
    static NSArray *schemes = nil;
    
    dispatch_once(&fetchBundleOnce, ^{
        schemes = [[NSBundle mainBundle].infoDictionary valueForKey:@"LSApplicationQueriesSchemes"];
    });
    
    return [schemes containsObject:urlScheme];
}

+ (BOOL)isPublishPermission:(NSString *)permission
{
    return [permission hasPrefix:@"publish"]
    || [permission hasPrefix:@"manage"]
    || [permission isEqualToString:@"ads_management"]
    || [permission isEqualToString:@"create_event"]
    || [permission isEqualToString:@"rsvp_event"];
}

+ (BOOL)isUnity
{
    NSString *userAgentSuffix = [NWSettings userAgentSuffix];
    if (userAgentSuffix != nil && [userAgentSuffix rangeOfString:@"Unity"].location != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
