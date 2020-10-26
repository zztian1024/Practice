//
//  TestClass.h
//  KVO
//
//  Created by Tian on 2020/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;

@end

@interface TestClass : NSObject

- (void)test;

@end

NS_ASSUME_NONNULL_END
