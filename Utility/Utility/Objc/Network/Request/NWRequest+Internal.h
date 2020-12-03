//
//  NWRequest+Internal.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWRequest.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, NWRequestFlags) {
    NWRequestFlagFlagNone = 0,
    NWRequestFlagSkipClientToken = 1 << 1,
    NWRequestFlagDoNotInvalidateTokenOnError = 1 << 2,
    NWRequestFlagDisableErrorRecovery = 1 << 3,
};

@interface NWRequest (Internal)

- (instancetype)initWithPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                       flags:(NWRequestFlags)flags;

- (instancetype)initWithPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                 tokenString:(NSString *)tokenString
                  HTTPMethod:(NSString *)HTTPMethod
                       flags:(NWRequestFlags)flags;

@property (nonatomic, assign) NWRequestFlags flags;

+ (NSString *)serializeURL:(NSString *)baseUrl
                    params:(NSDictionary *)params
                httpMethod:(NSString *)httpMethod
                  forBatch:(BOOL)forBatch;
@end

NS_ASSUME_NONNULL_END
