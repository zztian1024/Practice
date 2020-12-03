//
//  NWRequestConnection.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWRequestConnection.h"
#import "NWURLSession.h"
#import "NWSettings.h"
#import "NSMutableArray+Safe.h"
#import "NSMutableDictionary+Safe.h"
#import "NSString+URL.h"
#import "NWRequestMetadata.h"
#import "NWRequest.h"
#import "NWRequestBody.h"
#import "NWRequest+Internal.h"
#import "NWRequestMetadata.h"
#import "NWErrorConfiguration.h"
#import "NWLogger.h"
#import "NWError.h"
#import "UtilityTools.h"
#import "NWAccessToken.h"
#import "NWConstants.h"

typedef NS_ENUM(NSUInteger, NWRequestConnectionState) {
    kStateCreated,
    kStateSerialized,
    kStateStarted,
    kStateCompleted,
    kStateCancelled,
};

static NSTimeInterval _defaultTimeout = 60.0;
static NSString *const kBatchKey = @"batch";
static NSString *const kBatchMethodKey = @"method";
static NSString *const kBatchRelativeURLKey = @"relative_url";
static NSString *const kBatchAttachmentKey = @"attached_files";
static NSString *const kBatchFileNamePrefix = @"file";
static NSString *const kBatchEntryName = @"name";

static NSString *const kAccessTokenKey = @"access_token";
static NSString *const kSDK = @"ios";
static NSString *const kUserAgentBase = @"iOSSDK";

static NSString *const kBatchRestMethodBaseURL = @"method/";
static NSString *const kGraphURLPrefix = @"graph.";
static NSString *const kGraphVideoURLPrefix = @"graph-video.";
NSString *const NonJSONResponseProperty = @"NON_JSON_RESULT";

static NWErrorConfiguration *_errorConfiguration;

@interface NWRequestConnection () <
NSURLSessionDataDelegate
#if !TARGET_OS_TV
//...
#endif
>

@property (nonatomic, retain) NSMutableArray *requests;
@property (nonatomic, assign) NWRequestConnectionState state;
@property (nonatomic, strong) NWLogger *logger;
@property (nonatomic, assign) uint64_t requestStartTime;

@end

@implementation NWRequestConnection {
    NSString *_overrideVersionPart;
    NSUInteger _expectingResults;
    NSOperationQueue *_delegateQueue;
    NWURLSession *_session;
#if !TARGET_OS_TV
    //...
#endif
}

- (instancetype)init {
    if ((self = [super init])) {
        _requests = [[NSMutableArray alloc] init];
        _timeout = _defaultTimeout;
        _state = kStateCreated;
        _logger = [[NWLogger alloc] initWithLoggingBehavior:NWLoggingBehaviorNetworkRequests];
        _session = [[NWURLSession alloc] initWithDelegate:self delegateQueue:_delegateQueue];
    }
    return self;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
}

#pragma mark - Public

+ (void)setDefaultConnectionTimeout:(NSTimeInterval)defaultTimeout {
    if (defaultTimeout >= 0) {
        _defaultTimeout = defaultTimeout;
    }
}

+ (NSTimeInterval)defaultConnectionTimeout {
    return _defaultTimeout;
}

- (void)addRequest:(NWRequest *)request completionHandler:(NWRequestBlock)handler {
    [self addRequest:request batchEntryName:@"" completionHandler:handler];
}

- (void)addRequest:(NWRequest *)request batchEntryName:(NSString *)name completionHandler:(NWRequestBlock)handler {
    NSDictionary<NSString *, id> *batchParams = name.length > 0 ? @{kBatchEntryName : name } : nil;
    [self addRequest:request batchParameters:batchParams completionHandler:handler];
}

- (void)addRequest:(NWRequest *)request batchParameters:(NSDictionary<NSString *,id> *)batchParameters completionHandler:(NWRequestBlock)handler {
    if (self.state != kStateCreated) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Cannot add requests once started or if a URLRequest is set"
                                     userInfo:nil];
    }
    NWRequestMetadata *metadata = [[NWRequestMetadata alloc] initWithRequest:request
                                                           completionHandler:handler
                                                             batchParameters:batchParameters];
    
    [self.requests safe_addObject:metadata];
}

