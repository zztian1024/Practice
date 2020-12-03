//
//  NWLogger.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWLogger : NSObject

@property (copy, nonatomic) NSString *contents;
@property (nonatomic, readonly) NSUInteger loggerSerialNumber;
@property (copy, nonatomic, readonly) NSString *loggingBehavior;
@property (nonatomic, readonly, getter=isActive) BOOL active;

- (instancetype)initWithLoggingBehavior:(NSString *)loggingBehavior;
- (void)appendString:(NSString *)string;
- (void)appendFormat:(NSString *)formatString, ... NS_FORMAT_FUNCTION(1,2);
- (void)appendKey:(NSString *)key value:(NSString *)value;
- (void)emitToNSLog;
+ (NSUInteger)generateSerialNumber;

+ (void)singleShotLogEntry:(NSString *)loggingBehavior
                  logEntry:(NSString *)logEntry;

+ (void)singleShotLogEntry:(NSString *)loggingBehavior
              formatString:(NSString *)formatString, ... NS_FORMAT_FUNCTION(2,3);

+ (void)singleShotLogEntry:(NSString *)loggingBehavior
              timestampTag:(NSObject *)timestampTag
              formatString:(NSString *)formatString, ... NS_FORMAT_FUNCTION(3,4);

+ (void)registerCurrentTime:(NSString *)loggingBehavior
                    withTag:(NSObject *)timestampTag;

+ (void)registerStringToReplace:(NSString *)replace
                    replaceWith:(NSString *)replaceWith;
@end

NS_ASSUME_NONNULL_END
