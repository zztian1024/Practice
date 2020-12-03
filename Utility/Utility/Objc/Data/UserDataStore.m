//
//  UserDataStore.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "UserDataStore.h"
#import "UtilityTools.h"
#import "NSMutableDictionary+Safe.h"

UserDataType UserDataFieldEmail = @"email";
UserDataType UserDataFieldName = @"name";
UserDataType UserDataFieldPhone = @"phone";
UserDataType UserDataFieldGender = @"gender";
UserDataType UserDataFieldCity = @"city";

static dispatch_queue_t serialQueue;
static NSString *const UserDataKey = @"com.test.UserDataStore.userData";

static NSMutableDictionary<NSString *, NSString *> *hashedUserData;

@implementation UserDataStore

+ (void)initialize {
    serialQueue = dispatch_queue_create("com.test.UserDataStore", DISPATCH_QUEUE_SERIAL);
    hashedUserData = [UserDataStore initializeUserData:UserDataKey];
}

+ (void)setAndHashData:(NSString *)data forType:(UserDataType)type {
    [UserDataStore setHashData:data forType:type];
}

+ (void)setHashData:(nullable NSString *)hashData
            forType:(UserDataType)type {
    dispatch_async(serialQueue, ^{
        if (!hashData) {
            [hashedUserData removeObjectForKey:type];
        } else {
            [hashedUserData safe_setObject:hashData forKey:type];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[UserDataStore stringByHashedData:hashedUserData]
                                                  forKey:UserDataKey];
    });
}

+ (NSString *)getHashedData {
    __block NSString *hashedUserDataString;
    dispatch_sync(serialQueue, ^{
        NSMutableDictionary<NSString *, NSString *> *hashedUD = [[NSMutableDictionary alloc] init];
        [hashedUD addEntriesFromDictionary:hashedUserData];
        hashedUserDataString = [UserDataStore stringByHashedData:hashedUD];
    });
    return hashedUserDataString;
}

+ (void)clearDataForType:(UserDataType)type {
    [UserDataStore setAndHashData:nil forType:type];
}

#pragma mark - Helper Methods

+ (NSMutableDictionary<NSString *, NSString *> *)initializeUserData:(NSString *)userDataKey {
    NSString *userData = [[NSUserDefaults standardUserDefaults] stringForKey:userDataKey];
    NSMutableDictionary<NSString *, NSString *> *hashedUserData = nil;
    if (userData) {
        hashedUserData = (NSMutableDictionary<NSString *, NSString *> *)[UtilityTools JSONObjectWithData:[userData dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                 options: NSJSONReadingMutableContainers
                                                                                                   error: nil];
    }
    if (!hashedUserData) {
        hashedUserData = [[NSMutableDictionary alloc] init];
    }
    return hashedUserData;
}

+ (NSString *)stringByHashedData:(id)hashedData {
    NSError *error;
    NSData *jsonData = [UtilityTools dataWithJSONObject:hashedData
                                                options:0
                                                  error:&error];
    if (jsonData) {
        return [[NSString alloc] initWithData:jsonData
                                     encoding:NSUTF8StringEncoding];
    } else {
        return @"";
    }
}
@end
