//
//  NWConstants.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

#ifndef NW_CAST_TO_CLASS_OR_NIL_FUNC
 #define NW_CAST_TO_CLASS_OR_NIL_FUNC
 #ifdef __cplusplus
extern "C" {
 #endif
/** Use the type-safe NW_CAST_TO_CLASS_OR_NIL instead. */
id _CastToClassOrNilUnsafeInternal(id object, Class klass);
 #ifdef __cplusplus
}
 #endif
#endif

#ifndef NW_CAST_TO_CLASS_OR_NIL
 #define NW_CAST_TO_CLASS_OR_NIL(obj_, class_) ((class_ *)_CastToClassOrNilUnsafeInternal(obj_, [class_ class]))
#endif

#ifndef NW_CAST_TO_PROTOCOL_OR_NIL_FUNC
 #define NW_CAST_TO_PROTOCOL_OR_NIL_FUNC
 #ifdef __cplusplus
extern "C" {
 #endif
/** Use the type-safe NW_CAST_TO_PROTOCOL_OR_NIL instead. */
id _CastToProtocolOrNilUnsafeInternal(id object, Protocol *protocol);
 #ifdef __cplusplus
}
 #endif
#endif

#ifndef NW_CAST_TO_PROTOCOL_OR_NIL
 #define NW_CAST_TO_PROTOCOL_OR_NIL(obj_, protocol_) ((id<protocol_>)_FBSDKCastToProtocolOrNilUnsafeInternal(obj_, @protocol(protocol_)))
#endif


NS_ASSUME_NONNULL_BEGIN

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

FOUNDATION_EXPORT NSErrorDomain const NWErrorDomain
NS_SWIFT_NAME(ErrorDomain);

#else

FOUNDATION_EXPORT NSString *const NWErrorDomain
NS_SWIFT_NAME(ErrorDomain);

#endif



#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0

