//
//  NWErrorConfiguration.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWErrorConfiguration.h"
#import "UtilityTools.h"

#define NW_ERROR_RECOVERY_CONFIGURATION_DESCRIPTION_KEY @"description"
#define NW_ERROR_RECOVERY_CONFIGURATION_OPTIONS_KEY @"options"
#define NW_ERROR_RECOVERY_CONFIGURATION_CATEGORY_KEY @"category"
#define NW_ERROR_RECOVERY_CONFIGURATION_ACTION_KEY @"action"

@implementation NWErrorRecoveryConfiguration

- (instancetype)initWithRecoveryDescription:(NSString *)description
                         optionDescriptions:(NSArray *)optionDescriptions
                                   category:(NWRequestError)category
                         recoveryActionName:(NSString *)recoveryActionName
{
    if ((self = [super init])) {
        _localizedRecoveryDescription = [description copy];
        _localizedRecoveryOptionDescriptions = [optionDescriptions copy];
        _errorCategory = category;
        _recoveryActionName = [recoveryActionName copy];
    }
    return self;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder {
    NSString *description = [decoder decodeObjectOfClass:[NSString class] forKey:NW_ERROR_RECOVERY_CONFIGURATION_DESCRIPTION_KEY];
    NSArray *options = [decoder decodeObjectOfClass:[NSArray class] forKey:NW_ERROR_RECOVERY_CONFIGURATION_OPTIONS_KEY];
    NSNumber *category = [decoder decodeObjectOfClass:[NSNumber class] forKey:NW_ERROR_RECOVERY_CONFIGURATION_CATEGORY_KEY];
    NSString *action = [decoder decodeObjectOfClass:[NSString class] forKey:NW_ERROR_RECOVERY_CONFIGURATION_ACTION_KEY];
    
    return [self initWithRecoveryDescription:description
                          optionDescriptions:options
                                    category:category.unsignedIntegerValue
                          recoveryActionName:action];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_localizedRecoveryDescription forKey:NW_ERROR_RECOVERY_CONFIGURATION_DESCRIPTION_KEY];
    [encoder encodeObject:_localizedRecoveryOptionDescriptions forKey:NW_ERROR_RECOVERY_CONFIGURATION_OPTIONS_KEY];
    [encoder encodeObject:@(_errorCategory) forKey:NW_ERROR_RECOVERY_CONFIGURATION_CATEGORY_KEY];
    [encoder encodeObject:_recoveryActionName forKey:NW_ERROR_RECOVERY_CONFIGURATION_ACTION_KEY];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    // immutable
    return self;
}

@end

