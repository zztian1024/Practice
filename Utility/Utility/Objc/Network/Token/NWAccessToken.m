//
//  NWAccessToken.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWAccessToken.h"
#import "NSMutableDictionary+Safe.h"
#import "NWSettings.h"

static NWAccessToken *_currentAccessToken;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

NSNotificationName const NWAccessTokenDidChangeNotification = @"com.AccessTokenData.NWAccessTokenDidChangeNotification";

#else

NSString *const NWAccessTokenDidChangeNotification = @"com.AccessTokenData.NWAccessTokenDidChangeNotification";

#endif

NSString *const NWAccessTokenDidChangeUserIDKey = @"AccessTokenDidChangeUserIDKey";
NSString *const NWAccessTokenChangeNewKey = @"AccessToken";
NSString *const NWAccessTokenChangeOldKey = @"AccessTokenOld";
NSString *const NWAccessTokenDidExpireKey = @"AccessTokenDidExpireKey";

#define NW_ACCESSTOKEN_TOKENSTRING_KEY @"tokenString"
#define NW_ACCESSTOKEN_PERMISSIONS_KEY @"permissions"
#define NW_ACCESSTOKEN_DECLINEDPERMISSIONS_KEY @"declinedPermissions"
#define NW_ACCESSTOKEN_EXPIREDPERMISSIONS_KEY @"expiredPermissions"
#define NW_ACCESSTOKEN_APPID_KEY @"appID"
#define NW_ACCESSTOKEN_USERID_KEY @"userID"
#define NW_ACCESSTOKEN_REFRESHDATE_KEY @"refreshDate"
#define NW_ACCESSTOKEN_EXPIRATIONDATE_KEY @"expirationDate"
#define NW_ACCESSTOKEN_DATA_EXPIRATIONDATE_KEY @"dataAccessExpirationDate"
#define NW_ACCESSTOKEN_DOMAIN_KEY @"domain"

@implementation NWAccessToken

- (instancetype)initWithTokenString:(NSString *)tokenString
                        permissions:(NSArray *)permissions
                declinedPermissions:(NSArray *)declinedPermissions
                 expiredPermissions:(NSArray *)expiredPermissions
                              appID:(NSString *)appID
                             userID:(NSString *)userID
                     expirationDate:(NSDate *)expirationDate
                        refreshDate:(NSDate *)refreshDate
           dataAccessExpirationDate:(NSDate *)dataAccessExpirationDate {
    if ((self = [super init])) {
        _tokenString = [tokenString copy];
        _permissions = [NSSet setWithArray:permissions];
        _declinedPermissions = [NSSet setWithArray:declinedPermissions];
        _expiredPermissions = [NSSet setWithArray:expiredPermissions];
        _appID = [appID copy];
        _userID = [userID copy];
        _expirationDate = [expirationDate copy] ?: [NSDate distantFuture];
        _refreshDate = [refreshDate copy] ?: [NSDate date];
        _dataAccessExpirationDate = [dataAccessExpirationDate copy] ?: [NSDate distantFuture];
    }
    return self;
}

- (instancetype)initWithTokenString:(NSString *)tokenString
                        permissions:(NSArray<NSString *> *)permissions
                declinedPermissions:(NSArray<NSString *> *)declinedPermissions
                 expiredPermissions:(NSArray<NSString *> *)expiredPermissions
                              appID:(NSString *)appID
                             userID:(NSString *)userID
                     expirationDate:(NSDate *)expirationDate
                        refreshDate:(NSDate *)refreshDate
           dataAccessExpirationDate:(NSDate *)dataAccessExpirationDate
                        graphDomain:(NSString *)graphDomain {
    NWAccessToken *accessToken =
    [self
     initWithTokenString:tokenString
     permissions:permissions
     declinedPermissions:declinedPermissions
     expiredPermissions:expiredPermissions
     appID:appID
     userID:userID
     expirationDate:expirationDate
     refreshDate:refreshDate
     dataAccessExpirationDate:dataAccessExpirationDate];
    
    if (accessToken != nil) {
        accessToken->_domain = [graphDomain copy];
    }
    
    return accessToken;
}

+ (NWAccessToken *)currentAccessToken {
    return _currentAccessToken;
}

+ (void)setCurrentAccessToken:(NWAccessToken *)currentAccessToken {
    [NWAccessToken setCurrentAccessToken:currentAccessToken shouldDispatchNotif:YES];
}

