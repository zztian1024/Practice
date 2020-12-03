//
//  NWURLSessionTask.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NWURLSessionTaskBlock)(NSData *responseData,
                                      NSURLResponse *response,
                                      NSError *error)
NS_SWIFT_NAME(NWURLSessionTaskBlock);

@interface NWURLSessionTask : NSObject

@property (nonatomic, strong) NSURLSessionTask *task;
@property (atomic, readonly) NSURLSessionTaskState state;
@property (nonatomic, strong, readonly) NSDate *requestStartDate;
@property (nonatomic, copy, nullable) NWURLSessionTaskBlock handler;
@property (nonatomic, assign) uint64_t requestStartTime;
@property (nonatomic, assign) NSUInteger loggerSerialNumber;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithRequest:(NSURLRequest *)request
                    fromSession:(NSURLSession *)session
              completionHandler:(NWURLSessionTaskBlock)handler;

- (void)start;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
