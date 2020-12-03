//
//  UserDataStore.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString *const UserDataType NS_TYPED_EXTENSIBLE_ENUM NS_SWIFT_NAME(UserDataType);
FOUNDATION_EXPORT UserDataType UserDataFieldEmail;
FOUNDATION_EXPORT UserDataType UserDataFieldName;
FOUNDATION_EXPORT UserDataType UserDataFieldPhone;
FOUNDATION_EXPORT UserDataType UserDataFieldGender;
FOUNDATION_EXPORT UserDataType UserDataFieldCity;


@interface UserDataStore : NSObject

+ (void)setAndHashData:(nullable NSString *)data forType:(UserDataType)type;
+ (nullable NSString *)getHashedData;
+ (void)clearDataForType:(UserDataType)type;

@end

NS_ASSUME_NONNULL_END