- (void)cancel {
    self.state = kStateCancelled;
    [self.session invalidateAndCancel];
}

- (void)overrideAPIVersion:(NSString *)version {
    if (![_overrideVersionPart isEqualToString:version]) {
        _overrideVersionPart = [version copy];
    }
}

- (void)start {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _errorConfiguration = [[NWErrorConfiguration alloc] initWithDictionary:nil];
    });
    
    NSMutableURLRequest *request = [self requestWithBatch:self.requests timeout:_timeout];
    self.state = kStateStarted;
    
    //    [self logRequest:request bodyLength:0 bodyLogger:nil attachmentLogger:nil];
    _requestStartTime = [UtilityTools currentTimeInMilliseconds];
    
    NWURLSessionTaskBlock completionHanlder = ^(NSData *responseDataV1, NSURLResponse *responseV1, NSError *errorV1) {
        NWURLSessionTaskBlock handler = ^(NSData *responseDataV2,
                                          NSURLResponse *responseV2,
                                          NSError *errorV2) {
            [self completeFBSDKURLSessionWithResponse:responseV2
                                                 data:responseDataV2
                                         networkError:errorV2];
        };
        
        if (errorV1) {
            [self _taskDidCompleteWithError:errorV1 handler:handler];
        } else {
            [self taskDidCompleteWithResponse:responseV1 data:responseDataV1 requestStartTime:self.requestStartTime handler:handler];
        }
    };
    [self.session executeURLRequest:request completionHandler:completionHanlder];
    
    id<NWRequestConnectionDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(requestConnectionWillBeginLoading:)]) {
        if (_delegateQueue) {
            [_delegateQueue addOperationWithBlock:^{
                [delegate requestConnectionWillBeginLoading:self];
            }];
        } else {
            [delegate requestConnectionWillBeginLoading:self];
        }
    }
}

- (NSOperationQueue *)delegateQueue {
    return _delegateQueue;
}

- (void)setDelegateQueue:(NSOperationQueue *)queue {
    _session.delegateQueue = queue;
    _delegateQueue = queue;
}

- (NWURLSession *)session {
    return _session;
}

#pragma mark - Private methods (request generation)

//
// Adds request data to a batch in a format expected by the JsonWriter.
// Binary attachments are referenced by name in JSON and added to the
// attachments dictionary.
//
- (void)addRequest:(NWRequestMetadata *)metadata
           toBatch:(NSMutableArray *)batch
       attachments:(NSMutableDictionary *)attachments
        batchToken:(NSString *)batchToken
{
    NSMutableDictionary *requestElement = [[NSMutableDictionary alloc] init];
    
    if (metadata.batchParameters) {
        [requestElement addEntriesFromDictionary:metadata.batchParameters];
    }
    
    if (batchToken) {
        NSMutableDictionary<NSString *, id> *params = [NSMutableDictionary
                                                       dictionaryWithDictionary:metadata.request.parameters];
        [params safe_setObject:batchToken forKey:kAccessTokenKey];
        metadata.request.parameters = params;
        [self registerTokenToOmitFromLog:batchToken];
    }
    
    NSString *urlString = [self urlStringForSingleRequest:metadata.request forBatch:YES];
    [requestElement safe_setObject:urlString forKey:kBatchRelativeURLKey];
    [requestElement safe_setObject:metadata.request.HTTPMethod forKey:kBatchMethodKey];
    
    [batch safe_addObject:requestElement];
}

