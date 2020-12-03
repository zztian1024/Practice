//
//  NWKeychainStore.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWKeychainStore : NSObject

@property (nonatomic, readonly, copy) NSString *service;
@property (nonatomic, readonly, copy) NSString *accessGroup;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup NS_DESIGNATED_INITIALIZER;

- (BOOL)setDictionary:(NSDictionary *)value forKey:(NSString *)key accessibility:(CFTypeRef)accessibility;
- (NSDictionary *)dictionaryForKey:(NSString *)key;

- (BOOL)setString:(NSString *)value forKey:(NSString *)key accessibility:(CFTypeRef)accessibility;
- (NSString *)stringForKey:(NSString *)key;

- (BOOL)setData:(NSData *)value forKey:(NSString *)key accessibility:(CFTypeRef)accessibility;
- (NSData *)dataForKey:(NSString *)key;

// hook for subclasses to override keychain query construction.
- (NSMutableDictionary *)queryForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
