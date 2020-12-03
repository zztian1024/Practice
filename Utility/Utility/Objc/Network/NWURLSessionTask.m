//
//  NWURLSessionTask.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWURLSessionTask.h"

@implementation NWURLSessionTask

- (instancetype)init {
    if ((self = [super init])) {
        _requestStartDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request
                    fromSession:(NSURLSession *)session
              completionHandler:(nonnull NWURLSessionTaskBlock)handler {
    if ((self = [self init])) {
        self.requestStartTime = (uint64_t)([self.requestStartDate timeIntervalSince1970] * 1000);
        self.task = [session dataTaskWithRequest:request completionHandler:handler];
    }
    return self;
}

- (NSURLSessionTaskState)state {
    return self.task.state;
}

#pragma mark - Task State

- (void)start {
    [self.task resume];
}

- (void)cancel {
    [self.task cancel];
    self.handler = nil;
}

@end
