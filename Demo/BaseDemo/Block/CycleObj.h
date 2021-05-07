//
//  CycleObj.h
//  Block
//
//  Created by Tian on 2021/5/7.
//

#import <Foundation/Foundation.h>
@class CycleObj;

NS_ASSUME_NONNULL_BEGIN

typedef void(^MyBlock1)(CycleObj *);
typedef void(^MyBlock)();

@interface CycleObj : NSObject

@property (nonatomic, copy) MyBlock block;
@property (nonatomic, copy) MyBlock block1;
@property (nonatomic, copy) NSString *name;

- (void)test;

@end

NS_ASSUME_NONNULL_END
