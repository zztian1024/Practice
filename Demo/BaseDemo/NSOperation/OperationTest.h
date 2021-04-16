//
//  OperationTest.h
//  NSOperation
//
//  Created by Tian on 2021/4/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OperationTest : NSObject

- (void)blockTest;
- (void)executionBlockTest;
- (void)invocationTest;
- (void)downloadOptTest;
- (void)operationQueueTest;
@end

NS_ASSUME_NONNULL_END