FOUNDATION_EXPORT NSErrorUserInfoKey const NWErrorArgumentCollectionKey
NS_SWIFT_NAME(ErrorArgumentCollectionKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWErrorArgumentNameKey
NS_SWIFT_NAME(ErrorArgumentNameKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWErrorArgumentValueKey
NS_SWIFT_NAME(ErrorArgumentValueKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWErrorDeveloperMessageKey
NS_SWIFT_NAME(ErrorDeveloperMessageKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWErrorLocalizedDescriptionKey
NS_SWIFT_NAME(ErrorLocalizedDescriptionKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWErrorLocalizedTitleKey
NS_SWIFT_NAME(ErrorLocalizedTitleKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWRequestErrorKey
NS_SWIFT_NAME(RequestErrorKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWRequestErrorGraphErrorCodeKey
NS_SWIFT_NAME(RequestErrorGraphErrorCodeKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWRequestErrorGraphErrorSubcodeKey
NS_SWIFT_NAME(RequestErrorGraphErrorSubcodeKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWRequestErrorHTTPStatusCodeKey
NS_SWIFT_NAME(RequestErrorHTTPStatusCodeKey);

FOUNDATION_EXPORT NSErrorUserInfoKey const NWRequestErrorParsedJSONResponseKey
NS_SWIFT_NAME(RequestErrorParsedJSONResponseKey);

#else

FOUNDATION_EXPORT NSString *const NWErrorArgumentCollectionKey
NS_SWIFT_NAME(ErrorArgumentCollectionKey);

FOUNDATION_EXPORT NSString *const NWErrorArgumentNameKey
NS_SWIFT_NAME(ErrorArgumentNameKey);

FOUNDATION_EXPORT NSString *const NWErrorArgumentValueKey
NS_SWIFT_NAME(ErrorArgumentValueKey);

FOUNDATION_EXPORT NSString *const NWErrorDeveloperMessageKey
NS_SWIFT_NAME(ErrorDeveloperMessageKey);

FOUNDATION_EXPORT NSString *const NWErrorLocalizedDescriptionKey
NS_SWIFT_NAME(ErrorLocalizedDescriptionKey);

FOUNDATION_EXPORT NSString *const NWErrorLocalizedTitleKey
NS_SWIFT_NAME(ErrorLocalizedTitleKey);

FOUNDATION_EXPORT NSString *const NWRequestErrorKey
NS_SWIFT_NAME(RequestErrorKey);

FOUNDATION_EXPORT NSString *const NWRequestErrorGraphErrorCodeKey
NS_SWIFT_NAME(RequestErrorGraphErrorCodeKey);

FOUNDATION_EXPORT NSString *const NWRequestErrorGraphErrorSubcodeKey
NS_SWIFT_NAME(RequestErrorGraphErrorSubcodeKey);

FOUNDATION_EXPORT NSString *const NWRequestErrorHTTPStatusCodeKey
NS_SWIFT_NAME(RequestErrorHTTPStatusCodeKey);

FOUNDATION_EXPORT NSString *const NWRequestErrorParsedJSONResponseKey
NS_SWIFT_NAME(RequestErrorParsedJSONResponseKey);

#endif


typedef NS_ENUM(NSUInteger, NWRequestError) {
    NWRequestErrorOther = 0,
    NWRequestErrorTransient = 1,
    NWRequestErrorRecoverable = 2
} NS_SWIFT_NAME(RequestError);

typedef void (^NWCodeBlock)(void)
NS_SWIFT_NAME(CodeBlock);

typedef void (^NWErrorBlock)(NSError *_Nullable error)
NS_SWIFT_NAME(ErrorBlock);

typedef void (^NWSuccessBlock)(BOOL success, NSError *_Nullable error)
NS_SWIFT_NAME(SuccessBlock);


typedef NS_ERROR_ENUM(NWErrorDomain, NWCoreError)
{
  /**
   Reserved.
   */
  NWErrorReserved = 0,

  /**
   The error code for errors from invalid encryption on incoming encryption URLs.
   */
  NWErrorEncryption,

  /**
   The error code for errors from invalid arguments to SDK methods.
   */
  NWErrorInvalidArgument,

  /**
   The error code for unknown errors.
   */
  NWErrorUnknown,

  /**
   A request failed due to a network error. Use NSUnderlyingErrorKey to retrieve
   the error object from the NSURLSession for more information.
   */
  NWErrorNetwork,

  /**
   The error code for errors encountered during an App Events flush.
   */
  NWErrorAppEventsFlush,

  /**
   An endpoint that returns a binary response was used with FBSDKGraphRequestConnection.

   Endpoints that return image/jpg, etc. should be accessed using NSURLRequest
   */
  NWErrorGraphRequestNonTextMimeTypeReturned,

  /**
   The operation failed because the server returned an unexpected response.

   You can get this error if you are not using the most recent SDK, or you are accessing a version of the
   Graph API incompatible with the current SDK.
   */
  NWErrorGraphRequestProtocolMismatch,

  /**
   The Graph API returned an error.

   See below for useful userInfo keys (beginning with FBSDKGraphRequestError*)
   */
  NWErrorGraphRequestGraphAPI,

  /**
   The specified dialog configuration is not available.

   This error may signify that the configuration for the dialogs has not yet been downloaded from the server
   or that the dialog is unavailable.  Subsequent attempts to use the dialog may succeed as the configuration is loaded.
   */
  NWErrorDialogUnavailable,

  /**
   Indicates an operation failed because a required access token was not found.
   */
  NWErrorAccessTokenRequired,

  /**
   Indicates an app switch (typically for a dialog) failed because the destination app is out of date.
   */
  NWErrorAppVersionUnsupported,

  /**
   Indicates an app switch to the browser (typically for a dialog) failed.
   */
  NWErrorBrowserUnavailable,

  NWErrorBridgeAPIInterruption,
} NS_SWIFT_NAME(CoreError);

NS_ASSUME_NONNULL_END