//
// Serializes all requests in the batch to JSON and appends the result to
// body.  Also names all attachments that need to go as separate blocks in
// the body of the request.
//
// All the requests are serialized into JSON, with any binary attachments
// named and referenced by name in the JSON.
//
- (void)appendJSONRequests:(NSArray *)requests
                    toBody:(NWRequestBody *)body
        andNameAttachments:(NSMutableDictionary *)attachments
                    logger:(NWLogger *)logger
{
    NSMutableArray *batch = [[NSMutableArray alloc] init];
    NSString *batchToken = nil;
    for (NWRequestMetadata *metadata in requests) {
        NSString *individualToken = [self accessTokenWithRequest:metadata.request];
        BOOL isClientToken = [NWSettings clientToken] && [individualToken hasSuffix:[NWSettings clientToken]];
        if (!batchToken
            && !isClientToken) {
            batchToken = individualToken;
        }
        [self addRequest:metadata
                 toBatch:batch
             attachments:attachments
              batchToken:[batchToken isEqualToString:individualToken] ? nil : individualToken];
    }
    
    NSString *jsonBatch = [NSString JSONStringForObject:batch error:NULL invalidObjectHandler:NULL];
    
    [body appendWithKey:kBatchKey formValue:jsonBatch logger:logger];
    if (batchToken) {
        [body appendWithKey:kAccessTokenKey formValue:batchToken logger:logger];
    }
}

- (BOOL)_shouldWarnOnMissingFieldsParam:(NWRequest *)request
{
    NSString *minVersion = @"2.4";
    NSString *version = request.version;
    if (!version) {
        return YES;
    }
    if ([version hasPrefix:@"v"]) {
        version = [version substringFromIndex:1];
    }
    
    NSComparisonResult result = [version compare:minVersion options:NSNumericSearch];
    
    // if current version is the same as minVersion, or if the current version is > minVersion
    return (result == NSOrderedSame) || (result == NSOrderedDescending);
}

// Validate that all GET requests after v2.4 have a "fields" param
- (void)_validateFieldsParamForGetRequests:(NSArray *)requests
{
    for (NWRequestMetadata *metadata in requests) {
        NWRequest *request = metadata.request;
        if ([request.HTTPMethod.uppercaseString isEqualToString:@"GET"]
            && [self _shouldWarnOnMissingFieldsParam:request]
            && !request.parameters[@"fields"]
            && [request.path rangeOfString:@"fields="].location == NSNotFound) {
            [NWLogger singleShotLogEntry:NWLoggingBehaviorDeveloperErrors
                            formatString:@"starting with Graph API v2.4, GET requests for /%@ should contain an explicit \"fields\" parameter", request.path];
        }
    }
}

