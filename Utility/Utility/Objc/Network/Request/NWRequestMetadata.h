//
//  NWRequestMetadata.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import "NWRequestConnection.h"

NS_ASSUME_NONNULL_BEGIN

@interface NWRequestMetadata : NSObject

@property (nonatomic, retain) NWRequest *request;
@property (nonatomic, copy) NWRequestBlock completionHandler;
@property (nonatomic, copy) NSDictionary *batchParameters;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithRequest:(NWRequest *)request
              completionHandler:(NWRequestBlock)handler
                batchParameters:(NSDictionary *)batchParameters
NS_DESIGNATED_INITIALIZER;

- (void)invokeCompletionHandlerForConnection:(NWRequestConnection *)connection
                                 withResults:(id)results
                                       error:(NSError *)error;
@end

NS_ASSUME_NONNULL_END
