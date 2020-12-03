//
//  QRCodeHelper.h
//  Utility
//
//  Created by Tian on 2020/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeHelper : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (UIImage *)buildQRCodeWithString:(NSString *)infoString size:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
