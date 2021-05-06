//
//  UIControl+ClickInterval.h
//  AOP
//
//  Created by Tian on 2021/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (ClickInterval)
/// 点击事件响应的时间间隔，不设置或者大于 0 时为默认时间间隔
@property (nonatomic, assign) NSTimeInterval clickInterval;
/// 是否忽略响应的时间间隔
@property (nonatomic, assign) BOOL ignoreClickInterval;

+ (void)ci_exchangeClickMethod;

@end

NS_ASSUME_NONNULL_END
