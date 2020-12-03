//
//  NWError.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWError : NSObject

+ (NSError *)errorWithCode:(NSInteger)code message:(nullable NSString *)message;

+ (NSError *)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code message:(nullable NSString *)message;

+ (NSError *)errorWithCode:(NSInteger)code
                   message:(nullable NSString *)message
           underlyingError:(nullable NSError *)underlyingError;

+ (NSError *)errorWithDomain:(NSErrorDomain)domain
                        code:(NSInteger)code
                     message:(nullable NSString *)message
             underlyingError:(nullable NSError *)underlyingError;

+ (NSError *)errorWithCode:(NSInteger)code
                  userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)userInfo
                   message:(nullable NSString *)message
           underlyingError:(nullable NSError *)underlyingError;

+ (NSError *)errorWithDomain:(NSErrorDomain)domain
                        code:(NSInteger)code
                    userInfo:(nullable NSDictionary<NSErrorUserInfoKey, id> *)userInfo
                     message:(nullable NSString *)message
             underlyingError:(nullable NSError *)underlyingError;

+ (NSError *)invalidArgumentErrorWithName:(NSString *)name
                                    value:(nullable id)value
                                  message:(nullable NSString *)message;

+ (NSError *)invalidArgumentErrorWithDomain:(NSErrorDomain)domain
                                       name:(NSString *)name
                                      value:(nullable id)value
                                    message:(nullable NSString *)message;

+ (NSError *)invalidArgumentErrorWithName:(NSString *)name
                                    value:(nullable id)value
                                  message:(nullable NSString *)message
                          underlyingError:(nullable NSError *)underlyingError;

+ (NSError *)invalidArgumentErrorWithDomain:(NSErrorDomain)domain
                                       name:(NSString *)name
                                      value:(nullable id)value
                                    message:(nullable NSString *)message
                            underlyingError:(nullable NSError *)underlyingError;

+ (NSError *)invalidCollectionErrorWithName:(NSString *)name
                                 collection:(id<NSFastEnumeration>)collection
                                       item:(id)item
                                    message:(nullable NSString *)message;

+ (NSError *)invalidCollectionErrorWithName:(NSString *)name
                                 collection:(id<NSFastEnumeration>)collection
                                       item:(id)item
                                    message:(nullable NSString *)message
                            underlyingError:(nullable NSError *)underlyingError;

+ (NSError *)requiredArgumentErrorWithName:(NSString *)name message:(nullable NSString *)message;

+ (NSError *)requiredArgumentErrorWithDomain:(NSErrorDomain)domain
                                        name:(NSString *)name
                                     message:(nullable NSString *)message;

+ (NSError *)requiredArgumentErrorWithName:(NSString *)name
                                   message:(nullable NSString *)message
                           underlyingError:(nullable NSError *)underlyingError;

+ (NSError *)unknownErrorWithMessage:(NSString *)message;

+ (BOOL)isNetworkError:(NSError *)error;
+ (void)enableErrorReport;

@end

NS_ASSUME_NONNULL_END
