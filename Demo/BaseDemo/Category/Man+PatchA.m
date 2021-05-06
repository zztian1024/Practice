//
//  Man+PatchA.m
//  Category
//
//  Created by Tian on 2021/5/5.
//

#import "Man+PatchA.h"

@implementation Man (PatchA)
- (void)speak:(NSString *)something
{
    NSLog(@"PatchA ==== %@ 说：%@",self, something);
}
 
- (void)singSong:(NSString *)song
{
    NSLog(@"PatchA ==== %@ 唱：%@",self, song);
}
@end
