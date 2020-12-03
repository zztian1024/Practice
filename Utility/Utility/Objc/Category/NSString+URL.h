//
//  NSString+URL.h
//  Utility
//
//  Created by Tian on 2020/10/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef id _Nullable (^InvalidObjectHandler)(id object, BOOL *stop)
NS_SWIFT_NAME(InvalidObjectHandler);

@interface NSString (URL)

/**
 Encodes a value for an URL.
 @return The encoded value.
 */
- (NSString *)URLEncode;

/**
 Decodes a value from an URL.
 @return The decoded value.
 */
- (NSString *)URLDecode;

/**
 Constructs a query string from a dictionary.
 @param dictionary The dictionary with key/value pairs for the query string.
 @param errorRef If an error occurs, upon return contains an NSError object that describes the problem.
 @param invalidObjectHandler Handles objects that are invalid, returning a replacement value or nil to ignore.
 @return Query string representation of the parameters.
 */
+ (nullable NSString *)queryStringWithDictionary:(NSDictionary<NSString *, id> *)dictionary
                                           error:(NSError *__autoreleasing *)errorRef
                            invalidObjectHandler:(nullable InvalidObjectHandler)invalidObjectHandler;

+ (nullable NSString *)JSONStringForObject:(id)object
                                     error:(NSError *__autoreleasing *)errorRef
                      invalidObjectHandler:(nullable InvalidObjectHandler)invalidObjectHandler;

/**
 Parses a query string into a dictionary.
 @param queryString The query string value.
 @return A dictionary with the key/value pairs.
 */
+ (NSDictionary<NSString *, NSString *> *)dictionaryWithQueryString:(NSString *)queryString;

+ (nullable NSString *)SHA256Hash:(nullable NSObject *)input;

@end

NS_ASSUME_NONNULL_END
