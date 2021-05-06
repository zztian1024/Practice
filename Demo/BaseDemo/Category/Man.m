//
//  Man.m
//  Category
//
//  Created by Tian on 2021/5/5.
//

#import "Man.h"

@implementation Man

+ (void)speak:(NSString *)something
{
    NSLog(@"Man ==== %@ 说：%@",self, something);
}
 
- (void)singSong:(NSString *)song
{
    NSLog(@"Man ==== %@ 唱：%@",self, song);
}
@end
