//
//  NWURLSession.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWURLSession.h"

@implementation NWURLSession

- (instancetype)initWithDelegate:(id<NSURLSessionDataDelegate>)delegate
                   delegateQueue:(NSOperationQueue *)queue {
    if ((self = [super init])) {
        self.delegate = delegate;
        self.delegateQueue = queue;
    }
    return self;
}

- (void)executeURLRequest:(NSURLRequest *)request
        completionHandler:(nonnull NWURLSessionTaskBlock)handler {
    if (!self.valid) {
        [self updateSessionWithBlock:^{
            NWURLSessionTask *task = [[NWURLSessionTask alloc] initWithRequest:request fromSession:self.session completionHandler:handler];
            [task start];
        }];
    } else {
        NWURLSessionTask *task = [[NWURLSessionTask alloc] initWithRequest:request fromSession:self.session completionHandler:handler];
        [task start];
    }
}

- (void)updateSessionWithBlock:(dispatch_block_t)block {
    if (!self.valid) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                     delegate:_delegate
                                                delegateQueue:_delegateQueue];
    }
    block();
}

- (void)invalidateAndCancel {
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (BOOL)valid {
    return self.session != nil;
}

@end