+ (void)setCurrentAccessToken:(NWAccessToken *)token
          shouldDispatchNotif:(BOOL)shouldDispatchNotif {
    if (token != _currentAccessToken) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo safe_setObject:token forKey:NWAccessTokenChangeNewKey];
        [userInfo safe_setObject:_currentAccessToken forKey:NWAccessTokenChangeOldKey];
        
        if (![_currentAccessToken.userID isEqualToString:token.userID] || !self.isCurrentAccessTokenActive) {
            userInfo[NWAccessTokenDidChangeUserIDKey] = @YES;
        }
        
        _currentAccessToken = token;
        
        if (token == nil) {
            // deleteCookies
        }
        
        [NWSettings accessTokenCache].accessToken = token;
        if (shouldDispatchNotif) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NWAccessTokenDidChangeNotification
                                                                object:[self class]
                                                              userInfo:userInfo];
        }
    }
}

+ (BOOL)isCurrentAccessTokenActive {
    NWAccessToken *currentAccessToken = [self currentAccessToken];
    return currentAccessToken != nil && !currentAccessToken.isExpired;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    // we're immutable.
    return self;
}

#pragma mark NSCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    NSString *appID = [decoder decodeObjectOfClass:[NSString class] forKey:NW_ACCESSTOKEN_APPID_KEY];
    NSSet *declinedPermissions = [decoder decodeObjectOfClass:[NSSet class] forKey:NW_ACCESSTOKEN_DECLINEDPERMISSIONS_KEY];
    NSSet *expiredPermissions = [decoder decodeObjectOfClass:[NSSet class] forKey:NW_ACCESSTOKEN_EXPIREDPERMISSIONS_KEY];
    NSSet *permissions = [decoder decodeObjectOfClass:[NSSet class] forKey:NW_ACCESSTOKEN_PERMISSIONS_KEY];
    NSString *tokenString = [decoder decodeObjectOfClass:[NSString class] forKey:NW_ACCESSTOKEN_TOKENSTRING_KEY];
    NSString *userID = [decoder decodeObjectOfClass:[NSString class] forKey:NW_ACCESSTOKEN_USERID_KEY];
    NSDate *refreshDate = [decoder decodeObjectOfClass:[NSDate class] forKey:NW_ACCESSTOKEN_REFRESHDATE_KEY];
    NSDate *expirationDate = [decoder decodeObjectOfClass:[NSDate class] forKey:NW_ACCESSTOKEN_EXPIRATIONDATE_KEY];
    NSDate *dataAccessExpirationDate = [decoder decodeObjectOfClass:[NSDate class] forKey:NW_ACCESSTOKEN_DATA_EXPIRATIONDATE_KEY];
    NSString *graphDomain = [decoder decodeObjectOfClass:[NSString class] forKey:NW_ACCESSTOKEN_DOMAIN_KEY];
    
    return
    [self
     initWithTokenString:tokenString
     permissions:permissions.allObjects
     declinedPermissions:declinedPermissions.allObjects
     expiredPermissions:expiredPermissions.allObjects
     appID:appID
     userID:userID
     expirationDate:expirationDate
     refreshDate:refreshDate
     dataAccessExpirationDate:dataAccessExpirationDate
     graphDomain:graphDomain];
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.appID forKey:NW_ACCESSTOKEN_APPID_KEY];
    [encoder encodeObject:self.declinedPermissions forKey:NW_ACCESSTOKEN_DECLINEDPERMISSIONS_KEY];
    [encoder encodeObject:self.expiredPermissions forKey:NW_ACCESSTOKEN_EXPIREDPERMISSIONS_KEY];
    [encoder encodeObject:self.permissions forKey:NW_ACCESSTOKEN_PERMISSIONS_KEY];
    [encoder encodeObject:self.tokenString forKey:NW_ACCESSTOKEN_TOKENSTRING_KEY];
    [encoder encodeObject:self.userID forKey:NW_ACCESSTOKEN_USERID_KEY];
    [encoder encodeObject:self.expirationDate forKey:NW_ACCESSTOKEN_EXPIRATIONDATE_KEY];
    [encoder encodeObject:self.refreshDate forKey:NW_ACCESSTOKEN_REFRESHDATE_KEY];
    [encoder encodeObject:self.dataAccessExpirationDate forKey:NW_ACCESSTOKEN_DATA_EXPIRATIONDATE_KEY];
    [encoder encodeObject:self.domain forKey:NW_ACCESSTOKEN_DOMAIN_KEY];
}

@end