//
// Generates a NSURLRequest based on the contents of self.requests, and sets
// options on the request.  Chooses between URL-based request for a single
// request and JSON-based request for batches.
//
- (NSMutableURLRequest *)requestWithBatch:(NSArray *)requests
                                  timeout:(NSTimeInterval)timeout
{
    NWRequestBody *body = [[NWRequestBody alloc] init];
    NWLogger *bodyLogger = [[NWLogger alloc] initWithLoggingBehavior:_logger.loggingBehavior];
    NWLogger *attachmentLogger = [[NWLogger alloc] initWithLoggingBehavior:_logger.loggingBehavior];
    
    NSMutableURLRequest *request;
    
    if (requests.count == 0) {
        [[NSException exceptionWithName:NSInvalidArgumentException
                                 reason:@"FBSDKGraphRequestConnection: Must have at least one request or urlRequest not specified."
                               userInfo:nil]
         raise];
    }
    
    [self _validateFieldsParamForGetRequests:requests];
    
    if (requests.count == 1) {
        NWRequestMetadata *metadata = [requests objectAtIndex:0];
        NSURL *url = [NSURL URLWithString:[self urlStringForSingleRequest:metadata.request forBatch:NO]];
        request = [NSMutableURLRequest requestWithURL:url
                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                      timeoutInterval:timeout];
        
        // HTTP methods are case-sensitive; be helpful in case someone provided a mixed case one.
        NSString *httpMethod = metadata.request.HTTPMethod.uppercaseString;
        request.HTTPMethod = httpMethod;
    } else {
        // Find the session with an app ID and use that as the batch_app_id. If we can't
        // find one, try to load it from the plist. As a last resort, pass 0.
        NSString *batchAppID = [NWSettings appID];
        if (!batchAppID || batchAppID.length == 0) {
            // The Graph API batch method requires either an access token or batch_app_id.
            // If we can't determine an App ID to use for the batch, we can't issue it.
            [[NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:@"NWRequestConnection: [NWSettings appID] must be specified for batch requests"
                                   userInfo:nil]
             raise];
        }
        
        [body appendWithKey:@"batch_app_id" formValue:batchAppID logger:bodyLogger];
        
        NSMutableDictionary *attachments = [[NSMutableDictionary alloc] init];
        
        [self appendJSONRequests:requests
                          toBody:body
              andNameAttachments:attachments
                          logger:bodyLogger];
        
        NSURL *url = [UtilityTools
                      URLWithHostPrefix:kGraphURLPrefix
                      path:@""
                      queryParameters:@{}
                      defaultVersion:_overrideVersionPart
                      error:NULL];
        
        request = [NSMutableURLRequest requestWithURL:url
                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                      timeoutInterval:timeout];
        request.HTTPMethod = @"POST";
    }
    
    NSData *compressedData;
    if ([request.HTTPMethod isEqualToString:@"POST"] && (compressedData = [body compressedData])) {
        request.HTTPBody = compressedData;
        [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    } else {
        request.HTTPBody = body.data;
    }
    [request setValue:[NWRequestConnection userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setValue:[body mimeContentType] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPShouldHandleCookies:NO];
    
    [self logRequest:request bodyLength:(request.HTTPBody.length / 1024) bodyLogger:bodyLogger attachmentLogger:attachmentLogger];
    
    return request;
}

- (NSString *)urlStringForSingleRequest:(NWRequest *)request forBatch:(BOOL)forBatch
{
    NSMutableDictionary<NSString *, id> *params = [NSMutableDictionary dictionaryWithDictionary:request.parameters];
    [params safe_setObject:@"json" forKey:@"format"];
    [params safe_setObject:kSDK forKey:@"sdk"];
    [params safe_setObject:@"false" forKey:@"include_headers"];
    
    request.parameters = params;
    
    NSString *baseURL;
    if (forBatch) {
        baseURL = request.path;
    } else {
        NSString *token = [self accessTokenWithRequest:request];
        if (token) {
            [params setValue:token forKey:kAccessTokenKey];
            request.parameters = params;
            [self registerTokenToOmitFromLog:token];
        }
        
        NSString *prefix = kGraphURLPrefix;
        // We special case a graph post to <id>/videos and send it to graph-video.facebook.com
        // We only do this for non batch post requests
        NSString *graphPath = request.path.lowercaseString;
        if ([request.HTTPMethod.uppercaseString isEqualToString:@"POST"]
            && [graphPath hasSuffix:@"/videos"]) {
            graphPath = [graphPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
            NSArray *components = [graphPath componentsSeparatedByString:@"/"];
            if (components.count == 2) {
                prefix = kGraphVideoURLPrefix;
            }
        }
        
        baseURL = [UtilityTools
                   URLWithHostPrefix:prefix
                   path:request.path
                   queryParameters:@{}
                   defaultVersion:request.version
                   error:NULL].absoluteString;
    }
    
    NSString *url = [NWRequest serializeURL:baseURL
                                     params:request.parameters
                                 httpMethod:request.HTTPMethod
                                   forBatch:forBatch];
    return url;
}

- (void)registerTokenToOmitFromLog:(NSString *)token
{
    if (![NWSettings.loggingBehaviors containsObject:NWLoggingBehaviorAccessTokens]) {
        [NWLogger registerStringToReplace:token replaceWith:@"ACCESS_TOKEN_REMOVED"];
    }
}

#pragma mark - Private methods (response parsing)

- (void)completeFBSDKURLSessionWithResponse:(NSURLResponse *)response
                                       data:(NSData *)data
                               networkError:(NSError *)error
{
    if (self.state != kStateCancelled) {
        NSAssert(
                 self.state == kStateStarted,
                 @"Unexpected state %lu in completeWithResponse",
                 (unsigned long)self.state
                 );
        self.state = kStateCompleted;
    }
    
    NSArray *results = nil;
    _urlResponse = (NSHTTPURLResponse *)response;
    if (response) {
        NSAssert(
                 [response isKindOfClass:[NSHTTPURLResponse class]],
                 @"Expected NSHTTPURLResponse, got %@",
                 response
                 );
        
        NSInteger statusCode = _urlResponse.statusCode;
        
        if (!error && [response.MIMEType hasPrefix:@"image"]) {
            error = [NWError errorWithCode:NWErrorGraphRequestNonTextMimeTypeReturned
                                   message:@"Response is a non-text MIME type; endpoints that return images and other "
                     @"binary data should be fetched using NSURLRequest and NSURLSession"];
        } else {
            results = [self parseJSONResponse:data
                                        error:&error
                                   statusCode:statusCode];
        }
    } else if (!error) {
        error = [NWError errorWithCode:NWErrorUnknown
                               message:@"Missing NSURLResponse"];
    }
    
    if (!error) {
        if (self.requests.count != results.count) {
            error = [NWError errorWithCode:NWErrorGraphRequestProtocolMismatch
                                   message:@"Unexpected number of results returned from server."];
        } else {
            [_logger appendFormat:@"Response <#%lu>\nDuration: %llu msec\nSize: %lu kB\nResponse Body:\n%@\n\n",
             (unsigned long)_logger.loggerSerialNumber,
             [UtilityTools currentTimeInMilliseconds] - _requestStartTime,
             (unsigned long)data.length,
             results];
        }
    }
    
    if (error) {
        [_logger appendFormat:@"Response <#%lu> <Error>:\n%@\n%@\n",
         (unsigned long)_logger.loggerSerialNumber,
         error.localizedDescription,
         error.userInfo];
    }
    [_logger emitToNSLog];
    
    [self _completeWithResults:results networkError:error];
    
    [self.session invalidateAndCancel];
}

- (void)taskDidCompleteWithResponse:(NSURLResponse *)response
                               data:(NSData *)data
                   requestStartTime:(uint64_t)requestStartTime
                            handler:(NWURLSessionTaskBlock)handler
{
    @try {
        [self logAndInvokeHandler:handler
                         response:response
                     responseData:data
                 requestStartTime:requestStartTime];
    } @finally {}
}

- (NSArray *)parseJSONResponse:(NSData *)data
                         error:(NSError **)error
                    statusCode:(NSInteger)statusCode
{
    // Graph API can return "true" or "false", which is not valid JSON.
    // Translate that before asking JSON parser to look at it.
    NSString *responseUTF8 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray *results = [[NSMutableArray alloc] init];;
    id response = [self parseJSONOrOtherwise:responseUTF8 error:error];
    
    if (responseUTF8 == nil) {
        NSString *base64Data = data.length != 0 ? [data base64EncodedStringWithOptions:0] : @"";
        if (base64Data != nil) {
            //...
        }
    }
    
    NSDictionary *responseError = nil;
    if (!response) {
        if ((error != NULL) && (*error == nil)) {
            *error = [self _errorWithCode:NWErrorUnknown
                               statusCode:statusCode
                       parsedJSONResponse:nil
                               innerError:nil
                                  message:@"The server returned an unexpected response."];
        }
    } else if (self.requests.count == 1) {
        // response is the entry, so put it in a dictionary under "body" and add
        // that to array of responses.
        [results addObject:@{
            @"code" : @(statusCode),
            @"body" : response
        }];
    } else if ([response isKindOfClass:[NSArray class]]) {
        // response is the array of responses, but the body element of each needs
        // to be decoded from JSON.
        for (id item in response) {
            // Don't let errors parsing one response stop us from parsing another.
            NSError *batchResultError = nil;
            if (![item isKindOfClass:[NSDictionary class]]) {
                [results safe_addObject:item];
            } else {
                NSMutableDictionary *result = [((NSDictionary *)item) mutableCopy];
                if (result[@"body"]) {
                    [result safe_setObject:[self parseJSONOrOtherwise:result[@"body"] error:&batchResultError] forKey:@"body"];
                }
                [results safe_addObject:result];
            }
            if (batchResultError) {
                // We'll report back the last error we saw.
                *error = batchResultError;
            }
        }
    } else if ([response isKindOfClass:[NSDictionary class]]
               && (responseError = response[@"error"]) != nil
               && [responseError[@"type"] isEqualToString:@"OAuthException"]) {
        // if there was one request then return the only result. if there were multiple requests
        // but only one error then the server rejected the batch access token
        NSDictionary *result = @{
            @"code" : @(statusCode),
            @"body" : response
        };
        
        for (NSUInteger resultIndex = 0, resultCount = self.requests.count; resultIndex < resultCount; ++resultIndex) {
            [results safe_addObject:result];
        }
    } else if (error != NULL) {
        *error = [self _errorWithCode:NWErrorGraphRequestProtocolMismatch
                           statusCode:statusCode
                   parsedJSONResponse:results
                           innerError:nil
                              message:nil];
    }
    
    return results;
}


- (id)parseJSONOrOtherwise:(NSString *)unsafeString
                     error:(NSError **)error
{
    id parsed = nil;
    
    // Historically, people have passed-in `id` here. So, gotta double-check.
    NSString *const utf8 = NW_CAST_TO_CLASS_OR_NIL(unsafeString, NSString);
    if (!(*error) && utf8) {
        parsed = [UtilityTools objectForJSONString:utf8 error:error];
        // if we fail parse we attempt a re-parse of a modified input to support results in the form "foo=bar", "true", etc.
        // which is shouldn't be necessary since Graph API v2.1.
        if (*error) {
            // we round-trip our hand-wired response through the parser in order to remain
            // consistent with the rest of the output of this function (note, if perf turns out
            // to be a problem -- unlikely -- we can return the following dictionary outright)
            NSError *reparseError = nil;
            parsed =
            [UtilityTools
             objectForJSONString:
             [NSString JSONStringForObject:@{ NonJSONResponseProperty : utf8 }
                                         error:NULL
                          invalidObjectHandler:NULL]
             error:&reparseError];
            
            if (!reparseError) {
                *error = nil;
            }
        }
    }
    return parsed;
}

- (NSError *)_errorWithCode:(NWCoreError)code
                 statusCode:(NSInteger)statusCode
         parsedJSONResponse:(id<NSObject>)response
                 innerError:(NSError *)innerError
                    message:(NSString *)message
{
    NSMutableDictionary *const userInfo = [[NSMutableDictionary alloc] init];
    //[FBSDKTypeUtility dictionary:userInfo setObject:@(statusCode) forKey:FBSDKGraphRequestErrorHTTPStatusCodeKey];
    
    if (response) {
        //[userInfo setObject:response forKey:NWRequestErrorParsedJSONResponseKey];
    }
    
    if (innerError) {
        //[userInfo setObject:innerError forKey:NWRequestErrorParsedJSONResponseKey];
    }
    
    if (message) {
        //[userInfo setObject:message forKey:NWDeveloperMessageKey];
    }
    
    return
    [[NSError alloc]
     initWithDomain:NWErrorDomain
     code:code
     userInfo:userInfo];
}

- (void)_completeWithResults:(NSArray *)results
                networkError:(NSError *)networkError
{
    NSUInteger count = self.requests.count;
    _expectingResults = count;
    NSUInteger disabledRecoveryCount = 0;
    
    [self.requests enumerateObjectsUsingBlock:^(NWRequestMetadata *metadata, NSUInteger i, BOOL *stop) {
        id result = networkError ? nil : [results objectAtIndex:i];
        NSError *const resultError = networkError ?: errorFromResult(result, metadata.request);
        
        id body = nil;
        if (!resultError && [result isKindOfClass:[NSDictionary class]]) {
            body = result[@"body"];
        }
        
        [self processResultBody:body error:resultError metadata:metadata canNotifyDelegate:networkError == nil];
    }];
    
    if (networkError) {
        if ([_delegate respondsToSelector:@selector(requestConnection:didFailWithError:)]) {
            [_delegate requestConnection:self didFailWithError:networkError];
        }
    }
}


- (void)processResultBody:(NSDictionary *)body error:(NSError *)error metadata:(NWRequestMetadata *)metadata canNotifyDelegate:(BOOL)canNotifyDelegate
{
  void (^finishAndInvokeCompletionHandler)(void) = ^{
    NSDictionary<NSString *, id> *graphDebugDict = body[@"__debug__"];
    if ([graphDebugDict isKindOfClass:[NSDictionary class]]) {
      [self processResultDebugDictionary:graphDebugDict];
    }
    [metadata invokeCompletionHandlerForConnection:self withResults:body error:error];

    if (--self->_expectingResults == 0) {
      if (canNotifyDelegate && [self->_delegate respondsToSelector:@selector(requestConnectionDidFinishLoading:)]) {
        [self->_delegate requestConnectionDidFinishLoading:self];
      }
    }
  };

  // this is already on the queue since we are currently in the NSURLSession callback.
  finishAndInvokeCompletionHandler();
}

- (void)processResultDebugDictionary:(NSDictionary *)dict
{
  NSArray *messages = dict[@"messages"];
  if (!messages.count) {
    return;
  }

  [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    NSDictionary *messageDict = obj;
    NSString *type = messageDict[@"type"];
    NSString *link = messageDict[@"link"];
    //...
  }];
}

static NSError *_Nullable errorFromResult(id untypedParam, NWRequest *request)
{
  NSDictionary *const result = NW_CAST_TO_CLASS_OR_NIL(untypedParam, NSDictionary);
  if (!result) {
    return nil;
  }

  NSDictionary *const body = NW_CAST_TO_CLASS_OR_NIL(result[@"body"], NSDictionary);
  if (!body) {
    return nil;
  }

  NSDictionary *const errorDictionary = NW_CAST_TO_CLASS_OR_NIL(body[@"error"], NSDictionary);
  if (!errorDictionary) {
    return nil;
  }

  NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
  return [NWError errorWithCode:NWErrorGraphRequestGraphAPI
                          userInfo:userInfo
                           message:nil
                   underlyingError:nil];
}

#pragma mark - Private methods (logging and completion)

- (void)logAndInvokeHandler:(NWURLSessionTaskBlock)handler
                      error:(NSError *)error
{
    if (error) {
        NSString *logEntry = [NSString
                              stringWithFormat:@"URLSessionTask <#%lu>:\n  Error: '%@'\n%@\n",
                              100L,
                              error.localizedDescription,
                              error.userInfo];
        
        [self logMessage:logEntry];
    }
    
    [self invokeHandler:handler error:error response:nil responseData:nil];
}

- (void)logAndInvokeHandler:(NWURLSessionTaskBlock)handler
                   response:(NSURLResponse *)response
               responseData:(NSData *)responseData
           requestStartTime:(uint64_t)requestStartTime
{
    // Basic logging just prints out the URL.  FBSDKGraphRequest logging provides more details.
    NSString *mimeType = response.MIMEType;
    NSMutableString *mutableLogEntry = [NSMutableString stringWithFormat:@"FBSDKGraphRequestConnection <#%lu>:\n  Duration: %llu msec\nResponse Size: %lu kB\n  MIME type: %@\n",
                                        (unsigned long)[NWLogger generateSerialNumber],
                                        [UtilityTools currentTimeInMilliseconds] - requestStartTime,
                                        (unsigned long)responseData.length / 1024,
                                        mimeType];
    
    if ([mimeType isEqualToString:@"text/javascript"]) {
        NSString *responseUTF8 = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        [mutableLogEntry appendFormat:@"  Response:\n%@\n\n", responseUTF8];
    }
    
    [self logMessage:mutableLogEntry];
    
    [self invokeHandler:handler error:nil response:response responseData:responseData];
}

- (void)invokeHandler:(NWURLSessionTaskBlock)handler
                error:(NSError *)error
             response:(NSURLResponse *)response
         responseData:(NSData *)responseData {
    if (handler != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(responseData, response, error);
        });
    }
}

