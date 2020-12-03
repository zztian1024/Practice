//
//  UtilityTools.h
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define NW_CANOPENURL_APP @"auth2"
#define NW_CANOPENURL_FBAPI @"api"
#define NW_CANOPENURL_MESSENGER @"messenger-share-api"
#define NW_CANOPENURL_MSQRD_PLAYER @"msqrdplayer"
#define NW_CANOPENURL_SHARE_EXTENSION @"shareextension"


@interface UtilityTools : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Encodes a value for an URL.
 @param value The value to encode.
 @return The encoded value.
 */
+ (NSString *)URLEncode:(NSString *)value;

/**
 Decodes a value from an URL.
 @param value The value to decode.
 @return The decoded value.
 */
+ (NSString *)URLDecode:(NSString *)value;

/*
 Lightweight wrapper around Foundation's isValidJSONObject:
 
 Returns YES if the given object can be converted to JSON data, NO otherwise.
 Calling this method or attempting a conversion are the definitive ways to tell if a given object can be converted to JSON data.
 */
+ (BOOL)isValidJSONObject:(id)obj;

+ (nullable id)objectForJSONString:(NSString *)string error:(NSError *__autoreleasing *)errorRef;

/*
 Lightweight safety wrapper around Foundation's NSJSONSerialization:dataWithJSONObject:options:error:
 
 Generate JSON data from a Foundation object.
 If the object will not produce valid JSON then null is returned.
 Setting the NSJSONWritingPrettyPrinted option will generate JSON with whitespace designed to make the output more readable.
 If that option is not set, the most compact possible JSON will be generated.
 If an error occurs, the error parameter will be set and the return value will be nil.
 The resulting data is a encoded in UTF-8.
 */
