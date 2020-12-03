//
//  NWSettings.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <UIKit/UIKit.h>
#import "NWAccessTokenCaching.h"

#define VERSION_STRING @"0.1.0"
#define TARGET_PLATFORM_VERSION @"v8.0"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *const NWLoggingBehavior NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(LoggingBehavior);

FOUNDATION_EXPORT NWLoggingBehavior NWLoggingBehaviorNetworkRequests;
FOUNDATION_EXPORT NWLoggingBehavior NWLoggingBehaviorAccessTokens;
FOUNDATION_EXPORT NWLoggingBehavior NWLoggingBehaviorDeveloperErrors;
FOUNDATION_EXPORT NWLoggingBehavior NWLoggingBehaviorInformational;

#define DATA_PROCESSING_OPTIONS         @"data_processing_options"

@interface NWSettings : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (class, nonatomic, copy, readonly) NSString *sdkVersion;
@property (class, nonatomic, copy, null_resettable) NSString *APIVersion;
@property (class, nullable, nonatomic, readonly, copy) NSString *APIDebugParamValue;
@property (class, nonatomic, assign, getter=isErrorRecoveryEnabled) BOOL errorRecoveryEnabled;
@property (class, nonatomic, copy, nullable) NSString *clientToken;
@property (class, nonatomic, copy, nullable) NSString *appURLSchemeSuffix;
@property (class, nonatomic, copy, nullable) NSString *appID;

@property (class, nonatomic, copy) NSSet<NWLoggingBehavior> *loggingBehaviors
NS_REFINED_FOR_SWIFT;

/**
 The quality of JPEG images sent to Facebook from the SDK,
 expressed as a value from 0.0 to 1.0.

 If not explicitly set, the default is 0.9.

 @see [UIImageJPEGRepresentation](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIKitFunctionReference/#//apple_ref/c/func/UIImageJPEGRepresentation) */
@property (class, nonatomic, assign) CGFloat JPEGCompressionQuality
NS_SWIFT_NAME(jpegCompressionQuality);


#pragma mark - Internal

+ (BOOL)isDataProcessingRestricted;
+ (nullable NSObject<NWAccessTokenCaching> *)accessTokenCache;
+ (nullable NSDictionary<NSString *, id> *)dataProcessingOptions;
+ (void)setAccessTokenCache:(nullable NSObject<NWAccessTokenCaching> *)accessTokenCache;
@property (class, nullable, nonatomic, copy) NSString *userAgentSuffix;

@end

NS_ASSUME_NONNULL_END
