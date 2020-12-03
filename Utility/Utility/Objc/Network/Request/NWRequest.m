//
//  RequestHelper.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWRequest.h"
#import "NWAccessToken.h"
#import "NWSettings.h"
#import "NSMutableDictionary+Safe.h"
#import "NSString+URL.h"
#import "NWRequest+Internal.h"

NWHTTPMethod NWHTTPMethodGET = @"GET";
NWHTTPMethod NWHTTPMethodPOST = @"POST";
NWHTTPMethod NWHTTPMethodPUT = @"PUT";
NWHTTPMethod NWHTTPMethodDELETE = @"DELETE";

@interface NWRequest ()

@property (nonatomic, assign) NWRequestFlags flags;
@property (nonatomic, readwrite, copy) NWHTTPMethod HTTPMethod;

@end

@implementation NWRequest
@synthesize HTTPMethod;

- (instancetype)initWithPath:(NSString *)path {
    return [self initWithPath:path parameters:@{}];
}

- (instancetype)initWithPath:(NSString *)path HTTPMethod:(NWHTTPMethod)method {
    return [self initWithPath:path parameters:@{} HTTPMethod:method];
}

- (instancetype)initWithPath:(NSString *)path parameters:(NSDictionary<NSString *,id> *)parameters {
    return [self initWithPath:path parameters:parameters flags:NWRequestFlagFlagNone];
}

- (instancetype)initWithPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                  HTTPMethod:(NWHTTPMethod)method {
    return [self initWithPath:path
                   parameters:parameters
                  tokenString:[NWAccessToken currentAccessToken].tokenString
                      version:nil
                   HTTPMethod:method];
}

- (instancetype)initWithPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                       flags:(NWRequestFlags)flags {
    return [self initWithPath:path
                   parameters:parameters
                  tokenString:[NWAccessToken currentAccessToken].tokenString
                   HTTPMethod:NWHTTPMethodGET
                        flags:flags];
}

- (instancetype)initWithPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                 tokenString:(NSString *)tokenString
                  HTTPMethod:(NWHTTPMethod)method
                       flags:(NWRequestFlags)flags {
    if ((self = [self initWithPath:path
                        parameters:parameters
                       tokenString:tokenString
                           version:[NWSettings APIVersion]
                        HTTPMethod:method])) {
        self.flags |= flags;
    }
    return self;
}

- (instancetype)initWithPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                 tokenString:(NSString *)tokenString
                     version:(NSString *)version
                  HTTPMethod:(NWHTTPMethod)method
{
    if ((self = [super init])) {
        _tokenString = tokenString ? [tokenString copy] : nil;
        _version = version ? [version copy] : [NWSettings APIVersion];
        _path = [path copy];
        self.HTTPMethod = method.length > 0 ? [method copy] : NWHTTPMethodGET;
        _parameters = parameters ?: @{};
        if (!NWSettings.errorRecoveryEnabled) {
            _flags = NWRequestFlagDisableErrorRecovery;
        }
    }
    return self;
}

- (BOOL)isNWErrorRecoveryDisabled {
    return (self.flags & NWRequestFlagDisableErrorRecovery);
}

- (void)setErrorRecoveryDisabled:(BOOL)disable {
    if (disable) {
        self.flags |= NWRequestFlagDisableErrorRecovery;
    } else {
        self.flags &= ~NWRequestFlagDisableErrorRecovery;
    }
}

+ (NSString *)serializeURL:(NSString *)baseUrl
                    params:(NSDictionary *)params {
    return [self serializeURL:baseUrl params:params httpMethod:NWHTTPMethodGET];
}

+ (NSString *)serializeURL:(NSString *)baseUrl
                    params:(NSDictionary *)params
                httpMethod:(NSString *)httpMethod {
    return [self serializeURL:baseUrl params:params httpMethod:httpMethod forBatch:NO];
}

+ (NSString *)serializeURL:(NSString *)baseUrl
                    params:(NSDictionary *)params
                httpMethod:(NSString *)httpMethod
                  forBatch:(BOOL)forBatch {
    params = [self preprocessParams:params];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSURL *parsedURL = [NSURL URLWithString:[baseUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
#pragma clang pop
    
    if ([httpMethod isEqualToString:NWHTTPMethodPOST] && !forBatch) {
        return baseUrl;
    }
    
    NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
    NSString *query = [NSString queryStringWithDictionary:params error:NULL invalidObjectHandler:^id (id object, BOOL *stop) {
        return object;
    }];
    return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}

+ (NSDictionary *)preprocessParams:(NSDictionary *)params {
    NSString *debugValue = [NWSettings APIDebugParamValue];
    if (debugValue) {
        NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
        [mutableParams safe_setObject:debugValue forKey:@"debug"];
        return mutableParams;
    }
    
    return params;
}

- (NWRequestConnection *)startWithCompletionHandler:(NWRequestBlock)handler {
    NWRequestConnection *connection = [[NWRequestConnection alloc] init];
    [connection addRequest:self completionHandler:handler];
    [connection start];
    return connection;
}

#pragma mark - Debugging helpers

- (NSString *)description {
    NSMutableString *result = [NSMutableString stringWithFormat:@"<%@: %p",
                               NSStringFromClass([self class]),
                               self];
    if (self.path) {
        [result appendFormat:@", path: %@", self.path];
    }
    if (self.HTTPMethod) {
        [result appendFormat:@", HTTPMethod: %@", self.HTTPMethod];
    }
    [result appendFormat:@", parameters: %@>", self.parameters.description];
    return result;
}

@end