- (void)logMessage:(NSString *)message {
    //[SDKLogger singleShotLogEntry:FBSDKLoggingBehaviorNetworkRequests formatString:@"%@", message];
}

#pragma mark - Private methods (miscellaneous)

- (void)_taskDidCompleteWithError:(NSError *)error
                          handler:(NWURLSessionTaskBlock)handler
{
    @try {
        if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == kCFURLErrorSecureConnectionFailed) {
            NSOperatingSystemVersion iOS9Version = { .majorVersion = 9, .minorVersion = 0, .patchVersion = 0 };
            if ([UtilityTools isOSRunTimeVersionAtLeast:iOS9Version]) {
                [NWLogger singleShotLogEntry:NWLoggingBehaviorDeveloperErrors
                                    logEntry:@"WARNING: FBSDK secure network request failed. Please verify you have configured your "
                 "app for Application Transport Security compatibility described at https://developers.facebook.com/docs/ios/ios9"];
            }
        }
        [self logAndInvokeHandler:handler error:error];
    } @finally {}
}

- (void)logRequest:(NSMutableURLRequest *)request
        bodyLength:(NSUInteger)bodyLength
        bodyLogger:(NWLogger *)bodyLogger
  attachmentLogger:(NWLogger *)attachmentLogger
{
    if (_logger.isActive) {
        [_logger appendFormat:@"Request <#%lu>:\n", (unsigned long)_logger.loggerSerialNumber];
        [_logger appendKey:@"URL" value:request.URL.absoluteString];
        [_logger appendKey:@"Method" value:request.HTTPMethod];
        [_logger appendKey:@"UserAgent" value:[request valueForHTTPHeaderField:@"User-Agent"]];
        [_logger appendKey:@"MIME" value:[request valueForHTTPHeaderField:@"Content-Type"]];
        
        if (bodyLength != 0) {
            [_logger appendKey:@"Body Size" value:[NSString stringWithFormat:@"%lu kB", (unsigned long)bodyLength / 1024]];
        }
        
        if (bodyLogger != nil) {
            [_logger appendKey:@"Body (w/o attachments)" value:bodyLogger.contents];
        }
        
        if (attachmentLogger != nil) {
            [_logger appendKey:@"Attachments" value:attachmentLogger.contents];
        }
        
        [_logger appendString:@"\n"];
        
        [_logger emitToNSLog];
    }
}

