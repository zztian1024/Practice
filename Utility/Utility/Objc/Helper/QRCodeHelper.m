//
//  QRCodeHelper.m
//  Utility
//
//  Created by Tian on 2020/10/28.
//

#import "QRCodeHelper.h"

@implementation QRCodeHelper

+ (UIImage *)buildQRCodeWithString:(NSString *)infoString size:(CGFloat)size {
    NSData *qrCodeData = [infoString dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setValue:qrCodeData forKey:@"inputMessage"];
    CIImage *ciImage = [filter outputImage];
    return [self createfNonInterpolatedImageFromCIImage:ciImage withSize:size];
}

+ (UIImage *) createfNonInterpolatedImageFromCIImage:(CIImage *)iamge withSize:(CGFloat)size{
    CGRect extent = iamge.extent;
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t with = scale * CGRectGetWidth(extent);
    size_t height = scale * CGRectGetHeight(extent);
    
    UIGraphicsBeginImageContext(CGSizeMake(with, height));
    CGContextRef bitmapContextRef = UIGraphicsGetCurrentContext();
    
    CIContext *context = [CIContext contextWithOptions:nil];
    //通过CIContext 将CIImage生成CGImageRef
    CGImageRef bitmapImage = [context createCGImage:iamge fromRect:extent];
    //在对二维码放大或缩小处理时,禁止插值
    CGContextSetInterpolationQuality(bitmapContextRef, kCGInterpolationNone);
    //对二维码进行缩放
    CGContextScaleCTM(bitmapContextRef, scale, scale);
    //将二维码绘制到图片上下文
    CGContextDrawImage(bitmapContextRef, extent, bitmapImage);
    //获得上下文中二维码
    UIImage *retVal =  UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(bitmapImage);
    CGContextRelease(bitmapContextRef);
    return retVal;
}

@end
