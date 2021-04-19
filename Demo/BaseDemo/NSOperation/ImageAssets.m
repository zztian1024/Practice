//
//  ImageAssets.m
//  NSOperation
//
//  Created by Tian on 2021/4/19.
//

#import "ImageAssets.h"

@interface ImageItem ()

+ (instancetype)imageItemWithDict:(NSDictionary *)dict;

@end

@implementation ImageItem

+ (instancetype)imageItemWithDict:(NSDictionary *)dict {
    ImageItem *item = [[ImageItem alloc] init];
    item.name = [dict valueForKey:@"name"];
    item.avatar = [dict valueForKey:@"avatar"];
    
    return item;
}

@end

static NSArray *_images;

@interface ImageAssets ()

@end

@implementation ImageAssets

+ (NSArray<ImageItem *> *)getImages {
    NSString *path = [[NSBundle mainBundle]pathForResource:@"images.plist" ofType:nil];
    NSArray *imageArr = [NSArray arrayWithContentsOfFile:path];
    
    NSMutableArray *images = [NSMutableArray array];
    for (NSDictionary *dict in imageArr) {
        ImageItem *item = [ImageItem imageItemWithDict:dict];
        [images addObject:item];
    }
    _images = images;
    return _images;
}

@end
