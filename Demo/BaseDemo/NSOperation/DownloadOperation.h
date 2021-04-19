//
//  DownloadOperation.h
//  NSOperation
//
//  Created by Tian on 2021/4/16.
//

#import <UIkit/UIKit.h>
@class DownloadOperation;

NS_ASSUME_NONNULL_BEGIN

@protocol DownloadOperationDelegate <NSObject>

-(void)downloadOperation:(DownloadOperation *)operation didFishedDownLoad:(UIImage *)image;

@end

@interface DownloadOperation : NSOperation

@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, weak)id <DownloadOperationDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
