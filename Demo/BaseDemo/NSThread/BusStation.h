//
//  BusStation.h
//  NSThread
//
//  Created by Tian on 2021/4/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BusStation : NSObject

/** 售票员1 */
@property (nonatomic, strong) NSThread *conductor1;
/** 售票员2 */
@property (nonatomic, strong) NSThread *conductor2;
/** 售票员3 */
@property (nonatomic, strong) NSThread *conductor3;
 
@property (atomic, assign) NSInteger totalCount;

- (void)startSale;

@end

NS_ASSUME_NONNULL_END
