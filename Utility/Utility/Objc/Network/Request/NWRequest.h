//
//  RequestHelper.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import "NWRequestConnection.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSString *const NWHTTPMethod NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(HTTPMethod);

FOUNDATION_EXPORT NWHTTPMethod NWHTTPMethodGET NS_SWIFT_NAME(get);
FOUNDATION_EXPORT NWHTTPMethod NWHTTPMethodPOST NS_SWIFT_NAME(post);
FOUNDATION_EXPORT NWHTTPMethod NWHTTPMethodPUT NS_SWIFT_NAME(put);
FOUNDATION_EXPORT NWHTTPMethod NWHTTPMethodDELETE NS_SWIFT_NAME(delete);

@interface NWRequest : NSObject

@property (nonatomic, copy) NSDictionary<NSString *, id> *parameters;
@property (nonatomic, copy, readonly, nullable) NSString *tokenString;
@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NWHTTPMethod HTTPMethod;

@property (nonatomic, copy, readonly) NSString *version;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithPath:(NSString *)path;

- (instancetype)initWithPath:(NSString *)path HTTPMethod:(NWHTTPMethod)method;

- (instancetype)initWithPath:(NSString *)path parameters:(NSDictionary<NSString *, id> *)parameters;

- (instancetype)initWithPath:(NSString *)path
                  parameters:(NSDictionary<NSString *, id> *)parameters
                  HTTPMethod:(NWHTTPMethod)method;

- (instancetype)initWithPath:(NSString *)path
                  parameters:(NSDictionary<NSString *, id> *)parameters
                 tokenString:(nullable NSString *)tokenString
                     version:(nullable NSString *)version
                  HTTPMethod:(NWHTTPMethod)method NS_DESIGNATED_INITIALIZER;

- (void)setErrorRecoveryDisabled:(BOOL)disable
NS_SWIFT_NAME(setErrorRecovery(disabled:));

- (NWRequestConnection *)startWithCompletionHandler:(nullable NWRequestBlock)handler;

@end

NS_ASSUME_NONNULL_END
