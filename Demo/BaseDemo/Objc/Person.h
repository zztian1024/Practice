//
//  Person.h
//  Objc
//
//  Created by Tian on 2021/4/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person: NSObject

// 64bit 8byte 对齐
// 32bit 4byte 对齐

// 内存分配16字节对齐

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) NSInteger gender;

- (void)sleep;
- (void)run;

@end

@interface Man : Person

- (void)playGames;

@end



NS_ASSUME_NONNULL_END
