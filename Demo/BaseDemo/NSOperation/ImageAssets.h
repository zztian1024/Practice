//
//  ImageAssets.h
//  NSOperation
//
//  Created by Tian on 2021/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageItem : NSObject

@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *name;

@end

@interface ImageAssets : NSObject

+ (NSArray<ImageItem *> *)getImages;

@end

NS_ASSUME_NONNULL_END