@implementation NWErrorConfiguration{
    NSMutableDictionary *_configurationDictionary;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if ((self = [super init])) {
        if (dictionary) {
            _configurationDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
        } else {
            _configurationDictionary = [NSMutableDictionary dictionary];
            NSString *localizedOK =
            NSLocalizedStringWithDefaultValue(
                                              @"ErrorRecovery.OK",
                                              @"SDK",
                                              [UtilityTools bundleForStrings],
                                              @"OK",
                                              @"The title of the label to start attempting error recovery"
                                              );
            NSString *localizedCancel =
            NSLocalizedStringWithDefaultValue(
                                              @"ErrorRecovery.Cancel",
                                              @"SDK",
                                              [UtilityTools bundleForStrings],
                                              @"Cancel",
                                              @"The title of the label to decline attempting error recovery"
                                              );
            NSString *localizedTransientSuggestion =
            NSLocalizedStringWithDefaultValue(
                                              @"ErrorRecovery.Transient.Suggestion",
                                              @"SDK",
                                              [UtilityTools bundleForStrings],
                                              @"The server is temporarily busy, please try again.",
                                              @"The fallback message to display to retry transient errors"
                                              );
            NSString *localizedLoginRecoverableSuggestion =
            NSLocalizedStringWithDefaultValue(
                                              @"ErrorRecovery.Login.Suggestion",
                                              @"SDK",
                                              [UtilityTools bundleForStrings],
                                              @"Please log into this app again to reconnect your Facebook account.",
                                              @"The fallback message to display to recover invalidated tokens"
                                              );
            NSArray *fallbackArray = @[
                @{ @"name" : @"login",
                   @"items" : @[@{ @"code" : @102 },
                                @{ @"code" : @190 }],
                   @"recovery_message" : localizedLoginRecoverableSuggestion,
                   @"recovery_options" : @[localizedOK, localizedCancel]},
                @{ @"name" : @"transient",
                   @"items" : @[@{ @"code" : @1 },
                                @{ @"code" : @2 },
                                @{ @"code" : @4 },
                                @{ @"code" : @9 },
                                @{ @"code" : @17 },
                                @{ @"code" : @341 }],
                   @"recovery_message" : localizedTransientSuggestion,
                   @"recovery_options" : @[localizedOK]},
            ];
            [self parseArray:fallbackArray];
        }
    }
    return self;
}
//
//- (NWErrorConfiguration *)recoveryConfigurationForCode:(NSString *)code subcode:(NSString *)subcode request:(NWRequest *)request {
//    code = code ?: @"*";
//    subcode = subcode ?: @"*";
//    NWErrorRecoveryConfiguration *configuration = (_configurationDictionary[code][subcode]
//                                                   ?: _configurationDictionary[code][@"*"]
//                                                   ?: _configurationDictionary[@"*"][subcode]
//                                                   ?: _configurationDictionary[@"*"][@"*"]);
//    if (configuration.errorCategory == NWGraphRequestErrorRecoverable
//        && [NWSettings clientToken]
//        && [request.parameters[@"access_token"] hasSuffix:[NWSettings clientToken]]) {
//        // do not attempt to recovery client tokens.
//        return nil;
//    }
//    return configuration;
//}
//
//- (void)parseArray:(NSArray<NSDictionary *> *)array{
//    for (NSDictionary *dictionary in [FBSDKTypeUtility arrayValue:array]) {
//        [FBSDKTypeUtility dictionary:dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
//            FBSDKGraphRequestError category;
//            NSString *action = [FBSDKTypeUtility stringValue:dictionary[@"name"]];
//            if ([action isEqualToString:kErrorCategoryOther]) {
//                category = FBSDKGraphRequestErrorOther;
//            } else if ([action isEqualToString:kErrorCategoryTransient]) {
//                category = FBSDKGraphRequestErrorTransient;
//            } else {
//                category = FBSDKGraphRequestErrorRecoverable;
//            }
//            NSString *suggestion = dictionary[@"recovery_message"];
//            NSArray *options = dictionary[@"recovery_options"];
//
//            NSArray *validItems = [FBSDKTypeUtility dictionary:dictionary objectForKey:@"items" ofType:NSArray.class];
//            for (NSDictionary *codeSubcodesDictionary in validItems) {
//                NSDictionary *validCodeSubcodesDictionary = [FBSDKTypeUtility dictionaryValue:codeSubcodesDictionary];
//                if (!validCodeSubcodesDictionary) {
//                    continue;
//                }
//
//                NSNumber *numericCode = [FBSDKTypeUtility dictionary:validCodeSubcodesDictionary objectForKey:@"code" ofType:NSNumber.class];
//                NSString *code = numericCode.stringValue;
//                if (!code) {
//                    return;
//                }
//
//                NSMutableDictionary *currentSubcodes = self->_configurationDictionary[code];
//                if (!currentSubcodes) {
//                    currentSubcodes = [NSMutableDictionary dictionary];
//                    [FBSDKTypeUtility dictionary:self->_configurationDictionary setObject:currentSubcodes forKey:code];
//                }
//
//                NSArray *validSubcodes = [FBSDKTypeUtility dictionary:validCodeSubcodesDictionary objectForKey:@"subcodes" ofType:NSArray.class];
//                if (validSubcodes.count > 0) {
//                    for (NSNumber *subcodeNumber in validSubcodes) {
//                        NSNumber *validSubcodeNumber = [FBSDKTypeUtility numberValue:subcodeNumber];
//                        if (validSubcodeNumber == nil) {
//                            continue;
//                        }
//                        [FBSDKTypeUtility dictionary:currentSubcodes setObject:[[FBSDKErrorRecoveryConfiguration alloc]
//                                                                                initWithRecoveryDescription:suggestion
//                                                                                optionDescriptions:options
//                                                                                category:category
//                                                                                recoveryActionName:action] forKey:validSubcodeNumber.stringValue];
//                    }
//                } else {
//                    [FBSDKTypeUtility dictionary:currentSubcodes setObject:[[FBSDKErrorRecoveryConfiguration alloc]
//                                                                            initWithRecoveryDescription:suggestion
//                                                                            optionDescriptions:options
//                                                                            category:category
//                                                                            recoveryActionName:action] forKey:@"*"];
//                }
//            }
//        }];
//    }
//}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

//- (id)initWithCoder:(NSCoder *)decoder {
//    NSSet *classes = [[NSSet alloc] initWithObjects:[NSDictionary class], [FBSDKErrorRecoveryConfiguration class], nil];
//    NSDictionary *configurationDictionary = [decoder decodeObjectOfClasses:classes
//                                                                    forKey:FBSDKERRORCONFIGURATION_DICTIONARY_KEY];
//    return [self initWithDictionary:configurationDictionary];
//}
//
//- (void)encodeWithCoder:(NSCoder *)encoder {
//    [encoder encodeObject:_configurationDictionary forKey:FBSDKERRORCONFIGURATION_DICTIONARY_KEY];
//}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
