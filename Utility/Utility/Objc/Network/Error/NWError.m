//
//  NWError.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWError.h"
#import "NWConstants.h"
#import "NSMutableArray+Safe.h"
#import "NSMutableDictionary+Safe.h"
#import "NWErrorReport.h"

@implementation NWError

static BOOL isErrorReportEnabled = NO;

#pragma mark - Class Methods

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message {
    return [self errorWithCode:code message:message underlyingError:nil];
}

+ (NSError *)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code message:(NSString *)message {
    return [self errorWithDomain:domain code:code message:message underlyingError:nil];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message underlyingError:(NSError *)underlyingError {
    return [self errorWithCode:code userInfo:@{} message:message underlyingError:underlyingError];
}

+ (NSError *)errorWithDomain:(NSErrorDomain)domain
                        code:(NSInteger)code
                     message:(NSString *)message
             underlyingError:(NSError *)underlyingError {
    return [self errorWithDomain:domain code:code userInfo:@{} message:message underlyingError:underlyingError];
}

+ (NSError *)errorWithCode:(NSInteger)code
                  userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)userInfo
                   message:(NSString *)message
           underlyingError:(NSError *)underlyingError {
    return [self errorWithDomain:NWErrorDomain
                            code:code
                        userInfo:userInfo
                         message:message
                 underlyingError:underlyingError];
}

+ (NSError *)errorWithDomain:(NSErrorDomain)domain
                        code:(NSInteger)code
                    userInfo:(NSDictionary<NSErrorUserInfoKey, id> *)userInfo
                     message:(NSString *)message
             underlyingError:(NSError *)underlyingError {
    NSMutableDictionary *fullUserInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    [fullUserInfo safe_setObject:message forKey:NWErrorDeveloperMessageKey];
    [fullUserInfo safe_setObject:underlyingError forKey:NSUnderlyingErrorKey];
    userInfo = fullUserInfo.count ? [fullUserInfo copy] : nil;
    if (isErrorReportEnabled) {
        [NWErrorReport saveError:code errorDomain:domain message:message];
    }
    
    return [[NSError alloc] initWithDomain:domain code:code userInfo:userInfo];
}

+ (NSError *)invalidArgumentErrorWithName:(NSString *)name value:(id)value message:(NSString *)message {
    return [self invalidArgumentErrorWithName:name value:value message:message underlyingError:nil];
}

+ (NSError *)invalidArgumentErrorWithDomain:(NSErrorDomain)domain
                                       name:(NSString *)name
                                      value:(id)value
                                    message:(NSString *)message {
    return [self invalidArgumentErrorWithDomain:domain name:name value:value message:message underlyingError:nil];
}

+ (NSError *)invalidArgumentErrorWithName:(NSString *)name
                                    value:(id)value
                                  message:(NSString *)message
                          underlyingError:(NSError *)underlyingError {
    return [self invalidArgumentErrorWithDomain:NWErrorDomain
                                           name:name
                                          value:value
                                        message:message
                                underlyingError:underlyingError];
}

+ (NSError *)invalidArgumentErrorWithDomain:(NSErrorDomain)domain
                                       name:(NSString *)name
                                      value:(id)value
                                    message:(NSString *)message
                            underlyingError:(NSError *)underlyingError {
    if (!message) {
        message = [[NSString alloc] initWithFormat:@"Invalid value for %@: %@", name, value];
    }
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo safe_setObject:name forKey:NWErrorArgumentNameKey];
    [userInfo safe_setObject:value forKey:NWErrorArgumentValueKey];
    return [self errorWithDomain:domain
                            code:NWErrorInvalidArgument
                        userInfo:userInfo
                         message:message
                 underlyingError:underlyingError];
}

+ (NSError *)invalidCollectionErrorWithName:(NSString *)name
                                 collection:(id<NSFastEnumeration>)collection
                                       item:(id)item
                                    message:(NSString *)message {
    return [self invalidCollectionErrorWithName:name collection:collection item:item message:message underlyingError:nil];
}

+ (NSError *)invalidCollectionErrorWithName:(NSString *)name
                                 collection:(id<NSFastEnumeration>)collection
                                       item:(id)item
                                    message:(NSString *)message
                            underlyingError:(NSError *)underlyingError {
    if (!message) {
        message =
        [[NSString alloc] initWithFormat:@"Invalid item (%@) found in collection for %@: %@", item, name, collection];
    }
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo safe_setObject:name forKey:NWErrorArgumentNameKey];
    [userInfo safe_setObject:item forKey:NWErrorArgumentValueKey];
    [userInfo safe_setObject:collection forKey:NWErrorArgumentCollectionKey];
    return [self errorWithCode:NWErrorInvalidArgument
                      userInfo:userInfo
                       message:message
               underlyingError:underlyingError];
}

+ (NSError *)requiredArgumentErrorWithName:(NSString *)name message:(NSString *)message {
    return [self requiredArgumentErrorWithName:name message:message underlyingError:nil];
}

+ (NSError *)requiredArgumentErrorWithDomain:(NSErrorDomain)domain name:(NSString *)name message:(NSString *)message {
    if (!message) {
        message = [[NSString alloc] initWithFormat:@"Value for %@ is required.", name];
    }
    return [self invalidArgumentErrorWithDomain:domain name:name value:nil message:message underlyingError:nil];
}

+ (NSError *)requiredArgumentErrorWithName:(NSString *)name
                                   message:(NSString *)message
                           underlyingError:(NSError *)underlyingError {
    if (!message) {
        message = [[NSString alloc] initWithFormat:@"Value for %@ is required.", name];
    }
    return [self invalidArgumentErrorWithName:name value:nil message:message underlyingError:underlyingError];
}

+ (NSError *)unknownErrorWithMessage:(NSString *)message {
    return [self errorWithCode:NWErrorUnknown userInfo:@{} message:message underlyingError:nil];
}

+ (BOOL)isNetworkError:(NSError *)error {
    NSError *innerError = error.userInfo[NSUnderlyingErrorKey];
    if (innerError && [self isNetworkError:innerError]) {
        return YES;
    }
    
    switch (error.code) {
        case NSURLErrorTimedOut:
        case NSURLErrorCannotFindHost:
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorNotConnectedToInternet:
        case NSURLErrorInternationalRoamingOff:
        case NSURLErrorCallIsActive:
        case NSURLErrorDataNotAllowed:
            return YES;
        default:
            return NO;
    }
}

+ (void)enableErrorReport {
    isErrorReportEnabled = YES;
}
@end
