//
//  NWErrorConfiguration.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import "NWConstants.h"
@class NWRequest;

NS_ASSUME_NONNULL_BEGIN

@interface NWErrorRecoveryConfiguration : NSObject<NSCopying, NSSecureCoding>

@property (nonatomic, readonly) NSString *localizedRecoveryDescription;
@property (nonatomic, readonly) NSArray *localizedRecoveryOptionDescriptions;
@property (nonatomic, readonly) NWRequestError errorCategory;
@property (nonatomic, readonly) NSString *recoveryActionName;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithRecoveryDescription:(NSString *)description
                         optionDescriptions:(NSArray *)optionDescriptions
                                   category:(NWRequestError)category
                         recoveryActionName:(NSString *)recoveryActionName NS_DESIGNATED_INITIALIZER;
@end

@interface NWErrorConfiguration : NSObject <NSSecureCoding, NSCopying>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithDictionary:(nullable NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (void)parseArray:(NSArray<NSDictionary *> *)array;

- (NWErrorConfiguration *)recoveryConfigurationForCode:(NSString *)code subcode:(NSString *)subcode request:(NWRequest *)request;

@end

NS_ASSUME_NONNULL_END
