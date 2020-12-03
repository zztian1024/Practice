//
//  NWRequestConnection.h
//  Utility
//
//  Created by Tian on 2020/10/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NWRequest;
@class NWRequestConnection;

typedef void (^NWRequestBlock)(NWRequestConnection *_Nullable connection,
                               id _Nullable result,
                               NSError *_Nullable error);

@protocol NWRequestConnectionDelegate <NSObject>

@optional

- (void)requestConnectionWillBeginLoading:(NWRequestConnection *)connection;

- (void)requestConnectionDidFinishLoading:(NWRequestConnection *)connection;

- (void)requestConnection:(NWRequestConnection *)connection didFailWithError:(NSError *)error;

- (void)requestConnection:(NWRequestConnection *)connection
          didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

@end

@interface NWRequestConnection : NSObject

/// Defaults to 60 seconds.
@property (class, nonatomic, assign) NSTimeInterval defaultConnectionTimeout;
@property (nonatomic, weak, nullable) id<NWRequestConnectionDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, retain, readonly, nullable) NSHTTPURLResponse *urlResponse;
@property (nonatomic, retain) NSOperationQueue *delegateQueue;

- (void)addRequest:(NWRequest *)request completionHandler:(NWRequestBlock)handler;

- (void)addRequest:(NWRequest *)request batchEntryName:(NSString *)name completionHandler:(NWRequestBlock)handler;

- (void)addRequest:(NWRequest *)request
   batchParameters:(nullable NSDictionary<NSString *, id> *)batchParameters
 completionHandler:(NWRequestBlock)handler;

- (void)cancel;

- (void)start;

- (void)overrideAPIVersion:(NSString *)version;

@end

NS_ASSUME_NONNULL_END
