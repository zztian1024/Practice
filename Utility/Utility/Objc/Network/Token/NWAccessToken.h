//
//  NWAccessToken.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

FOUNDATION_EXPORT NSNotificationName const NWAccessTokenDidChangeNotification
NS_SWIFT_NAME(AccessTokenDidChange);

#else

FOUNDATION_EXPORT NSString *const NWAccessTokenDidChangeNotification
NS_SWIFT_NAME(AccessTokenDidChangeNotification);

#endif

@interface NWAccessToken : NSObject<NSCopying, NSSecureCoding>

@property (class, nonatomic, copy, nullable) NWAccessToken *currentAccessToken;
@property (class, nonatomic, assign, readonly, getter=isCurrentAccessTokenActive) BOOL currentAccessTokenIsActive;
@property (nonatomic, copy, readonly) NSString *tokenString;
@property (nonatomic, copy, readonly) NSString *appID;
@property (nonatomic, copy, readonly) NSString *userID;
@property (nonatomic, copy, readonly) NSDate *expirationDate;
@property (nonatomic, copy, readonly) NSDate *refreshDate;
@property (nonatomic, copy, readonly) NSDate *dataAccessExpirationDate;
@property (nonatomic, copy, readonly) NSString *domain;
@property (readonly, assign, nonatomic, getter=isExpired) BOOL expired;

@property (nonatomic, copy, readonly) NSSet<NSString *> *declinedPermissions
NS_REFINED_FOR_SWIFT;

@property (nonatomic, copy, readonly) NSSet<NSString *> *expiredPermissions
NS_REFINED_FOR_SWIFT;

@property (nonatomic, copy, readonly) NSSet<NSString *> *permissions
NS_REFINED_FOR_SWIFT;

@end

NS_ASSUME_NONNULL_END
