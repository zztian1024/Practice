//
//  Person.h
//  Cache_t
//
//  Created by Tian on 2021/5/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, copy) NSString *sign;

- (void)run;
- (void)eat;
- (void)sing;
- (void)play;

+ (void)drink;

@end

NS_ASSUME_NONNULL_END
