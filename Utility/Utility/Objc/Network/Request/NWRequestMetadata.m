//
//  NWRequestMetadata.m
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import "NWRequestMetadata.h"
#import "NWRequest.h"

@implementation NWRequestMetadata

- (instancetype)initWithRequest:(NWRequest *)request
              completionHandler:(NWRequestBlock)handler
                batchParameters:(NSDictionary *)batchParameters
{
    if ((self = [super init])) {
        _request = request;
        _batchParameters = [batchParameters copy];
        _completionHandler = [handler copy];
    }
    return self;
}

- (void)invokeCompletionHandlerForConnection:(NWRequestConnection *)connection
                                 withResults:(id)results
                                       error:(NSError *)error
{
    if (self.completionHandler) {
        self.completionHandler(connection, results, error);
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, batchParameters: %@, completionHandler: %@, request: %@>",
            NSStringFromClass([self class]),
            self,
            self.batchParameters,
            self.completionHandler,
            self.request.description];
}
@end