+ (nullable NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

/*
 Lightweight safety wrapper around Foundation's NSJSONSerialization:JSONObjectWithData:options:error:
 
 Create a Foundation object from JSON data.
 Set the NSJSONReadingAllowFragments option if the parser should allow top-level objects that are not an NSArray or NSDictionary.
 Setting the NSJSONReadingMutableContainers option will make the parser generate mutable NSArrays and NSDictionaries.
 Setting the NSJSONReadingMutableLeaves option will make the parser generate mutable NSString objects.
 If an error occurs during the parse, then the error parameter will be set and the result will be nil.
 The data must be in one of the 5 supported encodings listed in the JSON specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE.
 The data may or may not have a BOM.
 The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
 */
+ (nullable id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

/**
 Gzip data with default compression level if possible.
 @param data The raw data.
 @return nil if unable to gzip the data, otherwise gzipped data.
 */
+ (nullable NSData *)gzip:(NSData *)data;
+ (nullable NSString *)SHA256Hash:(nullable NSObject *)input;

/**
  Creates a timer using Grand Central Dispatch.
 @param interval The interval to fire the timer, in seconds.
 @param block The code block to execute when timer is fired.
 @return The dispatch handle.
 */
+ (dispatch_source_t)startGCDTimerWithInterval:(double)interval block:(dispatch_block_t)block;

/**
 Stop a timer that was started by startGCDTimerWithInterval.
 @param timer The dispatch handle received from startGCDTimerWithInterval.
 */
+ (void)stopGCDTimer:(dispatch_source_t)timer;

+ (NSBundle *)bundleForStrings;
+ (uint64_t)currentTimeInMilliseconds;

+ (NSURL *)URLWithHostPrefix:(NSString *)hostPrefix
                        path:(NSString *)path
             queryParameters:(NSDictionary<NSString *, NSString *> *)queryParameters
              defaultVersion:(NSString *)defaultVersion
                       error:(NSError *__autoreleasing *)errorRef;

+ (nullable NSURL *)URLWithScheme:(NSString *)scheme
                             host:(NSString *)host
                             path:(NSString *)path
                  queryParameters:(NSDictionary *)queryParameters
                            error:(NSError *__autoreleasing *)errorRef;

/**
  Tests whether the supplied URL is a valid URL for opening in the browser.
 @param URL The URL to test.
 @return YES if the URL refers to an http or https resource, otherwise NO.
 */
+ (BOOL)isBrowserURL:(NSURL *)URL;

/**
  Tests whether the supplied bundle identifier references a Facebook app.
 @param bundleIdentifier The bundle identifier to test.
 @return YES if the bundle identifier refers to a Facebook app, otherwise NO.
 */
+ (BOOL)isFacebookBundleIdentifier:(NSString *)bundleIdentifier;

/**
  Tests whether the operating system is at least the specified version.
 @param version The version to test against.
 @return YES if the operating system is greater than or equal to the specified version, otherwise NO.
 */
+ (BOOL)isOSRunTimeVersionAtLeast:(NSOperatingSystemVersion)version;

/**
  Tests whether the supplied bundle identifier references the Safari app.
 @param bundleIdentifier The bundle identifier to test.
 @return YES if the bundle identifier refers to the Safari app, otherwise NO.
 */
+ (BOOL)isSafariBundleIdentifier:(NSString *)bundleIdentifier;

/**
  Checks equality between 2 objects.

 Checks for pointer equality, nils, isEqual:.
 @param object The first object to compare.
 @param other The second object to compare.
 @return YES if the objects are equal, otherwise NO.
 */
+ (BOOL)object:(id)object isEqualToObject:(id)other;

/**
 *  Deletes all the cookies in the NSHTTPCookieStorage for app web dialogs
 */
+ (void)deleteAppCookies;

/**
  Extracts permissions from a response fetched from me/permissions
 @param responseObject the response
 @param grantedPermissions the set to add granted permissions to
 @param declinedPermissions the set to add declined permissions to.
 */
+ (void)extractPermissionsFromResponse:(NSDictionary *)responseObject
                    grantedPermissions:(NSMutableSet *)grantedPermissions
                   declinedPermissions:(NSMutableSet *)declinedPermissions
                    expiredPermissions:(NSMutableSet *)expiredPermissions;

/**
  Registers a transient object so that it will not be deallocated until unregistered
 @param object The transient object
 */
+ (void)registerTransientObject:(id)object;

/**
  Unregisters a transient object that was previously registered with registerTransientObject:
 @param object The transient object
 */
+ (void)unregisterTransientObject:(__weak id)object;

/**
  validates that the app ID is non-nil, throws an NSException if nil.
 */
+ (void)validateAppID;

/**
 Validates that the client access token is non-nil, otherwise - throws an NSException otherwise.
 Returns the composed client access token.
 */
+ (NSString *)validateRequiredClientAccessToken;

/**
  validates that the right URL schemes are registered, throws an NSException if not.
 */
+ (void)validateURLSchemes;

/**
  validates that Facebook reserved URL schemes are not registered, throws an NSException if they are.
 */
+ (void)validateFacebookReservedURLSchemes;

/**
  Attempts to find the first UIViewController in the view's responder chain. Returns nil if not found.
 */
+ (nullable UIViewController *)viewControllerForView:(UIView *)view;

/**
  returns true if the url scheme is registered in the CFBundleURLTypes
 */
+ (BOOL)isRegisteredURLScheme:(NSString *)urlScheme;

/**
 returns the current key window
 */
+ (nullable UIWindow *)findWindow;

/**
  returns currently displayed top view controller.
 */
+ (nullable UIViewController *)topMostViewController;

#if !TARGET_OS_TV
/**
  returns interface orientation for the key window.
 */
+ (UIInterfaceOrientation)statusBarOrientation;
#endif

/**
  Converts NSData to a hexadecimal UTF8 String.
 */
+ (nullable NSString *)hexadecimalStringFromData:(NSData *)data;

/*
  Checks if the permission is a publish permission.
 */
+ (BOOL)isPublishPermission:(NSString *)permission;

#pragma mark - FB Apps Installed

@property (class, nonatomic, assign, readonly) BOOL isAppInstalled;

+ (void)checkRegisteredCanOpenURLScheme:(NSString *)urlScheme;
+ (BOOL)isRegisteredCanOpenURLScheme:(NSString *)urlScheme;

#define FBSDKConditionalLog(condition, loggingBehavior, desc, ...) \
{ \
  if (!(condition)) { \
    NSString *msg = [NSString stringWithFormat:(desc), ##__VA_ARGS__]; \
    [FBSDKLogger singleShotLogEntry:loggingBehavior logEntry:msg]; \
  } \
}

#define FB_BASE_URL @"xxxxx.com"

@end

NS_ASSUME_NONNULL_END