- (NSString *)accessTokenWithRequest:(NWRequest *)request {
    NSString *token = request.tokenString ?: request.parameters[kAccessTokenKey];
    if (!token && !(request.flags & NWRequestFlagSkipClientToken) && [NWSettings clientToken].length > 0) {
        return [NSString stringWithFormat:@"%@|%@", [NWSettings appID], [NWSettings clientToken]];
    }
    return token;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
+ (NSString *)userAgent {
    static NSString *agent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        agent = [NSString stringWithFormat:@"%@.%@", kUserAgentBase, VERSION_STRING];
    });
    NSString *agentWithSuffix = nil;
    if ([NWSettings userAgentSuffix]) {
        agentWithSuffix = [NSString stringWithFormat:@"%@/%@", agent, [NWSettings userAgentSuffix]];
    }
    if (@available(iOS 13.0, *)) {
        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        SEL selector = NSSelectorFromString(@"isMacCatalystApp");
        if (selector && [processInfo respondsToSelector:selector] && [processInfo performSelector:selector]) {
            return [NSString stringWithFormat:@"%@/%@", agentWithSuffix ?: agent, @"macOS"];
        }
    }
    
    return agentWithSuffix ?: agent;
}

#pragma clang diagnostic pop

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    id<NWRequestConnectionDelegate> delegate = self.delegate;
    
    if ([delegate respondsToSelector:@selector(requestConnection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [delegate requestConnection:self
                    didSendBodyData:(NSUInteger)bytesSent
                  totalBytesWritten:(NSUInteger)totalBytesSent
          totalBytesExpectedToWrite:(NSUInteger)totalBytesExpectedToSend];
    }
}

#pragma mark - Debugging helpers

- (NSString *)description {
    NSMutableString *result = [NSMutableString stringWithFormat:@"<%@: %p, %lu request(s): (\n",
                               NSStringFromClass([self class]),
                               self,
                               (unsigned long)self.requests.count];
    BOOL comma = NO;
    for (NWRequestMetadata *metadata in self.requests) {
        NWRequest *request = metadata.request;
        if (comma) {
            [result appendString:@",\n"];
        }
        [result appendString:request.description];
        comma = YES;
    }
    [result appendString:@"\n)>"];
    return result;
}
@end
