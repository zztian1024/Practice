//
//  NWURLSession.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import "NWURLSessionTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NWURLSession : NSObject

@property (nullable, atomic, strong) NSURLSession *session;
@property (nullable, nonatomic, weak) id<NSURLSessionDataDelegate> delegate;
@property (nullable, nonatomic, retain) NSOperationQueue *delegateQueue;

- (instancetype)initWithDelegate:(id<NSURLSessionDataDelegate>)delegate
                   delegateQueue:(NSOperationQueue *)delegateQueue;

- (void)executeURLRequest:(NSURLRequest *)request completionHandler:(NWURLSessionTaskBlock)handler;

- (void)updateSessionWithBlock:(dispatch_block_t)block;

- (void)invalidateAndCancel;

- (BOOL)valid;

@end

NS_ASSUME_NONNULL_END
