//
//  NWConstants.c
//  Utility
//
//  Created by Tian on 2020/10/30.
//

#import "NWConstants.h"


id _CastToClassOrNilUnsafeInternal(id object, Class klass)
{
  return [(NSObject *)object isKindOfClass:klass] ? object : nil;
}

id _CastToProtocolOrNilUnsafeInternal(id object, Protocol *protocol)
{
  return [(NSObject *)object conformsToProtocol:protocol] ? object : nil;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

NSErrorDomain const NWErrorDomain = @"com.nw.sdk.core";

#else

NSString *const NWErrorDomain = @"com.nw.sdk.core";

#endif


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

NSErrorUserInfoKey const NWErrorArgumentCollectionKey = @"com.xxxx.sdk:NWErrorArgumentCollectionKey";
NSErrorUserInfoKey const NWErrorArgumentNameKey = @"com.xxxx.sdk:NWErrorArgumentNameKey";
NSErrorUserInfoKey const NWErrorArgumentValueKey = @"com.xxxx.sdk:NWErrorArgumentValueKey";
NSErrorUserInfoKey const NWErrorDeveloperMessageKey = @"com.xxxx.sdk:NWErrorDeveloperMessageKey";
NSErrorUserInfoKey const NWErrorLocalizedDescriptionKey = @"com.xxxx.sdk:NWErrorLocalizedDescriptionKey";
NSErrorUserInfoKey const NWErrorLocalizedTitleKey = @"com.xxxx.sdk:NWErrorLocalizedErrorTitleKey";

NSErrorUserInfoKey const NWGraphRequestErrorKey = @"com.xxxx.sdk:NWGraphRequestErrorKey";
NSErrorUserInfoKey const NWGraphRequestErrorCategoryKey = @"com.xxxx.sdk:NWGraphRequestErrorCategoryKey";
NSErrorUserInfoKey const NWGraphRequestErrorGraphErrorCodeKey = @"com.xxxx.sdk:NWGraphRequestErrorGraphErrorCodeKey";
NSErrorUserInfoKey const NWGraphRequestErrorGraphErrorSubcodeKey = @"com.xxxx.sdk:NWGraphRequestErrorGraphErrorSubcodeKey";
NSErrorUserInfoKey const NWGraphRequestErrorHTTPStatusCodeKey = @"com.xxxx.sdk:NWGraphRequestErrorHTTPStatusCodeKey";
NSErrorUserInfoKey const NWGraphRequestErrorParsedJSONResponseKey = @"com.xxxx.sdk:NWGraphRequestErrorParsedJSONResponseKey";

#else

NSString *const NWErrorArgumentCollectionKey = @"com.xxxx.sdk:NWErrorArgumentCollectionKey";
NSString *const NWErrorArgumentNameKey = @"com.xxxx.sdk:NWErrorArgumentNameKey";
NSString *const NWErrorArgumentValueKey = @"com.xxxx.sdk:NWErrorArgumentValueKey";
NSString *const NWErrorDeveloperMessageKey = @"com.xxxx.sdk:NWErrorDeveloperMessageKey";
NSString *const NWErrorLocalizedDescriptionKey = @"com.xxxx.sdk:NWErrorLocalizedDescriptionKey";
NSString *const NWErrorLocalizedTitleKey = @"com.xxxx.sdk:NWErrorLocalizedErrorTitleKey";

NSString *const NWGraphRequestErrorKey = @"com.xxxx.sdk:NWGraphRequestErrorCategoryKey";
NSString *const NWGraphRequestErrorCategoryKey = @"com.xxxx.sdk:NWGraphRequestErrorCategoryKey";
NSString *const NWGraphRequestErrorGraphErrorCodeKey = @"com.xxxx.sdk:NWGraphRequestErrorGraphErrorCodeKey";
NSString *const NWGraphRequestErrorGraphErrorSubcodeKey = @"com.xxxx.sdk:NWGraphRequestErrorGraphErrorSubcodeKey";
NSString *const NWGraphRequestErrorHTTPStatusCodeKey = @"com.xxxx.sdk:NWGraphRequestErrorHTTPStatusCodeKey";
NSString *const NWGraphRequestErrorParsedJSONResponseKey = @"com.xxxx.sdk:NWGraphRequestErrorParsedJSONResponseKey";

#endif
