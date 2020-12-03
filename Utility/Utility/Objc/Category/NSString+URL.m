//
//  NSString+URL.m
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import "NSString+URL.h"
#import "NSMutableDictionary+Safe.h"
#import "NSMutableArray+Safe.h"
#import <CommonCrypto/CommonCrypto.h>
#import "UtilityTools.h"

@protocol BASIC_FBSDKError

+ (NSError *)invalidArgumentErrorWithName:(NSString *)name value:(id)value message:(NSString *)message;

@end

@implementation NSString (URL)

- (NSString *)URLDecode {
    NSString *URLStr = [self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    URLStr = [URLStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
#pragma clang diagnostic pop
    return URLStr;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (NSString *)URLEncode {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL, // characters to leave unescaped
                                                                                 CFSTR(":!*();@/&?+$,='"),
                                                                                 kCFStringEncodingUTF8
                                                                                 );
}
#pragma clang diagnostic pop

+ (NSString *)queryStringWithDictionary:(NSDictionary<NSString *,id> *)dictionary
                                  error:(NSError *__autoreleasing  _Nullable *)errorRef
                   invalidObjectHandler:(InvalidObjectHandler)invalidObjectHandler {
    NSMutableString *queryString = [[NSMutableString alloc] init];
    __block BOOL hasParameters = NO;
    if (dictionary) {
        NSMutableArray<NSString *> *keys = [dictionary.allKeys mutableCopy];
        // remove non-string keys, as they are not valid
        [keys filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL (id evaluatedObject, NSDictionary<id, id> *bindings) {
            return [evaluatedObject isKindOfClass:[NSString class]];
        }]];
        // sort the keys so that the query string order is deterministic
        [keys sortUsingSelector:@selector(compare:)];
        BOOL stop = NO;
        for (NSString *key in keys) {
            id value = [self _convertRequestValue:dictionary[key]];
            if ([value isKindOfClass:[NSString class]]) {
                value = [value URLEncode];
            }
            if (invalidObjectHandler && ![value isKindOfClass:[NSString class]]) {
                value = invalidObjectHandler(value, &stop);
                if (stop) {
                    break;
                }
            }
            if (value) {
                if (hasParameters) {
                    [queryString appendString:@"&"];
                }
                [queryString appendFormat:@"%@=%@", key, value];
                hasParameters = YES;
            }
        }
    }
    if (errorRef != NULL) {
        *errorRef = nil;
    }
    return (queryString.length ? [queryString copy] : nil);
}


+ (NSString *)JSONStringForObject:(id)object
                            error:(NSError *__autoreleasing *)errorRef
             invalidObjectHandler:(InvalidObjectHandler)invalidObjectHandler
{
    if (invalidObjectHandler || ![UtilityTools isValidJSONObject:object]) {
        object = [self _convertObjectToJSONObject:object invalidObjectHandler:invalidObjectHandler stop:NULL];
        if (![UtilityTools isValidJSONObject:object]) {
            if (errorRef != NULL) {
                Class ErrorClass = NSClassFromString(@"NWError");
                if ([ErrorClass respondsToSelector:@selector(invalidArgumentErrorWithName:value:message:)]) {
                    *errorRef = [ErrorClass invalidArgumentErrorWithName:@"object"
                                                                   value:object
                                                                 message:@"Invalid object for JSON serialization."];
                }
            }
            return nil;
        }
    }
    NSData *data = [UtilityTools dataWithJSONObject:object options:0 error:errorRef];
    if (!data) {
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
+ (BOOL)      dictionary:(NSMutableDictionary<NSString *, id> *)dictionary
  setJSONStringForObject:(id)object
                  forKey:(id<NSCopying>)key
                   error:(NSError *__autoreleasing *)errorRef
{
    if (!object || !key) {
        return YES;
    }
    NSString *JSONString = [self JSONStringForObject:object error:errorRef invalidObjectHandler:NULL];
    if (!JSONString) {
        return NO;
    }
    [dictionary safe_setObject:JSONString forKey:key];
    return YES;
}

+ (id)_convertObjectToJSONObject:(id)object
            invalidObjectHandler:(InvalidObjectHandler)invalidObjectHandler
                            stop:(BOOL *)stopRef
{
    __block BOOL stop = NO;
    if ([object isKindOfClass:[NSString class]] || [object isKindOfClass:[NSNumber class]]) {
        // good to go, keep the object
    } else if ([object isKindOfClass:[NSURL class]]) {
        object = ((NSURL *)object).absoluteString;
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary<NSString *, id> *dictionary = [[NSMutableDictionary alloc] init];
        [(NSDictionary<id, id> *) object enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *dictionaryStop) {
            [dictionary
             safe_setObject:[self _convertObjectToJSONObject:obj invalidObjectHandler:invalidObjectHandler stop:&stop]
             forKey:key];
            if (stop) {
                *dictionaryStop = YES;
            }
        }];
        object = dictionary;
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSMutableArray<id> *array = [[NSMutableArray alloc] init];
        for (id obj in (NSArray *)object) {
            id convertedObj = [self _convertObjectToJSONObject:obj invalidObjectHandler:invalidObjectHandler stop:&stop];
            [array safe_addObject:convertedObj];
            if (stop) {
                break;
            }
        }
        object = array;
    } else {
        object = invalidObjectHandler(object, stopRef);
    }
    if (stopRef != NULL) {
        *stopRef = stop;
    }
    return object;
}

+ (NSDictionary<NSString *, NSString *> *)dictionaryWithQueryString:(NSString *)queryString {
    NSMutableDictionary<NSString *, NSString *> *result = [[NSMutableDictionary alloc] init];
    NSArray<NSString *> *parts = [queryString componentsSeparatedByString:@"&"];
    
    for (NSString *part in parts) {
        if (part.length == 0) {
            continue;
        }
        
        NSRange index = [part rangeOfString:@"="];
        NSString *key;
        NSString *value;
        
        if (index.location == NSNotFound) {
            key = part;
            value = @"";
        } else {
            key = [part substringToIndex:index.location];
            value = [part substringFromIndex:index.location + index.length];
        }
        
        key = [key URLDecode];
        value = [value URLDecode];
        if (key && value) {
            [result safe_setObject:value forKey:key];
        }
    }
    return result;
}

+ (NSString *)SHA256Hash:(NSObject *)input {
    NSData *data = nil;
    
    if ([input isKindOfClass:[NSData class]]) {
        data = (NSData *)input;
    } else if ([input isKindOfClass:[NSString class]]) {
        data = [(NSString *)input dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (!data) {
        return nil;
    }
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);
    NSMutableString *hashed = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hashed appendFormat:@"%02x", digest[i]];
    }
    
    return [hashed copy];
}

+ (id)_convertRequestValue:(id)value {
    if ([value isKindOfClass:[NSNumber class]]) {
        value = ((NSNumber *)value).stringValue;
    } else if ([value isKindOfClass:[NSURL class]]) {
        value = ((NSURL *)value).absoluteString;
    }
    return value;
}

@end
